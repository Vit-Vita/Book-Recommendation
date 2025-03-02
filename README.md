# SQL-Based Book Recommendation System
In a world where countless books are published every year, choosing the right one can be overwhelming. 
This project created by a team of three students introduces an SQL-based book recommendation system designed to simplify book selection by providing personalized suggestions based on user preferences.

## Features
- Users enter a book title they like to receive recommendations of highly-rated books enjoyed by similar readers.
- Option to explore new genres based on community preferences.
- Uses a weighted scoring algorithm to ensure diverse and relevant recommendations.

## Data Sources
- Amazon Books Reviews (Kaggle)
- Google Books API for book metadata

## Tech Stack
- MySQL (Database Management System)
- MySQL Workbench (Database Design & Querying)
- Metabase (Data Visualization)

## Database & System Architecture
The recommendation engine operates as follows:

1. Data Normalization – Ensures efficient data storage and retrieval:
- Second Normal Form (2NF) applied by creating separate tables for Publishers and Users, ensuring all attributes are fully functionally dependent on primary keys.
- ISBN and Price moved from Ratings to Books for better data structure.
  
2. Entity-Relationship Model – Main entities include:
- Books – Contains book details and foreign keys for publishers, authors, and genres.
- Ratings – Stores user ratings linked to Books and Users.
- Users – Captures reviewer information.
- Metadata Tables – Store additional book and rating details.

3. Query Optimization – A multi-step SQL query with Common Table Expressions (CTEs) efficiently retrieves relevant books:
- Identifies users who rated the input book 4+ stars.
- Finds books highly rated by those users.
- Computes a weighted score and ranks results.
- Extracts top 10 recommendations with book details.
