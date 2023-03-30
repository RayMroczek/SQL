/* Joins */

Select orders.*,
       accounts.*,
FROM orders
JOIN accounts
  ON orders.account_id = accounts.id;

/*select all columns from both tables this way too */
  Select *
  FROM orders
  JOIN accounts
    ON orders.account_id = accounts.id;

SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

/* the columns in you resulting table can be ordered however you'd like. */
/*The order of the ON clause doesn't really seem to matter.*/

SELECT accounts.name, orders.total
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
ORDER BY orders.total DESC;

SELECT orders.standard_qty,
orders.gloss_qty,
orders.poster_qty,
accounts.website,
accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

/*Joining 3 tables */
SELECT *
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;

SELECT web_events.channel, accounts.name, orders.total
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id;

/*ALIASes - two options:*/
FROM tablename AS t1
JOIN tablename2 AS t2

FROM tablename t1
JOIN tablename2 t2

Select t1.column1 aliasname, t2.column2 aliasname2
FROM tablename AS t1
JOIN tablename2 AS t2

/*Simplifying JOINS with aliases*/

SELECT accounts.name, accounts.primary_poc, web_events.occurred_at, web_events.channel
FROM accounts
JOIN web_events
ON accounts.id = web_events.account_id
WHERE accounts.name = 'Walmart';

SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

/*2nd example of joins and aliases*/
SELECT region.name as region,
sales_reps.name as sales_rep,
accounts.name as account
FROM region
JOIN sales_reps
ON region.id = sales_reps.region_id
JOIN accounts
ON sales_reps.id = accounts.sales_rep_id;

SELECT r.name as region,
s.name as sales_rep,
a.name as account
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id;

/* more complicated join when there's not a direct connection */
SELECT region.name as region,
accounts.name,
(orders.total_amt_usd/(total + 0.01)) as unit_price
FROM region
JOIN sales_reps
ON sales_reps.region_id = region.id
JOIN accounts
ON accounts.sales_rep_id = sales_reps.id
JOIN orders
ON orders.account_id = accounts.id;

/*simplifying*/

SELECT r.name region, a.name account,
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

/* Left joins and filtering */

SELECT c.countryid, c.countryName, s.stateName
FROM Country c
LEFT JOIN State s
ON c.countryid = s.countryid;

SELECT table1.*, table2.*
FROM table1
LEFT JOIN table2
ON table1.id = table2.id
AND table1.var6 = ‘abc’


/* quiz and examples*/
SELECT r.name region, a.name account, o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
WHERE o.standard_qty > 100 AND o.poster_qty > 50
ORDER BY unit_price DESC;

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
ORDER BY a.name;

SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = 1001;

/*remember to use between with times, and that it starts at midnight on that day*/
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

/*NULLS. remember that null is not a value, it's a property of the data*/
SELECT *
FROM table
WHERE var1 IS NULL;

SELECT *
FROM table
WHERE var1 IS NOT NULL;

/*COUNT: count returns all the rows with at least some data */
SELECT COUNT(*)
FROM orders
WHERE var1 >= '2016-12-01'
AND var1 < '2017-01-01';

/*so count will return only counts for rows with values.
You can check and see which rows are null in the second bit of code*/
SELECT COUNT(var1)
FROM orders;

SELECT *
FROM orders
WHERE var1 IS NULL;

/*SUM: for numeric. will treat null as zeros.*/
SELECT SUM(standard_qty) AS standard,
SUM(gloss_qty) AS gloss,
SUM(poster_qty) AS poster
FROM orders;

SELECT SUM(standard_amt_usd) as tot_standard,
SUM(gloss_amt_usd) as tot_gloss
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

/* MIN and MAX */
SELECT MIN(standard_qty) as standard_min,
MAX(standard_qty) as standard_max
FROM orders;

/*AVERAGE: what can we expect on a regular basis */
SELECT AVG(standard_qty) as standard_avg
FROM orders;

/*each column will need to be named to show up*/
SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss,
           AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd,
           AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders;

/*GROUP BY: include grouping var in select clause.
put group by clause between where and order clauses.
LIMIT at the end will limit the number of rows in your new aggregate table*/
SELECT group_var,
AVG(var1) as var1_avg,
AVG(var2) as var2_avg
FROM table1
WHERE group_var = 'abc'
GROUP BY group_var
ORDER BY group_var;

