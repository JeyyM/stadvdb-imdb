DROP TABLE IF EXISTS title_episode;

CREATE TABLE title_episode (
  tconst         VARCHAR(12) NOT NULL PRIMARY KEY,   -- episode id
  parentTconst   VARCHAR(12) NULL,                   -- series/parent title id
  seasonNumber   INT NULL,
  episodeNumber  INT NULL,
  KEY idx_parent (parentTconst),
  KEY idx_parent_se (parentTconst, seasonNumber, episodeNumber)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.episode.tsv'
INTO TABLE title_episode
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'         -- use '\r\n' if Windows line endings
IGNORE 1 LINES
(@tconst, @parent, @season, @ep)
SET
  tconst        = NULLIF(@tconst,'\\N'),
  parentTconst  = NULLIF(@parent,'\\N'),
  seasonNumber  = CAST(NULLIF(@season,'\\N') AS UNSIGNED),
  episodeNumber = CAST(NULLIF(@ep,'\\N') AS UNSIGNED);
