USE bookworms;

-- 1NF for Genres
CREATE TABLE Genre (
    GenreId INT AUTO_INCREMENT PRIMARY KEY,
    GenreName VARCHAR(800) NOT NULL
);

CREATE TABLE BookHasGenre (
    BookId INT,
    GenreId INT,
    PRIMARY KEY (BookId, GenreId),
    FOREIGN KEY (BookId) REFERENCES Books(BookId),
    FOREIGN KEY (GenreId) REFERENCES Genre(GenreId)
);

CREATE TEMPORARY TABLE TempGenres (
    BookId INT,
    CleanGenre VARCHAR(800)
);

-- Clean genre names by removing brackets and quotes (ampersands are kept because they are part of the genre name)
INSERT INTO TempGenres (BookId, CleanGenre)
SELECT BookId, REPLACE(REPLACE(REPLACE(REPLACE(Genres, '[', ''), ']', ''), '''', ''),'"', '') AS CleanedGenres
FROM Books;

INSERT INTO Genre (GenreName)
SELECT DISTINCT TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanGenre, ',', numbers.n), ',', -1), '[', ''), ']', '')) AS genre
FROM TempGenres t
JOIN (
    SELECT n1.N + n2.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n1,
         (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n2
    ORDER BY n
) numbers
WHERE numbers.n <= 1 + (LENGTH(t.CleanGenre) - LENGTH(REPLACE(t.CleanGenre, ',', '')))
ON DUPLICATE KEY UPDATE GenreName = GenreName;


-- Split genres into individual rows
CREATE TEMPORARY TABLE SplitGenres AS
SELECT
    t.BookId,
    TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanGenre, ',', numbers.n), ',', -1), '[', ''), ']', '')) AS GenreName
FROM TempGenres t
JOIN (
    SELECT n1.N + n2.N * 10 + 1 AS n
    FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n1,
         (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n2
    ORDER BY n
) numbers
WHERE numbers.n <= 1 + (LENGTH(t.CleanGenre) - LENGTH(REPLACE(t.CleanGenre, ',', '')))
AND TRIM(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(t.CleanGenre, ',', numbers.n), ',', -1), '[', ''), ']', '')) <> '';


CREATE INDEX idxSplitGenresGenreName ON SplitGenres(GenreName(255));
CREATE INDEX idxSplitGenresBookId ON SplitGenres(BookId);

-- Insert book-genre relationship
INSERT INTO BookHasGenre (BookId, GenreId)
SELECT DISTINCT s.BookId, g.GenreId
FROM SplitGenres s
JOIN Genre g ON s.GenreName = g.GenreName;

DROP TEMPORARY TABLE SplitGenres;
DROP TEMPORARY TABLE TempGenres;
ALTER TABLE Books DROP COLUMN Genres;

-- Verification test
SELECT g.GenreName AS GenreName
FROM Books b
JOIN BookHasGenre bhg ON b.BookId = bhg.BookId
JOIN Genre g ON bhg.GenreId = g.GenreId
WHERE b.BookTitle = 'Anthology of american folk music';
-- Should return Music

SELECT * FROM Genre;
SELECT * FROM BookHasGenre;
SELECT * FROM Books;
