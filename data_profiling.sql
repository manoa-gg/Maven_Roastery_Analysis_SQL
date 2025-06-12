/* ================================================
PHASE 2: DATA PROFILING
Purpose: Understand distributions and quality of cleaned data

Key Activities:
- Calculated central tendency metrics (mean, median, mode)
- Identified most frequent values across dimensions
- Verified expected value ranges
- Established baseline performance metrics
================================================ */

create table sales_revenue_2
like sales_revenue_1;

insert sales_revenue_2
select *
from sales_revenue_1;

select *
from sales_revenue_2;

select count(distinct transaction_id), count(distinct product_type), 
	count(distinct product_category), count(distinct product_detail),
    count(distinct store_location), count(distinct `month`), count(distinct `weekday`),
    count(distinct hour_group)
from sales_revenue_2;

select max(unit_price), min(unit_price), max(transaction_qty), max(hour_group), 
	min(transaction_qty), max(revenue), min(revenue), min(hour_group)
from sales_revenue_2;

select sum(unit_price), sum(revenue), sum(transaction_qty), 
	avg(unit_price), avg(revenue), avg(transaction_qty)
from sales_revenue_2; 

select product_category, count(distinct product_type), count(distinct product_detail)
from sales_revenue_2
group by product_category; ## Coffee has the most variety of product

select *
from sales_revenue_2;

## MODE 
# Most Frequent Value Product
select product_detail, count(*) as frequency
from sales_revenue_2
group by product_detail
order by frequency desc
limit 1;

# Most Frequent Value Month
select `month`, count(*) as frequency
from sales_revenue_2
group by `month`
order by frequency desc
limit 1;

# Most Frequent Value Day
select `weekday`, count(*) as frequency
from sales_revenue_2
group by `weekday`
order by frequency desc
limit 1;

# Most Frequent Value Time
select hour_group, count(*) as frequency
from sales_revenue_2
group by hour_group
order by frequency desc
limit 1;

# Most Frequent Value Price 
select unit_price, count(*) as frequency
from sales_revenue_2
group by unit_price
order by frequency desc
limit 1;

## Median Revenue
WITH ordered_transactions AS (
    SELECT revenue,
        ROW_NUMBER() OVER (ORDER BY revenue) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM sales_revenue_2
)
SELECT 
    AVG(revenue) AS median_revenue
FROM ordered_transactions
WHERE row_num IN (
    (total_rows + 1) / 2, 
    (total_rows + 2) / 2
);

## Median Quantity Sold
WITH qty_sold AS (
    SELECT transaction_qty,
        ROW_NUMBER() OVER (ORDER BY transaction_qty) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM sales_revenue_2
)
SELECT 
    AVG(transaction_qty) AS median_qty
FROM qty_sold
WHERE row_num IN (
    (total_rows + 1) / 2, 
    (total_rows + 2) / 2
);

# STD
select stddev(revenue) as rev_std
from sales_revenue_2;

select stddev(transaction_qty) as qty_std
from sales_revenue_2;

select *
from sales_revenue_2
where revenue >= 150;

## ORDER BY
# Monthly sales
select `month`, count(*) as frequency
from sales_revenue_2
group by `month`
order by frequency desc; ## CONTINUOUS GROWTH FROM MONTH TO MONTH 

# Most quantity sold by transaction
select transaction_qty, count(*) as frequency
from sales_revenue_2
group by transaction_qty
order by frequency desc; ## MOST QUANTITY SOLD ON EVERY TRANSACTION IS 1

# Most sold item by price
select unit_price, count(*) as frequency
from sales_revenue_2
group by unit_price
order by frequency desc; ## 3$ ITEM IS THE MOST BOUGHT

# Most Performing Store Location
select store_location, sum(transaction_qty) as total_qty,
	count(transaction_id) as tot_transaction
from sales_revenue_2
group by store_location
order by total_qty desc; ## LOWER MANHATTAN IS THE MOST PERFORMING BRANCH IN TERMS OF SALES 

# Most Profitable Store Location
select store_location, sum(revenue)
from sales_revenue_2
group by store_location; ## HELL's KITCHEN IS THE MOST PROFITABLE BRANCH 