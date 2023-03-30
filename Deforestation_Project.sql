/*Creating Forestation View with 2 new columns*/

CREATE VIEW forestation AS
SELECT f.*, l.total_area_sq_mi, r.region, r.income_group,
l.total_area_sq_mi *2.59 AS land_area_sqkm,
f.forest_area_sqkm/(l.total_area_sq_mi *2.59) AS percent_forest
FROM forest_area f
INNER JOIN land_area l
ON f.country_code = l.country_code AND f.year = l.year
LEFT JOIN regions r
ON f.country_code = r.country_code;

/*------1. GLOBAL SITUATION------*/
/*Calculating forest area for 1990*/
  SELECT ROUND(CAST(forest_area_sqkm/1000000 AS NUMERIC),2)
  FROM forestation
  WHERE year = '1990' AND country_code = 'WLD';
/*output: 41.28 million sq km*/

/*Calculating forest area for 2016*/
SELECT ROUND(CAST(forest_area_sqkm/1000000 AS NUMERIC),2)
FROM forestation
WHERE year = '2016' AND country_code = 'WLD';
/*output: 39.96 million sq km*/

/*Calculating loss: number and percent.*/
/*Creating a new table first that has 1990 and 2016 forest data in separate columns to make it easier to calculate differences.*/
WITH year_1990 AS
(SELECT country_code, forest_area_sqkm AS forest_sqkm_1990
FROM forestation
WHERE year = 1990 AND country_code = 'WLD'),

year_2016 AS
(SELECT country_code, forest_area_sqkm AS forest_sqkm_2016
FROM forestation
WHERE year = 2016 AND country_code = 'WLD')

SELECT *,
year_2016.forest_sqkm_2016 - year_1990.forest_sqkm_1990 AS number_decrease,
(year_2016.forest_sqkm_2016 - year_1990.forest_sqkm_1990)/ (year_1990.forest_sqkm_1990)*100 AS percent_decrease
FROM year_1990
 year_2016
ON year_1990.country_code = year_2016.country_code;
/*output for number decrease: -1,324,449 sq km or 1.32 million sq km
rounded output for percent decrease: - -3.208% */

/*comparing lost sq km to country land areas:*/


WITH year_2016 AS (
  SELECT *
  FROM forestation
  WHERE year = '2016'),

year_1990 AS (
  SELECT *
  FROM forestation
  WHERE year = '1990')

SELECT year_2016.country_name, ROUND(CAST((year_2016.land_area_sqkm/1000000) AS NUMERIC),2)
FROM year_2016
WHERE year_2016.land_area_sqkm < (
  SELECT difference
  FROM (SELECT (year_2016.forest_area_sqkm - year_1990.forest_area_sqkm)*(-1) as difference
  FROM year_2016
  JOIN year_1990
  ON year_2016.country_code = year_1990.country_code
  WHERE year_2016.country_code = 'WLD'
  LIMIT 1) sub)
  ORDER BY 2 DESC
  LIMIT 1;

/*Output shows this as greater than the entire land area of Peru in 2016 (1.28 million sq km)
PLEASE NOTE: NEITHER TEMPLATE NOR SECTION QUESTIONS ASKS FOR RESULT IN SQ MILES. SQ KM PROVIDED */

/*------2. REGIONAL OUTLOOK------*/
/*Creating table that compares percent forest area across regions for 1990 and 2016*/
WITH regions_1990 AS
(SELECT region,
ROUND(CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100 AS NUMERIC) , 2) AS forest_percentage_1990
FROM forestation
WHERE year = 1990
GROUP BY 1),

regions_2016 AS
(SELECT region,
ROUND(CAST((SUM(forest_area_sqkm)/SUM(land_area_sqkm))*100 AS NUMERIC) , 2) AS forest_percentage_2016
FROM forestation
WHERE year = 2016
GROUP BY 1)

SELECT *,
regions_2016.forest_percentage_2016 - regions_1990.forest_percentage_1990  AS percent_change
FROM regions_1990
INNER JOIN regions_2016
ON regions_1990.region = regions_2016.region
ORDER BY regions_2016.forest_percentage_2016 DESC;
/*output:
world % forest in 2016: 31.38%
region with highest % forest in 2016: Latin America & Caribbean at 46.16%
region with lowest % forestation in 2016: Middle East & North Africa at 2.07%

region with highest % forest in 1990: Latin America & Caribbean at 51.03%
region with lowest % forestation in 1990: Middle East & North Africa at 1.78%

regions with losses:
Latin America & Caribbean from 51.03% to 46.16%
Sub-Saharan Africa from 30.67% to 28.79%
Resulting World losses: 32.42% to 31.38%*/

/*------3. COUNTRY-LEVEL DETAIL------*/
/*first creating views to use for this whole section.*/
CREATE VIEW DIFFERENCE AS
SELECT
country_code,
country_name,
SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END) AS forest_1990,
SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END) AS forest_2016,
ROUND(CAST(SUM(CASE WHEN year=2016 THEN forest_area_sqkm ELSE NULL END) -
SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END) AS NUMERIC),2) AS forest_area_change,
ROUND(CAST(((SUM(case when year=2016 THEN forest_area_sqkm ELSE NULL END) -
SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END))/
SUM(CASE WHEN year=1990 THEN forest_area_sqkm ELSE NULL END))*100 AS NUMERIC),2) AS forest_area_p_change
FROM forestation
WHERE country_code <>'WLD'
AND year IN (1990,2016)
GROUP BY 1,2;

