Postress_Lesson3
INSERT INTO "movies" ("name", "release_date") VALUES
('Episode 5', '1977-05-25'),
('Episode 6', '1980-05-17');

INSERT INTO "movies" VALUES
(DEFAULT, 'Episode 5', '1977-05-25');

\dt
\d posts
SELECT * FROM posts
SELECT DISTINCT "category" FROM "posts"

/* create an empty table, then fill it with data based on SELECT */

CREATE TABLE "categories" (
  "id", SERIAL,
  "name", VARCHAR,
);

INSERT INTO "categories" ("name")
SELECT DISTINCT "category" FROM "posts"
);

/*quiz*/

SELECT * FROM denormalized_people LIMIT 10;

/*inserting first and last name into a table that also has a serial id column*/

INSERT INTO people ("first_name", "last_name")
SELECT "first_name", "last_name" FROM denormalized_people;

/*splitting emails out by comma*/
/*this creates a table with emails split out into individual rows*/

SELECT
first_name, last_name,
REGEXP_SPLIT_TO_TABLE (emails, ',')
FROM denormalized_people
LIMIT 10;

/*now I need to figure out how to get this information into the emails table,
and then merge in the serial IDs from the normal people table*/
/*check your data first - is this select statement getting you what you want?*/
SELECT people.id, REGEXP_SPLIT_TO_TABLE (denormalized_people.emails, ',')
FROM people
JOIN denormalized_people
ON (people.first_name = denormalized_people.first_name AND people.last_name = denormalized_people.last_name)
LIMIT 10;

/*yes, so then let's insert it into people_emails*/
INSERT INTO people_emails ("person_id", "email_address")
SELECT people.id, REGEXP_SPLIT_TO_TABLE (denormalized_people.emails, ',')
FROM people
JOIN denormalized_people
ON (people.first_name = denormalized_people.first_name AND people.last_name = denormalized_people.last_name);
/*check your work*/
SELECT * FROM people_emails LIMIT 10;

INSERT INTO people_emails
SELECT first_name, last_name,
REGEXP_SPLIT_TO_TABLE (emails, ',')
FROM denormalized_people;

JOIN people_emails
ON people.first_name

/*updating data (up to this point you've been inserting)*/

UPDATE "table" SET "columnname" = 'string' WHERE "other_column" < 33;
UPDATE "table"  SET "columnname" = 'string'
WHERE "other_column" BETWEEN 33 AND 65; -- inclusive of 33 and 65
UPDATE "table" SET "columnname" = 'string' WHERE "other_column" >=66;

/*without WHERE it will just update all rows - the example below
will change values for all rows for these two columns:*/
UPDATE "table" SET "columnname" = 'string', "other_column" = 100;

/*altering table to add in a column*/
ALTER TABLE posts ADD COLUMN category_id INTEGER;
/*bringing in ids to that new column that are the right ids for the category
by using a sub-select or subquery*/
UPDATE posts SET category_id = (
  SELECT id
  FROM categories
  WHERE categories.name = posts.category);

  /*now we can drop the text category column*/
  ALTER TABLE posts DROP COLUMN category;

  /*quiz - transform all upper case to lower case with first letter cap*/
  SELECT CONCAT(LEFT(last_name,1), SUBSTR(LOWER(last_name),2))
  FROM people
  LIMIT 10;

  UPDATE people SET last_name = (CONCAT(LEFT(last_name,1), SUBSTR(LOWER(last_name),2)));

  -- Update the last_name column to be capitalized (other option)
  UPDATE "people" SET "last_name" =
    SUBSTR("last_name", 1, 1) ||
    LOWER(SUBSTR("last_name", 2));
  /*quiz - create a date column, use info to update it, and delete an old column*/
/* 55 years 22 d.... is an INTERVAL data type*/
ALTER TABLE people ADD COLUMN date_of_birth DATE;
SELECT (CURRENT_TIMESTAMP - born_ago::INTERVAL)::DATE FROM people LIMIT 10;
UPDATE people SET date_of_birth = (CURRENT_TIMESTAMP - born_ago::INTERVAL)::DATE;
SELECT * FROM PEOPLE LIMIT 10;
ALTER TABLE people DROP COLUMN born_ago;



-- Change the born_ago column to date_of_birth
ALTER TABLE "people" ADD column "date_of_birth" DATE;

UPDATE "people" SET "date_of_birth" =
  (CURRENT_TIMESTAMP - "born_ago"::INTERVAL)::DATE;

ALTER TABLE "people" DROP COLUMN "born_ago";

/*deleting: first run a select, and then delete if that looks right*/
SELECT * FROM users WHERE state = 'NY';
DELETE FROM users WHERE sate = 'NY';
/*extra nonsense*/
SELECT CURRENT_TIMESTAMP - date_of_birth FROM users;
/* timestamp minus a date returns a number of days, followed by hours and seconds that kind of looks like an interval
but what is it?*/
SELECT pg_typeof(CURRENT_TIMESTAMP - date_of_birth) FROM users;
/*it's intervals*/
/* the following code compares two things and returns boolean T or F statement*/
SELECT
(CURRENT_TIMESTAMP - date_of_birth) < INTERVAL '21 years'
FROM users;
/*we can use this to delete certain people from the table, where the conditional statement = True*/
DELETE FROM users WHERE
(CURRENT_TIMESTAMP - date_of_birth) < INTERVAL '21 years';

/*just delete all data:*/
DELETE FROM users;

\set AUTOCOMMIT OFF


/*quiz*/
BEGIN;
DELETE FROM user_data WHERE state IN ('NY', 'CA');
ALTER TABLE user_data
  ADD COLUMN first_name VARCHAR,
  ADD COLUMN last_name VARCHAR;

UPDATE TABLE user_data
  first_name = SPLIT_PART(name, " ", 1),
  last_name = SPLIT_PART(name, " ", 2);

ALTER TABLE user_data
  DROP COLUMN name;

CREATE TABLE states (
  id SERIAL,
  state VARCHAR(2)
);

INSERT INTO states (state)
  SELECT DISTINCT state FROM user_data;

ALTER TABLE user_data
  ADD COLUMN state_id SMALLINT;

INSERT INTO user_data (state_id)
SELECT



-- Do everything in a transaction
BEGIN;


-- Remove all users from New York and California
DELETE FROM "user_data" WHERE "state" IN ('NY', 'CA');

-- Split the name column in first_name and last_name
ALTER TABLE "user_data"
  ADD COLUMN "first_name" VARCHAR,
  ADD COLUMN "last_name" VARCHAR;

UPDATE "user_data" SET
  "first_name" = SPLIT_PART("name", ' ', 1),
  "last_name" = SPLIT_PART("name", ' ', 2);

ALTER TABLE "user_data" DROP COLUMN "name";

/* moving states out into their own table and then adding ids back in to user*/
CREATE TABLE states (
  id SMALLSERIAL,
  state CHAR(2)
);

INSERT INTO states (state)
  SELECT DISTINCT state FROM user_data;

ALTER TABLE user_data ADD COLUMN state_id SMALLINT;

UPDATE user_data SET state_id = (
  SELECT states.id
  FROM states
  WHERE states.state = user_data.state
);

ALTER TABLE user_data DROP COLUMN state;
