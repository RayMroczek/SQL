/* constraints*/
/* constrain a column to only accept unique values*/

CREATE TABLE users (
  id SERIAL,
  username VARCHAR
);

ALTER TABLE users ADD UNIQUE (username);
\d users
/* you can see what constraints are present when describing the table.
they will have names, either assigned or not. You can drop them this way: */
ALTER TABLE users DROP CONSTRAINT "users_username_key"

/*you can also name your constraints:*/
ALTER TABLE users ADD CONSTRAINT "unique_usernames" UNIQUE (username);

/* you can create your constraints at the same time as you make your table*/

CREATE TABLE users (
  id SERIAL,
  username VARCHAR UNIQUE
);
--alternative syntax
CREATE TABLE users (
  id SERIAL,
  username VARCHAR,
  UNIQUE (username)
);

--my favorite
CREATE TABLE users (
  id SERIAL,
  username VARCHAR,
  CONSTRAINT "unique_usernames" UNIQUE (username)
);

/* create a unique constraint that takes into account combinations */
/*this will ensure that for a given game, there are no recurring ranks*/
CREATE TABLE leaderboards (
  game_id INTEGER,
  player_id INTEGER,
  rank SMALLINT,
  UNIQUE (game_id, rank)
);

/*primary key constraints*/

CREATE TABLE users (
  id SERIAL,
  username VARCHAR UNIQUE
);

\d users

/*you can corrupt your unique username:*/
INSERT INTO users (id, username) values
(1, 'user1'),
(1, 'user2');

/*you can add a unique constraint onto your id column*/
ALTER TABLE users ADD UNIQUE (id);
/*but this will allow nulls...*/
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR UNIQUE NOT NULL
)
/*primary keys are special because there can only be one per table*/
/*primary key ensures it is unique and not null.*/
/*other ways to write this */
CREATE TABLE users (
  id SERIAL,
  username VARCHAR,
  PRIMARY KEY (id),
  UNIQUE NOT NULL (username)
);

CREATE TABLE users (
  id SERIAL,
  username VARCHAR,
  CONSTRAINT "constraint_name1" PRIMARY KEY (id),
  CONSTRAINT "constraint_name2" UNIQUE NOT NULL (username)
);

/*quiz*/

ALTER TABLE books ADD CONSTRAINT unique_book_id UNIQUE NOT NULL id;
ALTER TABLE books DROP CONSTRAINT unique_book_id;

ALTER TABLE "books" ADD PRIMARY KEY ("id");

ALTER TABLE "books" ADD UNIQUE ("isbn");

ALTER TABLE "authors" ADD PRIMARY KEY ("id");

ALTER TABLE "authors" ADD UNIQUE ("email_address");

/*composite constraint*/
ALTER TABLE "book_authors" ADD PRIMARY KEY ("book_id", "author_id");

ALTER TABLE "book_authors" ADD UNIQUE ("book_id", "contribution_rank");

/*foreign key constraints - so that the values of one table restrict the
values of another table for a certain column*/

/*foreign key is the type of constraint*/
ALTER TABLE comments
ADD FOREIGN KEY (user_id) REFERENCES users (id);
/*this constraint will not work if there's something in one table that breaks
the rule you're trying to set up. */
ALTER TABLE comments
ADD FOREIGN KEY (user_id) REFERENCES users;
/*Also, when you reference a table and don't
provide a set of columns, your database will assume you're referencing the primary key.*/

CREATE TABLE comment_likes (
  user_id INTEGER REFERENCES users (id), --way 1
  comment_id INTEGER,
  FOREIGN KEY (comment_id) REFERENCES comments (id) -- way 2
)

/* modifiers to foreign key constraints */
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users (id) ON DELETE CASCADE, -- this will delete all comments when original post is deleted.
  content TEXT
)

INSERT INTO comments (user_id, content) VALUES (1, 'hello');
SELECT * FROM comments;
DELETE FROM users WHERE id = 1;
/*this will delete all rows in the comments table that were from user id = 1.*/
/* if you don't specify delete cascade, it is automatically using delete restrict.*/

/*new modifier for foreign keys:
when user 2 is deleted in the main users table,
instead of deleting the comments associated with user 2,
the user_id column in the comments table will be set to NULL.*/

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users (id) ON DELETE SET NULL, -- this will delete all comments when original post is deleted.
  content TEXT
)

/*quiz*/
--first explore.
\d;
\d+ employee_projects; -- employee_id, project_id; compound constraint on emp + project IDs
\d+ employees; -- id (constraint as primary key), name, manager_id
\d+ projects; -- id (constraint as primary key), name

--1. rules that should be in place: if a manager gets deleted, the employee should stay in the system with null manager
--2. can't delete an employee who still has projects
--3. when a project is deleted, we don't need to keep track of who was working on it.

