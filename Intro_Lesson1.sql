/* SELECT ALL OR SPECIFIC COLUMNS */

SELECT *
FROM orders;

SELECT abc, def
FROM orders;

/* LIMITING OUTPUT */

SELECT abc, def
FROM orders
LIMIT 10;

/* ORDER BY CLAUSE */

SELECT abc, def
FROM orders
ORDER BY xyz
LIMIT 10;

SELECT abc, def
FROM orders
ORDER BY xyz DESC
LIMIT 10;

SELECT abc, def
FROM orders
ORDER BY xyz, def;

SELECT abc, def
FROM orders
ORDER by xyz DESC, def;

/* WHERE CLAUSE */

SELECT *
FROM orders
WHERE abc = 1
ORDER by XYZ;

SELECT *
FROM orders
WHERE abc != 1
ORDER by XYZ;

SELECT *
FROM orders
WHERE abc >= 1
ORDER by XYZ;

SELECT *
FROM orders
WHERE abc > 1
ORDER by XYZ;

SELECT *
FROM orders
WHERE abc = 'text';

/* Mathematical Operators */

SELECT id, (var1/var2)*100 AS new_var_name, var3
FROM orders
LIMIT 10;

SELECT id, account_id,
   var1/(var1 + var2 + var3) AS new_var_name
FROM orders
LIMIT 10;

SELECT id, account_id, var1/var2 AS new_var_name
FROM orders
LIMIT 10;

/* Different Operators: LIKE */

SELECT id, name
FROM accounts
WHERE name LIKE 'C%';

SELECT id, name
FROM accounts
WHERE name LIKE '%one%';

SELECT id, name
FROM accounts
WHERE name LIKE '%s';

/* Different Operators: IN */

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

/* Different Operators: NOT IN & NOT LIKE*/

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom')

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

SELECT name
FROM accounts
WHERE name NOT LIKE '%one%';

/* Different Operators: AND and BETWEEN*/

WHERE column >= 6 AND column <= 10
WHERE column BETWEEN 6 AND 10

SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT *
FROM accounts
WHERE name != 'C%' AND name = '%s';

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2016-12-31'
ORDER BY occurred_at DESC;

/* Different Operators: OR*/

SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;

SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
           AND primary_poc NOT LIKE '%eana%');
