DROP TABLE IF EXISTS title_episode;

CREATE TABLE title_episode (
  tconst        VARCHAR(12) NOT NULL PRIMARY KEY,
  parentTconst  VARCHAR(12) NULL,
  seasonNumber  INT NULL,
  episodeNumber INT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

LOAD DATA LOCAL INFILE 'C:\\Users\\asus\\Desktop\\STADVDB Dataset\\title.episode.tsv'
INTO TABLE title_episode
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t' ESCAPED BY '\\'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@tconst, @parent, @season, @ep)
SET
  tconst        = NULLIF(@tconst,'\\N'),
  parentTconst  = NULLIF(@parent,'\\N'),
  seasonNumber  = CAST(NULLIF(@season,'\\N') AS UNSIGNED),
  episodeNumber = CAST(NULLIF(@ep,'\\N') AS UNSIGNED);