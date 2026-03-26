-- 1.Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;


-- 2.Calculate the total revenue generated from pizza sales.
select 
round(sum(orders_details.quantity * pizzas.price),2) as total_sales 
from orders_details join pizzas on pizzas.pizza_id=orders_details.pizza_id;


-- 3.Identify the highest-priced pizza.
select pizza_types.name,pizzas.price as highest_price_pizza from pizzas join pizza_types 
on pizzas.pizza_type_id=pizza_types.pizza_type_id order by pizzas.price desc limit 1;


-- 4.Identify the most common pizza size ordered.
select pizzas.size,count(orders_details.order_details_id)as order_count from pizzas join orders_details 
on pizzas.pizza_id =orders_details.pizza_id group by pizzas.size order by order_count desc limit 1;


-- 5.List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(orders_details.quantity) as quantities from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id join orders_details on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.name order by quantities  desc limit 5;




#intermediate questions

-- 1.Join the necessary tables to find the total quantity of each pizza category.
select pizza_types.category,sum(orders_details.quantity) as quantities from pizza_types join pizzas on 
pizza_types.pizza_type_id=pizzas.pizza_type_id join orders_details on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantities desc;


-- 2.Determine the distribution of orders by hour of the day.
select hour(order_time) as hour,count(order_id) as order_count from orders group by hour (order_time);


-- 3.Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category;


-- 4.Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg_pizza_order_per_day from
 (select orders.order_date, sum(orders_details.quantity) as quantity from orders join orders_details on 
orders.order_id=orders_details.order_id group by orders.order_date)as order_quantity;


-- 5.Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(orders_details.quantity * pizzas.price) as revenue from 
pizza_types join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id join 
orders_details on orders_details.pizza_id=pizzas.pizza_id group by pizza_types.name
order by revenue desc limit 3;


-- Advanced:
-- 1.Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
sum(orders_details.quantity * pizzas.price)/ (select (sum(orders_details.quantity * pizzas.price)) as total_sales 
from orders_details join pizzas on pizzas.pizza_id=orders_details.pizza_id )*100 as revenue from 
pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join orders_details
on orders_details.pizza_id=pizzas.pizza_id group by pizza_types.category order by revenue desc;


-- 2.Analyze the cumulative revenue generated over time.

SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details 
    JOIN pizzas 
        ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders 
        ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) as sales;



-- 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select 
name,
revenue from
(SELECT 
    category,
    name,
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_no
FROM (
    SELECT 
pizza_types.category,pizza_types.name,sum((orders_details.quantity)*pizzas.price)as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id join orders_details
on orders_details.pizza_id=pizzas.pizza_id group by pizza_types.category,pizza_types.name)as a)
as b where rank_no <=3;