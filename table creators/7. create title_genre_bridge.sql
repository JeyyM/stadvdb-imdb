DROP TABLE IF EXISTS title_genre_bridge;

CREATE TABLE title_genre_bridge (
  tconst  VARCHAR(12) NOT NULL,
  genreID INT NOT NULL,
  PRIMARY KEY (tconst, genreID),
  FOREIGN KEY (tconst)  REFERENCES title_basics(tconst) ON DELETE CASCADE,
  FOREIGN KEY (genreID) REFERENCES genre_dt(genreID) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT IGNORE INTO title_genre_bridge (tconst, genreID)
SELECT DISTINCT
       b.tconst,
       g.genreID
FROM title_basics AS b
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(b.genres, ',', '","'), '"]'),
       '$[*]' COLUMNS (genre VARCHAR(64) PATH '$')
     ) AS jt
  ON TRUE
JOIN genre_dt AS g
  ON g.genreName = TRIM(jt.genre)
WHERE b.genres IS NOT NULL;

SELECT COUNT(*) AS links FROM title_genre_bridge;
SELECT * FROM title_genre_bridge;
