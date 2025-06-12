/* ================================================
PHASE 3: Key Metrics
Purpose: To analyze key performance indicators and identify patterns in sales data

Key Activities:
- Peak Hour Analysis: 
		Calculated the frequency of transactions by hour group.
- Average Daily Transactions: 
		Computed the average number of transactions per weekday.
- Total Revenue by Product Category: 
		Aggregated total and average revenue by product category.
- Average Transaction Value Per Store: 
		Calculated total revenue, average transaction value (ATV), and average spend per transaction by store location.
- Peak Sales Hour: 
		Computed the average number of transactions per hour.
- Popular Items: 
		Identified the top-selling items by total units sold.
- Popular Category by Average Product Detail: 
		Calculated the average transaction quantity by product category.
================================================ */

#== Peak Hour Analysis ==#
select hour_group, count(*) as frequency
from sales_revenue_2
group by hour_group
order by frequency desc; 
/*
Insight: The peak hours for transactions are between 07-10 AM.
Recommendation: Ensure maximum staffing coverage during these peak hours to handle the rush 
efficiently. Consider offering morning specials or promotions to attract more customers during 
this time.*/

#== Average Daily Transactions ==#
select weekday, (count(weekday)/count(distinct transaction_date)) as avg_transaction_daily
from sales_revenue_2
group by `weekday`
order by avg_transaction_daily desc;
/*
Insight: Friday has the highest average number of transactions, although differences between
days are not too significant.
Recommendation: Promote premium products and special offers on Fridays to capitalize on higher 
customer traffic and increase average transaction value.*/

#== Total Revenue by Product Category ==#
select product_category, round(sum(revenue), 2) as total_revenue, round(avg(revenue), 2) as avg_revenue
from sales_revenue_2
group by product_category
order by total_revenue desc; 
/*
Insight: Coffee and Tea contribute the most to total sales. Coffee Beans and Merchandise 
show high per-transaction values.
Recommendation: Double down on marketing and promotions for Coffee and Tea to maintain their 
revenue leadership. Highlight Coffee Beans and Merchandise for upselling or bundling 
(e.g., pair coffee with beans for a discount) to increase margins.*/

#== Average Transaction Value Per Store ==#
select store_location, round(sum(revenue), 2) as total_revenue, round(sum(revenue)/ count(transaction_id), 2) as atv,
	round(sum(revenue)/ sum(transaction_qty), 2) as avg_spend_per_transaction
from sales_revenue_2
group by store_location
order by atv desc;
/*
Insight: Lower Manhattan has the highest average transaction value (ATV), while Hell’s 
Kitchen has high traffic but lower ATV.
Recommendation: Leverage Lower Manhattan's high ATV by testing upselling strategies 
(e.g., add pastry for $2) to further boost transaction value. Optimize Hell’s Kitchen's 
volume by promoting premium products (e.g., merchandise, coffee beans) to increase ATV.*/

#== Peak Sales Hour ==#
WITH transaction_hour AS (
    SELECT transaction_date, hour_group,
        COUNT(*) AS hourly_total
    FROM sales_revenue_2
    GROUP BY transaction_date, hour_group)
SELECT hour_group, round(AVG(hourly_total), 2) AS avg_transaction_per_hour
FROM transaction_hour
GROUP BY hour_group
ORDER BY avg_transaction_per_hour desc;
/*
Insight: The average number of transactions is highest during the morning hours (07-10 AM).
Recommendation: Capitalize on morning demand by ensuring maximum coverage during these hours. 
Revive afternoon slumps by creating lunch-friendly combos and offering afternoon discounts 
(e.g., 14-16 o'clock happy hour) to boost sales.*/

#== Popular Items ==#
select product_detail, sum(transaction_qty) as tot_unit_sold
from sales_revenue_2
group by product_detail
order by tot_unit_sold desc
limit 5;
/*
Insight: RG size dominates the top 5 best-selling items.
Recommendation: Capitalize on size preferences by testing promotions for larger sizes 
(e.g., upgrade to large for $0.5 extra). Train staff to recommend popular items to customers 
during slower periods to increase sales.*/

#== Popular Category by Average Product Detail ==#
select product_category, (round(sum(transaction_qty)/count(distinct product_detail), 2)) as avg_based_type
from sales_revenue_2
group by product_category
order by avg_based_type desc;
/*
Insight: The average transaction quantity varies by product category.
Recommendation: Use this data to tailor inventory and staffing strategies. Focus on categories 
with higher average transaction quantities to optimize sales and customer satisfaction.*/

/*================================================
PHASE 4: Strategic Planning
Purpose: To analyze trends and performance across different dimensions for strategic decision making

Key Activities
- Daily Revenue Trend Analysis: 
		Computed daily revenue trends and ranked top categories by weekday.
- Top-Selling Products by Store Location: 
		Identified top-selling products by store location and ranked them.
- Hourly Sales Performance Analysis:
		Analyzed total transactions and revenue by hour.
- Hourly Sales Performance by Store Location:
		Analyzed total transactions and revenue by hour for specific store locations.
================================================ */

# Daily Revenue Trend Analysis
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
/*
Strategic Insight: Coffee dominates daily revenue across all 7 days, contributing 38–39% of 
daily revenue consistently. This suggests strong brand loyalty or habitual purchasing behavior.
Strategic Recommendation: Expand coffee-related upsells (e.g., premium blends, subscriptions) 
to reinforce purchasing habits. Create combo deals (e.g., “Coffee + Other category items at 
10% off”) to increase sales of lower category items.*/

# Top-Selling Products by Store Location
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
/*
Strategic Insight: Sales are highly distributed across many products, suggesting a broad 
inventory strategy. While this reduces dependency on single items, it may indicate inefficiency
in stocking or missed opportunities to promote high-margin "hero" products.
Strategic Recommendation: Use location-specific insights to balance variety with targeted 
growth opportunities. Promote high-margin products and consider localized marketing strategies 
to enhance sales efficiency.*/

# cross-check
select store_location, product_detail, sum(transaction_qty) as total_qty
from sales_revenue_2
where store_location = 'astoria'
group by store_location, product_detail
order by total_qty desc;

# Hourly Sales Performance Analysis
select hour_group, count(transaction_id) as tot_transactions,
	round(sum(revenue), 2) as hourly_rev
from sales_revenue_2
group by hour_group
order by hourly_rev desc;
/*
Strategic Insight: Mornings (07-11 AM) are peak sales hours, while afternoons and evenings 
show lower revenue.
Strategic Recommendation: Double down on mornings by adding staff to reduce wait times and 
maximize peak revenue. Revive afternoons with discounted coffee-pastry combos or iced beverages. 
Promote evening specials to drive late-day traffic.*/

# Hourly Sales Performance by Store Location
select hour_group, store_location, count(transaction_id) as tot_transactions, 
	round(sum(revenue), 2) as hourly_rev
from sales_revenue_2
where hour_group >= 7 and hour_group <= 11
group by hour_group, store_location
order by hourly_rev desc;
/*
Strategic Insight: Different store locations have varying peak hours and sales patterns.
Strategic Recommendation: Tailor strategies to each store's unique sales patterns. For example:
	- Hell’s Kitchen: Maximize 8-10 AM by staffing extra registers and stocking premium/impulse 
					items near checkout.
	- Lower Manhattan: Partner with nearby gyms or offices for loyalty perks 
					(e.g., “Show your gym badge for a free pastry with coffee”).
	- Astoria: Promote larger sizes (e.g., family packs) or subscription models 
			(e.g., “Weekly Coffee Delivery”).*/