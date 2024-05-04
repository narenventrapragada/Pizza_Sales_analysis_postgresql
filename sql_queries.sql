select * from Pizzas

select * from pizza_types

select * from orders

select * from order_details

-- Retrieve the total number of orders placed

select count(order_id) as total_orders
from orders

-- Calculate total revenue generated from pizza sales

select sum(price*quantity) as sales
from Pizzas p
join order_details o 
on p.pizza_id = o.pizza_id

-- Identify the highest priced pizza

select pt.name,price
from Pizzas p
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
order by price desc
limit 1

-- Identify the most common pizza size ordered

select p.size,count(o.order_details_id) as no_of_orders
from Pizzas p
join order_details o
on p.pizza_id = o.pizza_id
group by p.size
order by no_of_orders desc

-- List the top 5 ordered pizza types along with their quantities

select name,sum(quantity) as total_quantity
from Pizzas p
join order_details o
on p.pizza_id = o.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by name
order by total_quantity desc
limit 5

-- Join the necessary tables to find the quantity of each pizza category ordered

select category,sum(quantity) as total_orders
from Pizzas p
join order_details o
on p.pizza_id = o.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id 
group by category
order by total_orders desc

-- Determine the distribution of orders by hours of the day
select extract(hour from order_time) as hours,count(o.order_id) as total_orders
from orders o
group by extract(hour from order_time)
order by total_orders desc

-- Join relevant tables to find the category-wise distribution of pizzas

select category,count(name) from pizza_types
group by category

-- Group the orders by date and calculate the average number of pizzas order per day

with cte as (
	select order_date,sum(quantity) as total_quantity
	from orders o
	join order_details od
	on o.order_id = od.order_id
	group by order_date
)

select round(avg(total_quantity),0)
from cte

-- Determine the top 3 most ordered pizza types based on revenue.

select name,sum(price*quantity) as sales
from Pizzas p
join order_details o 
on p.pizza_id = o.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by name
order by sales desc
limit 3

-- calculate the percentage contribution of each category to total revenue

select category,round(sum(quantity*price)/(
		select sum(price*quantity) as sales
		from Pizzas p
		join order_details o 
		on p.pizza_id = o.pizza_id
	)*100,2) as perc_of_sales
from Pizzas p
join order_details o 
on p.pizza_id = o.pizza_id
join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
group by category

-- Analyze the cumulative revenue generated over time

with cte as (
	select o.order_date,sum(price*quantity) as sales
	from order_details o1
	join orders o 
	on o1.order_id = o.order_id
	join Pizzas p
	on o1.pizza_id = p.pizza_id
	group by o.order_date
)
select *,sum(sales) over(order by order_date) cumulative_revenue
from cte

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
with cte as(
	select category,name,sum(quantity*price) as revenue
	from Pizzas p
	join order_details o 
	on p.pizza_id = o.pizza_id
	join pizza_types pt
	on p.pizza_type_id = pt.pizza_type_id
	group by category,name
),
	cte_final as (
		select *,row_number() over(partition by category order by revenue desc) as rnk
		from cte
)
select category,name,revenue
from cte_final
where rnk < 4
