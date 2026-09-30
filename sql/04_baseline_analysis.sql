-- DB1B Airline Analysis
-- 04_baseline_analysis.sql
--
-- Purpose:
-- Build a high-level picture of the 2024 DB1B Ticket data after validation.
--
-- Scope:
-- U.S. Department of Transportation, BTS DB1B Ticket 2024 Q1-Q4.
--
-- Note:
-- These are descriptive baseline metrics. They describe what appears in the
-- dataset and should not be interpreted as causal explanations.


-- C1) Overall itinerary-fare statistics
SELECT
    AVG(itin_fare) AS avg_itin_fare,
    MIN(itin_fare) AS min_itin_fare,
    MAX(itin_fare) AS max_itin_fare
FROM db1b_ticket;

SELECT
    AVG(itin_fare) AS avg_itin_fare_paid,
    MIN(itin_fare) AS min_itin_fare_paid,
    MAX(itin_fare) AS max_itin_fare_paid
FROM db1b_ticket
WHERE itin_fare > 0;

-- Observed results:
-- All rows:       AVG ≈ 442.31, MIN = 0, MAX = 46,510
-- itin_fare > 0: AVG ≈ 442.66, MIN = 1, MAX = 46,510
--
-- Interpretation:
-- Removing zero-fare rows changes the overall average only slightly because
-- zero-fare rows represent a very small share of the dataset.


-- C2) Overall fare-per-mile statistics
SELECT
    AVG(fare_per_mile) AS avg_fare_per_mile,
    MIN(fare_per_mile) AS min_fare_per_mile,
    MAX(fare_per_mile) AS max_fare_per_mile
FROM db1b_ticket;

SELECT
    AVG(fare_per_mile) AS avg_fare_per_mile_positive,
    MIN(fare_per_mile) AS min_fare_per_mile_positive,
    MAX(fare_per_mile) AS max_fare_per_mile_positive
FROM db1b_ticket
WHERE fare_per_mile > 0;

-- Observed results:
-- All rows:             AVG ≈ 0.28243, MIN = 0, MAX = 174.6450
-- fare_per_mile > 0:   AVG ≈ 0.28266, MIN = 0.0001, MAX = 174.6450


-- C3) Itinerary distribution by quarter
SELECT
    quarter,
    COUNT(*) AS total_itinerary,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS itinerary_percentage
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Observed results:
-- Q1 ≈ 22.59%
-- Q2 ≈ 26.07%
-- Q3 ≈ 25.49%
-- Q4 ≈ 25.85%
--
-- Interpretation:
-- Q2 has the largest share of itinerary records in the 2024 dataset.


-- C4) Average itinerary fare by quarter
SELECT
    quarter,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Observed results:
-- Q1 ≈ 446.23
-- Q2 ≈ 444.90
-- Q3 ≈ 421.69
-- Q4 ≈ 456.59


-- C5) Average fare per mile by quarter
SELECT
    quarter,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Observed pattern:
-- Q4 has the highest average fare per mile, while Q3 is the lowest.


-- C6) Top 10 reporting carriers by itinerary count
SELECT
    rp_carrier,
    COUNT(*) AS itinerary_total
FROM db1b_ticket
GROUP BY rp_carrier
ORDER BY itinerary_total DESC
LIMIT 10;

-- Observed top carriers include:
-- WN, AA, DL, UA, OO, NK, AS, F9, YX, MQ
--
-- WN has the largest itinerary count in this dataset.


-- C7) Highest average itinerary fare among sufficiently represented carriers
SELECT
    rp_carrier,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY rp_carrier
HAVING COUNT(*) >= 200000
ORDER BY average_itin_fare DESC
LIMIT 10;

-- Analytical choice:
-- A minimum threshold of 200,000 itinerary records is used so that very small
-- carriers do not dominate the ranking through unstable averages.
--
-- Observed result:
-- DL has the highest average itinerary fare among carriers that meet this
-- threshold, followed by UA and AS.


-- C8) One-way vs round-trip comparison
SELECT
    round_trip,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(distance) AS average_distance,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY round_trip
ORDER BY round_trip;

-- Observed results:
-- round_trip = 0:
--   count ≈ 7,953,857
--   avg itin_fare ≈ 319.58
--   avg distance ≈ 1,474.70
--   avg fare_per_mile ≈ 0.298
--
-- round_trip = 1:
--   count ≈ 12,112,219
--   avg itin_fare ≈ 522.90
--   avg distance ≈ 2,545.16
--   avg fare_per_mile ≈ 0.272
--
-- Interpretation:
-- Round-trip itinerary records are more numerous and have higher average total
-- fare and distance, while their average fare per mile is slightly lower.


-- C9) Average fare and distance by number of coupons
SELECT
    coupons,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(distance) AS average_distance
FROM db1b_ticket
GROUP BY coupons
ORDER BY coupons ASC;

-- Observed result:
-- The largest group is 2 coupons, with about 10,604,511 itinerary records.
--
-- Pattern:
-- As coupon count increases, average distance and average itinerary fare
-- generally increase. Very high coupon counts have much smaller sample sizes.


-- C10) Fare patterns by distance group
SELECT
    distance_group,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY distance_group
ORDER BY distance_group ASC;

-- Interpretation:
-- Average itinerary fare generally increases across higher distance groups,
-- while average fare per mile generally decreases.
--
-- Caution:
-- Extreme distance groups have much smaller sample sizes than the central
-- groups, so their averages should be interpreted together with COUNT(*).


-- C11) Top 10 origin states by itinerary count
SELECT
    origin_state,
    COUNT(*) AS itinerary_total
FROM db1b_ticket
GROUP BY origin_state
ORDER BY itinerary_total DESC
LIMIT 10;

-- Observed results:
-- CA = 2,450,120
-- TX = 1,869,588
-- FL = 1,830,990
-- NY = 1,020,491
-- IL =   766,498
-- VA =   760,622
-- CO =   651,669
-- NC =   641,793
-- PA =   576,833
-- AZ =   563,110


-- C12) Baseline takeaways
--
-- 1. Q2 has the largest share of itinerary records, at about 26.07%.
-- 2. WN has the largest itinerary count; among carriers with at least 200,000
--    records, DL has the highest average itinerary fare.
-- 3. Round-trip itinerary records are more common and have higher average total
--    fare and distance, but slightly lower average fare per mile.
-- 4. Two-coupon itineraries form the largest coupon group.
-- 5. Average itinerary fare generally rises across higher distance groups,
--    while fare per mile generally falls; extreme distance groups should be
--    interpreted with their smaller sample sizes in mind.
--
-- Additional descriptive note:
-- CA is the origin state with the largest itinerary count in this dataset.
