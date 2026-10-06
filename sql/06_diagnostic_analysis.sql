-- Digging into some of the findings from 05_exploratory_analysis.sql.
-- The notes below are possible explanations, not proven causes.


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

-- In these groups round-trip has more coupons and a higher fare per mile than
-- one-way. Both could be behind the higher fare.


-- E2) Why can one-way average fare exceed round-trip at high distance groups?
--     Same query as E1, sorted from the highest distance group.
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

-- One-way has far fewer rows than round-trip in the high groups, so a few
-- extreme fares can pull its average up. In some groups its fare per mile is
-- also higher.


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

-- The high fares come with long distances and more coupons in some segments.


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

-- The decline shows up for the carriers, quarters and trip types checked
-- here. The query doesn't say what drives it.


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

-- HA has a higher fare per mile than G4 in the distance groups they share,
-- while average distance doesn't always move the same way.


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

-- WN has the largest share in both states in every quarter.
-- Share = carrier itineraries / all itineraries for that state and quarter.


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

-- Several of the biggest segments are two-coupon ones, especially WN
-- round-trip in distance groups 2-4. WN alone doesn't explain it for the
-- whole table.


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

-- The high average isn't spread evenly. The top rows are concentrated in a
-- few origin states, NJ in particular.
