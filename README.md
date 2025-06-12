# [Maven_Roastery_Analysis] SQL Analysis Portfolio

## 🚀 Project Overview
| Category          | Description |
|-------------------|-------------|
| **Business Case** | Analyzing sales data from Maven Roastery to identify key performance indicators and strategic opportunities for revenue growth.|
| **Data Source**   | Mock cafe dataset from Kaggle |
| **Key Insights**  | Coffee and Tea contribute to almost 70% of cafe revenue; mornings (07-10 AM) are peak sales hours.|

## 🧠 Skills Demonstrated
**SQL**, **Data Cleaning**, **Data Profiling**, **Statistical Analysis**, **Business Intelligence**, **Strategic Planning**

## 📂 File Guide
| File | Purpose | Key Features |
|------|---------|-------------|
| `maven_roastery_raw.csv` | Raw dataset | Initial dataset with raw data |
| `maven_roastery_cleaned.csv` | Cleaned dataset | Cleaned, transformed, and standardized data |
| `data_prep.sql` | Data preparation | Missing value handling, transformation, deduplication |
| `data_profiling.sql` | Data profiling | Central tendency metrics, frequent values, value ranges |
| `full_analytics_kpi_strategic.sql` | Business insights | Revenue trends, product overview, consumer behavior, store performance |

## 💡 Highlighted Analysis
```sql
# Data Preparation
-- Remove duplicates
with dc As (
    select *,
    row_number() over (
        partition by transaction_id, transaction_date, transaction_time, transaction_qty, 
        store_id, product_id, unit_price, product_category,
        product_type, product_detail) As row_num
    from maven_roastery_sales)
delete from maven_roastery_sales
where transaction_id in (
    select transaction_id
    from dc
    where row_num > 1);

# Data Profiling 
--Basic data overview
select count(distinct transaction_id) as distinct_transactions, 
       count(distinct product_type) as distinct_product_types, 
       count(distinct product_category) as distinct_product_categories
from maven_roastery_sales;

# Analytics 
-- Hourly Sales Performance
select hour_group, count(transaction_id) as total_transactions, 
       round(sum(revenue), 2) as hourly_revenue
from maven_roastery_sales
group by hour_group
order by hourly_revenue desc;

````
## 📈 Insights and Recommendations

**Insight 1: Peak Sales Hours**
- Insight: Mornings (07-10 AM) are peak sales hours.
- Recommendation: Double down on mornings by adding staff to reduce wait times and maximize peak revenue. Revive 		        afternoons with discounted coffee-pastry combos or iced beverages. Promote evening specials to drive 		        late-day traffic.

**Insight 2: Dominant Product Categories**
- Insight: Coffee and Tea contribute to almost 70% of daily revenue.
- Recommendation: Expand coffee-related upsells (e.g., premium blends, subscriptions) to reinforce purchasing habits. 		    Create combo deals (e.g., “Coffee + Other category items at 10% off”) to increase sales of lower 		              category items.

**Insight 3: High-Performing Store Locations**
- Insight: Lower Manhattan shows the highest sales volume, while Hell’s Kitchen is the most profitable branch.
- Recommendation: Leverage Lower Manhattan's high sales volume by testing upselling strategies (e.g., add pastry for 		    $2) to further boost transaction value. Optimize Hell’s Kitchen's volume by promoting premium 			              products (e.g., merchandise, coffee beans) to increase ATV.

## 📈 About Me

**👋 Business Strategist → Data Analyst**

*Leveraging 5+ years in business development to deliver data-driven insights*

**- Background** : With a strong background in business development, I transitioned to data analysis to provide                    actionable insights that drive business growth.

**- Skills** : Proficient in SQL, data cleaning, data profiling, statistical analysis, business intelligence, and                  strategic planning.

**- Approach** : I focus on translating complex data into clear, actionable insights that inform strategic decision-               making and operational improvements.
