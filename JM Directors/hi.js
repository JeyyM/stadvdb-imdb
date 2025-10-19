ALTER TABLE directors_dt
  ADD INDEX idx_validcount_avgrating(validCount, avgWeightedRating);
  
ALTER TABLE directors_dt
  DROP INDEX idx_validcount_avgrating