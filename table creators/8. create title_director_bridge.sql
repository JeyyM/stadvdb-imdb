DROP TABLE IF EXISTS title_director_bridge;

CREATE TABLE title_director_bridge (
  tconst VARCHAR(12) NOT NULL,
  nconst VARCHAR(12) NOT NULL,
  PRIMARY KEY (tconst, nconst),
  FOREIGN KEY (tconst) REFERENCES title_ft(tconst),
  FOREIGN KEY (nconst) REFERENCES directors_dt(nconst)
) ENGINE=InnoDB;

INSERT IGNORE INTO title_director_bridge (tconst, nconst)
SELECT DISTINCT
       c.tconst,
       TRIM(j.dir_id) AS nconst
FROM title_crew AS c
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(c.directors, ',', '","'), '"]'),
       '$[*]' COLUMNS (dir_id VARCHAR(16) PATH '$')
     ) AS j
  ON TRUE
JOIN directors_dt AS d
  ON d.nconst = TRIM(j.dir_id)
JOIN title_ft AS f
  ON f.tconst = c.tconst
WHERE c.directors IS NOT NULL;

SELECT * FROM title_director_bridge;