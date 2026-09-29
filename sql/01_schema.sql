-- DB1B Airline Analysis
-- 01_schema.sql
-- PostgreSQL raw-table schema for DB1BTicket 2024 Q1-Q4.
-- The final CSV field is an empty source-file artifact and is retained during
-- raw ingestion so the PostgreSQL column count matches the physical CSV.

CREATE TABLE IF NOT EXISTS db1b_ticket (
    itin_id BIGINT,
    coupons INTEGER,
    year SMALLINT,
    quarter SMALLINT,
    origin TEXT,
    origin_airport_id INTEGER,
    origin_airport_seq_id BIGINT,
    origin_city_market_id INTEGER,
    origin_country TEXT,
    origin_state_fips INTEGER,
    origin_state TEXT,
    origin_state_name TEXT,
    origin_wac INTEGER,
    round_trip NUMERIC,
    on_line NUMERIC,
    dollar_cred BIGINT,
    fare_per_mile NUMERIC,
    rp_carrier TEXT,
    passengers NUMERIC,
    itin_fare NUMERIC,
    bulk_fare NUMERIC,
    distance NUMERIC,
    distance_group INTEGER,
    miles_flown NUMERIC,
    itin_geo_type INTEGER,
    csv_extra_column TEXT
);

-- Q1-Q4 are appended into this same table.
-- Do not drop csv_extra_column until all quarterly files have been loaded
-- and the column has been validated as empty across the complete dataset.
