-- purpose, load Base.csv into raw_applications
CREATE OR REPLACE TABLE raw_applications AS
SELECT
    ROW_NUMBER() OVER () AS application_id,
    *
FROM read_csv('data/raw/Base.csv')