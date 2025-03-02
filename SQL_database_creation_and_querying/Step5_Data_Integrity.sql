USE bookworms;

-- Add the BookId to the Ratings columns based on the matching BookTitle
CREATE TEMPORARY TABLE TempRatingsUpdate AS
SELECT r.RatingId, b.BookId
FROM Ratings r
JOIN Books b ON r.BookTitle = b.BookTitle;

CREATE INDEX idx_temp_ratings_update ON TempRatingsUpdate(RatingId);

UPDATE Ratings r
JOIN TempRatingsUpdate t ON r.RatingId = t.RatingId
SET r.BookId = t.BookId;

DROP TEMPORARY TABLE TempRatingsUpdate;
ALTER TABLE Ratings DROP COLUMN BookTitle;

SELECT * FROM Ratings;