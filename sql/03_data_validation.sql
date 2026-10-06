-- Data quality checks on db1b_ticket (2024 Q1-Q4): NULLs, ranges, zero fares,
-- short distances, outliers and flag values.
-- Nothing is deleted here. Unusual rows are noted and, where needed, filtered
-- in the analysis queries.


-- ============================================================
-- A. Basic checks
-- ============================================================

-- 1) NULL count per column
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

-- 0 NULLs in all 25 columns.


-- 2) Min / max of the numeric columns
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

-- coupons:       1 to 13
-- year:          2024 to 2024
-- quarter:       1 to 4
-- fare_per_mile: 0 to 174.6450
-- itin_fare:     0 to 46,510
-- passengers:    1 to 992
-- distance:      17 to 31,662
-- miles_flown:   17 to 26,472
--
-- The zero fares, very short distances and the highest fares are looked at
-- in section B.


-- 3) Negative values
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

-- None.


-- ============================================================
-- B. Unusual values
-- ============================================================

-- B1) Rows with itin_fare = 0
SELECT COUNT(*) AS itin_fare_zero
FROM db1b_ticket
WHERE itin_fare = 0;

SELECT
    SUM(CASE WHEN itin_fare = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS itin_fare_zero_pct
FROM db1b_ticket;

-- 16,233 rows, about 0.0809% of the table.


-- B2) What do the zero-fare rows look like?
SELECT
    itin_id,
    quarter,
    rp_carrier,
    round_trip,
    passengers,
    distance,
    miles_flown,
    fare_per_mile,
    bulk_fare
FROM db1b_ticket
WHERE itin_fare = 0
ORDER BY quarter, itin_id
LIMIT 100;

-- These columns don't show why the fare is zero.


-- B3) Do zero-fare rows also have fare_per_mile = 0?
SELECT COUNT(*) AS zero_fare_nonzero_fpm
FROM db1b_ticket
WHERE itin_fare = 0
  AND fare_per_mile <> 0;

SELECT COUNT(*) AS both_zero
FROM db1b_ticket
WHERE itin_fare = 0
  AND fare_per_mile = 0;

-- Yes. both_zero = 16,233, the same count as B1, and no counterexample.


-- B4) Rows with fare_per_mile = 0
SELECT COUNT(*) AS fare_per_mile_zero
FROM db1b_ticket
WHERE fare_per_mile = 0;

-- 16,233 rows, matching B1. Queries about paid fares filter these out with
-- WHERE; the rows stay in the raw table.


-- B5) Very short flown distances
SELECT COUNT(*) AS short_distance_rows
FROM db1b_ticket
WHERE miles_flown < 100;

SELECT
    itin_id,
    rp_carrier,
    coupons,
    round_trip,
    origin,
    distance,
    miles_flown,
    itin_fare,
    fare_per_mile
FROM db1b_ticket
WHERE miles_flown < 100
ORDER BY miles_flown ASC, itin_fare DESC
LIMIT 20;

-- 5,742 rows are under 100 miles; the shortest is 17.
-- Kept: a short distance alone doesn't make a row wrong.


-- B6) Are distance and miles_flown always the same?
SELECT
    COUNT(*) FILTER (WHERE distance = miles_flown) AS equal_distance,
    COUNT(*) FILTER (WHERE distance > miles_flown) AS distance_greater,
    COUNT(*) FILTER (WHERE distance < miles_flown) AS distance_smaller
FROM db1b_ticket;

-- distance = miles_flown : 19,612,790
-- distance > miles_flown :    453,286
-- distance < miles_flown :          0
--
-- Not interchangeable, so each query has to pick the one it actually needs.


-- B7) Highest itinerary fares
SELECT
    itin_id,
    itin_fare,
    coupons,
    round_trip,
    rp_carrier,
    distance,
    miles_flown,
    fare_per_mile
FROM db1b_ticket
ORDER BY itin_fare DESC
LIMIT 10;

-- Far above typical fares, with mixed distances and coupon counts. Kept.


-- B8) Highest fare per mile
SELECT
    itin_id,
    fare_per_mile,
    itin_fare,
    coupons,
    distance,
    miles_flown,
    rp_carrier
FROM db1b_ticket
ORDER BY fare_per_mile DESC
LIMIT 10;

-- Mostly fairly high fares on short distances.


-- B9) Flag values, including dollar_cred
SELECT 'round_trip' AS column_name,
       CAST(round_trip AS VARCHAR) AS value,
       COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY round_trip

UNION ALL

SELECT 'on_line',
       CAST(on_line AS VARCHAR),
       COUNT(*)
FROM db1b_ticket
GROUP BY on_line

UNION ALL

SELECT 'bulk_fare',
       CAST(bulk_fare AS VARCHAR),
       COUNT(*)
FROM db1b_ticket
GROUP BY bulk_fare

UNION ALL

SELECT 'dollar_cred',
       CAST(dollar_cred AS VARCHAR),
       COUNT(*)
FROM db1b_ticket
GROUP BY dollar_cred
ORDER BY column_name, value;

-- All four only contain 0 and 1.


-- B10) Decisions for the analysis
--
-- - The raw table stays as it is; no rows are deleted.
-- - Zero-fare rows are filtered with WHERE in queries about paid fares.
-- - Short-distance rows and the extreme fares stay in.
-- - distance and miles_flown are treated as two different measures.


-- ============================================================
-- C. csv_extra_column
-- ============================================================

-- The extra empty CSV field from 01_schema.sql. Check that it is empty before
-- dropping it.

SELECT
    COUNT(*) AS total_rows,
    COUNT(csv_extra_column) AS non_null_extra_column
FROM db1b_ticket;
