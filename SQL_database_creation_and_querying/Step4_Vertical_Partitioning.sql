USE bookworms;

-- ON BOOKS TABLE
-- Create the BooksMetadata table
CREATE TABLE BooksMetadata (
    BookId INT PRIMARY KEY,
    BookDescription TEXT,
    ImageLink VARCHAR(150),
    PreviewLink VARCHAR(1000),
    InfoLink VARCHAR(500),
    CONSTRAINT fk_booksmetadata_book_id FOREIGN KEY (BookId) REFERENCES Books(BookId)
);

INSERT INTO BooksMetadata (BookId, BookDescription, ImageLink, PreviewLink, InfoLink)
SELECT BookId, BookDescription, ImageLink, PreviewLink, InfoLink
FROM Books;

ALTER TABLE Books
DROP COLUMN BookDescription,
DROP COLUMN ImageLink,
DROP COLUMN PreviewLink,
DROP COLUMN InfoLink;


-- ON RATINGS TABLE
-- Create the RatingsMetadata table
CREATE TABLE RatingsMetadata (
    RatingId INT PRIMARY KEY,
    ReviewSummary LONGTEXT,
    ReviewText LONGTEXT,
    CONSTRAINT fk_ratingsmetadata_rating_id FOREIGN KEY (RatingId) REFERENCES Ratings(RatingId)
);

INSERT INTO RatingsMetadata (RatingId, ReviewSummary, ReviewText)
SELECT RatingId, ReviewSummary, ReviewText
FROM Ratings;

ALTER TABLE Ratings
DROP COLUMN ReviewSummary,
DROP COLUMN ReviewText;

SELECT * FROM BooksMetadata;
SELECT * FROM RatingsMetadata;

