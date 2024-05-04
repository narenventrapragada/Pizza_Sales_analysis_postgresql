create table Pizzas(
	pizza_id varchar(50),
	pizza_type_id varchar(50),
	size varchar(5),
	price decimal
)

select *
from Pizzas

select *
from pizza_types

create table orders(
	order_id int,
	order_date date,
	order_time time
)

select *
from orders

create table order_details(
	order_details_id int,
	order_id int,
	pizza_id varchar(25),
	quantity int
)

select *
from order_details