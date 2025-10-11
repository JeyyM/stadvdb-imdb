DROP TABLE IF EXISTS title_ft;

CREATE TABLE title_ft (
  tconst VARCHAR(12) NOT NULL PRIMARY KEY,
  primaryTitle VARCHAR(512) NOT NULL,
  typeID INT NOT NULL, 
  runtimeMinutes SMALLINT UNSIGNED NULL,
  averageRating DECIMAL(3,1) NULL,
  numVotes INT UNSIGNED NULL,
  startYear SMALLINT UNSIGNED NULL

  FOREIGN KEY (typeID) REFERENCES type_dt(typeID),
);

INSERT INTO title_ft
  (tconst, primaryTitle, typeID, runtimeMinutes, averageRating, numVotes, startYear)
SELECT
  b.tconst,
  b.primaryTitle,
  t.typeID,
  b.runtimeMinutes,
  r.averageRating,
  r.numVotes,
  b.startYear
FROM title_basics AS b
JOIN type_dt AS t
  ON b.titleType = t.titleType
LEFT JOIN title_ratings AS r
  ON r.tconst = b.tconst
WHERE b.titleType IS NOT NULL;

SELECT * FROM title_ft;
