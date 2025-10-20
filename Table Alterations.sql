USE imdb;

-- Z-score and Percentile
ALTER TABLE title_ft DROP INDEX idx_title_ft_avg_rating;
CREATE INDEX idx_title_ft_avg_rating ON title_ft(averageRating);

ALTER TABLE title_ft DROP INDEX idx_title_ft_num_votes;
CREATE INDEX idx_title_ft_num_votes ON title_ft(numVotes);

-- Best Directors Overall
ALTER TABLE directors_dt DROP INDEX idx_directors_rating_count;
CREATE INDEX idx_directors_rating_count ON directors_dt(avgWeightedRating, validCount);

-- Average Rating of a Genre Over Time
ALTER TABLE title_ft DROP INDEX idx_ft_startYear_avgRating;
CREATE INDEX idx_ft_startYear_avgRating ON title_ft(startYear, averageRating);

-- Best Directors of a Genre and Media Type
ALTER TABLE title_genre_bridge DROP INDEX idx_tgb_genre_tconst;
CREATE INDEX idx_tgb_genre_tconst ON title_genre_bridge(genreID, tconst);

ALTER TABLE title_director_bridge DROP INDEX idx_tdb_nconst_tconst;
CREATE INDEX idx_tdb_nconst_tconst ON title_director_bridge(nconst, tconst);

ALTER TABLE genre_dt DROP INDEX idx_genre_name;
CREATE INDEX idx_genre_name ON genre_dt(genreName);

ALTER TABLE type_dt DROP INDEX idx_type_title;
CREATE INDEX idx_type_title ON type_dt(titleType);
    
ALTER TABLE title_ft DROP INDEX idx_title_type;
CREATE INDEX idx_title_type ON title_ft(typeID, tconst, weightedRating);

-- Movie Search
ALTER TABLE title_ft DROP INDEX idx_title_primaryTitle_fulltext;
CREATE FULLTEXT INDEX idx_title_primaryTitle_fulltext ON title_ft(primaryTitle);