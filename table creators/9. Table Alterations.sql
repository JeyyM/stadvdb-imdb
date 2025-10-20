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