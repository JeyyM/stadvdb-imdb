USE imdb;

ALTER TABLE directors_dt
  ADD COLUMN validCount INT NOT NULL DEFAULT 0,
  ADD COLUMN avgWeightedRating DECIMAL(5,3) NULL;

UPDATE directors_dt d
JOIN(
    SELECT
      tdb.nconst,
    COUNT(t.weightedRating) AS validCount,
    AVG(t.weightedRating) AS avgWeightedRating
      FROM title_director_bridge tdb
  JOIN title_ft t ON t.tconst = tdb.tconst
  WHERE t.weightedRating IS NOT NULL
  GROUP BY tdb.nconst
) vals ON vals.nconst = d.nconst
SET d.validCount = vals.validCount,
    d.avgWeightedRating = vals.avgWeightedRating;
    

-- Add/Update columns for profession bitmasking
DROP TABLE IF EXISTS profession_map;
CREATE TABLE profession_map (
  professionID INT PRIMARY KEY,
  bitpos TINYINT UNSIGNED NOT NULL,
  UNIQUE KEY ux_bitpos (bitpos)
) ENGINE=InnoDB;

INSERT INTO profession_map (professionID, bitpos)
SELECT professionID, ROW_NUMBER() OVER (ORDER BY professionID) - 1
FROM profession_dt
ORDER BY professionID;

-- ALTER TABLE directors_dt
  -- DROP COLUMN IF EXISTS professionCombo,
  -- DROP COLUMN IF EXISTS profComboMask;

ALTER TABLE directors_dt
  ADD COLUMN professionCombo VARCHAR(255) NULL,
  ADD COLUMN profComboMask BIGINT UNSIGNED NULL;

-- This UPDATE depends on director_profession_bridge
WITH
professionsPerDirector AS (
  SELECT
      dpb.nconst,
      GROUP_CONCAT(p.professionName ORDER BY p.professionName SEPARATOR ', ') AS professionCombo
  FROM director_profession_bridge AS dpb
  JOIN profession_dt AS p
    ON p.professionID = dpb.professionID
  GROUP BY dpb.nconst
),
masks AS (
  SELECT
      dpb.nconst,
      BIT_OR(1 << pm.bitpos) AS combo_mask
  FROM director_profession_bridge AS dpb
  JOIN profession_map AS pm
    ON pm.professionID = dpb.professionID
  GROUP BY dpb.nconst
)
UPDATE directors_dt d
JOIN professionsPerDirector ppd ON ppd.nconst = d.nconst
JOIN masks m ON m.nconst = d.nconst
SET d.professionCombo = ppd.professionCombo,
    d.profComboMask = m.combo_mask;

-- Create Movie Feature Vector (Base View)
DROP VIEW IF EXISTS movie_feature_vector;

CREATE VIEW movie_feature_vector AS
SELECT 
    t.tconst,
    t.primaryTitle,
    -- Normalized numerical attributes
    ((t.averageRating - stats.min_rating) / (stats.max_rating - stats.min_rating)) AS norm_rating,
    ((t.numVotes - stats.min_votes) / (stats.max_votes - stats.min_votes)) AS norm_votes,
    ((t.runtimeMinutes - stats.min_runtime) / (stats.max_runtime - stats.min_runtime)) AS norm_runtime,

    -- Genre binary indicators (1 if movie belongs to the genre, else 0)
    MAX(CASE WHEN g.genreID = 1 THEN 1 ELSE 0 END) AS genre_Action,
    MAX(CASE WHEN g.genreID = 2 THEN 1 ELSE 0 END) AS genre_Adult,
    MAX(CASE WHEN g.genreID = 3 THEN 1 ELSE 0 END) AS genre_Adventure,
    MAX(CASE WHEN g.genreID = 4 THEN 1 ELSE 0 END) AS genre_Animation,
    MAX(CASE WHEN g.genreID = 5 THEN 1 ELSE 0 END) AS genre_Biography,
    MAX(CASE WHEN g.genreID = 6 THEN 1 ELSE 0 END) AS genre_Comedy,
    MAX(CASE WHEN g.genreID = 7 THEN 1 ELSE 0 END) AS genre_Crime,
    MAX(CASE WHEN g.genreID = 8 THEN 1 ELSE 0 END) AS genre_Documentary,
    MAX(CASE WHEN g.genreID = 9 THEN 1 ELSE 0 END) AS genre_Drama,
    MAX(CASE WHEN g.genreID = 10 THEN 1 ELSE 0 END) AS genre_Family,
    MAX(CASE WHEN g.genreID = 11 THEN 1 ELSE 0 END) AS genre_Fantasy,
    MAX(CASE WHEN g.genreID = 12 THEN 1 ELSE 0 END) AS genre_Film_Noir,
    MAX(CASE WHEN g.genreID = 13 THEN 1 ELSE 0 END) AS genre_Game_Show,
    MAX(CASE WHEN g.genreID = 14 THEN 1 ELSE 0 END) AS genre_History,
    MAX(CASE WHEN g.genreID = 15 THEN 1 ELSE 0 END) AS genre_Horror,
    MAX(CASE WHEN g.genreID = 16 THEN 1 ELSE 0 END) AS genre_Music,
    MAX(CASE WHEN g.genreID = 17 THEN 1 ELSE 0 END) AS genre_Musical,
    MAX(CASE WHEN g.genreID = 18 THEN 1 ELSE 0 END) AS genre_Mystery,
    MAX(CASE WHEN g.genreID = 19 THEN 1 ELSE 0 END) AS genre_News,
    MAX(CASE WHEN g.genreID = 20 THEN 1 ELSE 0 END) AS genre_Reality_TV,
    MAX(CASE WHEN g.genreID = 21 THEN 1 ELSE 0 END) AS genre_Romance,
    MAX(CASE WHEN g.genreID = 22 THEN 1 ELSE 0 END) AS genre_Sci_Fi,
    MAX(CASE WHEN g.genreID = 23 THEN 1 ELSE 0 END) AS genre_Short,
    MAX(CASE WHEN g.genreID = 24 THEN 1 ELSE 0 END) AS genre_Sport,
    MAX(CASE WHEN g.genreID = 25 THEN 1 ELSE 0 END) AS genre_Talk_Show,
    MAX(CASE WHEN g.genreID = 26 THEN 1 ELSE 0 END) AS genre_Thriller,
    MAX(CASE WHEN g.genreID = 27 THEN 1 ELSE 0 END) AS genre_War,
    MAX(CASE WHEN g.genreID = 28 THEN 1 ELSE 0 END) AS genre_Western
