DROP TABLE IF EXISTS director_profession_bridge;

CREATE TABLE director_profession_bridge (
  nconst VARCHAR(12),
  professionID INT,
  PRIMARY KEY (nconst, professionID),
  FOREIGN KEY (nconst) REFERENCES directors_dt(nconst),
  FOREIGN KEY (professionID) REFERENCES profession_dt(professionID)
);

INSERT IGNORE INTO director_profession_bridge (nconst, professionID)
SELECT DISTINCT d.nconst, p.professionID
FROM directors_dt AS d
JOIN name_basics AS nb
  ON nb.nconst = d.nconst
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(nb.primaryProfession, ',', '","'), '"]'),
       '$[*]' COLUMNS (prof VARCHAR(64) PATH '$')
     ) AS jt
  ON TRUE -- This allows for an instant join without setting some condition
JOIN profession_dt AS p
  ON p.professionName = TRIM(jt.prof)
WHERE nb.primaryProfession IS NOT NULL AND jt.prof IS NOT NULL;

SELECT COUNT(*) AS total_links FROM director_profession_bridge;
SELECT * FROM director_profession_bridge;
