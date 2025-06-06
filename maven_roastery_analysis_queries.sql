## AGGREGATION
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
order by total_qty desc; ## Lower Manhattan is the most performing branch in terms of sales

# Most Profitable Store Location
select store_location, sum(revenue)
from sales_revenue_2
group by store_location;

## Analytics 1
# Peak hour
select hour_group, count(*) as frequency
from sales_revenue_2
group by hour_group
order by frequency desc; ## FROM 07-10 IN THE MORNING IS THE PEAK HOUR

# AVG day to day transaction
select weekday, (count(weekday)/count(distinct transaction_date)) as avg_transaction_daily
from sales_revenue_2
group by `weekday`
order by avg_transaction_daily desc; ## FRIDAY IS THE DAY WITH MOST AVG SALES ALTHOUGH DIFFERENCES BETWEEN DAYS IS NOT TOO SIGNIFICANT

# Total Revenue by Product Category
select product_category, round(sum(revenue), 2) as total_revenue, round(avg(revenue), 2) as avg_revenue
from sales_revenue_2
group by product_category
order by total_revenue desc; 
# 1. Coffee and Tea are the backbone of revenue, contributing 93% of total sales. 
# 		Double down on marketing/promotions for these categories to maintain revenue leadership.
# 2. Coffee Beans and Merchandise show high per-transaction value, suggesting opportunities to increase margins
#		Highlight Coffee Beans and Merchandise to upsell or bundle (e.g., Pair coffee with beans for a discount)

# Average Transaction Value Per Store
select store_location, round(sum(revenue), 2) as total_revenue, round(sum(revenue)/ count(transaction_id), 2) as atv,
	round(sum(revenue)/ sum(transaction_qty), 2) as avg_spend_per_transaction
from sales_revenue_2
group by store_location
order by atv desc;
# 1. Leverage lower manhattan's high ATV by
#		test upselling strategies (e.g, add pastry for 2$) to further boost transaction value
# 2. Optimize hell's kitchen's volume
# use its high traffic to promote premium products (e.g, merchandise, coffee bean) to increase ATV

# Peak Sales Hour
WITH transaction_hour AS (
    SELECT transaction_date, hour_group,
        COUNT(*) AS hourly_total
    FROM sales_revenue_2
    GROUP BY transaction_date, hour_group)
SELECT hour_group, round(AVG(hourly_total), 2) AS avg_transaction_per_hour
FROM transaction_hour
GROUP BY hour_group
ORDER BY avg_transaction_per_hour desc;
# 1. Capitalize on morning demand
#		Ensure maximum coverage during 7-10 in the morning to handle the rush
# 2. Revive afternoon slumps
# 		create lunch friendly combos and offer afternoon discount (e.g, 14-16 o'çlock happy hour) to boost sales

# Popular Item
select product_detail, sum(transaction_qty) as tot_unit_sold
from sales_revenue_2
group by product_detail
order by tot_unit_sold desc
limit 5;
# 1. Capitalize on size preferences
# 		RG size dominate the top 5. Test promotions for LG versions (e.g, upgrade to large for $0.5 extra)
# 2. Inventory and Staffing
# 		train staff to recommend popular items to customers during slower periods  

# Popular Category by avg on product_detail
select product_category, (round(sum(transaction_qty)/count(distinct product_detail), 2)) as avg_based_type
from sales_revenue_2
group by product_category
order by avg_based_type desc;

## Analytics 2
# Daily Revenue Trend by Product Category
with trend as (select weekday, product_category, round(sum(revenue), 2) as total_revenue,
			sum(sum(revenue)) over (partition by weekday) as daily_total, 
			row_number () over (partition by weekday
            order by sum(revenue) desc) as day_rank
            from sales_revenue_2
            group by product_category, weekday)
	select weekday, product_category, total_revenue, 
		round((total_revenue/ daily_total) * 100, 2) as revenue_percentage, day_rank
	from trend
	where day_rank <= 3
    group by weekday, product_category
    order by day_rank asc;
# summary : Coffee dominates daily revenue across all 7 days, contributing 38–39% of daily revenue consistently.
# Implication: Coffee sales suggesting strong brand loyalty or habitual purchasing behavior.Consider expanding coffee-related upsells (e.g., premium blends, subscriptions).
# Bundle Strategically: Create combo deals (e.g., “Coffee + Other category items at 10% off”) to reinforce purchasing habits and increase lower category items sales

# Top - Selling Products per Store Location
with top_selling as (
				select store_location, product_detail, sum(transaction_qty) as total_qty,
                sum(sum(transaction_qty)) over (partition by store_location) as store_qty, 
                row_number() over (partition by store_location
                order by sum(transaction_qty) desc) as top_selling_rank
                from sales_revenue_2
                group by store_location, product_detail)
select store_location, product_detail, total_qty,
		round((total_qty/ store_qty) * 100, 2) as qty_precentage, top_selling_rank 
from top_selling
where top_selling_rank <= 3
order by store_location, top_selling_rank asc;
# summary : Sales are highly distributed across many products, suggesting a broad inventory strategy. 
# 			While this reduces dependency on single items, it may indicate inefficiency in stocking or missed opportunities to promote high-margin "hero" products.
# While fragmented sales reduce risk, they may dilute operational efficiency. Use location-specific insights to balance variety with targeted growth opportunities

# cross-check
select store_location, product_detail, sum(transaction_qty) as total_qty
from sales_revenue_2
where store_location = 'astoria'
group by store_location, product_detail
order by total_qty desc;

# Hourly Sales Performance
select hour_group, count(transaction_id) as tot_transactions,
	round(sum(revenue), 2) as hourly_rev
from sales_revenue_2
group by hour_group
order by hourly_rev desc;
# Recommendations : 
# Double down on Mornings : Add staff during 7–11 AM to reduce wait times and maximize peak revenue
# Revive afternoon : Launch campaign with discounted coffee-pastry combos or discounted iced beverages
# Rethink evenings : promote free stuff for every purchase after 18.00
# addressing the midday/eveing gap could unlock 15-20% incremental revenue growth with minimal operation changes

# Hourly Sales Performance Based on Store Location
select hour_group, store_location, count(transaction_id) as tot_transactions, 
	round(sum(revenue), 2) as hourly_rev
from sales_revenue_2
where hour_group >= 7 and hour_group <= 11
group by hour_group, store_location
order by hourly_rev desc;
# Recommendations
# Hell’s Kitchen: Maximize 8–10 AM by staffing extra registers and stock premium/impulse items (e.g., bottled cold brew, muffins) near checkout.
# Lower Manhattan: Leverage Early Hours by partnering with nearby gyms or offices for loyalty perks (e.g., “Show your gym badge for a free pastry with coffee”).
# Astoria: Target Local Demographics by promoting larger sizes (e.g., family packs) or subscription models (e.g., “Weekly Coffee Delivery”).
# Morning hours are non-negotiable revenue drivers, but localized strategies can amplify performance. 
# Hell’s Kitchen should focus on volume efficiency, Lower Manhattan on early-bird loyalty, and Astoria on community-centric bundles