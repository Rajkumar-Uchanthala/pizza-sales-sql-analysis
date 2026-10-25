-- Q1.Retrieve the total number of orders placed.
select count(order_id) from orders;

-- Q2.Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity*p.price),2) as total_revenue
from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id

-- Q3.Identify the highest-priced pizza. 
select 
	pt.name,
	max(p.price) as highest_price
from pizzas as p
join pizza_types as pt
	on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by highest_price desc
limit 1

-- Q4.Identify the most common pizza size ordered.
select 
	p.size,
    count(od.order_details_id) as order_cnt
from pizzas as p
join order_details as od
on p.pizza_id=od.pizza_id
group by p.size
order by order_cnt desc

-- Q5.List the top 5 most ordered pizza types along with their quantities.
select 
	pt.name,
    sum(od.quantity) as qty_sum
from pizza_types as pt
join pizzas as p
	on pt.pizza_type_id=p.pizza_type_id
join order_details as od
	on p.pizza_id=od.pizza_id
group by pt.name
order by qty_sum desc
limit 5

-- Q6.Join the necessary tables to find the total quantity of each pizza category ordered.
select 
	pt.category,
    sum(od.quantity) as qty_sum
from pizza_types as pt
join pizzas as p
	on pt.pizza_type_id=p.pizza_type_id
join order_details as od
	on p.pizza_id=od.pizza_id
group by pt.category
order by qty_sum desc
limit 5

-- Q7.Determine the distribution of orders by hour of the day.
select 
	hour(order_time) as hour,
    count(order_id) as order_cnt
from orders
group by hour

-- Q8.Join relevant tables to find the category-wise distribution of pizzas.
select category,count(pt.name)
from pizza_types as pt
group by category


-- Q9.Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(qty_sum),2) as avg
from (select
	o.order_date as date,
    sum(od.quantity) as qty_sum
from orders as o
join order_details as od
on o.order_id=od.order_id
group by date) as order_qty


-- Q10. Determine the top 3 most ordered pizza types based on revenue.
select 
	pt.name,
    sum(od.quantity*p.price) as revenue
from pizza_types as pt
join pizzas as p
	on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.name
order by revenue desc 
limit 3


-- Q11.lculate the percentage contribution of each pizza type to total revenue.
select 
	pt.category,
   round(sum(od.quantity*p.price)/(select round(sum(od.quantity*p.price),2) as total_revenue
from order_details as od
join pizzas as p
on p.pizza_id=od.pizza_id)*100,2) as revenue
from pizza_types as pt
join pizzas as p
	on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category


-- Q12.Analyze the cumulative revenue generated over time.
select order_date,
	sum(revenue) over(order by order_date) as cum_revenue
    from (select 
	o.order_date,
    sum(od.quantity*p.price) as revenue
from order_details as od
join pizzas as p
	on od.pizza_id=p.pizza_id
join orders as o
on o.order_id=od.order_id
group by o.order_date) as sales;


-- Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category
select name,revenue from 
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pt.category , pt.name,
sum(od.quantity*p.price) as revenue
from pizza_types as pt join pizzas as p
on pt.pizza_type_id=p.pizza_type_id
join order_details as od
on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as a) as b
where rn<=3;