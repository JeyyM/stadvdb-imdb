DROP TABLE IF EXISTS title_principals;

CREATE TABLE title_principals (
  tconst      VARCHAR(12) NOT NULL,   -- title ID
  ordering    INT NOT NULL,           -- credited order
  nconst      VARCHAR(12) NOT NULL,   -- person ID
  category    VARCHAR(64) NULL,       -- e.g., actor, director
  job         VARCHAR(256) NULL,      -- job description
  characters  TEXT NULL,              -- JSON-like list ["Self"], ["Batman"]
  PRIMARY KEY (tconst, ordering, nconst),
  KEY idx_principals_person (nconst),
  KEY idx_principals_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.principals.tsv'
INTO TABLE title_principals
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'          -- use '\r\n' if Windows line endings
IGNORE 1 LINES
(@tconst, @ordering, @nconst, @category, @job, @characters)
SET
  tconst     = NULLIF(@tconst,'\\N'),
  ordering   = CAST(NULLIF(@ordering,'\\N') AS UNSIGNED),
  nconst     = NULLIF(@nconst,'\\N'),
  category   = NULLIF(@category,'\\N'),
  job        = NULLIF(@job,'\\N'),
  characters = NULLIF(@characters,'\\N');
