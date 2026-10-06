-- Baseline numbers for db1b_ticket (2024 Q1-Q4): fares, quarters, carriers,
-- trip type, coupons, distance groups and origin states.


-- C1) Itinerary fare overall, with and without zero fares
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

-- All rows:      avg 442.31, min 0, max 46,510
-- itin_fare > 0: avg 442.66, min 1, max 46,510
--
-- Dropping the zero fares barely moves the average.


-- C2) Fare per mile overall, with and without zeros
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

-- All rows:          avg 0.28243, min 0,      max 174.6450
-- fare_per_mile > 0: avg 0.28266, min 0.0001, max 174.6450


-- C3) Share of itineraries per quarter
SELECT
    quarter,
    COUNT(*) AS total_itinerary,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS itinerary_percentage
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Q1 = 22.59%
-- Q2 = 26.07%  (largest)
-- Q3 = 25.49%
-- Q4 = 25.85%


-- C4) Average itinerary fare per quarter
SELECT
    quarter,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Q1 = 446.23
-- Q2 = 444.90
-- Q3 = 421.69
-- Q4 = 456.59


-- C5) Average fare per mile per quarter
SELECT
    quarter,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Q4 is highest, Q3 lowest.


-- C6) Top 10 carriers by itinerary count
SELECT
    rp_carrier,
    COUNT(*) AS itinerary_total
FROM db1b_ticket
GROUP BY rp_carrier
ORDER BY itinerary_total DESC
LIMIT 10;

-- WN, AA, DL, UA, OO, NK, AS, F9, YX, MQ


-- C7) Highest average fare among carriers with at least 200,000 itineraries
SELECT
    rp_carrier,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare
FROM db1b_ticket
GROUP BY rp_carrier
HAVING COUNT(*) >= 200000
ORDER BY average_itin_fare DESC
LIMIT 10;

-- The 200,000 cut-off keeps small carriers with noisy averages out of the
-- ranking.
-- DL is highest, then UA and AS.


-- C8) One-way vs round-trip
SELECT
    round_trip,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(distance) AS average_distance,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY round_trip
ORDER BY round_trip;

--                 one-way (0)   round-trip (1)
-- itineraries       7,953,857       12,112,219
-- avg itin_fare        319.58           522.90
-- avg distance       1,474.70         2,545.16
-- avg fare_per_mile     0.298            0.272
--
-- Round trips are more common, longer and more expensive in total, but
-- slightly cheaper per mile.


-- C9) Fare and distance by number of coupons
SELECT
    coupons,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(distance) AS average_distance
FROM db1b_ticket
GROUP BY coupons
ORDER BY coupons ASC;

-- 2 coupons is the biggest group (10,604,511 itineraries).
-- Fare and distance generally go up with the coupon count; the highest counts
-- have very few rows.


-- C10) Fare by distance group
SELECT
    distance_group,
    COUNT(*) AS itinerary_total,
    AVG(itin_fare) AS average_itin_fare,
    AVG(fare_per_mile) AS average_fare_per_mile
FROM db1b_ticket
GROUP BY distance_group
ORDER BY distance_group ASC;

-- Average fare generally goes up with distance group and fare per mile
-- generally goes down. The longest-distance groups have far fewer rows, so
-- read their averages together with the count.


-- C11) Top 10 origin states by itinerary count
SELECT
    origin_state,
    COUNT(*) AS itinerary_total
FROM db1b_ticket
GROUP BY origin_state
ORDER BY itinerary_total DESC
LIMIT 10;

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
