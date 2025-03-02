-- Data Load
USE bookworms;
SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Load Books
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/books_data.csv'

INTO TABLE Books
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' -- Because some titles are enclosed by "", others not
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @var_Title, 
    @var_description, 
    @var_authors, 
    @var_image, 
    @var_previewLink, 
    @var_publisher, 
    @var_publishedDate, 
    @var_infoLink, 
    @var_categories, 
    @var_RatingsCount
)
SET
    BookTitle = CONCAT(UPPER(SUBSTRING(@var_Title, 1, 1)), LOWER(SUBSTRING(@var_Title FROM 2))),
    -- Normalize movie title to capitalize first letter
    BookDescription = @var_description,
    Authors = @var_authors,
    ImageLink = @var_image,
    PreviewLink = @var_previewLink,
    Publisher = @var_publisher,
    PublishedDate = @var_publishedDate,
    InfoLink = @var_infoLink,
    Genres = @var_categories,
    RatingsCount = IF(@var_RatingsCount = '' OR @var_RatingsCount IS NULL, 0, @var_RatingsCount);

CREATE INDEX idx_books_book_id ON Books(BookId); -- To make operations faster
CREATE INDEX idx_books_book_title ON Books(BookTitle); -- To make operations faster

-- Delete duplicate titles
DELETE b1
FROM Books b1
LEFT JOIN (
    SELECT MIN(BookId) AS BookId
    FROM Books
    GROUP BY BookTitle
) AS b2 ON b1.BookId = b2.BookId
WHERE b2.BookId IS NULL;

SELECT COUNT(*) AS CountOfUniqueDuplicates
FROM (
    SELECT BookTitle
    FROM Books
    GROUP BY BookTitle
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT * FROM Books;