/*Guideline #1: here is a list of features and specifications that Udiddit needs in order to support its website and administrative interface:
Allow new users to register:
Each username has to be unique
Usernames can be composed of at most 25 characters
Usernames can’t be empty
We won’t worry about user passwords for this project*/


CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(25) UNIQUE NOT NULL,
  -- to users who haven't logged in in the last year:
  last_login DATE,
  CONSTRAINT valid_username CHECK (LENGTH(TRIM(username)) > 0)
);

--NOT NEEDED (from feedback, unique automatically generates index): CREATE UNIQUE INDEX ON users (LOWER(username)); -- to prevent 'Bob' and 'bob'
CREATE INDEX last_login_index ON users (last_login); --to speed up date searches
CREATE INDEX user_inded ON users (username); --to speed up finding a user by username

--INSERT INTO users (username) VALUES ('abcdefghijklmnopqrstuvwxyz'); --checking length constraint (checked)
--INSERT INTO users (username) VALUES ('Bob'), ('bob'); --checking case sensitivity (checked)

/*Topic names have to be unique.
The topic’s name is at most 30 characters
The topic’s name can’t be empty
Topics can have an optional description of at most 500 characters.*/

CREATE TABLE topics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(30) UNIQUE NOT NULL,
  description VARCHAR(500),
  -- preventing spaces as name:
  CONSTRAINT valid_name CHECK (LENGTH(TRIM(name))>0)
);

--NOT NEEDED (from feedback: unique automatically creates index): CREATE INDEX topic_name_index ON topics (name);

/*Allow registered users to create new posts on existing topics:
Posts have a required title of at most 100 characters
The title of a post can’t be empty.
Posts should contain either a URL or a text content, but not both.
If a topic gets deleted, all the posts associated with it should be automatically deleted too.
If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.*/

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(500) NOT NULL, --post titles do not need ot be unique
  url VARCHAR(500),
  text_content VARCHAR,
  topic_id INTEGER REFERENCES topics (id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users (id) ON DELETE SET NULL,
  --to find latest posts and latest posts by a given user:
  post_date DATE,
  --either URL or text:
  CONSTRAINT url_or_text CHECK (url IS NULL OR text_content IS NULL),
  --preventing spaces as title:
  CONSTRAINT valid_title CHECK (LENGTH(TRIM(title))>0)
);

CREATE INDEX user_posts_index ON posts (user_id); --speed up finding posts by a certain user
CREATE INDEX post_date_index ON posts (post_date); --speed up finding recent posts
CREATE INDEX post_url_index ON posts (url); --speed up specific URL searches
CREATE INDEX post_user_date_index ON posts (user_id, post_date); -- speed up searches for latest posts by a specific user
CREATE INDEX post_topic_date_index ON posts (topic_id, post_date); -- speed up searchest for most recent posts for a given topic

--INSERT INTO posts (url) VALUES ('text'); -- checking title requirement (checked)
--INSERT INTO posts (title, url, text_content) VALUES ('title','text', 'text'); --checking url_or_text constraint. (checked)

/*Allow registered users to comment on existing posts:
A comment’s text content can’t be empty.
Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
If a post gets deleted, all comments associated with it should be automatically deleted too.
If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.
If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too.*/

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  comment_text VARCHAR NOT NULL,
  post_id INTEGER NOT NULL REFERENCES posts ON DELETE CASCADE,
  parent_id INTEGER REFERENCES comments (id) ON DELETE CASCADE,
  comment_date DATE, --to find latest posts by a given user
  --referenced https://knowledge.udacity.com/questions/285776
  user_id INTEGER REFERENCES users ON DELETE SET NULL
);

CREATE INDEX comments_post_id ON comments (post_id); --to speed up searches for top-level comments
CREATE INDEX comments_parent_id ON comments (parent_id);--to speed up searches for top-level comments and direct children comments
CREATE INDEX comment_date_index ON comments (user_id, comment_date); --to speed up searches for recent comments by a given user

/*Make sure that a given user can only vote once on a given post:
Hint: you can store the (up/down) value of the vote as the values 1 and -1 respectively.
If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
If a post gets deleted, then all the votes for that post should be automatically deleted too.*/

CREATE TABLE votes (
  id SERIAL,
  user_id INTEGER REFERENCES users ON DELETE SET NULL,
  post_id INTEGER REFERENCES posts ON DELETE CASCADE,
  vote SMALLINT NOT NULL,
  CONSTRAINT valid_vote CHECK (vote = 1 OR vote = -1),
  PRIMARY KEY (id, user_id) -- only one vote per user per post
);

/*NEW, 2nd submission*/
CREATE INDEX votes_index ON votes (vote); -- speed up summary functions


/*MIGRATING DATA */

/*Topic descriptions can all be empty
Since the bad_comments table doesn’t have the threading feature, you can migrate all comments as top-level comments, i.e. without a parent
You can use the Postgres string function regexp_split_to_table to unwind the comma-separated votes values into separate rows
Don’t forget that some users only vote or comment, and haven’t created any posts. You’ll have to create those users too.
The order of your migrations matter! For example, since posts depend on users and topics, you’ll have to migrate the latter first.
Tip: You can start by running only SELECTs to fine-tune your queries, and use a LIMIT to avoid large data sets. Once you know you have the correct query, you can then run your full INSERT...SELECT query.
NOTE: The data in your SQL Workspace contains thousands of posts and comments. The DML queries may take at least 10-15 seconds to run.*/

/*user table will require a join of all users who created posts or commented*/
INSERT INTO users (username)
SELECT username FROM bad_posts
UNION
SELECT regexp_split_to_table(upvotes,',') FROM bad_posts
UNION
SELECT regexp_split_to_table(downvotes, ',') FROM bad_posts
UNION
SELECT username FROM bad_comments;


/*topics table, no descriptions*/
INSERT INTO topics (name)
SELECT DISTINCT topic FROM bad_posts;

/*posts table*/
INSERT INTO posts (id, title, url, text_content, topic_id, user_id)
SELECT bad_posts.id,  bad_posts.title, bad_posts.url, bad_posts.text_content, topics.id as topic_id, users.id as user_id
FROM bad_posts
JOIN topics
ON bad_posts.topic = topics.name
JOIN users
ON bad_posts.username = users.username;

/*comments table*/
INSERT INTO comments (id, comment_text, post_id, user_id)
SELECT bad_comments.id, bad_comments.text_content, bad_comments.post_id, users.id
FROM bad_comments
JOIN users
ON bad_comments.username = users.username;


/*votes table*/
INSERT INTO votes (user_id, post_id, vote)

SELECT users.id as user_id, posts.id as post_id, -1 AS down_vote
FROM (SELECT REGEXP_SPLIT_TO_TABLE(downvotes, ',') AS username
FROM bad_posts
) t1
JOIN users
ON users.username = t1.username
JOIN posts
ON posts.user_id = users.id

UNION

SELECT users.id as user_id, posts.id as post_id, 1 AS down_vote
FROM (SELECT REGEXP_SPLIT_TO_TABLE(upvotes, ',') AS username
FROM bad_posts
) t1
JOIN users
ON users.username = t1.username
JOIN posts
ON posts.user_id = users.id
--referenced https://knowledge.udacity.com/questions/425750

/*taking a final look at the migrated data*/
SELECT * FROM votes LIMIT 10;
SELECT * FROM comments LIMIT 10;
SELECT * FROM topics LIMIT 10;
SELECT * FROM users LIMIT 10;
SELECT * FROM posts LIMIT 10;
