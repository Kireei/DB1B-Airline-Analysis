-- DB1B Airline Analysis
-- 05_exploratory_analysis.sql
--
-- Purpose:
-- Explore patterns that emerge from validated baseline results.
--
-- Workflow:
-- detect an interesting pattern -> segment it -> compare it -> document limits.
--
-- Scope:
-- U.S. Department of Transportation, BTS DB1B Ticket 2024 Q1-Q4.
--
-- Note:
-- These are exploratory findings. They describe associations and segment-level
-- patterns and should not be interpreted as causal explanations.


-- D1) Does the fare pattern differ by quarter within the same distance group?
SELECT
    distance_group,
    quarter,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, quarter
ORDER BY distance_group, quarter;

-- Interpretation:
-- Within the same distance group, average itinerary fare changes across
-- quarters, but the observed differences are generally modest.


-- D2) Which carriers appear more or less expensive within the same distance group?
SELECT
    distance_group,
    rp_carrier,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, rp_carrier
ORDER BY distance_group ASC, avg_itin_fare ASC;

-- Exploratory observations:
-- G4 appears among the lower-average-fare carriers in distance groups 1-3.
-- PT, G7, and HA appear among higher-average-fare carriers in selected groups.
--
-- Limitation:
-- Carrier sample sizes differ substantially within each distance group, so
-- averages from smaller samples should be interpreted more cautiously.


-- D3) Does the one-way vs round-trip difference remain within the same distance group?
SELECT
    distance_group,
    round_trip,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, round_trip
ORDER BY distance_group, round_trip;

-- Interpretation:
-- Round-trip average fare is higher than one-way average fare across many lower
-- distance groups. In some higher distance groups, the pattern reverses.
-- Counts should be reviewed alongside averages because extreme distance groups
-- contain fewer observations.


-- D4) How does coupon count relate to fare after controlling for distance group?
SELECT
    distance_group,
    coupons,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY distance_group, coupons
ORDER BY distance_group, coupons;

-- Interpretation:
-- Within the same distance group, average itinerary fare generally tends to
-- increase as coupon count increases.
--
-- This is a descriptive association, not a correlation or causal conclusion.


-- D5) Which origin states have the highest average fare after applying a minimum sample?
SELECT
    origin_state,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY origin_state
HAVING COUNT(*) >= 50000
ORDER BY avg_itin_fare DESC;

-- Observed result:
-- AK has the highest average itinerary fare among origin states with at least
-- 50,000 itinerary records in this dataset.


-- D6) Does fare per mile decrease with distance group for major carriers?
SELECT
    rp_carrier,
    distance_group,
    COUNT(*) AS total_itin,
    AVG(fare_per_mile) AS avg_fpm
FROM db1b_ticket
WHERE rp_carrier IN ('WN', 'AA', 'DL', 'UA', 'OO')
  AND distance_group <= 3
GROUP BY rp_carrier, distance_group
ORDER BY rp_carrier, distance_group;

-- Interpretation:
-- For the major carriers checked, average fare per mile declines from distance
-- group 1 through distance group 3.
--
-- Scope limitation:
-- This query only evaluates distance groups 1-3, so the finding should not be
-- generalized to the full distance-group range without further analysis.


-- D7) Which carrier is most dominant in each major origin state?
WITH ranking_carrier AS (
    SELECT
        origin_state,
        rp_carrier,
        COUNT(*) AS total_itin,
        ROW_NUMBER() OVER (
            PARTITION BY origin_state
            ORDER BY COUNT(*) DESC
        ) AS ranking_rp_carrier
    FROM db1b_ticket
    GROUP BY origin_state, rp_carrier
)
SELECT
    origin_state,
    rp_carrier,
    total_itin
FROM ranking_carrier
WHERE ranking_rp_carrier = 1
  AND origin_state IN ('CA', 'TX', 'FL', 'NY', 'IL')
ORDER BY origin_state;

-- Observed results:
-- CA -> WN
-- FL -> AA
-- IL -> UA
-- NY -> DL
-- TX -> WN
--
-- WN is the dominant carrier by itinerary count in both CA and TX among the
-- five selected origin states.


-- D8) Does the one-way / round-trip distribution differ across carriers?
SELECT
    rp_carrier,
    round_trip,
    COUNT(*) AS total_itin,
    COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY rp_carrier) AS percentage
FROM db1b_ticket
GROUP BY rp_carrier, round_trip
ORDER BY rp_carrier, round_trip;

-- Interpretation:
-- Trip-type mix differs across carriers. For example, 3M has a larger one-way
-- share, while 9E and AA have larger round-trip shares in the observed results.
-- Percentages provide a fairer cross-carrier comparison than raw counts alone.


-- D9) Do coupon patterns differ across major carriers?
SELECT
    rp_carrier,
    coupons,
    COUNT(*) AS count_itin
FROM db1b_ticket
WHERE rp_carrier IN ('WN', 'AA', 'DL', 'UA', 'OO')
  AND coupons IN (1, 2, 3, 4, 5)
GROUP BY rp_carrier, coupons
ORDER BY rp_carrier, coupons;

-- Interpretation:
-- The selected major carriers show broadly similar coupon-count patterns, with
-- meaningful differences in absolute itinerary volume.
--
-- Optional extension:
-- Convert counts to within-carrier percentages for a more direct comparison of
-- coupon distributions across carriers.


-- D10a) Exploratory question: in which quarter do one-way passengers exceed round-trip?
SELECT
    quarter,
    SUM(passengers) AS total_passengers,
    CASE
        WHEN round_trip = 0 THEN 'one-way'
        WHEN round_trip = 1 THEN 'round-trip'
    END AS trip_type
FROM db1b_ticket
GROUP BY quarter, round_trip
ORDER BY quarter ASC, round_trip;

-- Observed result:
-- Round-trip passenger totals exceed one-way passenger totals in Q1-Q4.


-- D10b) Find interesting carrier + distance group + trip-type combinations
SELECT
    rp_carrier,
    distance_group,
    round_trip,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY rp_carrier, distance_group, round_trip
HAVING COUNT(*) >= 50000
ORDER BY avg_itin_fare DESC;

-- Observed top combination:
-- UA + distance_group 11 + round-trip has the highest average itinerary fare
-- among combinations with at least 50,000 itinerary records.
--
-- Interpretation:
-- This is a segment-level result, not evidence that UA is the highest-fare
-- carrier overall.


-- ============================================================
-- Exploratory takeaways
-- ============================================================
--
-- 1. Fare differences across quarters are relatively modest within the same
--    distance groups.
-- 2. Carrier fare comparisons change by distance group, and sample size matters.
-- 3. Round-trip fares are generally higher within lower distance groups, but the
--    pattern can reverse in higher distance groups.
-- 4. Within a distance group, higher coupon counts generally correspond to
--    higher average itinerary fares.
-- 5. AK has the highest average itinerary fare among states with >= 50,000 rows.
-- 6. For major carriers, fare per mile declines from distance groups 1 to 3.
-- 7. Dominant carriers differ across major origin states.
-- 8. One-way / round-trip composition varies by carrier.
-- 9. Major carriers show similar broad coupon patterns but different volumes.
-- 10. High-fare combinations become clearer when carrier, distance, trip type,
--     and minimum sample size are analyzed together.
