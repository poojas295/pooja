--inventory code--

--TABLE CREATION
CREATE TABLE ps1_inventory(
	as_on_date date NOT NULL,
	starting_inventory float ,
	inventory_in float,
	inventory_out float ,
	ending_inventory float,
)

---PROCEDURE
CREATE PROCEDURE dbo.ps2_inventory_pro
AS
BEGIN
	DECLARE @as_on_date DATE;
	DECLARE @starting_inventory FLOAT;
	DECLARE @inventory_in FLOAT ;
	DECLARE @inventory_out FLOAT ;
	DECLARE @ending_inventory FLOAT;
	DECLARE @last_date DATE
	SELECT  @as_on_date = MIN([date]), @last_date = MAX([date]) FROM dbo.niv_CAL_INV;
	WHILE @as_on_date <= @last_date	
	BEGIN
		SET @inventory_in = COALESCE ((SELECT SUM(current_selling_price) FROM sm_idv_table WHERE CAST(ad_placed_on AS DATE) = @as_on_date), 0);
		SET @inventory_out = COALESCE ((SELECT SUM(current_selling_price) FROM sm_idv_table WHERE CAST(sold_on AS DATE) = @as_on_date), 0);
		SET @starting_inventory = COALESCE((SELECT ending_inventory FROM ps1_inventory WHERE as_on_date = DATEADD(dd, -1, @as_on_date)), 0);
		SET @ending_inventory = COALESCE(((@starting_inventory + @inventory_in) - @inventory_out), 0);

		INSERT INTO ps1_inventory (as_on_date, starting_inventory, inventory_in, inventory_out, ending_inventory)
			VALUES (@as_on_date, @starting_inventory, @inventory_in, @inventory_out, @ending_inventory)
		SET @as_on_date = DATEADD(day, 1, @as_on_date)
	END
END 


--EXECUTION
EXEC dbo.ps2_inventory_pro
select * from ps1_inventory 


--What will be the start and end dates for your calendar table?
--Answer: 2020-11-04, 2021-06-14

select MIN(ad_placed_on) from cars_sales
select MAX(sold_on) from cars_sales

--How many records does your inventory table have?
-- Answer : 223
select distinct count(*) from ps1_inventory 


--What's the starting inventory value of the week having the date 2020-11-10?
-- Answer : 447000
select starting_inventory from ps1_inventory where as_on_date = '2020-11-10'


--What's the ending inventory level by the end of 2020?
-- ANswer : 29388698.3

SELECT TOP 1 ending_inventory FROM ps1_inventory WHERE as_on_date between '2020-01-01' AND '2020-12-31' 
ORDER BY as_on_date DESC



--Considering INR 25,000,000 as the safety stock level, how many times has the inventory breached this level?
--Answer : 135
SELECT COUNT(*) as BreachCount
FROM ps1_inventory
WHERE ending_inventory < 25000000



--Choose the week(s) which had the highest inventory added vs sold respectively
-- Answer : Week 50, Week 06

WITH weekly_inventory AS (
  SELECT
    WeekNo,
    SUM(inventory_in) AS inventory_in,
    SUM(inventory_out) AS inventory_out,
    SUM(inventory_in) - SUM(inventory_out) AS net_inventory
  FROM
    ps1_inventory ps
    JOIN SM_CAL_INV sci ON ps.as_on_date = sci.Date
  GROUP BY
    WeekNo
)
SELECT
  'Week ' + CAST(wi1.WeekNo AS VARCHAR) + ', Week ' + CAST(wi2.WeekNo AS VARCHAR) AS week_pair,
  wi1.net_inventory AS added_inventory,
  wi2.net_inventory AS sold_inventory
FROM
  weekly_inventory wi1
  JOIN weekly_inventory wi2 ON wi1.WeekNo <> wi2.WeekNo
WHERE
  wi1.net_inventory = (SELECT MAX(net_inventory) FROM weekly_inventory)
  AND wi2.net_inventory = (SELECT MIN(net_inventory) FROM weekly_inventory)

--What's the maximum number of weeks which saw a continuous rise in inventory levels
--Answer : 5

with cte AS
(
select
DATEPART(WEEK, as_on_date) AS WeekNumber,
sum(ending_inventory) weekly_inventory,
lag(sum(ending_inventory),1, 0) over(order by DATEPART(WEEK, as_on_date)) as prev_week,
case
when sum(ending_inventory) > lag(sum(ending_inventory),1,0)
over(order by DATEPART(WEEK, as_on_date))
then DATEPART(WEEK, as_on_date)
else -1
end as week_seq
from
ps1_inventory
group by DATEPART(WEEK, as_on_date)
)
,cte2 as
(
select *,
row_number() over (order by week_seq) as rn,
row_number() over (order by week_seq) - week_seq as grp
from cte where week_seq > -1
),
cte3 as
(
select count(*) as cnt from cte2
group by grp
)
select max(cnt) as maximum_number_week from cte3

