DROP TABLE IF EXISTS title_akas;

CREATE TABLE title_akas (
  titleId VARCHAR(12) NOT NULL,
  ordering INT NOT NULL,
  title VARCHAR(1024) NOT NULL,
  region VARCHAR(8) NULL,
  language VARCHAR(16) NULL,
  types TEXT NULL,
  attributes TEXT NULL,
  isOriginalTitle TINYINT(1) NOT NULL,
  PRIMARY KEY (titleId, ordering)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.akas.tsv'
INTO TABLE title_akas
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@titleId, @ordering, @title, @region, @language, @types, @attributes, @isOrig)
SET
  titleId = NULLIF(@titleId,'\\N'),
  ordering = CAST(NULLIF(@ordering,'\\N') AS SIGNED),
  title = NULLIF(@title,'\\N'),
  region = NULLIF(@region,'\\N'),
  language = NULLIF(@language,'\\N'),
  types = NULLIF(@types,'\\N'),
  attributes = NULLIF(@attributes,'\\N'),
  isOriginalTitle = CAST(NULLIF(@isOrig,'\\N') AS UNSIGNED);
