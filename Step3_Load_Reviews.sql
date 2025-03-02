-- Data Load
USE bookworms;
SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = true;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Load Reviews
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Books_rating.csv'
INTO TABLE Ratings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @var_Id, 
    @var_Title, 
    @var_Price, 
    @var_UserId, 
    @var_ProfileName, 
    @var_ReviewHelpfulness, 
    @var_ReviewScore, 
    @var_ReviewTime,
    @var_ReviewSummary,
    @var_ReviewText
)
SET
    ISBN = @var_Id,
    BookTitle = CONCAT(UPPER(SUBSTRING(@var_Title, 1, 1)), LOWER(SUBSTRING(@var_Title FROM 2))),
    Price = @var_Price,
    UserId = @var_UserId,
    ProfileName = @var_ProfileName,
    ReviewHelpfulness = @var_ReviewHelpfulness,
    ReviewScore = @var_ReviewScore,
    ReviewTime = FROM_UNIXTIME(@var_ReviewTime),
    ReviewSummary = @var_ReviewSummary,
    ReviewText = @var_ReviewText;


CREATE INDEX idx_ratings_rating_id ON Ratings(RatingId); -- To make operations faster
CREATE INDEX idx_ratings_book_title ON Ratings(BookTitle); -- To make operations faster
CREATE INDEX idx_ratings_book_id ON Ratings(BookId); -- To make operations faster

SELECT * FROM Ratings;
