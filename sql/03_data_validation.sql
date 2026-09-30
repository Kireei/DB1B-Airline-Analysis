-- DB1B Airline Analysis
-- 03_data_validation.sql
--
-- Purpose:
-- Validate completeness, duplication, ranges, cross-column consistency, and
-- potentially anomalous values before using DB1BTicket for business analysis.
--
-- Analytical principle:
-- Suspicious or extreme values are not automatically removed. They are first
-- investigated because unusual data can still be valid.
--
-- Scope:
-- U.S. Department of Transportation, BTS DB1B Ticket 2024 Q1-Q4.


-- ============================================================
-- A. CORE DATA-QUALITY CHECKS
-- ============================================================

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
-- Interpretation:
-- Very short distances, zero fares, high itinerary fares, and high passenger
-- counts are investigation candidates rather than automatic errors.


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


-- ============================================================
-- B. DATA CLEANING INVESTIGATION & ANALYTICAL SCOPE
-- ============================================================

-- B1) How many rows have itin_fare = 0?
SELECT COUNT(*) AS itin_fare_zero
FROM db1b_ticket
WHERE itin_fare = 0;

SELECT
    SUM(CASE WHEN itin_fare = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS itin_fare_zero_pct
FROM db1b_ticket;

-- Results:
-- 16,233 rows
-- Approximately 0.0809% of the 20,066,076 DB1BTicket rows.
--
-- Interpretation:
-- Zero-fare records are a very small part of the dataset. They are documented
-- as a data-quality note, not automatically treated as errors.


-- B2) Inspect the characteristics of zero-fare records
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

-- Interpretation:
-- This query is used to profile the zero-fare subset across carrier, quarter,
-- trip type, passenger count, and distance. The available fields do not by
-- themselves establish why the fare is zero.


-- B3) Do all itin_fare = 0 records also have fare_per_mile = 0?

-- Search for a counterexample.
SELECT COUNT(*) AS zero_fare_nonzero_fpm
FROM db1b_ticket
WHERE itin_fare = 0
  AND fare_per_mile <> 0;

-- Confirm the both-zero subset.
SELECT COUNT(*) AS both_zero
FROM db1b_ticket
WHERE itin_fare = 0
  AND fare_per_mile = 0;

-- Result:
-- both_zero = 16,233, equal to the full itin_fare = 0 count.
-- No counterexample was observed in the checked results.
--
-- Interpretation:
-- In the 2024 DB1BTicket data used here, zero itinerary fare and zero fare per
-- mile occur together. This demonstrates cross-column consistency, but it
-- does not explain the business reason for the zero values.


-- B4) How many rows have fare_per_mile = 0?
SELECT COUNT(*) AS fare_per_mile_zero
FROM db1b_ticket
WHERE fare_per_mile = 0;

-- Result:
-- 16,233 rows.
--
-- Interpretation:
-- The count matches itin_fare = 0. For paid-fare analysis these rows may be
-- excluded with an explicit WHERE filter, while remaining preserved in raw data.


-- B5) Inspect very short flown distances
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

-- Results:
-- 5,742 rows have miles_flown < 100.
-- Minimum observed miles_flown = 17.
--
-- Interpretation:
-- Very short distances are unusual and worth investigating, but distance alone
-- is not sufficient evidence that a record is invalid.


-- B6) Are distance and miles_flown always the same?
SELECT
    COUNT(*) FILTER (WHERE distance = miles_flown) AS equal_distance,
    COUNT(*) FILTER (WHERE distance > miles_flown) AS distance_greater,
    COUNT(*) FILTER (WHERE distance < miles_flown) AS distance_smaller
FROM db1b_ticket;

-- Results:
-- distance = miles_flown : 19,612,790
-- distance > miles_flown :    453,286
-- distance < miles_flown :          0
--
-- Interpretation:
-- The two measures are equal for most records, but they are not universally
-- identical. Because the fields have different definitions, downstream
-- analysis should select the metric that matches the business question.


-- B7) Candidate itinerary-fare outliers
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

-- Interpretation:
-- The top records contain itinerary fares far above typical values, with varied
-- distances and coupon counts. These are investigation candidates, not proven
-- data errors. Fare can be affected by factors not yet represented in this
-- stage of the analysis.


-- B8) Candidate fare-per-mile outliers
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

-- Interpretation:
-- In the top-10 profile, extreme fare_per_mile values often combine relatively
-- high itinerary fares with short distances. This top-10 inspection is not
-- sufficient to claim correlation or causality.


-- B9) Validate categorical flags
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

-- Result:
-- The checked flags use values 0 and 1.
--
-- Interpretation:
-- No out-of-domain binary values were observed in this scope.


-- B10) Analytical-scope decision
--
-- 1. Preserve the raw table. No row is deleted only because it is unusual.
-- 2. Keep itin_fare = 0 and fare_per_mile = 0 in raw data.
--    For paid-fare metrics, filter them explicitly in the analytical query.
-- 3. Keep short-distance records unless additional evidence demonstrates an error.
-- 4. Treat distance and miles_flown as separate measures with different meanings.
-- 5. Treat extreme fare and fare_per_mile records as investigation candidates.
-- 6. Use the validated 0/1 flags as analytical dimensions when relevant.
--
-- Conclusion:
-- Bagian B did not find strong evidence requiring permanent removal of records
-- from raw DB1BTicket. The output of this stage is an analytical scope:
-- documented anomalies, validated relationships, and explicit filters for
-- downstream metrics.


-- ============================================================
-- C. INGESTION ARTIFACT CHECK
-- ============================================================

-- The source CSV contains an extra empty physical field, imported as
-- csv_extra_column so PostgreSQL matches the source column count.
-- Validate this column before dropping it from a cleaned table/view.

SELECT
    COUNT(*) AS total_rows,
    COUNT(csv_extra_column) AS non_null_extra_column
FROM db1b_ticket;
