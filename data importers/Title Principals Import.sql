DROP TABLE IF EXISTS title_principals;

CREATE TABLE title_principals (
  tconst VARCHAR(12) NOT NULL,
  ordering INT NOT NULL,
  nconst VARCHAR(12) NOT NULL,
  category VARCHAR(64) NULL,
  job VARCHAR(256) NULL,
  characters TEXT NULL,
  PRIMARY KEY (tconst, ordering, nconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.principals.tsv'
INTO TABLE title_principals
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@tconst, @ordering, @nconst, @category, @job, @characters)
SET
  tconst     = NULLIF(@tconst,'\\N'),
  ordering   = CAST(NULLIF(@ordering,'\\N') AS UNSIGNED),
  nconst     = NULLIF(@nconst,'\\N'),
  category   = NULLIF(@category,'\\N'),
  job        = NULLIF(@job,'\\N'),
  characters = NULLIF(@characters,'\\N');
