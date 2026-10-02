-- DB1B Airline Analysis
-- 06_diagnostic_analysis.sql
--
-- Purpose:
-- Drill down into selected findings from the exploratory stage and test
-- plausible explanations without treating descriptive associations as causal.
--
-- Scope:
-- U.S. Department of Transportation, BTS DB1B Ticket 2024 Q1-Q4.


-- E1) Why is round-trip average fare higher than one-way within the same distance group?
SELECT
    distance_group,
    AVG(coupons) AS avg_coupons,
    AVG(distance) AS avg_distance,
    AVG(fare_per_mile) AS avg_fpm,
    COUNT(*) AS total_itin,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type
FROM db1b_ticket
GROUP BY distance_group, round_trip
ORDER BY distance_group ASC;

-- Finding:
-- Round-trip records show higher average coupon counts and higher average
-- fare-per-mile than one-way records within the same distance groups shown.
-- These factors may help explain the higher average itinerary fare, but the
-- analysis does not establish causality.


-- E2) Why can one-way average fare exceed round-trip at high distance groups?
SELECT
    distance_group,
    AVG(coupons) AS avg_coupons,
    AVG(distance) AS avg_distance,
    AVG(fare_per_mile) AS avg_fpm,
    COUNT(*) AS total_itin,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type
FROM db1b_ticket
GROUP BY distance_group, round_trip
ORDER BY distance_group DESC;

-- Finding:
-- At high distance groups, one-way sample sizes are much smaller than
-- round-trip sample sizes, making one-way averages more sensitive to extreme
-- observations. In some groups, one-way average fare-per-mile is also higher.


-- E3) Why does AK show a high average itinerary fare?
SELECT
    origin_state,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type,
    rp_carrier,
    AVG(coupons) AS avg_coupons,
    AVG(itin_fare) AS avg_itin_fare,
    AVG(distance) AS avg_distance,
    AVG(fare_per_mile) AS avg_fpm,
    COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY origin_state) AS type_trip_pct
FROM db1b_ticket
WHERE origin_state = 'AK'
GROUP BY origin_state, round_trip, rp_carrier
ORDER BY AVG(itin_fare) DESC;

-- Finding:
-- High average itinerary fare in AK appears together with relatively high
-- average distance and coupon counts in some segments. These are candidate
-- explanatory factors for further testing rather than proven causes.


-- E4) Why does fare_per_mile tend to decline as distance_group increases?
SELECT
    distance_group,
    quarter,
    rp_carrier,
    AVG(fare_per_mile) AS avg_fpm,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type
FROM db1b_ticket
WHERE rp_carrier IN ('WN', 'AA', 'DL')
GROUP BY distance_group, rp_carrier, quarter, round_trip
ORDER BY distance_group, quarter ASC;

-- Finding:
-- The decline in average fare-per-mile as distance group increases remains
-- visible across several carriers, quarters, and trip types checked. The
-- analysis does not identify the mechanism causing the decline.


-- E5) Why do some carriers appear more expensive within the same distance group?
SELECT
    rp_carrier,
    distance_group,
    AVG(coupons) AS avg_coupons,
    AVG(distance) AS avg_distance,
    AVG(fare_per_mile) AS avg_fpm
FROM db1b_ticket
WHERE rp_carrier IN ('HA', 'G4')
GROUP BY rp_carrier, distance_group
ORDER BY distance_group ASC;

-- Finding:
-- Within the same distance groups observed, HA consistently shows higher
-- average fare-per-mile than G4, while average distance does not always move
-- in the same direction.


-- E6) Why is WN dominant in CA and TX?
SELECT
    rp_carrier,
    origin_state,
    quarter,
    COUNT(*) AS total_itin,
    COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY origin_state, quarter
        ) AS carrier_share
FROM db1b_ticket
WHERE origin_state IN ('CA', 'TX')
GROUP BY origin_state, quarter, rp_carrier
ORDER BY origin_state, quarter, carrier_share DESC;

-- Finding:
-- WN has the highest carrier share in the CA and TX state-quarter comparisons
-- shown in the diagnostic output. The share is calculated against all carrier
-- itinerary records within the same origin_state and quarter.


-- E7) Why are two-coupon itineraries so dominant?
SELECT
    coupons,
    rp_carrier,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type,
    COUNT(*) AS trip_type_count,
    distance_group
FROM db1b_ticket
GROUP BY rp_carrier, round_trip, distance_group, coupons
ORDER BY trip_type_count DESC;

-- Finding:
-- Two-coupon itineraries are strongly represented in several high-volume
-- segments, especially WN round-trip records in distance groups 2-4. This does
-- not imply that WN alone explains two-coupon dominance across the full dataset.


-- E8) Why is UA + distance_group 11 + round-trip a high-fare large segment?
SELECT
    rp_carrier,
    origin_state,
    distance_group,
    quarter,
    round_trip,
    coupons,
    AVG(distance) AS avg_distance,
    AVG(fare_per_mile) AS avg_fpm,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
WHERE rp_carrier = 'UA'
  AND distance_group = 11
  AND round_trip = 1
GROUP BY rp_carrier, origin_state, distance_group, quarter, round_trip, coupons
HAVING COUNT(*) >= 1000
ORDER BY AVG(itin_fare) DESC;

-- Finding:
-- High average fare in the UA + distance group 11 + round-trip segment is not
-- evenly distributed across all subsegments. In the displayed output, some of
-- the highest values are concentrated in specific origins, especially NJ.


-- ============================================================
-- Diagnostic takeaways
-- ============================================================
--
-- 1. Round-trip fare differences remain after controlling for distance group
--    and coincide with differences in coupons and fare-per-mile.
-- 2. High-distance one-way reversals should be read together with much smaller
--    sample sizes and, in some groups, higher fare-per-mile.
-- 3. AK's high average fare appears alongside relatively high distance and
--    coupon counts in selected segments.
-- 4. The distance-group / fare-per-mile pattern persists across several
--    carriers, quarters, and trip types.
-- 5. HA vs G4 differences within the same distance groups are visible in
--    average fare-per-mile, while distance alone does not explain the pattern.
-- 6. WN holds the largest observed carrier share in CA and TX comparisons when
--    share is calculated within the same state-quarter.
-- 7. Two-coupon dominance is visible across several high-volume segments and is
--    especially strong in WN round-trip distance groups 2-4.
-- 8. The high-fare UA group-11 round-trip segment contains meaningful internal
--    variation by origin, quarter, and coupon count.
--
-- These results support diagnostic hypotheses, not causal conclusions.
