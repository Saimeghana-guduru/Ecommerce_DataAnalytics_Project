select * from orders;
-- 1. DESCRIPTIVE ANALYSIS

-- Total Orders 
select count(*) as total_orders
from orders;

-- Total Cancellations
select count(*) as total_cancellations
from orders
where order_status='canceled';

-- Total Sellers
select count(*) from sellers;
 
 -- Total Customers
 select count(*) from customers;
 
 -- Average Review Rating
 select avg(review_score) from reviews;
 
 -- Total Products
 select count(*) from products;
 
 -- Total revenue
 select sum(payment_value) as revenue
 from order_payments;
 
 -- Total categories
 select count(distinct product_category_name)
 from products;
 
 -- Average Revenue
 select round(avg(payment_value),1) AS AVG_REV
 from order_payments;
 
 -- 2.TREND ANALYSIS
 
 -- Monthly order trend
 select year(order_purchase_timestamp) as `year`,month(order_purchase_timestamp) as `month`,
 count(*) as total_orders
 from orders
 group by `year`,`month`
 order by `year`,`month`;
  
 -- Monthly revenue Trend
  select year(order_purchase_timestamp) as `year`,month(order_purchase_timestamp) as `month`,
 round(sum(payment_value),2) as total_revenue
 from orders o
 join order_payments op on op.order_id=o.order_id
 group by `year`,`month`
 order by `year`,`month`;
 
-- Monthly Review Score
 select year(order_purchase_timestamp) as `year`,month(order_purchase_timestamp) as `month`,
 round(avg(review_score),1) as avg_rating
 from orders o
 join reviews r on r.order_id=o.order_id
 group by `year`,`month`
 order by `year`,`month`; 
 
 -- Monthly Customers Growth
  select year(order_purchase_timestamp) as `year`,month(order_purchase_timestamp) as `month`,
 count(distinct customer_id) as total_custs
 from orders
 group by `year`,`month`
 order by `year`,`month`;
 
 -- Monthly Cancellation orders
  select year(order_purchase_timestamp) as `year`,month(order_purchase_timestamp) as `month`,
 count(*) as total_cancelled_orders
 from orders
 where order_status='canceled'
 group by `year`,`month`
 order by `year`,`month`;
 
 -- 3.CUSTOMER ANALYSIS
 
 -- customers by state
 select customer_state,
 count(*) as customers
 from customers
 group by customer_state;
 
 -- customers by City
 select customer_city,
 count(*) as customers
 from customers
 group by customer_city
 order by customers desc;
 
 -- customers spending
 select customer_unique_id,
 sum(payment_value) as total_spend
 from customers c
 join orders o on o.customer_id=c.customer_id
 join order_payments op on op.order_id=o.order_id
 group by customer_unique_id
 order by total_spend desc;
 
 -- Customer preferred payment
 select payment_type,
 count(*) as total_custs
 from order_payments
 group by payment_type
 order by total_custs desc;
 
 -- Geolocation vs Customers
 select customer_state,customer_city,
 count(*) as total_custs
 from customers c
 join orders o on o.customer_id=c.customer_id
 group by customer_state,customer_city
 order by total_custs desc;
 
 -- Repeated Customers
select customer_unique_id,
count(*) as total_orders
from orders o
join customers c on c.customer_id=o.customer_id
 group by customer_unique_id
 having count(*)>1
 order by total_orders desc;
 
 -- Customer Segmentation
select customer_unique_id,
sum(payment_value) as total_spend,
case when sum(payment_value)>10000 then 'High Value'
	 when sum(payment_value)>5000 then 'Medium Valued'
     else 'Less Value'
end as customer_type
from customers c
join orders o on c.customer_id=o.customer_id
join order_payments op on op.order_id=o.order_id
group by customer_unique_id;

-- 4.PRODUCT ANALYSIS

-- top product category
select product_category_name,
count(o.product_id) as total_sold
from order_items o
join products p on p.product_id=o.product_id
group by product_category_name
order by total_sold desc;