FROM 
    title_ft AS t
CROSS JOIN (
    SELECT 
        MIN(averageRating) AS min_rating, MAX(averageRating) AS max_rating,
        MIN(numVotes) AS min_votes, MAX(numVotes) AS max_votes,
        MIN(runtimeMinutes) AS min_runtime, MAX(runtimeMinutes) AS max_runtime
    FROM title_ft
    WHERE numVotes > 1000
) AS stats
LEFT JOIN title_genre_bridge AS g ON t.tconst = g.tconst
WHERE 
    t.numVotes > 1000 
    AND t.runtimeMinutes IS NOT NULL
GROUP BY 
    t.tconst, t.primaryTitle,
    stats.min_rating, stats.max_rating, 
    stats.min_votes, stats.max_votes, 
    stats.min_runtime, stats.max_runtime;

-- Z-score and Percentile
-- ALTER TABLE title_ft DROP INDEX IF EXISTS idx_title_ft_avg_rating;
CREATE INDEX idx_title_ft_avg_rating ON title_ft(averageRating);

-- ALTER TABLE title_ft DROP INDEX IF EXISTS idx_title_ft_num_votes;
CREATE INDEX idx_title_ft_num_votes ON title_ft(numVotes);

-- Best Directors Overall
-- ALTER TABLE directors_dt DROP INDEX IF EXISTS idx_directors_rating_count;
CREATE INDEX idx_directors_rating_count ON directors_dt(avgWeightedRating, validCount);

-- Average Rating of a Genre Over Time
-- ALTER TABLE title_ft DROP INDEX IF EXISTS idx_ft_startYear_avgRating;
CREATE INDEX idx_ft_startYear_avgRating ON title_ft(startYear, averageRating);

-- Best Directors of a Genre and Media Type
-- ALTER TABLE title_genre_bridge DROP INDEX IF EXISTS idx_tgb_genre_tconst;
CREATE INDEX idx_tgb_genre_tconst ON title_genre_bridge(genreID, tconst);

-- ALTER TABLE title_director_bridge DROP INDEX IF EXISTS idx_tdb_nconst_tconst;
CREATE INDEX idx_tdb_nconst_tconst ON title_director_bridge(nconst, tconst);

-- ALTER TABLE genre_dt DROP INDEX IF EXISTS idx_genre_name;
CREATE INDEX idx_genre_name ON genre_dt(genreName);

-- ALTER TABLE type_dt DROP INDEX IF EXISTS idx_type_title;
CREATE INDEX idx_type_title ON type_dt(titleType);
    
-- ALTER TABLE title_ft DROP INDEX IF EXISTS idx_title_type;
CREATE INDEX idx_title_type ON title_ft(typeID, tconst, weightedRating);

-- Movie Search
-- ALTER TABLE title_ft DROP INDEX IF EXISTS idx_title_primaryTitle_fulltext;
CREATE FULLTEXT INDEX idx_title_primaryTitle_fulltext ON title_ft(primaryTitle);

CREATE TABLE IF NOT EXISTS movie_feature_vector_materialized AS
SELECT * FROM movie_feature_vector;

CREATE INDEX idx_mat_vec_tconst 
ON movie_feature_vector_materialized(tconst(12));