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