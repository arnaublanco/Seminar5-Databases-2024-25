-- Drop the schema if it exists to start fresh
DROP SCHEMA IF EXISTS SocialMediaApplication;

-- Create the schema and use it
CREATE SCHEMA SocialMediaApplication;
USE SocialMediaApplication;

-- Exercise 1: Create Users and Posts tables, insert initial data

-- Create Users table
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL
);

-- Insert data into Users table
INSERT INTO Users (id, username, email, join_date) VALUES
(1, 'Teacher', 'Teacher@mail.com', '2024-09-26');

-- Create Posts table
CREATE TABLE Posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    post_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- Insert data into Posts table
INSERT INTO Posts (id, user_id, content, post_date) VALUES
(1, 1, 'Welcome to SQL Seminar', '2024-11-10');

-- Exercise 2: Add user and create Likes table with data

-- Insert a new user "John"
INSERT INTO Users (id, username, email, join_date) VALUES
(2, 'John', 'john@example.com', '2024-11-10');

-- Create Likes table
CREATE TABLE Likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES Posts(id),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- Insert like for John's like on Teacher's post
INSERT INTO Likes (id, post_id, user_id) VALUES
(1, 1, 2);

-- Exercise 3: Update email, insert additional users and posts, and create Comments table

-- Update Teacher's email
-- SET SQL_SAFE_UPDATES = 0; -- you may need this if safe updates is off
UPDATE Users SET email = 'teacher@example.com' WHERE id = 1;

-- Insert additional Users and Posts data
INSERT INTO Users (id, username, email, join_date) VALUES
(3, 'Alice', 'alice@example.com', '2024-11-11'),
(4, 'Bob', 'bob@example.com', '2024-11-11'),
(5, 'Mallory', 'mallory@example.com', '2024-11-12'),
(6, 'Janice', 'janice@example.com', '2024-11-13');

INSERT INTO Posts (id, user_id, content, post_date) VALUES
(2, 2, 'I’m loving it.', '2023-11-10'),
(3, 2, 'Looking forward to the seminar!!!', '2023-11-10'),
(4, 5, 'Seminar 3 was tough!', '2023-11-12');

-- Create Comments table
CREATE TABLE Comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment TEXT,
    comment_date DATE,
    FOREIGN KEY (post_id) REFERENCES Posts(id),
    FOREIGN KEY (user_id) REFERENCES Users(id)
);

-- Insert Comments data
INSERT INTO Comments (id, post_id, user_id, comment, comment_date) VALUES
(1, 3, 3, 'Me too! :)', '2024-11-11'),
(2, 4, 2, 'Nah', '2024-11-12'),
(3, 4, 4, 'Oh it was', '2024-11-12'),
(4, 4, 1, 'Let me know if you have any doubts', '2024-11-13'),
(5, 2, 5, 'McDonald’s?', '2024-11-13');

-- Exercise 4: Define foreign keys and create Followers table

-- Foreign keys for Posts, Likes, and Comments tables are already defined above

-- Create Followers table
CREATE TABLE Followers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT,
    following_id INT,
    FOREIGN KEY (follower_id) REFERENCES Users(id),
    FOREIGN KEY (following_id) REFERENCES Users(id)
);

-- Insert followers data
INSERT INTO Followers (follower_id, following_id) VALUES
    (1, 3),  -- Teacher follows Alice
    (3, 1),  -- Alice follows Teacher
    (1, 4),  -- Teacher follows Bob
    (4, 3),  -- Bob follows Alice
    (4, 5),  -- Bob follows Mallory
    (5, 4),  -- Mallory follows Bob
    (5, 6),  -- Mallory follows John
    (3, 6),  -- Alice follows John
    (1, 5),  -- Teacher follows Mallory
    (1, 6),  -- Teacher follows John
    (6, 1);  -- John follows Teacher

-- Exercise 5: Queries for specific data

-- 5.1 Find the post with the most likes
SELECT post_id, COUNT(*) AS n_likes
FROM Likes
GROUP BY post_id
ORDER BY n_likes DESC
LIMIT 1;

-- Expected Output:
-- +---------+---------+
-- | post_id | n_likes |
-- +---------+---------+
-- |    4    |    4    |
-- +---------+---------+

-- 5.2 Find the user with the most followers
SELECT following_id AS user_id, COUNT(*) AS num_followers
FROM Followers
GROUP BY following_id
ORDER BY num_followers DESC
LIMIT 1;

-- Expected Output:
-- +---------+---------------+
-- | user_id | num_followers |
-- +---------+---------------+
-- |    6    |       3       |
-- +---------+---------------+

