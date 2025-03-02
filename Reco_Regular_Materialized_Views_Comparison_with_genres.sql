USE bookworms;

-- Here we compare the regular views for queries VS materialized views for queries

--



-- REGULAR VIEW
-- A view of every book and for every book the users who rated it 4 or more
CREATE OR REPLACE VIEW BooksRatings4 AS
SELECT BookId, UserId
FROM ratings r
WHERE r.ReviewScore >=4;


SET @desiredGenre = '';

WITH
  LikedByUsers AS (
    SELECT DISTINCT
      br.UserId
    FROM
      BooksRatings4 br
      JOIN books b ON br.BookId = b.BookId
    WHERE
      b.BookTitle = 'Carrie'
  ),
  
 RecommendedBooks AS (
    SELECT
      b.BookId,
      b.BookTitle,
      bhg.GenreId, 
      g.GenreName,
      COUNT(r.RatingId) AS RatingsCount,
      COUNT(DISTINCT r.UserId) AS GoodRatingsCount
    FROM
      ratings r
      JOIN books b ON r.BookId = b.BookId
      JOIN bookhasgenre bhg ON b.BookId = bhg.BookId
      JOIN genre g ON bhg.GenreId = g.GenreId
    WHERE
      r.UserId IN (
        SELECT
          UserId
        FROM
          LikedByUsers
      )
      AND b.BookTitle <> 'Carrie'
    GROUP BY
      b.BookId,
      b.BookTitle,
      bhg.GenreId,
      g.GenreName
  ),
  -- Getting the recommended books by calculating a weighted score for each book, ordering the results and limiting to only the 10 first
  TopRecommendedBooks AS (
    SELECT
      rb.BookId,
      rb.BookTitle,
      rb.RatingsCount,
      rb.GoodRatingsCount,
      rb.GenreName,
      CASE 
       WHEN @desiredGenre IS NULL OR @desiredGenre='' THEN (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
       WHEN rb.GenreName = @desiredGenre THEN ((rb.GoodRatingsCount * rb.GoodRatingsCount)/ rb.RatingsCount)*7
       ELSE (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
      END AS WeightedScore
    FROM
      RecommendedBooks rb
    ORDER BY
      WeightedScore DESC
    LIMIT
      50
  )
  -- Select the books data to be displayed
SELECT * 
FROM 
(
SELECT
ROW_NUMBER() OVER (ORDER BY trb.WeightedScore DESC) AS TopPicks,
  trb.WeightedScore,
  b.BookTitle,
  GROUP_CONCAT(a.AuthorName SEPARATOR ', ') AS Authors,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount
FROM
  TopRecommendedBooks trb
  JOIN Books b ON trb.BookId = b.BookId
  JOIN BookHasAuthor bha ON b.BookId = bha.BookId
  JOIN Author a ON bha.AuthorId = a.AuthorId
  JOIN Publishers p ON b.PublisherId = p.PublisherId
  JOIN BooksMetadata bm ON b.BookId = bm.BookId
  JOIN RecommendedBooks rb ON b.BookId = rb.BookId
GROUP BY
  trb.WeightedScore,
  b.BookId,
  b.BookTitle,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount) subquery
  ORDER BY TopPicks
  LIMIT 10;
  
  -- This is the execution plan with the regular views: 
  EXPLAIN
  WITH
  LikedByUsers AS (
    SELECT DISTINCT
      br.UserId
    FROM
      BooksRatings4 br
      JOIN books b ON br.BookId = b.BookId
    WHERE
      b.BookTitle = 'Carrie'
  ),
  
  RecommendedBooks AS (
    SELECT
      b.BookId,
      b.BookTitle,
      bhg.GenreId, 
      g.GenreName,
      COUNT(r.RatingId) AS RatingsCount,
      COUNT(DISTINCT r.UserId) AS GoodRatingsCount
    FROM
      ratings r
      JOIN books b ON r.BookId = b.BookId
      JOIN bookhasgenre bhg ON b.BookId = bhg.BookId
      JOIN genre g ON bhg.GenreId = g.GenreId
    WHERE
      r.UserId IN (
        SELECT
          UserId
        FROM
          LikedByUsers
      )
      AND b.BookTitle <> 'Carrie'
    GROUP BY
      b.BookId,
      b.BookTitle,
      bhg.GenreId,
      g.GenreName
  ),
  -- Getting the recommended books by calculating a weighted score for each book, ordering the results and limiting to only the 10 first
  TopRecommendedBooks AS (
    SELECT
      rb.BookId,
      rb.BookTitle,
      rb.RatingsCount,
      rb.GoodRatingsCount,
      rb.GenreName,
      CASE 
       WHEN @desiredGenre IS NULL OR @desiredGenre='' THEN (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
       WHEN rb.GenreName = @desiredGenre THEN ((rb.GoodRatingsCount * rb.GoodRatingsCount)/ rb.RatingsCount)*7
       ELSE (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
      END AS WeightedScore
    FROM
      RecommendedBooks rb
    ORDER BY
      WeightedScore DESC
    LIMIT
      50
  )
  -- Select the books data to be displayed
SELECT * 
FROM 
(
SELECT
ROW_NUMBER() OVER (ORDER BY trb.WeightedScore DESC) AS TopPicks,
  trb.WeightedScore,
  b.BookTitle,
  GROUP_CONCAT(a.AuthorName SEPARATOR ', ') AS Authors,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount
FROM
  TopRecommendedBooks trb
  JOIN Books b ON trb.BookId = b.BookId
  JOIN BookHasAuthor bha ON b.BookId = bha.BookId
  JOIN Author a ON bha.AuthorId = a.AuthorId
  JOIN Publishers p ON b.PublisherId = p.PublisherId
  JOIN BooksMetadata bm ON b.BookId = bm.BookId
  JOIN RecommendedBooks rb ON b.BookId = rb.BookId
GROUP BY
  trb.WeightedScore,
  b.BookId,
  b.BookTitle,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount) subquery
  ORDER BY TopPicks
  LIMIT 10;
  
  -- MATERIALIZED VIEW


-- A materialized table of every book and for every book the users who rated it 4 or more
CREATE TABLE IF NOT EXISTS Bookslikedbyusers AS SELECT BookId, UserId FROM
    ratings
WHERE
    ReviewScore >= 4;

CREATE INDEX IX_UserID_BookId ON Bookslikedbyusers(UserId, BookId);


-- Query

-- Getting the users that rated the chosen book 4 or more
WITH
  LikedByUsers AS (
    SELECT DISTINCT
      blu.UserId
    FROM
      Bookslikedbyusers blu
      JOIN books b ON blu.BookId = b.BookId
    WHERE
      b.BookTitle = 'Carrie'
  ),
  
RecommendedBooks AS (
    SELECT
      b.BookId,
      b.BookTitle,
      bhg.GenreId, 
      g.GenreName,
      COUNT(r.RatingId) AS RatingsCount,
      COUNT(DISTINCT r.UserId) AS GoodRatingsCount
    FROM
      ratings r
      JOIN books b ON r.BookId = b.BookId
      JOIN bookhasgenre bhg ON b.BookId = bhg.BookId
      JOIN genre g ON bhg.GenreId = g.GenreId
    WHERE
      r.UserId IN (
        SELECT
          UserId
        FROM
          LikedByUsers
      )
      AND b.BookTitle <> 'Carrie'
    GROUP BY
      b.BookId,
      b.BookTitle,
      bhg.GenreId,
      g.GenreName
  ),
  -- Getting the recommended books by calculating a weighted score for each book, ordering the results and limiting to only the 10 first
  TopRecommendedBooks AS (
    SELECT
      rb.BookId,
      rb.BookTitle,
      rb.RatingsCount,
      rb.GoodRatingsCount,
      rb.GenreName,
      CASE 
       WHEN @desiredGenre IS NULL OR @desiredGenre='' THEN (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
       WHEN rb.GenreName = @desiredGenre THEN ((rb.GoodRatingsCount * rb.GoodRatingsCount)/ rb.RatingsCount)*7
       ELSE (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
      END AS WeightedScore
    FROM
      RecommendedBooks rb
    ORDER BY
      WeightedScore DESC
    LIMIT
      50
  )
  -- Select the books data to be displayed
SELECT * 
FROM 
(
SELECT
ROW_NUMBER() OVER (ORDER BY trb.WeightedScore DESC) AS TopPicks,
  trb.WeightedScore,
  b.BookTitle,
  GROUP_CONCAT(a.AuthorName SEPARATOR ', ') AS Authors,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount
FROM
  TopRecommendedBooks trb
  JOIN Books b ON trb.BookId = b.BookId
  JOIN BookHasAuthor bha ON b.BookId = bha.BookId
  JOIN Author a ON bha.AuthorId = a.AuthorId
  JOIN Publishers p ON b.PublisherId = p.PublisherId
  JOIN BooksMetadata bm ON b.BookId = bm.BookId
  JOIN RecommendedBooks rb ON b.BookId = rb.BookId
GROUP BY
  trb.WeightedScore,
  b.BookId,
  b.BookTitle,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount) subquery
  ORDER BY TopPicks
  LIMIT 10;
  
  -- Execution plan with the materialized view:
EXPLAIN
WITH
  LikedByUsers AS (
    SELECT DISTINCT
      blu.UserId
    FROM
      Bookslikedbyusers blu
      JOIN books b ON blu.BookId = b.BookId
    WHERE
      b.BookTitle = 'Carrie'
  ),
  

  RecommendedBooks AS (
    SELECT
      b.BookId,
      b.BookTitle,
      bhg.GenreId, 
      g.GenreName,
      COUNT(r.RatingId) AS RatingsCount,
      COUNT(DISTINCT r.UserId) AS GoodRatingsCount
    FROM
      ratings r
      JOIN books b ON r.BookId = b.BookId
      JOIN bookhasgenre bhg ON b.BookId = bhg.BookId
      JOIN genre g ON bhg.GenreId = g.GenreId
    WHERE
      r.UserId IN (
        SELECT
          UserId
        FROM
          LikedByUsers
      )
      AND b.BookTitle <> 'Carrie'
    GROUP BY
      b.BookId,
      b.BookTitle,
      bhg.GenreId,
      g.GenreName
  ),
  -- Getting the recommended books by calculating a weighted score for each book, ordering the results and limiting to only the 10 first
  TopRecommendedBooks AS (
    SELECT
      rb.BookId,
      rb.BookTitle,
      rb.RatingsCount,
      rb.GoodRatingsCount,
      rb.GenreName,
      CASE 
       WHEN @desiredGenre IS NULL OR @desiredGenre='' THEN (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
       WHEN rb.GenreName = @desiredGenre THEN ((rb.GoodRatingsCount * rb.GoodRatingsCount)/ rb.RatingsCount)*7
       ELSE (rb.GoodRatingsCount * rb.GoodRatingsCount) / rb.RatingsCount
      END AS WeightedScore
    FROM
      RecommendedBooks rb
    ORDER BY
      WeightedScore DESC
    LIMIT
      50
  )
  -- Select the books data to be displayed
SELECT * 
FROM 
(
SELECT
ROW_NUMBER() OVER (ORDER BY trb.WeightedScore DESC) AS TopPicks,
  trb.WeightedScore,
  b.BookTitle,
  GROUP_CONCAT(a.AuthorName SEPARATOR ', ') AS Authors,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount
FROM
  TopRecommendedBooks trb
  JOIN Books b ON trb.BookId = b.BookId
  JOIN BookHasAuthor bha ON b.BookId = bha.BookId
  JOIN Author a ON bha.AuthorId = a.AuthorId
  JOIN Publishers p ON b.PublisherId = p.PublisherId
  JOIN BooksMetadata bm ON b.BookId = bm.BookId
  JOIN RecommendedBooks rb ON b.BookId = rb.BookId
GROUP BY
  trb.WeightedScore,
  b.BookId,
  b.BookTitle,
  rb.GenreName,
  p.PublisherName,
  b.Price,
  b.ISBN,
  b.PublishedDate,
  bm.ImageLink,
  bm.BookDescription,
  rb.GoodRatingsCount,
  rb.RatingsCount) subquery
  ORDER BY TopPicks
  LIMIT 10;
