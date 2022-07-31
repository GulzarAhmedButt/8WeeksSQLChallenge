--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Gulzar Ahmed 
--Date: 31/07/2022 
--Tool used: MS SQL Server

CREATE Database dannys_diner;
Use dannys_diner;
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');



Select * from members

Select * 
from menu

Select *
from sales

-- What is the total amount each customer spent at the restaurant?
Select s.customer_id,SUM(m.price) as [Amount Spent]
from sales as s
join menu as m
on s.product_id = m.product_id
group by s.customer_id;


--How many days has each customer visited the restaurant?
Select customer_id,Count(Distinct order_date) as [Number of Days Visited]
from sales
group by customer_id;

-- What was the first item from the menu purchased by each customer?
Select t.customer_id,m.product_name
from 
(
	Select *
	from 
	(
	Select *,ROW_NUMBER() over (partition by customer_id order by order_date) as rn
	from sales
	) s
	where s.rn = 1
) t 
join menu as m
on t.product_id = m.product_id

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
Select top 1 m.product_name,COUNT(s.product_id) as [Number of Times Purchased]
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_name
order by [Number of Times Purchased] desc

-- Which item was the most popular for each customer?
WITH fav_item AS 
(Select s.customer_id,m.product_id,COUNT(m.product_id) as [Product Counts]
,Dense_Rank() over (partition by s.customer_id order by COUNT(m.product_id) desc) as rnk
from sales s
join menu as m
on s.product_id = m.product_id
group by s.customer_id,m.product_id)

Select customer_id,product_id,[Product Counts]
from fav_item
where rnk = 1

-- Which item was purchased first by the customer after they became a member?
with First_Item AS 
	(
			Select s.customer_id,s.product_id,s.order_date
			,DENSE_RANK() over (partition by s.customer_id order by s.order_date) as rnk
			from sales s
			join members m
			on s.customer_id = m.customer_id
			where s.order_date >= m.join_date
	)
Select customer_id,m.product_name
from First_Item fi
join menu as m 
on m.product_id = fi.product_id
where fi.rnk = 1


-- Which item was purchased just before the customer became a member?
with First_Item AS 
	(
			Select s.customer_id,s.product_id,s.order_date
			,DENSE_RANK() over (partition by s.customer_id order by s.order_date desc) as rnk
			from sales s
			join members m
			on s.customer_id = m.customer_id
			where s.order_date < m.join_date
	)
Select customer_id,m.product_name
from First_Item fi
join menu as m 
on m.product_id = fi.product_id
where fi.rnk = 1;

-- What is the total items and amount spent for each member before they became a member?
Select x.customer_id,COUNT(x.product_id) as [Total Items],SUM(x.price) as [Total Amount Spent]
from 
(
		Select s.customer_id,s.product_id,m.price 
		from sales s
		join menu m
		on m.product_id = s.product_id
		left join members me
		on s.customer_id = me.customer_id
		where s.order_date < me.join_date
) x
group by x.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with price_multiplier as 
(
	Select *,CASE WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10 END as points
	from menu
)
Select s.customer_id,SUM(m.points) as [Points Customers Spent]
from sales s
join price_multiplier m
on s.product_id = m.product_id
group by s.customer_id

--  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 1. Find member validity date of each customer and get last date of January
-- 2. Use CASE WHEN to allocate points by date and product id
-- 3. SUM price and points
with dates_cte as 
(
	Select *,DATEADD(DAY,6,join_date) as valid_date,EOMONTH('2021-01-31') as last_date
	from members
)
Select s.customer_id,m.product_id,s.order_date,d.join_date,d.valid_date,m.price,
SUM(Case when s.order_date BETWEEN d.join_date and d.valid_date then 20 * m.price END) as points
from dates_cte d
join sales s
on s.customer_id = d.customer_id
join menu m
on m.product_id = s.product_id
where s.order_date < d.last_date
group by s.customer_id,m.product_id,s.order_date,d.join_date,d.valid_date,m.price