--  highest Revenue product
select product_category_name,
sum(price) as total_rev
from products p
join order_items o on o.product_id=p.product_id
group by product_category_name;

-- Highest rated product
select product_category_name,
round(avg(review_score),2) as avg_rev
from products p
join order_items o on o.product_id=p.product_id
join reviews r on r.order_id=o.order_id
group by product_category_name;

-- late deliveries by product catgeory
select product_category_name,
sum(delivery_status='Late\r') as late_count
from products p
join order_items oi on oi.product_id=p.product_id
join orders o on o.order_id=oi.order_id
group by product_category_name;

-- Average freight cost by category
select product_category_name,
round(avg(freight_value),2) as avg_freight_val
from products p
join order_items o on o.product_id=p.product_id
group by product_category_name;

-- product contribution to total revenue
select product_category_name,
round(sum(price),2) as total_price,
round(
	sum(price)*100.0/
    (select sum(price) from order_items)
,2) as contribution
from products p
join order_items oi on oi.product_id=p.product_id
group by product_category_name;

-- 5. SELLER ANALYSIS

-- top seller by revenue
select seller_id,
sum(price) as total_price
from order_items
group by seller_id
order by total_price desc;

-- Repeated sellers
select seller_id,
count(*) as total_orders
from order_items
group by seller_id
having count(*)>1;

-- Sellers by state
select s.seller_state,
count(distinct s.seller_id) as total_count
from sellers s
join order_items o on o.seller_id=s.seller_id
group by s.seller_state;

-- Top Seller state by revenue
select seller_state,
round(sum(price),2) as total_rev
from sellers s
join order_items o on o.seller_id=s.seller_id
group by seller_state;

-- seller avg review rating
select seller_id,
avg(review_score) avg_rev
from order_items o
join reviews r on r.order_id=o.order_id 
group by seller_id;

-- 6. Payment Analysis
-- Most preferred payment type
select payment_type,
count(*) as total_count
from order_payments
group by payment_type;

-- Revenue by payment type
select payment_type,
sum(price) as total_rev
from order_payments op
join order_items oi on oi.order_id=op.order_id
group by payment_type;

-- Payment Installments distribution
select payment_installments,
count(*) as total_count
from order_payments
group by payment_installments;

-- payment seq distribution
select payment_sequential,
count(*) as total_count
from order_payments
group by payment_sequential
order by payment_sequential;

-- 7.GEOLOCATION ANALYSIS
-- orders by state
select customer_state,
count(*) as total_orders
from customers c 
join orders o on o.customer_id=c.customer_id
group by customer_state;

-- revenue by state
select seller_state,
round(sum(price),2) as total_rev
from sellers s
join order_items oi on oi.seller_id=s.seller_id
group by seller_state;

-- rating by state
select customer_state,
round(avg(review_score),2) as avg_score
from customers c
join orders o on o.customer_id=c.customer_id
join reviews r on r.order_id=o.order_id
group by customer_state;

-- Late deliveries by state
select customer_state,
sum(delivery_status='Late\r') as late_count
from customers c
join orders o on o.customer_id=c.customer_id
group by customer_state;

-- cancelled orders by state
select customer_state,
sum(order_status='canceled') as can_orders
from customers c
join orders o on o.customer_id=c.customer_id
group by customer_state;

-- 8.REVIEW ANALYSIS

-- review count
select review_score,
count(*) as review_count
from reviews
group by review_score;

-- 9.DIAGNOSTIC ANALYSIS
-- late delivery vs rating
select delivery_status,
avg(review_score) as avg_score
from orders o
join reviews r on r.order_id=o.order_id
group by delivery_status;

-- geolocation vs cancelled orders
select customer_state,
count(*) as can_orders
from orders o
join customers c on c.customer_id=o.customer_id
where order_status='canceled'
group by customer_state
order by can_orders desc;

