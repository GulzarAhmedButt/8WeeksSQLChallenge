Drop database IF EXISTS pizza_runner;

CREATE DATABASE pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-02-01 23:51:23'),
  (3, 102, 2, '', NULL, '2020-02-01 23:51:23'),
  (4,103, 1, '4', '', '2020-04-01 13:23:46'),
  (4, 103, 1, '4', '', '2020-04-01 13:23:46'),
  (4, 103, 2, '4', '', '2020-04-01 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-08-01 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-08-01 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-08-01 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-09-01 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-10-01 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-11-01 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-11-01 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" DATETIME,
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, '', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08T21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10T00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, '', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11T18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


Select * from 
customer_orders

Select * from pizza_names

Select * from pizza_recipes

Select * from pizza_toppings

Select * from runner_orders

Select * from runners

-- Pizza Metrics

SELECT order_id, customer_id, pizza_id, 
  CASE 
    WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
    ELSE exclusions
    END AS exclusions,
  CASE 
    WHEN extras IS NULL or extras LIKE 'null' THEN ' '
    ELSE extras 
    END AS extras, 
  order_time
INTO #customer_orders -- create TEMP TABLE
FROM customer_orders;


SELECT order_id, runner_id,
  CASE 
    WHEN pickup_time LIKE 'null' THEN ' '
    ELSE pickup_time 
    END AS pickup_time,
  CASE 
    WHEN distance LIKE 'null' THEN ' '
    WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
    ELSE distance END AS distance,
  CASE 
    WHEN duration LIKE 'null' THEN ' ' 
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
    ELSE duration END AS duration,
  CASE 
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ''
    ELSE cancellation END AS cancellation
INTO #runner_orders
FROM runner_orders;




--How many pizzas were ordered?
Select Count(order_id) as [Pizzas Ordered]
from #customer_orders

--How many unique customer orders were made?
Select Count(Distinct customer_id) as [Unique Customer Orders]
from #customer_orders;

--How many successful orders were delivered by each runner?
Select runner_id,Count(1) as [Orders Delivered] 
from #runner_orders
where cancellation not in ('Restaurant Cancellation','Customer Cancellation')
group by runner_id;

--How many of each type of pizza was delivered?
Select CAST(p.pizza_name as VARCHAR(100)) AS [Pizza Name],Count(p.pizza_id) as [Pizza Delivered]
from #customer_orders co
join pizza_names p
on co.pizza_id = p.pizza_id
join #runner_orders r
on r.order_id = co.order_id
where cancellation not in ('Restaurant Cancellation','Customer Cancellation')
group by CAST(p.pizza_name as VARCHAR(100));

--How many Vegetarian and Meatlovers were ordered by each customer?
Select co.customer_id,CAST(p.pizza_name as VARCHAR(100)) as Pizza_Name,COUNT(1) as [Pizza Ordered]
from #customer_orders co
join pizza_names p
on co.pizza_id = p.pizza_id
group by co.customer_id,CAST(p.pizza_name as VARCHAR(100))
order by co.customer_id;

-- What was the maximum number of pizzas delivered in a single order?
Select top 1 co.order_id,Count(pizza_id) as [Pizzas Delivered]
from #customer_orders co 
group by co.order_id
order by [Pizzas Delivered] desc

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id, changes, COUNT(changes) as NumberOfChanges
FROM (
	SELECT *,
    CASE 
		WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 'Y'
        WHEN exclusions IS NULL AND extras IS NULL THEN 'N'
        END AS changes
	FROM #customer_orders) as t
GROUP BY changes, customer_id;

-- What was the total volume of pizzas ordered for each hour of the day?
Select DATEPART(HOUR,order_time) as [Time in Hours],Count(order_id) as Orders
from #customer_orders
group by DATEPART(HOUR,order_time)

-- 10.	What was the volume of orders for each day of the week?
SELECT FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, 
 COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

-- 11.	How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?
Select DATEPART(week,registration_date) as WeekPeriod,Count(runner_id) as Number_of_Runners
from runners
group by DATEPART(week,registration_date);

-- 12.	What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with t1 
as
(
	Select c.order_time,r.pickup_time,DATEDIFF(minute,c.order_time,r.pickup_time) as pickup_minutes
	from #customer_orders c
	join #runner_orders r
	on r.order_id = c.order_id
	where cancellation not in ('Restaurant Cancellation','Customer Cancellation')
)
Select AVG(pickup_minutes) as AverageMinutes
from t1

-- 13.	Is there any relationship between the number of pizzas and how long the order takes to prepare?
with t1 
as
(
	Select c.order_id,Count(c.pizza_id) as Pizza_order,DATEDIFF(minute,c.order_time,r.pickup_time) as prep_minutes
	from #customer_orders c
	join #runner_orders r
	on r.order_id = c.order_id
	where cancellation not in ('Restaurant Cancellation','Customer Cancellation')
	group by c.order_id,c.order_time,r.pickup_time
)
Select pizza_order,AVG(prep_minutes) as AveragePrepMinutes
from t1
group by pizza_order


-- 14.	What was the average distance travelled for each customer?
Select c.customer_id,Avg(CAST(r.distance as float)) as AverageDistanceTravelled
from #runner_orders r
join #customer_orders c
on c.order_id = r.order_id
group by c.customer_id

--15.	What was the difference between the longest and shortest delivery times for all orders?
Select (CAST(Max(duration) as int) - CAST(Min(duration) as int)) as Difference
from #runner_orders
where duration not like '% %'


-- 16.	What was the average speed for each runner for each delivery and do you notice any trend for these values?
Select order_id,Avg(CAST(distance as float) / Cast((duration) as float) * 60) as AverageSpeed
from #runner_orders
where duration not like '% %' or duration <> 0 and cancellation not in ('Restaurant Cancellation','Customer Cancellation')
group by order_id;

-- 17.	What is the successful delivery percentage for each runner?
Select 
runner_id,Round(100 * SUM(Case 
when cancellation in ('Restaurant Cancellation','Customer Cancellation') then 0
else 1 end) / Count(*),0) as Success_Percent
from #runner_orders
group by runner_id





