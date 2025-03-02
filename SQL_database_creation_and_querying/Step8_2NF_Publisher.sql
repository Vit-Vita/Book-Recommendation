-- 2NF
-- Books table, Publisher normalization
USE bookworms;
CREATE TABLE Publishers (
    PublisherId INT AUTO_INCREMENT PRIMARY KEY,
    PublisherName VARCHAR(255) NOT NULL
);

CREATE TEMPORARY TABLE TempPublishers AS
SELECT DISTINCT Publisher AS PublisherName
FROM Books;

INSERT INTO Publishers (PublisherName)
SELECT PublisherName FROM TempPublishers;

DROP TEMPORARY TABLE TempPublishers;
ALTER TABLE Books ADD PublisherId INT;

CREATE TEMPORARY TABLE TempBooksUpdate AS
SELECT b.BookId, p.PublisherId
FROM Books b
JOIN Publishers p ON b.Publisher = p.PublisherName;

CREATE INDEX idx_temp_books_update ON TempBooksUpdate(BookId);

-- Update Books
UPDATE Books b
JOIN TempBooksUpdate t ON b.BookId = t.BookId
SET b.PublisherId = t.PublisherId;

DROP TEMPORARY TABLE TempBooksUpdate;

ALTER TABLE Books DROP COLUMN Publisher;
ALTER TABLE Books ADD CONSTRAINT fk_books_publisher_id FOREIGN KEY (PublisherId) REFERENCES Publishers(PublisherId);

SELECT * FROM Books;
SELECT * FROM Publishers;

