DROP TABLE IF EXISTS title_ft;

CREATE TABLE title_ft (
  tconst VARCHAR(12) NOT NULL PRIMARY KEY,
  primaryTitle VARCHAR(512) NOT NULL,
  typeID INT NOT NULL, 
  runtimeMinutes SMALLINT UNSIGNED NULL,
  averageRating DECIMAL(3,1) NULL,
  numVotes INT UNSIGNED NULL,
  startYear SMALLINT UNSIGNED NULL,
  weightedRating DECIMAL(4,2) NULL,

  FOREIGN KEY (typeID) REFERENCES type_dt(typeID)
);

INSERT INTO title_ft
  (tconst, primaryTitle, typeID, runtimeMinutes, averageRating, numVotes, startYear, weightedRating)
SELECT
  b.tconst,
  b.primaryTitle,
  t.typeID,
  b.runtimeMinutes,
  r.averageRating,
  r.numVotes,
  b.startYear,
  CASE 
    WHEN r.numVotes IS NOT NULL AND r.averageRating IS NOT NULL THEN
      -- IMDb's Bayesian formula with calculated means
      ((r.numVotes * 1.0) / (r.numVotes + stats.min_votes)) * r.averageRating + 
      ((stats.min_votes * 1.0) / (r.numVotes + stats.min_votes)) * stats.mean_rating
    ELSE NULL
  END AS weightedRating
FROM title_basics AS b
JOIN type_dt AS t
  ON b.titleType = t.titleType
LEFT JOIN title_ratings AS r
  ON r.tconst = b.tconst
CROSS JOIN (
  SELECT 
    AVG(averageRating) AS mean_rating,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY numVotes) AS min_votes
  FROM title_ratings 
  WHERE averageRating IS NOT NULL AND numVotes IS NOT NULL
) AS stats
WHERE b.titleType IS NOT NULL;

SELECT * FROM title_ft;
