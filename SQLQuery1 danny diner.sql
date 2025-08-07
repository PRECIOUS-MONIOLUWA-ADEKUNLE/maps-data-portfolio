create database Dannys_diner
 
create table sales (
customer_id varchar(1),
order_date date,
product_id int
);

insert into sales
( customer_id,order_date,product_id)
values
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

SELECT*
FROM SALES

CREATE TABLE MENU(
PRODUCT_ID INT,
PRODUCT_NAME VARCHAR(5),
PRICE INT
);

SELECT* FROM MENU

INSERT INTO MENU
(PRODUCT_ID, PRODUCT_NAME,PRICE)
VALUES
('1', 'SUSHI', '10'),
('2', 'CURRY', '15'),
('3', 'RAMEN', '12');

CREATE TABLE MEMBERS(
CUSTOMER_ID VARCHAR(1),
JOIN_DATE DATE);

SELECT* FROM MEMBERS

INSERT INTO MEMBERS
(CUSTOMER_ID, JOIN_DATE)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

--Solution to the case study questions
--1. What is the totalamount each customer spent at the restaurant?
select * from sales
select 
 s.customer_id,
 sum(m.price) as Total_Spent
from Sales s
Join Menu m On s.product_id = m.product_id
group by s.customer_id

--2. How many days has each customer visited the restaurant?
Select * from sales
select
  customer_id,
  count(distinct order_date)
as Visited_days
from sales
group by customer_id

--3. What was the first item from the menu purchased by each customer?
select 
  s.customer_id,
  s.order_date,
  m.product_name
from Sales s
join Menu m on s.product_id = m.product_id
where s.order_date = (
  select min(order_date)
  from sales 
  where customer_id = s.customer_id);

--4. What is the most purchased item from the menu and how many times was it purchased by all customers?
select Top 1
 m.product_name,
 count(*) as purchased_item
from Sales s
join Menu m on s.product_id = m.product_id
group by m.product_name
order by purchased_item desc;

select Top 1
 m.product_name,
 count(*) as purchased_item
from Sales s
join Menu m on s.product_id = m.product_id
group by m.product_name
order by purchased_item asc;

--5. Which item was the most popular for each customers?
with customer_item as(
 select
  s.customer_id,
  s.product_id,
  m.product_name,
  count(*) as purchase_total
  from sales s
  join menu m on s.product_id = m.product_id
  group by s.customer_id,s.product_id,m.product_name),
  ranked_items as (
      select *,
   rank() over (partition by customer_id order by purchase_total desc) as rank
   from customer_item)
   select
   customer_id,
 product_name,
  purchase_total
  from ranked_items
  where rank = 1;

--6. Which item was purchased first by the customer after they became a member?
with customer_purchases as (
  select
   s.customer_id,
   s.product_id,
   s.order_date,
   m. join_date
 from sales s
 join members m on s.customer_id = m.customer_id
    where s.order_date >= m.join_date),
ranked_purchase as (
 select *,
   row_number() over (partition by customer_id order by order_date asc) as rank
    from customer_purchases)
select 
   r.customer_id,
   r.product_id,
   menu. product_name,
   r.order_date
from ranked_purchase r
join menu on r.product_id =menu.product_id
where r.rank = 1;

--7. Which item was purchased just before the customer became a member?
with prememberorders as (
  select 
    s.customer_id,
	s.order_date,
	s.product_id
 from sales s
 join members m on s.customer_id =m.customer_id
 where s.order_date < m.join_date),
 lastprememberorder as (
  select 
    customer_id,
	max(order_date) as 
last_order_date
 from prememberorders
  group by customer_id 
)
select
  pmo.customer_id,
  pmo.order_date,
  me.product_name
from prememberorders pmo
join lastprememberorder lpo on pmo.customer_id =lpo.customer_id
and pmo.order_date = lpo.last_order_date
join menu me on pmo.product_id =me.product_id
order by pmo.customer_id;

--8. What is the total items and amount spent for each member before they became a member?
select 
  s.customer_id,
  count(s.product_id) as totalitems,
  sum(m.price) as totalcost
from sales s
join members mb on s.customer_id =mb.customer_id
join menu m on s.product_id = m.product_id
where s.order_date < mb.join_date
group by s.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2X points multiplier - how many points would each customer have?
select s.customer_id,
 sum(case when m.product_name = 'sushi' then m.price *20
 else m.price * 10
 end ) as accumulated_points
 from sales s
 join menu m on s.product_id = m.product_id
 group by s.customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2X points on all items, not just sushi - how many points do customer A and B have at the end of january
SELECT
  s.customer_id,
  SUM(
  CASE 
  WHEN s.order_date <= '2021-01-31' THEN
  CASE 
  WHEN s.order_date BETWEEN mb.join_date AND DATEADD(DAY, 6, mb.join_date) THEN
  -- 7-day bonus window
  CASE 
  WHEN m.product_name = 'sushi' THEN m.price * 40  -- 2x for sushi * 2x for join week
  ELSE m.price * 20  -- 2x for join week
  END
  ELSE
  CASE 
  WHEN m.product_name = 'sushi' THEN m.price * 20  -- Only sushi bonus
  ELSE m.price * 10  -- Normal items
  END
  END
  ELSE 0
  END
  ) AS Accumulated_points
FROM Sales s
JOIN Menu m ON s.product_id = m.product_id
JOIN Members mb ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A', 'B')
GROUP BY s.customer_id;

-- Bonus question

--1. Joing all things
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
   WHEN mb.join_date IS NOT NULL AND s.order_date >= mb.join_date THEN 'Y'
  ELSE 'N'
   END AS member,
  CASE
  WHEN mb.join_date IS NOT NULL AND s.order_date >= mb.join_date THEN
  CASE 
  WHEN m.product_name = 'sushi' THEN m.price * 40  -- 2x sushi × 2x membership bonus
 ELSE m.price * 20
 END
ELSE
  CASE 
  WHEN m.product_name = 'sushi' THEN m.price * 20
   ELSE m.price * 10
  END
  END AS points
FROM Sales s
JOIN Menu m ON s.product_id = m.product_id
LEFT JOIN Members mb ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date;


--2.Ranking all things
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
CASE
WHEN mb.join_date IS NOT NULL AND s.order_date >= mb.join_date THEN 'Y'
ELSE 'N'
END AS member,
 CASE
WHEN mb.join_date IS NOT NULL AND s.order_date >= mb.join_date THEN
RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date)
ELSE NULL
END AS ranking
FROM Sales s
JOIN Menu m ON s.product_id = m.product_id
LEFT JOIN Members mb ON s.customer_id = mb.customer_id
ORDER BY s.customer_id, s.order_date;
