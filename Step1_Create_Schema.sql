-- Database Schema:

CREATE DATABASE bookworms;

USE bookworms;

CREATE TABLE Books (
	BookId INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    BookTitle VARCHAR(500),
    BookDescription TEXT,
    Authors VARCHAR(2300),
    ImageLink VARCHAR(150),
    PreviewLink VARCHAR(1000),
    Publisher VARCHAR(255),
    PublishedDate VARCHAR(200),
    InfoLink VARCHAR(500),
    Genres VARCHAR(800),
    RatingsCount INT DEFAULT 0
);

CREATE TABLE Ratings (
	RatingId INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    BookId INT,
    ISBN VARCHAR(20),
    BookTitle VARCHAR(500),
    Price VARCHAR(20),
    UserId VARCHAR(40),
    ProfileName VARCHAR(100),
    ReviewHelpfulness VARCHAR(20),
    ReviewScore DECIMAL(5,2),
    ReviewTime DATETIME,
    ReviewSummary LONGTEXT,
    ReviewText LONGTEXT,
    CONSTRAINT fk_book_id FOREIGN KEY (BookId) REFERENCES Books(BookId)
);

SELECT * FROM Books;
SELECT * FROM Ratings;