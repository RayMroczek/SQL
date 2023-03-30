/*DATA CLEANING*/
/*LEFT AND RIGHT select*/

SELECT RIGHT(website, 3) AS type, COUNT(*)
FROM accounts
GROUP BY type

SELECT LEFT(name, 1) as initial, COUNT(*)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC

/*two ways of answering - first way creates two rows, second two columns*/
/*both create a tally by renaming as 0 or 1 and then summing it up*/
SELECT initial_cat, COUNT(*)
FROM
(SELECT name,
  CASE WHEN LEFT(name, 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
  THEN 'number' ELSE 'letter' END AS initial_cat
FROM accounts) sub1
  GROUP BY 1

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 1 ELSE 0 END AS num,
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9')
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;

/*CONCAT*/
SELECT
CONCAT(sales_reps.id, '_', region.name) AS EMP_ID_REGION, *
FROM sales_reps
JOIN region
ON sales_reps.region_id = region.id

/*CONCAT, LEFT, RIGHT, and SUBSTR*/
WITH t1 AS (SELECT name,
CONCAT('(', lat, ', ', long, ')') AS coordinate,
LEFT(name, 1) as first, RIGHT(name, 1) as last, SUBSTR(website, 4) as www
FROM accounts)

SELECT name, coordinate,
CONCAT(first, last, '@', www) as email
FROM t1

/*alternative without subquery*/
SELECT NAME, CONCAT(LAT, ', ', LONG) COORDINATE,
CONCAT(LEFT(PRIMARY_POC, 1), RIGHT(PRIMARY_POC, 1), '@', SUBSTR(WEBSITE, 5)) EMAIL
FROM ACCOUNTS;

/*DOUBLE INLINE!*/
SELECT CONCAT(part1, num)
FROM
(SELECT part1, COUNT(*) as num
FROM
(SELECT
CONCAT(account_id, '_', channel, '_') as part1
FROM web_events) sub1
GROUP BY 1) sub2

/*alternative*/
WITH T1 AS (
 SELECT ACCOUNT_ID, CHANNEL, COUNT(*)
 FROM WEB_EVENTS
 GROUP BY ACCOUNT_ID, CHANNEL
 ORDER BY ACCOUNT_ID
)
SELECT CONCAT(T1.ACCOUNT_ID, '_', T1.CHANNEL, '_', COUNT)
FROM T1;

SELECT CONCAT(day, '/', month, '/', year), date
FROM
(SELECT date, SUBSTR(date, 1, 2) as month, SUBSTR(date, 4, 2) as day, SUBSTR(date, 7, 4) as year
FROM sf_crime_data) sub1
LIMIT 10

/*SUBSTR, CONCAT, and CAST*/
SELECT CAST(CONCAT(year, '/', month, '/', day) AS date), date
FROM
(SELECT date, SUBSTR(date, 1, 2) as month, SUBSTR(date, 4, 2) as day, SUBSTR(date, 7, 4) as year
FROM sf_crime_data) sub1
LIMIT 10

/*or change type with :: instead of CAST, and use || to concat*/
SELECT date orig_date,
(SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data;

/*STRPOS and POSITION*/
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts;

SELECT LEFT(name, STRPOS(name, ' ') -1 ) first_name,
       RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps;

/*STRPOS and CONCAT*/
/*my code*/
SELECT
(LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) || '.' ||
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) || '@'
|| name || '.com')
FROM accounts
/*option 2*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
FROM t1;

/*other examples*/
/*shows how to remove spaces*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;

WITH t1 AS (
 SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

/*my messier version of the code above (without concatenation)*/
SELECT primary_poc, LEFT(LOWER(primary_poc), 1) as one,
SUBSTR(LOWER(primary_poc), STRPOS(primary_poc, ' ')-1, 1) as two,
RIGHT(LOWER(primary_poc), 1) as three,
LENGTH(RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' '))) as four,
UPPER(REPLACE(name, ' ', ''))
FROM accounts

/*Coalesce... */
/* when we left join here, accounts without orders are still included.
one row is missing order info, and this makes it also miss its ID for some reason.*/
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
/* we'll use COALESCE to fix it, so as it joins it will use a.id, and if missing, a.id again*/
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/*COALESCE can also be used to put zeros in when there is no value
 (see where it puts 0s if the total is not present):*/
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
