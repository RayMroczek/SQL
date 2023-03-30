CREATE TABLE "employees" (
  id SERIAL,
  emp_name TEXT,
  manager_id INTEGER
);
\d employees;

CREATE TABLE "employee_phones" (
  emp_id INTEGER,
  phone_number TEXT
);

\d employee_phones

/* you can hit tab twice to finish text*/

CREATE TABLE "employees" (
  "id" SERIAL,
  "name" TEXT,
  "salary" SMALLINT
);

INSERT INTO "employees" ("name") ("salary")
VALUES ('Alice', 25000), ('Bob', 22000);

/* to check it out:*/
TABLE employees;
/* you'll see that the ID was automatically generated; postgres did this.*/

/* casting one type as another - here text (in '' cast as numeric) */
SELECT '1.1'::NUMERIC + '1.2'::NUMERIC;
SELECT 1.1::REAL + 1.2::REAL;
/*if you need really huge numbers or need really exact numbers, don't use REAL.*/

/* character variables */
/*text and varchar without classifying n are most common, and are basically
interchangeable. text may be better for large blocks of text just for your
own awareness, and varchar for something smaller or limited.
you don't gain real efficiencies by using the limited options */

CREATE TABLE "employees" (
  "id" SERIAL,
  "badge_id" CHAR(6),
  "username" VARCHAR(30),
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "biography" TEXT
)

/* Date and Time Zone variables*/
SHOW TIMEZONE;
SELECT CURRENT_TIMESTAMP;
SET TIMEZONE='America/Los_Angeles';

/*timestamp without time zone is the default option which is UTC*/
CREATE TABLE "zones" (
  "t1" TIMESTAMP, --default
  "t2" TIMESTAMP WITH TIME ZONE
)

INSERT INTO "zones" VALUES
('2020-04-19 16:00:00-04', '2020-04-19 16:00:00-04')
/*the first one will be stored without time zone, the second will.*/

SET TIMEZONE='Etc/UTC'
/*time zone without time stamp is a time independent of where you are*/
SELECT CURRENT_DATE;
SELECT CURRENT_TIMESTAMP::DATE; --will cast the timestamp as a date

/*other variable types - JSON */
CREATE TABLE "json_test" (
  "val" JSONB
);

INSERT INTO "json_test" VALUES
({"name": "Alice", "age": 30}),
({"name": "Bob", "language": "English"});

SELECT "val" ->> 'name' FROM "json_test";
SELECT "val" FROM "json_test" WHERE "val" ->> 'name' = 'Alice';

CREATE TABLE "rooms" (
  "room" SMALLINT,
  "floor" SMALLINT,
  "sq_feet" SMALLINT
);

CREATE TABLE "customers" (
  "id" SERIAL,
  "first_name" VARCHAR,
  "last_name" VARCHAR,
  "phone_number" VARCHAR
);


CREATE TABLE "customer_emails" (
  "customer_id" NUMERIC,
  "email_address" VARCHAR
);

/*serial are integers under the hood*/
CREATE TABLE "reservations" (
  "id" SERIAL,
  "room" INTEGER,
  "customer_id" INTEGER,
  "check_in_date" DATE,
  "check_out_date" DATE
);

/*altering tables - VERY DANGEROUS */

CREATE TABLE "users" (
  "id" SERIAL,
  "first_name" VARCHAR(20),
  "last_name" VARCHAR(20),
  "nickname" VARCHAR(20)
);

ALTER TABLE "users" ADD COLUMN "email" VARCHAR;
ALTER TABLE "users" ALTER COLUMN "first_name" SET DATA TYPE VARCHAR;
ALTER TABLE "users" ALTER COLUMN "last_name" SET DATA TYPE VARCHAR;
ALTER TABLE "users" DROP COLUMN "nickname"
\d users

/*ctrl + L to clear screen*/
/* changes will take longer based on how much data you have*/

ALTER TABLE "students" ALTER COLUMN "email_address" SET DATA TYPE VARCHAR;
ALTER TABLE "courses" ALTER COLUMN "rating" SET DATA TYPE NUMERIC;
ALTER TABLE "registrations" ALTER COLUMN "student_id" SET DATA TYPE INTEGER;
ALTER TABLE "registrations" ALTER COLUMN "course_id" SET DATA TYPE INTEGER;

/*just explore a table, instead of SELECT * FROM students*/
TABLE students

/*other commands of great dangerz*/

DROP TABLE "tablename";

CREATE TABLE "demo" (
  "id" SERIAL,
  "name" VARCHAR
);

INSERT INTO "demo" ("name") VALUES ('ALICE'), ('Bob');
TABLE demo
TRUNCATE TABLE "demo";
/*all data was removed from demo - structure is still there though!*/
/*if you reinsert the data, the IDs will not reset but will continue from last value.*/
INSERT INTO "demo" ("name") VALUES ('ALICE'), ('Bob');
TABLE demo
/*if you want to reset...*/
TRUNCATE TABLE "demo" RESTART IDENTITY;

/*commenting*/
COMMENT ON COLUMN "tablename" ."columnname" IS 'first and last name';
\d+ tablename
/*that will give you a little more information about the table including comments.
