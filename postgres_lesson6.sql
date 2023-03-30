/*postgres Lesson 6*/
\ timing on -- will measure time to execute queries

/* create an index based on last name in a phone book: */

CREATE INDEX ON "phonebook_1000000" ("last_name");
/* you don't have to use alter table - they are attached to a table
but are global to your database*/

/* regex replace in postgres: replace some characters in a string with other characters.*/
/*here it's removing everything that isn't a number*/
SELECT phone_number, REGEX_REPLACE(phone_number, '[^0-9]+', '', 'g')
FROM phonebook_1000000;

/*reverse search*/
SELECT * FROM phonebook_1000000 WHERE
REGEX_REPLACE(phone_number, '[^0-9]+', '', 'g') = '14785470433'
FROM phonebook_1000000;
/* searching on an expression that contains the phone number column -- we con
create indeces on expressions*/
CREATE INDEX reverse_phone_search ON phonebook_1000000 ( --named index
  REGEX_REPLACE(phone_number, '[^0-9]+', '', 'g')
);

/*indeces can also be useful for doing case-insensitive searches*/
CREATE INDEX lower_last_name ON phonebook_1000000 (
  LOWER(last_name)
);

\d phonebook_1000000 --shows indeces

DROP INDEX lower_last_name; -- remove things you don't need cuz it takes up space!

/* pattern matching indeces*/
/*if you were to run this query after building your index, you'd see it wasn't using it
based on the amount of time it took.*/
SELECT * FROM phonebook_1000000 WHERE last_name LIKE 'Ziem%';
/* in order to do that, you have to use keyword VARCHAR_PATTERN_OPS
so that you can use the index to do equality or like operations.*/
CREATE INDEX ON phonebook_1000000 (last_name, VARCHAR_PATTERN_OPS);

/* compound indeces */

CREATE INDEX ON phonebook_1000000 (last_name, first_name);

/* UNIQUE INDECES*/
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR
);

CREATE UNIQUE INDEX ON users (LOWER(username)); -- won't let you sign up both Bob and bob

/*quiz answers*/
- Constraints
ALTER TABLE "authors"
  ADD PRIMARY KEY ("id");

ALTER TABLE "topics"
  ADD PRIMARY KEY("id"),
  ADD UNIQUE ("name"),
  ALTER COLUMN "name" SET NOT NULL;

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn"),
  ADD FOREIGN KEY ("author_id") REFERENCES "authors" ("id");

ALTER TABLE "book_topics"
  ADD PRIMARY KEY ("book_id", "topic_id");
-- or ("topic_id", "book_id") instead...?

-- We need to be able to quickly find books and authors by their IDs.
-- Already taken care of by primary keys

-- We need to be able to quickly tell which books an author has written.
CREATE INDEX "find_books_by_author" ON "books" ("author_id");

-- We need to be able to quickly find a book by its ISBN #.
-- The unique constraint on ISBN already takes care of that
--   by adding a unique index

-- We need to be able to quickly search for books by their titles
--   in a case-insensitive way, even if the title is partial. For example,
--   searching for "the" should return "The Lord of the rings".
CREATE INDEX "find_books_by_partial_title" ON "books" (
  LOWER("title") VARCHAR_PATTERN_OPS
);

-- For a given book, we need to be able to quickly find all the topics
--   associated with it.
-- The primary key on the book_topics table already takes care of that
--   since there's an underlying unique index

-- For a given topic, we need to be able to quickly find all the books
--   tagged with it.
CREATE INDEX "find_books_by_topic" ON "book_topics" ("topic_id");


/* explain tells you the query plan that postgres will do once it starts executing*/

EXPLAIN SELECT * FROM table1;

/*just an extra on how to generate a table of data*/
CREATE TABLE "samebook" AS
  SELECT
  generate_series (1, 1000000) id,
  'John'::varchar first_name,
  'Smith'::varchar last_name;

  /* explain analyze -- shows actual query results; whereas explain is best guess */

  EXPLAIN ANALYZE SELECT * FROM table1;

  /*quiz*/
/*A movie has a title and a description, and zero or more categories associated to it
A category is just a name, but that name has to be unique
Users can register to the system to rate movies:
A user's username has to be unique in a case-insensitive way. For instance, if a user registers with the username "Bob", then nobody can register with "bob" nor "BOB"
A user can only rate a movie once, and the rating is an integer between 0 and 100, inclusive
In addition to rating movies, users can also "like" categories.*/

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  movie VARCHAR, -- you might consider adding a limit, to limit abuse (like 1 gig of data in one row/column)
  description TEXT,
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE -- added limit to limit abuse
)
--remember serial = integer
CREATE TABLE movie_categories (
  movie_id INTEGER REFERENCES movies (id) ON DELETE CASCADE,
  category_id INTEGER REFERENCES categories (id),
  PRIMARY KEY (movie_id, category_id) --can be included instead of needing to alter table
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE -- specify var type then specify unique, etc.
);

CREATE UNIQUE INDEX ON users (LOWER(username)); -- expression index

CREATE TABLE user_ratings (
  --id SERIAL,
  user_id INTEGER REFERENCES users, -- foreign references in line, no need to reference primary key
  movie_id INTEGER REFERENCES movies,
  user_rating SMALLINT CHECK (rating BETWEEN 0 and 100),
  UNIQUE (user_id, movie_id) -- ***under the hood, this will create an index for a given user, what movies did they rate
);

CREATE INDEX user_movie_ratings ON user_ratings (movie_id); -- search based on movie_id alone.


CREATE TABLE user_likes (
    user_id INTEGER REFERENCES users (id) ON DELETE CASCADE,
    category_id REFERENCES categories
    PRIMARY KEY (user_id, category_id) -- under hood = index
)

CREATE INDEX user_category_likes ON user_likes (category_id);

--how can I create a rule around what values user_rating can take?
ALTER TABLE user_ratings
   ADD CONSTRAINT valid_rating CHECK (user_rating >= 0 AND user_rating <=100);
--or inline as above: user_rating SMALLINT CHECK (rating BETWEEN 0 and 100)

--how can I create a like or dislike column?

/*The following queries need to execute quickly and efficiently. The database will contain ~6 million movies:
Finding a movie by partially searching its name
Finding a user by their username
For a given user, find all the categories they like and movies they rated
For a given movie, find all the users who rated it
For a given category, find all the users who like it*/
--part two------

CREATE INDEX find_movies_by_partial_title ON movies (
  LOWER(movie) VARCHAR_PATTERN_OPS
);
