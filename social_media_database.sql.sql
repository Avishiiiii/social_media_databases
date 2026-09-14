CREATE DATABASE social_media_db;

USE social_media_db;

SHOW DATABASES;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    bio VARCHAR(255),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DESCRIBE users;

SHOW TABLES;

USE social_media_db;

CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

DESCRIBE posts;

SHOW TABLES;

CREATE TABLE comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

DESCRIBE comments;

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    UNIQUE (post_id, user_id)
);

SHOW TABLES;

CREATE TABLE followers (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (follower_id, following_id),

    FOREIGN KEY (follower_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (following_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SHOW TABLES;

INSERT INTO users (username, email, full_name, bio, date_of_birth)
VALUES
('Tulsi_Mehra', 'tulsi@media.com', 'Tulsi Mehra', 'Data Analytics Enthusiast', '2007-07-01'),
('rahul_sharma', 'rahul@media.com', 'Rahul Sharma', 'Tech Enthusiast', '2003-08-20'),
('priya_singh', 'priya@media.com', 'Priya Singh', 'Digital Creator', '2004-02-15'),
('aman_verma', 'aman@media.com', 'Aman Verma', 'Software Developer', '2002-11-10'),
('neha_gupta', 'neha@media.com', 'Neha Gupta', 'Photography Lover', '2003-06-25'),
('rohit_kumar', 'rohit@media.com', 'Rohit Kumar', 'Fitness & Travel', '2002-09-18');

SELECT *FROM USERS;

INSERT INTO posts (user_id, content)
VALUES
(1, 'Started learning Data Analytics and SQL today!'),
(2, 'Exploring new technologies and building projects.'),
(3, 'Just completed my latest creative project!'),
(1, 'Working on an exciting database project.'),
(4, 'Learning advanced SQL concepts.'),
(5, 'Sharing some beautiful photography tips today.'),
(6, 'Planning my next travel adventure!');

USE social_media_db;

SELECT user_id, username, full_name FROM users;

SELECT *FROM posts;

INSERT INTO comments (post_id, user_id, comment_text)
VALUES(8, 2, 'Great start! Keep learning.'),
(8, 3, 'SQL is really useful for data analytics.'),
(9, 1, 'Nice project idea!'),
(10, 4, 'Congratulations on completing it!'),
(11, 5, 'Looking forward to seeing the project.'),
(12, 6, 'Advanced SQL is interesting to learn.'),
(9, 3, 'Keep sharing your progress!');

SELECT *FROM comments;

USE social_media_db;

INSERT INTO likes (post_id, user_id)
VALUES(8, 2),
(8, 3),
(8, 4),
(9, 1),
(9, 3),
(10, 1),
(10, 5),
(11, 2),
(11, 6),
(12, 1),
(12, 3),
(12, 5);

SELECT *FROM likes;

INSERT INTO followers (follower_id, following_id)
VALUES(1, 2),
(1, 3),
(2, 1),
(2, 4),
(3, 1),
(3, 5),
(4, 1),
(4, 6),
(5, 2),
(5, 3),
(6, 1),
(6, 4);

SELECT *FROM followers;

CREATE VIEW user_posts_view AS
SELECT u.user_id,
    u.username,
    p.post_id,
    p.content,
    p.created_at
FROM users u
JOIN posts p
ON u.user_id = p.user_id;

-- Check the view
SELECT * FROM user_posts_view;


-- =========================================
-- PROCEDURE
-- =========================================

DELIMITER //

CREATE PROCEDURE GetUserPosts(IN uid INT)
BEGIN
    SELECT
        u.username,
        p.content,
        p.created_at
    FROM users u
    JOIN posts p
        ON u.user_id = p.user_id
    WHERE u.user_id = uid;
END //

DELIMITER ;


-- Test procedure
CALL GetUserPosts(1);

DROP FUNCTION IF EXISTS TotalFollowers;
-- =========================================
-- FUNCTION
-- =========================================

DELIMITER //

CREATE FUNCTION TotalFollowers(uid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT COUNT(*)
    INTO total
    FROM followers
    WHERE following_id = uid;

    RETURN total;
END //

DELIMITER ;


-- Test function
SELECT TotalFollowers(1);


-- =========================================
-- TABLE FOR TRIGGER LOGS
-- =========================================
drop table if exists post_logs;
CREATE TABLE post_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    message VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- =========================================
-- TRIGGER
-- =========================================

DELIMITER //

CREATE TRIGGER post_insert_log
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    INSERT INTO post_logs (post_id, message)
    VALUES (
        NEW.post_id,
        'New post created'
    );
END //

DELIMITER ;


-- =========================================
-- TEST TRIGGER
-- =========================================

INSERT INTO posts (user_id, content)
VALUES (1, 'Testing Trigger');


-- Check trigger output
SELECT * FROM post_logs;

CREATE INDEX idx_username ON users(username);

CREATE INDEX idx_post_user ON posts(user_id);

USE social_media_db;

DELIMITER //

CREATE TRIGGER prevent_self_follow
BEFORE INSERT ON followers
FOR EACH ROW
BEGIN
    IF NEW.follower_id = NEW.following_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A user cannot follow themselves';
    END IF;
END //

DELIMITER ;

SELECT u.username,
    COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY total_posts DESC;

SELECT p.post_id,
    p.content,
    COUNT(l.like_id) AS total_likes
FROM posts p
LEFT JOIN likes l
    ON p.post_id = l.post_id
GROUP BY p.post_id, p.content
ORDER BY total_likes DESC;

SELECT p.post_id,
    p.content,
    COUNT(c.comment_id) AS total_comments
FROM posts p
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY p.post_id, p.content
ORDER BY total_comments DESC;

SELECT
    u.username,
    COUNT(f.follower_id) AS followers
FROM users u
LEFT JOIN followers f
    ON u.user_id = f.following_id
GROUP BY u.user_id, u.username
ORDER BY followers DESC;

SELECT u.username,
    COUNT(DISTINCT p.post_id) AS posts,
    COUNT(DISTINCT l.like_id) AS likes_received,
    COUNT(DISTINCT c.comment_id) AS comments_received
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY u.user_id, u.username
ORDER BY likes_received DESC;

CREATE VIEW post_engagement AS
SELECT p.post_id,
    u.username,
    p.content,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM posts p
JOIN users u
    ON p.user_id = u.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY p.post_id, u.username, p.content;

SELECT *  FROM post_engagement ORDER BY total_likes DESC;

SHOW TABLES;
