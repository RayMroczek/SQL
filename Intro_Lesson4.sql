/*Subqueries*/
/*INLINE SUBQUERY
data is stored by event.
Goal is to get avg daily events, by channel.
We need to first aggregate to the day level, and then
average across days.*/
SELECT channel,
AVG(event_count) as avg_event_count
FROM
(SELECT DATE_TRUNC('day', occurred_at) AS day,
channel,
COUNT(web_events.*) as event_count
  FROM web_events
  GROUP BY 1,2
) sub
  GROUP BY 1
  ORDER BY 2

/* on an average day, how many sales do each of the reps make?
First need table of all sales by day, grouped by rep
Then we can average that up*/
SELECT rep,
AVG(orders)
FROM
(SELECT
s.name as rep,
DATE_TRUNC('day', o.occurred_at) as day,
COUNT(o.*) as orders
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1, 2) sub
GROUP BY 1
ORDER BY 2 DESC

/*Creating VIEWS which can let you query the same data again later*/
create view v1
as
select S.id, S.name as Rep_Name, R.name as Region_Name
from sales_reps S
join region R
on S.region_id = R.id
and R.name = 'Northeast';

CREATE VIEW V2
AS
SELECT r.name region, a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

/* NESTED SUBQUERY*/
SELECT *
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
(SELECT DATE_TRUNC('month',MIN(occurred_at)) AS min_month
FROM orders)
ORDER BY occurred at;

/*notice how you need to add names to your subquery table
that you can reference in the outer query*/

/*creating an aggregated table*/
SELECT a.name as account, w.channel as channel, COUNT(w.*) as event
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY 1, 2

/*nesting it within an outer query to select only maximum values for accounts*/
SELECT account, MAX(event) as max
FROM
(SELECT a.name as account, w.channel as channel, COUNT(w.*) as event
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY 1, 2) t1
GROUP BY 1

/*joining these two tables*/

SELECT t3.account, t3.channel, t3.event
FROM
(SELECT account, MAX(event) as max
FROM
(SELECT a.name as account, w.channel as channel, COUNT(w.*) as event
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY 1, 2) t1
GROUP BY 1) t2

JOIN (SELECT a.name as account, w.channel as channel, COUNT(w.*) as event
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY 1, 2) t3
ON t2.account = t3.account AND t2.max=t3.event

/*note that max will pull in all rows that are the max if there are ties,
and not just the first one that appears in the table */

/*create a table that shows sales rep total sales*/
SELECT r.name as region, s.name, SUM(o.total_amt_usd) as total_usd
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY 3

/*now pull out only the max for each region */
SELECT sub1.region, MAX(total_usd)
FROM
(SELECT r.name as region, s.name as name, SUM(o.total_amt_usd) as total_usd
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2) sub1
GROUP BY 1

/*now merge this max back with the other table to get the rep name*/

SELECT sub3.region, sub3.name, sub3.total_usd
FROM
(SELECT r.name as region, s.name as name, SUM(o.total_amt_usd) as total_usd
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2) sub3

JOIN (SELECT sub1.region as region, MAX(total_usd) as max
FROM
(SELECT r.name as region, s.name as name, SUM(o.total_amt_usd) as total_usd
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2) sub1
GROUP BY 1) sub2
ON sub3.region = sub2.region AND sub2.max = sub3.total_usd

/* STEP 1: creating a table with the total orders and $ for each region*/
SELECT r.name, COUNT(o.*) as count, SUM(o.total_amt_usd) as sum
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1

/* STEP 2: creating a table that selects the region with the highest total $*/
SELECT MAX(sub1.sum)
FROM
(SELECT r.name, COUNT(o.*) as count, SUM(o.total_amt_usd) as sum
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1) sub1

/*STEP 3: add in the details to go with the max you found*/
SELECT  sub3.region, sub3.count, sub3.sum
FROM (SELECT r.name AS region, COUNT(o.*) as count, SUM(o.total_amt_usd) as sum
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1) sub3

JOIN
(SELECT MAX(sub1.sum) as max
FROM
(SELECT r.name, COUNT(o.*) as count, SUM(o.total_amt_usd) as sum
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY 1) sub1
) sub2

ON sub2.max = sub3.sum

/*STEP 1. Which account ordered the most standard qty paper*/
SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/*STEP 2. How many accounts had greater total spend*/
SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total
                   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                         FROM accounts a
                         JOIN orders o
                         ON o.account_id = a.id
                         GROUP BY 1
                         ORDER BY 2 DESC
                         LIMIT 1) sub);

/* next */
SELECT MAX()
SELECT a.name, SUM(o.total_amt_usd) as sum
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                     FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                           FROM orders o
                           JOIN accounts a
                           ON a.id = o.account_id
                           GROUP BY a.id, a.name
                           ORDER BY 3 DESC
                           LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*another*/

SELECT AVG(sum)
FROM
(SELECT a.name, SUM(o.total_amt_usd) as sum
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10) sub1;

/*WITH SUBQUERIES, or Common Table Expressions*/
/*t1: all salesrep totals with region info*/
WITH table1 AS
(SELECT r.name as region, s.name as rep, SUM(o.total_amt_usd) as total
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1, 2),

table2 AS
(SELECT table1.region, MAX(table1.total) as max_total
FROM table1
GROUP BY 1)

SELECT table1.region, table1.rep, table2.max_total
FROM table1
JOIN table2
ON table2.max_total =table1.total
ORDER BY 3 DESC


/*next example*/
SELECT r.name, COUNT(o.*), SUM(o.total_amt_usd)
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1

/* next example*/
/*t1*/
SELECT o.account_id, SUM(o.total_amt_usd) as sum
FROM orders o
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

/*t2*/
SELECT w.account_id, w.channel, COUNT(w.*) as events
FROM web_events w
GROUP BY 1,2
ORDER BY 1

/*joining*/
WITH table1 AS (
SELECT o.account_id, SUM(o.total_amt_usd) as sum
FROM orders o
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1),

table2 AS (
  SELECT w.account_id, w.channel, COUNT(w.*) AS events
FROM web_events w
GROUP BY 1,2
ORDER BY 1)

SELECT table2.account_id, table2.channel, table2.events
FROM table2
JOIN table1
ON table2.account_id = table1.account_id

/*alternative*/
WITH t1 AS (
   SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.id, a.name
   ORDER BY 3 DESC
   LIMIT 1)
SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id FROM t1)
GROUP BY 1, 2
ORDER BY 3 DESC;

/*another example - two ways*/
SELECT AVG(sum)
FROM
(SELECT a.name as name, SUM(o.total_amt_usd) as sum
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10) sub

WITH t1 AS (
   SELECT a.name, SUM(o.total_amt_usd) tot_spent
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id
   GROUP BY a.name
   ORDER BY 2 DESC
   LIMIT 10)
SELECT AVG(tot_spent)
FROM t1;

/*new example: same query, just select clause diff (select avg_all vs. *)*/
WITH table1 AS (SELECT AVG(o.total_amt_usd) avg_all
FROM orders o),

table2 AS (SELECT o.account_id,  AVG(o.total_amt_usd) AS avg_order
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT avg_all FROM table1))

SELECT AVG(avg_order)
FROM table2


WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;
