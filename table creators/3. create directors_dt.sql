DROP TABLE IF EXISTS director_profession_bridge;
DROP TABLE IF EXISTS title_director_bridge;
DROP TABLE IF EXISTS directors_dt;

CREATE TABLE directors_dt (
  nconst VARCHAR(12) NOT NULL PRIMARY KEY,
  primaryName VARCHAR(255) NULL,
  birthYear SMALLINT UNSIGNED NULL,
  deathYear SMALLINT UNSIGNED NULL
) ENGINE=InnoDB;

INSERT INTO directors_dt (nconst, primaryName, birthYear, deathYear)
SELECT d.nconst, nb.primaryName, nb.birthYear, nb.deathYear
FROM (
  SELECT DISTINCT TRIM(j.dir_id) AS nconst
  FROM title_crew c
  JOIN JSON_TABLE(
         CONCAT('["', REPLACE(c.directors, ',', '","'), '"]'),
         '$[*]' COLUMNS (dir_id VARCHAR(16) PATH '$')
       ) AS j
  WHERE c.directors IS NOT NULL
) AS d
JOIN name_basics AS nb
  ON nb.nconst = d.nconst;

-- ONLY ADD THESE ONCE BRIDGE TABLES HAVE BEEN ADDED

-- ALTER TABLE directors_dt
--  DROP COLUMN validCount,
--  DROP COLUMN avgWeightedRating;alter

-- Precalculating averages and valid counts
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
    
-- Making a bitmap for profession combinations
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

ALTER TABLE directors_dt
  DROP COLUMN professionCombo,
  DROP COLUMN profComboMask;

ALTER TABLE directors_dt
  ADD COLUMN professionCombo VARCHAR(255) NULL,
  ADD COLUMN profComboMask BIGINT UNSIGNED NULL;
--   ADD INDEX idx_profComboMask (profComboMask);

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
