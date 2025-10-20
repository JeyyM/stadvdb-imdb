SELECT
d.primaryName,
  COUNT(*) AS totalWorks,
    SUM((
      SELECT(t2.startYear IS NULL OR t2.weightedRating IS NULL)
        FROM title_ft t2
        WHERE t2.tconst = t.tconst
    )) AS missingInfoCount
FROM directors_dt AS d
JOIN title_director_bridge AS tdb ON d.nconst = tdb.nconst
JOIN title_ft AS t ON t.tconst = tdb.tconst
GROUP BY d.nconst, d.primaryName
HAVING d.nconst = 'nm2078274';
