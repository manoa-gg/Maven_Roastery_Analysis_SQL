# [Maven_Roastery_Analysis] SQL Analysis Portfolio

👋 **Business Strategist → Data Analyst**  
*Leveraging 5+ years in business development to deliver data-driven insights*

## 🚀 Project Overview
| Category          | Description |
|-------------------|-------------|
| **Business Case** | [Analyzing opportunity to increase revenue] |
| **Data Source**   | [Mock cafe dataset from Kaggle] |
| **Key Insights**  | [2 Items driving almost 70% of cafe revenue] |

## 🧠 Skills Demonstrated
[![SQL]
[![Data Cleaning]
[![Business Intelligence]

## 📂 File Guide
| File | Purpose | Key Features |
|------|---------|-------------|
| `maven_roastery_cleaned.sql` | Final database structure | Cleaned, transformed, standardized |
| `maven_roastery_cleaning_process.sql` | Data preparation | Missing value handling, transformation, deduplication |
| `maven_roastery_analysis_queries.sql` | Business insights | Revenue trends, product overview, consumer behavior, store performance |

## 💡 Highlighted Analysis
```sql
# Hourly Sales Performance
select hour_group, count(transaction_id) as tot_transactions,
	round(sum(revenue), 2) as hourly_rev
from sales_revenue_2
group by hour_group
order by hourly_rev desc;
