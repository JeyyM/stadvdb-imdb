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