/* quiz */
SELECT accounts.name as account,
orders.occurred_at
FROM accounts
JOIN orders
ON accounts.id = orders.account_id
ORDER BY orders.occurred_at
LIMIT 1;

SELECT a.name account,
SUM(o.total_amt_usd) total_usd
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

/*retrieving maximum value*/
SELECT a.name as account,
w.occurred_at,
w.channel
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at DESC
LIMIT 1;

SELECT channel, COUNT(channel)
FROM web_events
GROUP BY channel
/*counting all existing rows in web_events with some data,
should be same as above */
SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel

SELECT a.name, MIN(o.total_amt_usd) minimum_order
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY minimum_order;

SELECT r.name, COUNT(s.*) as reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY reps;

/* counting up NAs across columns */
SELECT COUNT(*)-COUNT(name) As A,
COUNT(*)-COUNT(website) As B,
COUNT(*)-COUNT(primary_poc) As C,
COUNT(*)-COUNT(sales_rep_id) As D
FROM accounts;

/*Practicing pulling in percentage of sales of a certain type by rep*/
SELECT sales_reps.name,
SUM(orders.standard_amt_usd)/SUM(orders.total_amt_usd) AS standard_percent
FROM orders
JOIN accounts
ON orders.account_id = accounts.id
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_reps.name
ORDER BY standard_percent DESC;

/*More GROUP BY. Note: group by elements can be in any order.*/
SELECT account_id,
channel,
COUNT(id) AS events
FROM web_events
GROUP BY account_id, channel
ORDER BY account_id, events;

/*quiz, practice group by*/
SELECT a.name,
AVG(o.standard_qty) as standard_avg,
AVG(o.gloss_qty) as gloss_avg,
AVG(o.poster_qty) as poster_avg
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

SELECT a.name,
AVG(o.standard_amt_usd) as standard_usd,
AVG(o.gloss_amt_usd) as gloss_usd,
AVG(o.poster_amt_usd) as poster_usd
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

SELECT s.name,
w.channel,
COUNT(w.*) as count
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN web_events w
ON a.id = w.account_id
GROUP BY s.name, w.channel
ORDER BY s.name, count DESC;

SELECT r.name,
w.channel,
COUNT(w.channel) as count
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN web_events w
ON a.id = w.account_id
GROUP BY r.name, w.channel
ORDER BY count DESC

/*same output from following code - you can just use COUNT(*)
as it's the row count in your resluting table before you aggregate */

/*DISTINCT: get the total distinct count
then get the total distinct count of account + region
Remember: distinct counts unique occurences accross all included columns */
SELECT DISTINCT accounts.name
FROM accounts;

/*note different naming convention*/
SELECT DISTINCT accounts.name as "account name", region.name as region
FROM accounts
JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
JOIN region
ON sales_reps.region_id = region.id

/*two code bits are the same below*/
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

SELECT s.name,
COUNT(a.name) as accounts
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY num_accounts;

/*using numbers to reference what you've selected
This helps with reducing errors - so you don't have to type or paste formulas*/
SELECT var1
SUM(var2)
FROM table1
GROUP BY 1
ORDER BY 2 DESC;

/*HAVING clause: to use when aggregating for groups.
Note: you can't reference created columns in HAVING (e.g. sum_total_amt_usd)*/
SELECT account_id,
SUM(total_amt_usd) as sum_total_amt_usd
FROM orders
GROUP BY 1
HAVING SUM(total_amt_usd) >=250000
ORDER BY 2 DESC;

/*quiz*/
SELECT
s.name,
COUNT(a.name) as account_number
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(a.name) >=5

SELECT a.name,
COUNT(o.*) as order_count
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(o.*) >20;

SELECT a.name,
COUNT(o.*) as order_count
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(o.*) >20
ORDER BY order_count DESC
LIMIT 1;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spend DESC;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spend DESC;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_spend DESC
LIMIT 1;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_spend
LIMIT 1;

SELECT a.name,
COUNT(w.channel) as channel_use
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.name
HAVING COUNT(w.channel) > 6
ORDER BY channel_use;

/*dates*/
SELECT DATE_TRUNC('day', occurred_at) AS day,
SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY DATE_TRUNC('day', occurred_at)
ORDER BY DATE_TRUNC('day', occurred_at);

