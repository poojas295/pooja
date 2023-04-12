CREATE function ps_idv(@purchase_date datetime,@current_date datetime,@original_sp int) returns float
as
begin
DECLARE @age as int
SET @age = DATEDIFF(month,@purchase_date,@current_date)
DECLARE @x as float
SET @x = case when @age <= 6 then 0.95
         when @age > 6 and @age <= 12 then 0.85
         when @age > 12 and @age <= 24 then 0.80
         when @age > 24 and @age <= 36 then 0.70
         when @age > 36 and @age <= 48 then 0.60
         when @age > 48 and @age <= 60 then 0.50 end
return(case when @age>60 then 10000 else @x*@original_sp end)
end


create table ps_IDVTABLE(sales_id int NOT NULL,ad_placed_on datetime NOT NULL,sold_on datetime, original_sales_price int NOT NULL,
region nvarchar(50) NOT NULL,state nvarchar(50) NOT NULL,city nvarchar(50) NOT NULL,seller_Type nvarchar(50) NOT NULL,owner nvarchar(50) NOT NULL,
car_id int,current_selling_price float)


insert into dbo.ps_IDVTABLE(sales_id,ad_placed_on,sold_on,original_sales_price,region,state,city,seller_type,owner,car_id,current_selling_price)
select sales_id,ad_placed_on,sold_on,original_selling_price,Region,State,City,seller_type,owner,s.car_id,
dbo.niv_IDV(policy_bind_date,ad_placed_on,original_selling_price)
from cars_sales s join cars_policy p on s.car_id =p.car_id