-- 5.3 Find comments that contain an exclamation mark
SELECT * FROM Comments
WHERE comment LIKE '%!%';

-- Expected Output:
-- +----+---------+---------+-------------------------------+--------------+
-- | id | post_id | user_id |           comment             | comment_date |
-- +----+---------+---------+-------------------------------+--------------+
-- |  1 |    3    |    3    | Me too! :)                    |  2024-11-11  |
-- +----+---------+---------+-------------------------------+--------------+

-- Exercise 6: More specific queries

-- 6.1 Find the user with the most total comments on their posts
SELECT p.user_id, COUNT(*) AS total_comments
FROM Posts p
JOIN Comments c ON p.id = c.post_id
GROUP BY p.user_id
ORDER BY total_comments DESC
LIMIT 1;

-- Expected Output:
-- +---------+----------------+
-- | user_id | total_comments |
-- +---------+----------------+
-- |    5    |       3        |
-- +---------+----------------+
-- |    2    |       2        |
-- +---------+----------------+

-- 6.2 Identify posts with the most comments in the last 7 days
SELECT c.post_id AS post_id, COUNT(*) AS comment_count
FROM Comments c
WHERE c.comment_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY c.post_id
ORDER BY comment_count DESC;

-- Expected Output:
-- +---------+----------------+
-- | post_id | comment_count  |
-- +---------+----------------+
-- |    4    |       3        |
-- +---------+----------------+
-- |    2    |       1        |
-- +---------+----------------+
-- |    3    |       1        |
-- +---------+----------------+

-- 6.3 Calculate average comments per post for Bob

-- Option 1
SELECT AVG(comment_count) AS avg_comments_per_post
FROM (
    SELECT p.id AS post_id, COUNT(*) AS comment_count
    FROM Posts p
    LEFT JOIN Users u ON p.user_id = u.id
    LEFT JOIN Comments c ON p.id = c.post_id
    WHERE u.username = 'Bob'
    GROUP BY p.id
) AS post_comments;

-- Option 2
SELECT AVG(comment_count) AS avg_comments_per_post
FROM (
    SELECT u.username, p.id AS post_id, COUNT(c.id) AS comment_count
    FROM Posts p
    LEFT JOIN Users u ON p.user_id = u.id
    LEFT JOIN Comments c ON p.id = c.post_id
    GROUP BY u.username, p.id
) AS post_comments
WHERE username = 'Bob';

-- Expected Output:
-- Empty table, as Bob did not post anything.

-- Example of procedure (second point of the procedures section)

DELIMITER // 
CREATE PROCEDURE CountLikesByUser(IN username_input VARCHAR(50), OUT like_count INT)
BEGIN
    -- Declare variables
    DECLARE done INT DEFAULT 0;
    DECLARE current_like_id INT;

    -- Declare a cursor to select all likes where the user matches the input username
    DECLARE likeCursor CURSOR FOR 
        SELECT l.id
        FROM Likes l
        JOIN Posts p ON p.id = l.post_id
        JOIN Users u ON p.user_id = u.id
        WHERE u.username = username_input;

    -- Declare a handler to set done to 1 when there are no more rows to fetch
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Initialize the like count
    SET like_count = 0;

    -- Open the cursor
    OPEN likeCursor;

    -- Loop through each like and increment the like_count variable
    read_loop: LOOP
        FETCH likeCursor INTO current_like_id;

        -- Exit the loop if there are no more rows
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Increment like_count for each like by the user
        SET like_count = like_count + 1;
    END LOOP;

    -- Close the cursor
    CLOSE likeCursor;
END //
DELIMITER ;

CALL CountLikesByUser('Bob', @like_count);
SELECT @like_count AS TotalLikesByUser;

-- Expected Output:
-- Empty table, because Bob did not post anything, therefore he will not have any likes.

-- Exercise 7: Create a view for average likes per user

-- Drop the view if it already exists
DROP VIEW IF EXISTS UserLikes;

-- Create the UserLikes view
CREATE VIEW UserLikes AS
SELECT user_id, AVG(like_count) AS average_likes_per_post
FROM (
    SELECT p.user_id, p.id, COUNT(l.id) AS like_count
    FROM Posts p
    LEFT JOIN Likes l ON p.id = l.post_id
    GROUP BY p.id, p.user_id
) AS post_like_counts
GROUP BY user_id;

-- Visualize view
SELECT * FROM UserLikes;

-- Expected Output:
-- +---------+------------------------+
-- | user_id | average_likes_per_post |
-- +---------+------------------------+
-- |    1    |           1.0          |
-- +---------+------------------------+
-- |    2    |           2.0          |
-- +---------+------------------------+
-- |    5    |           4.0          |
-- +---------+------------------------+