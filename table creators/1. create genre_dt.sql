DROP TABLE IF EXISTS genre_dt;

CREATE TABLE genre_dt (
  genreID INT AUTO_INCREMENT PRIMARY KEY,
  genreName VARCHAR(16) NOT NULL UNIQUE
);

-- Insert IGNORE to avoid duplicates
INSERT IGNORE INTO genre_dt (genreName)
SELECT TRIM(jt.genre)
FROM title_basics b
JOIN JSON_TABLE(
  -- Create an array and insert each of them into the genres
       CONCAT('["', REPLACE(b.genres, ',', '","'), '"]'),
       '$[*]' COLUMNS (genre VARCHAR(64) PATH '$')
     ) jt
WHERE b.genres IS NOT NULL;

SELECT COUNT(*) AS total_genres FROM genre_dt;
SELECT * FROM genre_dt ORDER BY genreName;