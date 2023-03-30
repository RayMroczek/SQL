/*OVER (and PARTITION)*/
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders

SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) as year,
       SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

/*RANK with PARTITION*/

SELECT
id, account_id, total,
DENSE_RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;

/*ALIAS with WINDOW FUNCTION*/
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER monthly_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER monthly_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER monthly_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER monthly_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER monthly_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER monthly_window AS max_total_amt_usd
FROM orders
WINDOW monthly_window AS
(PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

/*LAG AND LEAD (require OVER clause, which I think requires a window function)*/
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders
       GROUP BY 1
      ) sub

SELECT account_id,
             standard_sum,
             LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
             LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
      FROM (
      SELECT account_id,
             SUM(standard_qty) AS standard_sum
             FROM orders
             GROUP BY 1
           ) sub

SELECT account_id,
total_amt_usd,
LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) AS lead,
LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) - total_amt_usd AS lead_difference
FROM orders;

/*note: in the table you're drawing FROM, you can include other vars and group by them.
makes no difference
V1:*/

SELECT id,
account_id,
occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT id, account_id, occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY 1, 2,3
) sub

/*V2*/
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders
 GROUP BY 1
) sub

/*NTILE */
SELECT
       account_id,
       occurred_at,
       standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
  FROM orders
 ORDER BY account_id DESC

 SELECT
        account_id,
        occurred_at,
        total_amt_usd,
        NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
   FROM orders
  ORDER BY account_id DESC

/*FULL JOINS */
SELECT s.name,
r.name as region
FROM sales_reps s
FULL JOIN region r
ON r.id = s.region_id

SELECT *
  FROM accounts
 FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
 WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL

/*INEQUALITY JOINS - works for numerical and string*/
SELECT o.id,
o.occurred_at as order_date,
w.*
FROM orders o
LEFT JOIN web_events w
ON w.account_id = o.account_id
AND w.occurred_at < o.occurred_at
WHERE DATE_TRUNC('month', o.occurred_at) =
(SELECT DATE_TRUNC('month', MIN(o.occurred_at)) FROM orders)
ORDER BY o.account_id, o.occurred_at;


SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name

/* SELF JOINs: joining the table to itself
Example: to find out which accounts made multiple orders within 30 days*/
SELECT o1.id AS o1_id,
o1.account_id AS o1_account_id,
o1.occurred_at AS o1_occurred_at,
o2.id AS o2_id,
o2.account_id AS o2_account_id,
o2.occurred_at AS o2_occurred_at
FROM orders o1
JOIN orders o2
ON o1.account_id = o2.account_id
AND o2.occurred_at > o1.occurred_at /*after the original order was placed */
AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days' /*time-bound the records*/
ORDER BY o1.account_id, o1.occurred_at

/*note that every row will be retained, and also
there may be additional rows if the conditions are met more than once.*/
SELECT w1.id AS w1_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
       w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
       w2.channel AS w2_channel
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
  AND w2.occurred_at > w1.occurred_at
  AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w2.occurred_at

/*UNION ALL AND UNION*/
SELECT *
  FROM web_events
  WHERE channel = 'facebook'

UNION

SELECT *
FROM web_events_2

/*performing operations on combined data set: 2 ways*/
/*way 1: subquery*/
SELECT channel,
COUNT(*) as sessions
FROM
(SELECT *
  FROM web_events
  WHERE channel = 'facebook'

UNION

SELECT *
FROM web_events_2) sub1

/*way 2: subquery*/

WITH t1 AS
(SELECT *
    FROM web_events
    WHERE channel = 'facebook'
  UNION
  SELECT *
  FROM web_events_2)

SELECT channel,
COUNT(*) AS sessions
FROM t1
GROUP BY 1
ORDER BY 2 DESC;

/*Performance Tuning*/
/*perform your query on a subset for exploratory analyses,
then run it on the full data set*/
SELECT *
FROM orders
WHERE occurred_at >= '2016-01-01'
AND occurred_at < '2016-07-01'

/*LIMIT your output automatically for big datasets*/
/*LIMIT doesn't work the same way for aggregations;
aggregations are performed first and then the LIMIT is applied.
If you want to limit the dataset before performing the aggregate function,
you'll need to do it in a subquery.*/

SELECT account_id,
SUM(poster_qty) AS sum_poster_qty
FROM SELECT * FROM orders LIMIT 100) sub
WHERE occurred_at >= '2016-01-01'
AND occurred_at < '2016-07-01'
GROUP BY 1

/*LIMIT the data that you're joining together */
/*in the query below, all web_events rows need to be evaluated
to match to the accounts table*/

SELECT accounts.name,
COUNT(*) as web_events
FROM accounts
JOIN web_events
ON web_events.account_id = accounts.id
GROUP BY 1
ORDER BY 2 DESC;

/*you could aggregate first within a subquery,
and drop it in your outer query to reduce cost dramatically*/
SELECT a.name,
      sub.web_events
FROM (
  SELECT account_id,
      COUNT(*) AS web_events
      FROM web_events
      GROUP BY 1
) sub
JOIN accounts a
ON a.id = sub.account_id
ORDER BY 2 DESC;

/*You can add "EXPLAIN" at the beginning of queries to get a sense
of how long your query will take and its query plan.*/

EXPLAIN
SELECT *
FROM orders
WHERE occurred_at >= '2016-01-01'
AND occurred_at < '2016-07-01'

/*JOINING subqueries:
helpful when wanting to join data from several tables
and aggregate by day for a dashboard*/
/*count distinct is a resource intensive method*/
SELECT DATE_TRUNC('day', occurred_at) AS date,
  COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
  COUNT(DISTINCT o.id) AS orders,
  COUNT(DISTINCT w.id) AS web_visits
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN web_events w
ON DATE_TRUNC('day', w.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;
/*joining on date fields causes a DATA EXPLOSION! 79k rows to then aggregate (example below)*/
SELECT o.occurred_at AS date,
a.sales_rep_id,
o.id as order_id,
w.id as web_event_id
FROM accounts a
JOIN orders o
ON a.id = o.account_id
JOIN web_events w
ON DATE_TRUNC('day', w.occurred_at) = DATE_TRUNC('day', o.occurred_at)
ORDER BY 1 DESC;

/*optimized: aggregating tables separately, so that the counts are performed across far smaller datasets*/
/*first subquery*/
SELECT DATE_TRUNC('day', o.occurred_at) AS date,
  COUNT(a.sales_rep_id) as active_sales_reps,
  COUNT(o.id) as orders
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
/*second subquery*/
  SELECT DATE_TRUNC('day', o.occured_at) AS date,
      COUNT(w.id) as web_events,
      FROM web_events w
      GROUP BY 1
/*when we join these two subqueries, we'll be joining about 1k rows to 1k rows,
where dates match: much less expensive*/

/*use coalesce here to return the first non-null value for dates*/

COALESCE(orders.date, web_events.date) AS date,
orders.active_sales_reps,
orders.orders,
web_events.web_visits
FROM
/*first subquery*/
(SELECT DATE_TRUNC('day', o.occurred_at) AS date,
  COUNT(a.sales_rep_id) as active_sales_reps,
  COUNT(o.id) as orders
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1) orders
/*using full join just in case one table has a different date that isn't
in the other table*/
  FULL JOIN
/*second subquery*/
(SELECT DATE_TRUNC('day', o.occured_at) AS date,
      COUNT(w.id) as web_events,
      FROM web_events w
      GROUP BY 1) web_events

ON web_events.date = orders.date
ORDER BY 1 DESC