SELECT DATE_PART('dow', occurred_at) AS day_of_week,
SUM(total) as total_qty
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

/*quiz*/
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_TRUNC('year', occurred_at) AS year,
COUNT(*) as orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_TRUNC('month', o.occurred_at) as month_and_year,
SUM(o.gloss_amt_usd) as gloss_usd
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_PART('year', occurred_at) AS year,
DATE_PART('month', occurred_at) AS month,
COUNT(*) as orders
FROM orders
GROUP BY 1 ,2
ORDER BY 1;

/*CASE WHEN */
SELECT id,
account_id,
occurred_at,
channel,
CASE WHEN channel = 'facebook' THEN 'yes' END AS is_facebook
FROM orders
ORDER BY occurred_at;

SELECT id,
account_id,
occurred_at,
channel,
CASE WHEN channel = 'facebook' THEN 'yes' ELSE 'no' END AS is_facebook
FROM orders
ORDER BY occurred_at;

SELECT id,
account_id,
occurred_at,
channel,
CASE WHEN channel = 'facebook' OR channel = 'direct' THEN 'yes' ELSE 'no' END AS is_facebook
FROM orders
ORDER BY occurred_at;
/*you can include a lot of when --> then statements,
evaluated in the order that they are given.*/

SELECT account_id,
occurred_at,
total,
CASE WHEN total > 500 THEN 'Over 500'
    WHEN total > 300 THEN '301-500'
    WHEN total > 100 THEN '101-300'
    ELSE '100 or under' END AS total_group
FROM orders;

/*But it's better to not have overlapping groups: non-overlapping*/
SELECT account_id,
occurred_at,
total,
CASE WHEN total > 500 THEN 'Over 500'
    WHEN total > 300 AND total <= 500 THEN '301-500'
    WHEN total > 100 AND total <=300 THEN '101-300'
    ELSE '100 or under' END AS total_group
FROM orders;

/*getting around divisions by 0 with CASE WHEN*/
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

/*combining aggregation and CASE WHEN: create a group,
then count by the groups you just created*/
SELECT CASE WHEN total > 500 THEN 'Over 500'
ELSE '500 or under' END AS total_group,
COUNT(*) AS order_count
FROM orders
GROUP BY 1

/*remember, WHERE clause only lets you count 1 thing at a time
but could be used:*/
SELECT COUNT(1) AS orders_over_500_units
FROM orders
WHERE total > 500;

SELECT id, account_id, total_amt_usd,
CASE WHEN total_amt_usd > 3000 THEN 'Large'
ELSE 'Small' END AS level
FROM orders

SELECT
CASE WHEN total >= 2000 THEN 'At least 2000'
WHEN total >=1000 AND total <2000 THEN 'Between 1 and 2k'
ELSE 'Less than 1000' END AS category_count,
COUNT(*)
FROM orders
GROUP BY 1;

/*the two below are equivalent...*/
SELECT s.name, COUNT(o.id) as orders,
CASE WHEN COUNT(o.id) > 200 THEN 'top'
ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;

SELECT s.name, COUNT(*) num_ords,
     CASE WHEN COUNT(*) > 200 THEN 'top'
     ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Level 1'
WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Level 2'
ELSE 'Level 3' END AS level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_spend DESC;

SELECT a.name,
SUM(o.total_amt_usd) as total_spend,
CASE WHEN SUM(o.total_amt_usd) > 200000 THEN 'Level 1'
WHEN SUM(o.total_amt_usd) >= 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Level 2'
ELSE 'Level 3' END AS level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE (DATE_TRUNC('year', o.occurred_at)) > '2015-12-31'
GROUP BY a.name
ORDER BY total_spend DESC;

/*equivalent*/
SELECT s.name,
COUNT(o.id) AS order_count,
SUM(o.total_amt_usd) as order_totals,
CASE WHEN (COUNT(o.id) > 200 OR SUM(o.total_amt_usd) >750000) THEN 'top'
WHEN (COUNT(o.id) > 150 AND COUNT(o.id) < 200) OR (SUM(o.total_amt_usd)>500000 AND SUM(o.total_amt_usd)<750000) THEN 'mid'
ELSE 'low' END as sales_group
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY s.name
ORDER BY 2 DESC;

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent,
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;

/*Subqueries*/
SELECT DATE_TRUNC()