/*SUCCESS STORIES*/
SELECT *
FROM DIFFERENCE
WHERE forest_area_change IS NOT NULL
ORDER BY forest_area_change DESC
LIMIT 5;
/*Output for greatest gains in terms of sq km is China and US, followed by India.*/

SELECT *
FROM DIFFERENCE
WHERE forest_area_change IS NOT NULL
ORDER BY forest_area_p_change DESC
LIMIT 5;
/*Output for greatest gains in terms of % is Iceland.*/

/*LARGEST CONCERNS*/
SELECT *
FROM DIFFERENCE
WHERE forest_area_change IS NOT NULL
ORDER BY forest_area_change ASC
LIMIT 5;

SELECT *
FROM DIFFERENCE
WHERE country_code <> 'WLD' AND forest_area_change IS NOT NULL
ORDER BY forest_area_p_change ASC
LIMIT 5;

/*QUARTILES*/
CREATE VIEW QUARTILES AS
SELECT *,
CASE WHEN percent_forest >.75 THEN 4
WHEN percent_forest >.50 AND percent_forest <=.75 THEN 3
WHEN percent_forest >.25 AND percent_forest <=.50 THEN 2
WHEN percent_forest <=.25 THEN 1
ELSE NULL
END AS quartiles
FROM forestation
WHERE year = 2016 and percent_forest IS NOT NULL AND country_code <> 'WLD'
ORDER BY percent_forest DESC;

SELECT quartiles, COUNT(country_name)
FROM QUARTILES
GROUP BY 1
ORDER BY 2 DESC;

/*countries in quartile 4*/
SELECT country_name, region,
ROUND(CAST((percent_forest*100) AS NUMERIC),2) as "percent forest"
FROM QUARTILES
WHERE quartiles = 4
ORDER BY 3 DESC;



/*Alternate code: would appreciate feedback on which is better (VIEWS or lag code below.
LAG code for LARGEST CONCERNS section*/

SELECT country_name, region,
ROUND(CAST(ABS(forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)) AS NUMERIC),2)
FROM
(SELECT country_name, region, year, forest_area_sqkm
FROM forestation
WHERE year = 1990 OR year = 2016 AND country_code <> 'WLD'
ORDER BY country_name, year) sub
ORDER BY forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year)
LIMIT 5;
/*Output: shows country name, region, (extra columns),
and rounded absolute difference for the 5 countries who lost the most forest sq km from 1990 to 2016.*/

/*finding top 5 countries in terms of percent losses: again using lag instead of two year-based tables*/
SELECT country_name, region,
ROUND(CAST((forest_area_sqkm - LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year))/(LAG(forest_area_sqkm) OVER (PARTITION BY country_name ORDER BY year))*100 AS NUMERIC),2) AS percent_loss
FROM
(SELECT country_name, region, year, forest_area_sqkm
FROM forestation
WHERE year = 1990 OR year = 2016 AND country_code <> 'WLD'
ORDER BY country_name, year DESC) sub
ORDER BY percent_loss
LIMIT 5;
/*Output: shows country name, region and top 5 in terms of % loss:
Togo, Nigeria, Uganda, Mauritania, and Honduras*/

/*3 views combined instead of one giant one*/
CREATE VIEW VIEW_2016 AS
SELECT *, forest_area_sqkm as forest_area_2016
FROM forestation
WHERE year = 2016

CREATE VIEW VIEW_1990 AS
SELECT *, forest_area_sqkm as forest_area_1990
FROM forestation
WHERE year = 1990

CREATE VIEW DIFFERENCES AS
SELECT VIEW_2016.country_code, VIEW_2016.country_name, VIEW_2016.region,
VIEW_1990.forest_area_1990, VIEW_2016.forest_area_2016,
ROUND(CAST(VIEW_2016.forest_area_2016 - VIEW_1990.forest_area_1990 AS NUMERIC), 2) AS forest_area_change,
ABS(ROUND(CAST(VIEW_2016.forest_area_2016 - VIEW_1990.forest_area_1990 AS NUMERIC), 2)) AS forest_area_change_abs,
ROUND(CAST(((VIEW_2016.forest_area_2016 - VIEW_1990.forest_area_1990)/VIEW_1990.forest_area_1990)*100 AS NUMERIC),2) AS forest_area_p_change
FROM VIEW_2016
INNER JOIN VIEW_1990
ON VIEW_2016.country_code = VIEW_1990.country_code;

/*ANSWERING SECTION QUESTION NOT IN REPORT*/
/*How many countries had a percent forestation higher than the United States in 2016?*/
SELECT COUNT(country_name)
FROM forestation
WHERE year = '2016' AND country_code <> 'WLD' AND forest_area_sqkm > (
  SELECT forest_area_sqkm
  FROM forestation
  WHERE year = '2016' AND country_code = 'USA'
)
/*output: 3 countries.*/
