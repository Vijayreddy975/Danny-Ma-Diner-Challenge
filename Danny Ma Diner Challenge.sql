/* 1. What is the total amount each customer spent at the restaurant? */

SELECT s.customer_id,sum(m.price) as total FROM sales s
LEFT JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;

/* 2. How many days has each customer visited the restaurant? */
SELECT distinct customer_id, Count(customer_id) as No_of_times_visit
FROM sales
GROUP BY customer_id;


/* 3. What was the first item from the menu purchased by each customer? */

WITH CTE AS (
SELECT s.customer_id,s.order_date,m.product_name,row_number() OVER (Partition By customer_id ORDER BY order_date asc) as rn
FROM sales s
LEFT JOIN menu m
ON s.product_id = m.product_id
ORDER BY s.order_date ASC)

SELECT * FROM CTE
where rn=1;

/* 4. What is the most purchased item on the menu and how many times was it purchased by all customers? */
SELECT S.customer_id,m.product_name,count(S.product_id) as times
FROM sales S
JOIN menu m
ON S.product_id = m.product_id
group by S.customer_id,m.product_name
Order by times desc,S.customer_id;


/* 5. Which item was the most popular for each customer? */

with cte as (
SELECT s.customer_id,m.product_name,
  count(m.product_name) as productname,
rank() over (partition by s.customer_id order by count(m.product_id) desc) as rn
from sales s
left join menu m
on s.product_id = m.product_id
group by s.customer_id,m.product_name )

SELECT customer_id,product_name FROM CTE
where rn = 1 ;


/* 6. Which item was purchased first by the customer after they became a member? */

with CTE as (
SELECT s.customer_id,m.product_name,
row_number() over (partition by s.customer_id order by s.order_date asc ) as rn
from sales s
left join menu m
on s.product_id = m.product_id
left join members k
on s.customer_id = k.customer_id
where s.order_date > k.join_date) 

SELECT * FROM CTE
where rn = 1;


/* 7. Which item was purchased just before the customer became a member? */

with CTE as (
SELECT s.customer_id,m.product_name,
row_number() over (partition by s.customer_id order by s.order_date asc ) as rn
from sales s
left join menu m
on s.product_id = m.product_id
left join members k
on s.customer_id = k.customer_id
where s.order_date < k.join_date) 

SELECT * FROM CTE
where rn = 1;


/* 8. What is the total items and amount spent for each member before they became a member? */

SELECT s.customer_id,Count(m.product_id),Sum(price) as total_sum
from sales s
left join menu m
on s.product_id = m.product_id
left join members k
on s.customer_id = k.customer_id
where s.order_date < k.join_date
group by s.customer_id;

/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */

SELECT s.customer_id,m.product_name,
sum(case when m.product_name = 'sushi' then m.price = 2*m.price
else 1*m.price end) as Customer_Points
from sales s
left join menu m
on s.product_id = m.product_id
group by s.customer_id,m.product_name;

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */

WITH dates AS 
(
   SELECT *, 
      DATE_ADD(join_date,INTERVAL 6 DAY) AS valid_date,
      LAST_DAY(join_date) AS last_date
   FROM members 
)
Select S.Customer_id, 
       SUM(
	   Case 
	  When m.product_ID = 1 THEN m.price*20
	  When S.order_date between D.join_date and D.valid_date Then m.price*20
	  Else m.price*10
	  END 
	  ) as Points
From Dates D
join Sales S
On D.customer_id = S.customer_id
Join Menu M
On M.product_id = S.product_id
Where S.order_date < d.last_date
Group by S.customer_id


