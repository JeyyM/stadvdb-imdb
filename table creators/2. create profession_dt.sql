DROP TABLE IF EXISTS profession_dt;

CREATE TABLE profession_dt (
  professionID INT AUTO_INCREMENT PRIMARY KEY,
  professionName VARCHAR(64) NOT NULL UNIQUE
);

-- Insert IGNORE to avoid duplicates
INSERT IGNORE INTO profession_dt (professionName)
SELECT DISTINCT TRIM(jt.prof)
FROM name_basics n
JOIN JSON_TABLE(
       -- Create an array and insert each of them into the professions
       CONCAT('["', REPLACE(n.primaryProfession, ',', '","'), '"]'),
       '$[*]' COLUMNS (prof VARCHAR(64) PATH '$')
     ) jt
WHERE n.primaryProfession IS NOT NULL;

SELECT COUNT(*) AS total_professions FROM profession_dt;
SELECT * FROM profession_dt ORDER BY professionName;
