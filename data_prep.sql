/*====================================================================
Phase 1	: Data Preparation
Purpose	: To prepare the data for analysis by ensuring it is clean, consistent, and ready 
		for further processing. 
Key Activities:
- Remove Duplicates: Eliminated duplicate records to ensure data uniqueness.
- Handle Missing Values: Removed records with missing or blank values in critical fields.
- Trim Data: Removed unnecessary spaces from string fields to standardize the format.
- Standardize Data: Corrected spelling errors, renamed categories, and converted text fields to lowercase for uniformity.
- Add Calculated Fields: Added new columns for calculated values (e.g., revenue) and derived attributes (e.g., month, weekday, hour_group).
- Verify Transformations: Checked the results of transformations to ensure correctness.
======================================================================*/

## Inboarding Data
drop database maven_roastery;
create database if not exists maven_roastery;
use maven_roastery;

drop table maven_roastery_sales;
create table sales_revenue
(transaction_id	varchar (50),
transaction_date date,
transaction_time time,
transaction_qty	int,
store_id int,
store_location varchar (255),
product_id int,
unit_price double,
product_category varchar (255),
product_type varchar (255),
product_detail varchar (255));

select *
from sales_revenue;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maven_roastery.csv' 
into table sales_revenue
fields terminated by '|'
ignore 1 lines;

create table sales_revenue_1
like sales_revenue;

insert sales_revenue_1
select *
from sales_revenue;

## Data Cleaning
# remove duplicate
with dc As
(select*,
row_number() over(
partition by transaction_id, transaction_date, transaction_time, transaction_qty, 
store_id, product_id, unit_price, product_category,
product_type, product_detail) As row_num
from sales_revenue_1)
select *
from dc
where row_num > 1;

# remove blank cell and null
select *
from sales_revenue_1
where (product_type is null or product_type = '')
	or (product_category is null or product_category = '')
	or (unit_price is null or unit_price = '')
    or (product_detail is null or product_detail = '');

# trim data
update sales_revenue_1
set
	product_type = trim(product_type), 
    product_category = trim(product_category), 
    product_detail = trim(product_detail),
    transaction_id = trim(transaction_id);

# cross-check for duplicate    
select product_type, product_category, product_detail, transaction_id, count(*)
from sales_revenue_1
group by product_type, product_category, product_detail, transaction_id
having count(*) > 1;

## standardized table
# Manually Checking Mispelling
select distinct product_category
from sales_revenue_1;

select distinct product_type
from sales_revenue_1;

# Renaming
select *
from sales_revenue_1
where product_category = 'flavours';

update sales_revenue_1
set product_category = 
	case
		when product_category = 'branded' then 'merchandise'
        when product_category = 'flavours' then 'add-ons'
	end
where product_category in ('branded', 'flavours');

# Lowercase
update sales_revenue_1
set
	product_type = lower(product_type),
    product_category = lower(product_category),
    product_detail = lower(product_detail),
    store_location = lower(store_location),
    weekday = lower(weekday);
    
select *
from sales_revenue_1;

# Check ID = Price Consistency
select product_id, unit_price, transaction_qty
from sales_revenue_1
where product_id = 32;

alter table sales_revenue_1
drop column revenue, 
drop column `month`,
drop column `weekday`,
drop column `hour_group`;

# Transform Table
alter table sales_revenue_1
add (revenue double,
	`month` varchar(255),
    `weekday` varchar(255),
    `hour_group` varchar(255));

update sales_revenue_1
set 
	revenue = (unit_price*transaction_qty),
     `month` = month(transaction_date),
    `weekday` = date_format(transaction_date, '%W'),
    `hour_group` = LPAD(hour(transaction_time), 2, '0');

# Verify Hour Group Result
select hour_group, count(*) as number_of_transaction
from sales_revenue_1
group by hour_group;