USE bookworms;

-- 1NF for Authors
CREATE TABLE Author (
    AuthorId INT AUTO_INCREMENT PRIMARY KEY,
    AuthorName VARCHAR(2300) NOT NULL
);

CREATE TABLE BookHasAuthor (
    BookId INT,
    AuthorId INT,
    PRIMARY KEY (BookId, AuthorId),
    FOREIGN KEY (BookId) REFERENCES Books(BookId),
    FOREIGN KEY (AuthorId) REFERENCES Author(AuthorId)
);

CREATE TEMPORARY TABLE TempAuthors (
    BookId INT,
    CleanAuthor VARCHAR(2300)
);

-- Clean author names removing brackets and quotation
INSERT INTO TempAuthors (BookId, CleanAuthor)
SELECT BookId, REPLACE(REPLACE(REPLACE(REPLACE(Authors, '[', ''), ']', ''), '''', ''), '&', '') AS CleanedAuthors
FROM Books;

-- Insert each unique author into the Author table (Query created with the help of ChatGPT)
INSERT INTO Author (AuthorName)
SELECT DISTINCT TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanAuthor, ',', numbers.n), ',', -1), '[', ''), ']', '')) AS author
FROM TempAuthors t
JOIN (
    SELECT n1.N + n2.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n1,
         (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n2
    ORDER BY n
) numbers
WHERE numbers.n <= 1 + (LENGTH(t.CleanAuthor) - LENGTH(REPLACE(t.CleanAuthor, ',', '')))
ON DUPLICATE KEY UPDATE AuthorName = AuthorName;

-- Split authors 
CREATE TEMPORARY TABLE SplitAuthors AS
SELECT
    t.BookId,
    TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanAuthor, ',', numbers.n), ',', -1), '[', ''), ']', '')) AS AuthorName
FROM TempAuthors t
JOIN (
    SELECT n1.N + n2.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n1,
         (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n2
    ORDER BY n
) numbers
WHERE numbers.n <= 1 + (LENGTH(t.CleanAuthor) - LENGTH(REPLACE(t.CleanAuthor, ',', '')))
AND TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanAuthor, ',', numbers.n), ',', -1), '[', ''), ']', '')) <> '';

CREATE INDEX idxSplitAuthorsAuthorName ON SplitAuthors(AuthorName(255));
CREATE INDEX idxSplitAuthorsBookId ON SplitAuthors(BookId);

-- Insert book-author relationship
INSERT INTO BookHasAuthor (BookId, AuthorId)
SELECT DISTINCT s.BookId, a.AuthorId
FROM SplitAuthors s
JOIN Author a ON s.AuthorName = a.AuthorName;

DROP TEMPORARY TABLE SplitAuthors;
DROP TEMPORARY TABLE TempAuthors;

ALTER TABLE Books DROP COLUMN Authors;

-- Verification
SELECT a.AuthorName
FROM Books b
JOIN BookHasAuthor bha ON b.BookId = bha.BookId
JOIN Author a ON bha.AuthorId = a.AuthorId
WHERE b.BookTitle = 'Anthology of american folk music';
-- Should return Ross Hair and Thomas Ruys Smith

-- Check the final tables
SELECT * FROM Author;
SELECT * FROM BookHasAuthor;
SELECT * FROM Books
