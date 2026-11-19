CREATE TABLE pharma_sales (
    date DATE,
    year INT,
    month INT,
    day INT,
    region VARCHAR(100),
    country VARCHAR(100),
    category VARCHAR(100),
    medicine VARCHAR(150),
    age_group VARCHAR(50),
    units_sold INT,
    unit_price NUMERIC(10,2),
    stock_level INT,
    expiry_days_remaining INT,
    covid_flag INT
);

Q1. Total records
select count(*) from pharma_sales;

select count(distinct(country)) from pharma_sales;
select count(distinct(region)) from pharma_sales;

select count(distinct(category)) from pharma_sales;
select count(distinct(medicine)) from pharma_sales;

select distinct(medicine) from pharma_sales;

select * from pharma_sales
limit 10;

select distinct category,medicine
from pharma_sales
group by category,medicine;

select sum(units_sold) as total_sold from pharma_sales;

select sum(units_sold*unit_price) as total_revenue from pharma_sales;

select avg(unit_price) as avg_price from pharma_sales;

select region, sum(units_sold*unit_price) as revenue
from pharma_sales
group by region
order by revenue desc;

select medicine,sum(units_sold) as sold
from pharma_sales
group by medicine
order by sold desc
limit 5;

--Q11. Revenue contribution by medicine
select medicine, sum(units_sold*unit_price) as revenue
from pharma_sales
group by medicine
order by revenue desc;

--Q12. Category performance
select 
	category, 
	medicine,
	sum(units_sold*unit_price) as item_revenue,
	round(
		sum(units_sold*unit_price)*100.0/
		sum(sum(units_sold*unit_price)) over (),2) as revenue_percentage
from pharma_sales
group by category,medicine
order by item_revenue desc;

--Q13. Monthly sales trend
select year, month, 
	sum(units_sold) as items_sold, 
	sum(units_sold*unit_price) as total_revenue
from pharma_sales
group by year,month
order by year,month;

--Q14. Regional performance
with medicine_sales as(
	select 
	region,
	medicine,
	sum(units_sold) as items_sold, 
	sum(units_sold*unit_price) as total_revenue
from pharma_sales
group by region,medicine
),
ranked_medicines as (
	select *,
		dense_rank() over(
		partition by region
		order by total_revenue desc
		) as rank
	from medicine_sales
	)
select
	region, 
	medicine, 
	total_revenue, 
	items_sold
from ranked_medicines
where rank <=3
order by region, total_revenue desc;

--Q15. Country-level performance
select 
	country,
	sum(units_sold*unit_price) as revenue,
	round(
		sum(units_sold*unit_price)*100.0/
		sum(sum(units_sold*unit_price)) over (),2) as revenue_percentage
from pharma_sales
group by country
order by revenue desc
limit 5;

--- Product demand analysis
--Q16. High-demand medicines
select medicine,
	sum(units_sold) as solds,
	avg(units_sold*unit_price) as avg_sp,
	avg(unit_price) as average_up
from pharma_sales
group by medicine
order by solds desc
limit 5;

--Inventry management
--Q17. Low-stock medicines
select category, medicine, region, stock_level
from pharma_sales
where stock_level <100
order by stock_level asc;

--Q18. Expiry risk analysis
select category, medicine, stock_level, expiry_days_remaining
from pharma_sales
where expiry_days_remaining <=30
order by expiry_days_remaining asc;

--Q19. COVID-period comparision
select 
	sum(units_sold*unit_price) as revenue, 
	sum(units_sold) as sold,
	avg(unit_price) as avg_price,
	covid_flag
from pharma_sales
group by covid_flag;

