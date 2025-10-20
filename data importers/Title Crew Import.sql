DROP TABLE IF EXISTS title_crew;

CREATE TABLE title_crew (
  tconst VARCHAR(12) NOT NULL PRIMARY KEY,
  directors TEXT NULL,
  writers   TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.crew.tsv'
INTO TABLE title_crew
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@tconst, @directors, @writers)
SET
  tconst = NULLIF(@tconst,'\\N'),
  directors = NULLIF(@directors,'\\N'),
  writers = NULLIF(@writers,'\\N');
