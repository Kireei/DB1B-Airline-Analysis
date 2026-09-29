-- DB1B Airline Analysis
-- 03_data_validation.sql
--
-- Purpose:
-- Validate completeness, duplication, ranges, and potentially anomalous values
-- before using DB1BTicket for business analysis.
--
-- Important:
-- Suspicious values are not automatically removed. They are first treated as
-- candidates for investigation because an unusual value can still be valid.


-- 1) NULL profile for the 25 business columns
SELECT
    COUNT(*) - COUNT(itin_id) AS itin_id_null,
    COUNT(*) - COUNT(coupons) AS coupons_null,
    COUNT(*) - COUNT(year) AS year_null,
    COUNT(*) - COUNT(quarter) AS quarter_null,
    COUNT(*) - COUNT(origin) AS origin_null,
    COUNT(*) - COUNT(origin_airport_id) AS origin_airport_id_null,
    COUNT(*) - COUNT(origin_airport_seq_id) AS origin_airport_seq_id_null,
    COUNT(*) - COUNT(origin_city_market_id) AS origin_city_market_id_null,
    COUNT(*) - COUNT(origin_country) AS origin_country_null,
    COUNT(*) - COUNT(origin_state_fips) AS origin_state_fips_null,
    COUNT(*) - COUNT(origin_state) AS origin_state_null,
    COUNT(*) - COUNT(origin_state_name) AS origin_state_name_null,
    COUNT(*) - COUNT(origin_wac) AS origin_wac_null,
    COUNT(*) - COUNT(round_trip) AS round_trip_null,
    COUNT(*) - COUNT(on_line) AS on_line_null,
    COUNT(*) - COUNT(dollar_cred) AS dollar_cred_null,
    COUNT(*) - COUNT(fare_per_mile) AS fare_per_mile_null,
    COUNT(*) - COUNT(rp_carrier) AS rp_carrier_null,
    COUNT(*) - COUNT(passengers) AS passengers_null,
    COUNT(*) - COUNT(itin_fare) AS itin_fare_null,
    COUNT(*) - COUNT(bulk_fare) AS bulk_fare_null,
    COUNT(*) - COUNT(distance) AS distance_null,
    COUNT(*) - COUNT(distance_group) AS distance_group_null,
    COUNT(*) - COUNT(miles_flown) AS miles_flown_null,
    COUNT(*) - COUNT(itin_geo_type) AS itin_geo_type_null
FROM db1b_ticket;

-- Result:
-- All checked business columns returned 0 SQL NULL values.


-- 2) Numeric range checks
SELECT
    MIN(coupons) AS min_coupons,
    MAX(coupons) AS max_coupons,
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    MIN(quarter) AS min_quarter,
    MAX(quarter) AS max_quarter,
    MIN(fare_per_mile) AS min_fare_per_mile,
    MAX(fare_per_mile) AS max_fare_per_mile,
    MIN(itin_fare) AS min_itin_fare,
    MAX(itin_fare) AS max_itin_fare,
    MIN(passengers) AS min_passengers,
    MAX(passengers) AS max_passengers,
    MIN(distance) AS min_distance,
    MAX(distance) AS max_distance,
    MIN(miles_flown) AS min_miles_flown,
    MAX(miles_flown) AS max_miles_flown
FROM db1b_ticket;

-- Observed values:
-- coupons:       1 to 13
-- year:          2024 to 2024
-- quarter:       1 to 4
-- fare_per_mile: 0 to approximately 176.463
-- itin_fare:     0 to approximately 49,519
-- passengers:    1 to 992
-- distance:      17 to 31,662
-- miles_flown:   17 to 26,472
--
-- Values such as very short distances, zero fare, very high itinerary fare,
-- and high passenger counts are treated as investigation candidates rather
-- than automatically classified as errors.


-- 3) Negative-value checks
SELECT
    COUNT(CASE WHEN coupons < 0 THEN 1 END) AS negative_coupons,
    COUNT(CASE WHEN year < 0 THEN 1 END) AS negative_year,
    COUNT(CASE WHEN quarter < 0 THEN 1 END) AS negative_quarter,
    COUNT(CASE WHEN fare_per_mile < 0 THEN 1 END) AS negative_fare_per_mile,
    COUNT(CASE WHEN itin_fare < 0 THEN 1 END) AS negative_itin_fare,
    COUNT(CASE WHEN passengers < 0 THEN 1 END) AS negative_passengers,
    COUNT(CASE WHEN distance < 0 THEN 1 END) AS negative_distance,
    COUNT(CASE WHEN miles_flown < 0 THEN 1 END) AS negative_miles_flown
FROM db1b_ticket;

-- Result:
-- No negative values were found in the checked numeric fields.


-- 4) Zero-fare validation
SELECT COUNT(*) AS itin_fare_zero
FROM db1b_ticket
WHERE itin_fare = 0;

SELECT COUNT(*) AS fare_per_mile_zero
FROM db1b_ticket
WHERE fare_per_mile = 0;

-- Results:
-- itin_fare = 0       -> 16,233 rows
-- fare_per_mile = 0   -> 16,233 rows


-- 5) Check whether the zero values occur on the same records
SELECT COUNT(*) AS both_zero
FROM db1b_ticket
WHERE itin_fare = 0
  AND fare_per_mile = 0;

-- Result:
-- 16,233 rows.
-- Therefore all observed zero-itinerary-fare records also have
-- fare_per_mile = 0.

-- Proportion:
-- 16,233 / 20,066,076 * 100 ≈ 0.0809%
--
-- Interpretation:
-- Zero-fare records represent only about 0.081% of the 2024 DB1BTicket rows.
-- This is documented as a data-quality / interpretation note, not automatically
-- removed as an error.


-- 6) CSV ingestion artifact
-- The source CSV contains an extra empty physical field, imported as
-- csv_extra_column so PostgreSQL matches the source column count.
-- Validate this column before dropping it from a cleaned table/view.

SELECT
    COUNT(*) AS total_rows,
    COUNT(csv_extra_column) AS non_null_extra_column
FROM db1b_ticket;
