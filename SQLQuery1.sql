
-- Q1
-- How many incidents took place 
-- where state of policy issue is different from the state of incident
-- And Customer is married?

select count(*) as incident_count from cars_claims as CC  
join cars_policy as CP  
On CC.PolicyID=CP.policy_number  
join cars_customers as CCP  
On CP.customer_id=CCP.CustomerID  
where incident_state<>policy_state and Marital= 'married' ;


-- Q2
-- How many cars were sold whose owner is not First owner and the cars have an incident history

select count(*) as car_count from cars_claims as CC
inner join cars_policy as CP    
on CC.PolicyID=CP.policy_number
inner join cars_sales  as CS
on CS.car_id=CP.car_id
where sold_on is not null and owner<>'First Owner'


-- Q3
-- Can you write a query to extract the model name from the name column in the car table?
-- Ex. from Maruti Swift Dzire VDI extract Maruti

SELECT SUBSTRING(name, 1, CHARINDEX(' ', name) - 1) AS company_name,     
       SUBSTRING(name,CHARINDEX(' ', name) + 1, LEN(name) - CHARINDEX(' ', name)) AS model_name
FROM cars


-- Q4
-- Write a query to calculate average mileage by fuel type

SELECT fuel, AVG(CONVERT(DECIMAL,replace(replace(mileage, 'kmpl', ''), 'km/kg', '')))  as avg_mileages
FROM cars group by fuel;


-- Q4.1
-- find out the average mileage by brand
select distinct(left(name,(charindex(' ',name)))) 
as model_name,ROUND( avg(cast(left(mileage, charindex (' ', mileage) ) as float ) ), 2)
from cars group by left(name,(charindex(' ',name)))


-- Q5
-- Write a query to sort the incidents by customers who held their policies for the longest
-- period at the time of incident
-- Ex. Customer 1 had a policy with bind_date as 01-01-2020 and the accident took place on 01-06-2020
-- Customer 2 had a policy with bind_date as 01-01-2019 and the accident took place on 01-06-2020
-- This means customer 2 has an older policy compared to Customer 1

select p.customer_id, p.policy_bind_date, c.incident_date,DATEDIFF(day,p.policy_bind_date,c.incident_date) as days  
from cars_claims c
right join cars_policy p
on c.PolicyID = p.policy_number
order by days desc


select avg(DATEDIFF(day,p.policy_bind_date,c.incident_date)) as avg_days  
from cars_claims c
right join cars_policy p
on c.PolicyID = p.policy_number


-- Q6
-- Write a query to print top 3 cities in each state by total claim amount

select incident_state, incident_city,sum(property)as total_claims,
rank() over
(partition by incident_state
order by sum(property) desc
)as rank
from cars_claims
group by incident_state, incident_city
order by 1