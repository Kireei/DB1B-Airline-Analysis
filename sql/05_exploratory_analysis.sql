-- Follow-up on the baseline (04): the same metrics split by distance group,
-- carrier, trip type, coupons and origin state.


-- D1) Does the fare differ by quarter within the same distance group?
SELECT
    distance_group,
    quarter,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, quarter
ORDER BY distance_group, quarter;

-- A little, but the differences between quarters are small.


-- D2) Which carriers are cheaper or more expensive within the same distance group?
SELECT
    distance_group,
    rp_carrier,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, rp_carrier
ORDER BY distance_group ASC, avg_itin_fare ASC;

-- G4 is among the cheapest in groups 1-3. PT, G7 and HA are among the most
-- expensive in some groups.
-- Carrier counts per group vary a lot, so check total_itin before comparing.


-- D3) Is round-trip still more expensive than one-way within the same distance group?
SELECT
    distance_group,
    round_trip,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY distance_group, round_trip
ORDER BY distance_group, round_trip;

-- Yes in many of the lower distance groups. In some of the higher groups it
-- flips, but those groups have few rows.


-- D4) Coupon count vs fare within the same distance group
SELECT
    distance_group,
    coupons,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY distance_group, coupons
ORDER BY distance_group, coupons;

-- Within a distance group, fare generally goes up with the coupon count.


-- D5) Origin states with the highest average fare (min 50,000 itineraries)
SELECT
    origin_state,
    COUNT(*) AS total_itin,
    AVG(itin_fare) AS avg_itin_fare
FROM db1b_ticket
GROUP BY origin_state
HAVING COUNT(*) >= 50000
ORDER BY avg_itin_fare DESC;

-- AK is highest.


-- D6) Does fare per mile fall with distance group for the big carriers?
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

-- Yes, for all five it falls from group 1 to group 3.
-- Only groups 1-3 are checked here.


-- D7) Largest carrier in each of the big origin states
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

-- CA -> WN
-- FL -> AA
-- IL -> UA
-- NY -> DL
-- TX -> WN


-- D8) One-way / round-trip mix per carrier
SELECT
    rp_carrier,
    round_trip,
    COUNT(*) AS total_itin,
    COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY rp_carrier) AS percentage
FROM db1b_ticket
GROUP BY rp_carrier, round_trip
ORDER BY rp_carrier, round_trip;

-- The mix differs by carrier: 3M has a larger one-way share, 9E and AA a
-- larger round-trip share.


-- D9) Coupon counts for the big carriers
SELECT
    rp_carrier,
    coupons,
    COUNT(*) AS count_itin
FROM db1b_ticket
WHERE rp_carrier IN ('WN', 'AA', 'DL', 'UA', 'OO')
  AND coupons IN (1, 2, 3, 4, 5)
GROUP BY rp_carrier, coupons
ORDER BY rp_carrier, coupons;

-- Similar shape for all five, just different volumes. Percentages within
-- each carrier would make this easier to compare.


-- D10a) Is there a quarter where one-way passengers exceed round-trip?
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

-- No. Round-trip is higher in all four quarters.


-- D10b) Highest-fare carrier + distance group + trip type combinations
--       (min 50,000 itineraries)
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

-- UA, distance group 11, round-trip is at the top.
-- That is one segment, not UA as a whole.