ALTER TABLE employees
ADD CONSTRAINT "valid_manager"
FOREIGN KEY manager_id references employees (id) ON DELETE SET NULL;

ALTER TABLE employee
ADD CONSTRAINT "keep_emps_with_projects"
FOREIGN KEY id REFERENCES employee_projects (employee_id) ON DELETE RESTRICT;

ALTER TABLE employee_projects
ADD CONSTRAINT "valid_project"
FOREIGN KEY project_id REFERENCES projects (id) ON DELETE CASCADE;

/* Custom or Check Constraints */

CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  quantity INTEGER
);

INSERT INTO items (name, quantity) VALUES ('widget', -1);

ALTER TABLE items
   ADD CONSTRAINT non_negative_quantity CHECK (quantity > 0);

/* you won't be able to do this constraint because it's violated by the data in there*/

TRUNCATE TABLE items;

/*not null in the table creation will mean you can't assign a null value to something: */
INSERT INTO items (name, quantity) VALUES (NULL, 1) -- won't work but
INSERT INTO items (name, quantity) VALUES ('', 1) --will work.

ALTER TABLE items
  ADD CONSTRAINT item_must_have_name CHECK (LENGTH(name) > 0); --fixes this for the most part.

ALTER TABLE items DROP CONSTRAINT item_must_have_name;

ALTER TABLE items
  ADD CONSTRAINT item_must_have_name
  CHECK (LENGTH(TRIM(name))>0); --constraint removes white spaces from begining and end so you can't have 3 spaces as name.

/*if your constraint is not named, it will be fine and will look like:*/
ALTER TABLE items
CHECK (quantity > 0);


ALTER TABLE "users"
  ADD CONSTRAINT "users_must_be_over_18" CHECK (
    CURRENT_TIMESTAMP - "date_of_birth" > INTERVAL '18 years'
  );

/*final quiz*/

\d;
\d books; -- id needs to be primary key, isbn should be unique?

ALTER TABLE books ADD PRIMARY KEY (id);
ALTER TABLE books ADD UNIQUE (isbn);

--ANSWER--
ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");

\d user_book_preferences; -- user id needs to be primary key.
--user id + book id needs to be unique.
--preference needs to be non-repeating for id + book.

ALTER TABLE user_book_preferences ADD PRIMARY KEY (user_id);
ALTER TABLE user_book_preferences ADD UNIQUE (user_id, book_id);

--ANSWER--
ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id");

--Q: how can I ensure non-repeating for???

\d users; -- id is primary key; username cannot be null.

ALTER TABLE users ADD PRIMARY KEY (id);

--answer--
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");

--ALTER TABLE USERS ADD UNIQUE NOT NULL (username); ???

/*foreign constraints, or maintaining referential integrity*/

/* book preferences can't reference book not in system*/
ALTER TABLE user_book_preferences
ADD FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE;

ALTER TABLE user_book_preferences
ADD FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

--ANSWER -
ALTER TABLE "user_book_preferences"
  ADD FOREIGN KEY ("user_id") REFERENCES "users",
  ADD FOREIGN KEY ("book_id") REFERENCES "books";

/*additional constraints*/
ALTER TABLE users
  ADD CONSTRAINT username_min5char CHECK (LEN(TRIM(username))>=5); -- min 5 char length

ALTER TABLE books
  ADD CONSTRAINT valid_book_name CHECK (LEN(TRIM(name))>0); --book name not empty

UPDATE TABLE books SET name = (LEFT(name,1) || SUBSTR(name),2); -- book name capitalized
-- this is redoing data in the system, but to make it a constraint? ANSWER:
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);
--remember you can check these using inserts after you alter the table to make sure it works.
-- how to make sure book preferences for users are unique?
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preference");


--FULL SOLUTION--
-- Primary and unique keys
ALTER TABLE "users"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("username"),
  ADD UNIQUE ("email");

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn");

ALTER TABLE "user_book_preferences"
  ADD PRIMARY KEY ("user_id", "book_id");


-- Foreign keys
ALTER TABLE "user_book_preferences"
  ADD FOREIGN KEY ("user_id") REFERENCES "users",
  ADD FOREIGN KEY ("book_id") REFERENCES "books";


-- Usernames need to have a minimum of 5 characters
ALTER TABLE "users" ADD CHECK (LENGTH("username") >= 5);


-- A book's name cannot be empty
ALTER TABLE "books" ADD CHECK(LENGTH(TRIM("name")) > 0);


-- A book's name must start with a capital letter
ALTER TABLE "books" ADD CHECK (
  SUBSTR("name", 1, 1) = UPPER(SUBSTR("name", 1, 1))
);


-- A user's book preferences have to be distinct
ALTER TABLE "user_book_preferences" ADD UNIQUE ("user_id", "preference");
