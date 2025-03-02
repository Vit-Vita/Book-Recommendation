-- 2NF 
-- Step 1: Users Table
USE bookworms;
CREATE TABLE Users (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    UserCode VARCHAR(40) NOT NULL,
    ProfileName VARCHAR(100),
    UNIQUE(UserCode)
);

CREATE TEMPORARY TABLE TempUsers AS
SELECT DISTINCT UserId AS UserCode, ProfileName
FROM Ratings;

-- Ensure uniqueness in TempUsers (Gotten with the help of ChatGPT)
CREATE TEMPORARY TABLE TempUniqueUsers AS
SELECT UserCode, MIN(ProfileName) AS ProfileName
FROM TempUsers
GROUP BY UserCode;

-- Insert distinct users into the Users table
INSERT IGNORE INTO Users (UserCode, ProfileName)
SELECT UserCode, ProfileName FROM TempUniqueUsers;

DROP TEMPORARY TABLE TempUsers;
DROP TEMPORARY TABLE TempUniqueUsers;

ALTER TABLE Ratings ADD NewUserId INT;

CREATE TEMPORARY TABLE TempRatingsUpdate AS
SELECT r.RatingId, u.UserId AS NewUserId
FROM Ratings r
JOIN Users u ON r.UserId = u.UserCode;

CREATE INDEX idx_temp_ratings_update ON TempRatingsUpdate(RatingId);

-- Update the Ratings table with the new UserId
UPDATE Ratings r
JOIN TempRatingsUpdate t ON r.RatingId = t.RatingId
SET r.NewUserId = t.NewUserId;

DROP TEMPORARY TABLE TempRatingsUpdate;
ALTER TABLE Ratings DROP COLUMN UserId;
ALTER TABLE Ratings DROP COLUMN ProfileName;

-- Rename column back to UserId
ALTER TABLE Ratings CHANGE NewUserId UserId INT;
ALTER TABLE Ratings ADD CONSTRAINT fk_ratings_user_id FOREIGN KEY (UserId) REFERENCES Users(UserId);


--
--
-- Step 2. Normalize ISBN and Price, move from Ratings to Books

ALTER TABLE Books ADD ISBN VARCHAR(20);
ALTER TABLE Books ADD Price VARCHAR(20);

CREATE TEMPORARY TABLE TempBookDetails AS
SELECT r.BookId, r.ISBN, r.Price
FROM Ratings r
WHERE r.ISBN IS NOT NULL AND r.Price IS NOT NULL;

CREATE INDEX idx_temp_bookdetails_bookid ON TempBookDetails(BookId);

UPDATE Books b
JOIN TempBookDetails t ON b.BookId = t.BookId
SET b.ISBN = t.ISBN, b.Price = t.Price;

DROP TEMPORARY TABLE TempBookDetails;

ALTER TABLE Ratings DROP COLUMN ISBN;
ALTER TABLE Ratings DROP COLUMN Price;

SELECT * FROM Books;
SELECT * FROM Ratings;
SELECT * FROM Users;
