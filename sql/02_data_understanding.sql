-- First look at db1b_ticket (2024 Q1-Q4): row counts, grain, and the values
-- in the main categorical columns.

-- 1) Total rows
SELECT COUNT(*) AS total_data
FROM db1b_ticket;

-- 20,066,076


-- 2) Rows per quarter
SELECT
    quarter,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Q1 = 4,533,056
-- Q2 = 5,231,861
-- Q3 = 5,114,707
-- Q4 = 5,186,452


-- 3) Is itin_id unique?
SELECT
    itin_id,
    COUNT(*) AS occurrences
FROM db1b_ticket
GROUP BY itin_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- No rows returned, so 1 row = 1 itinerary.


-- 4) Values in the categorical columns

-- 0/1 flags
SELECT 'round_trip' AS column_name,
       CAST(round_trip AS VARCHAR) AS value,
       COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY round_trip

UNION ALL

SELECT 'on_line' AS column_name,
       CAST(on_line AS VARCHAR) AS value,
       COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY on_line

UNION ALL

SELECT 'bulk_fare' AS column_name,
       CAST(bulk_fare AS VARCHAR) AS value,
       COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY bulk_fare;

-- All three only contain 0 and 1.


-- itin_geo_type
SELECT
    itin_geo_type,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY itin_geo_type
ORDER BY itin_geo_type;

-- 1 and 2 only.


-- Reporting carriers
SELECT
    rp_carrier,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY rp_carrier
ORDER BY rp_carrier;

-- Two-character codes: 3M, 9E, AA, AS, B6, ...


-- Origin country
SELECT
    origin_country,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY origin_country
ORDER BY origin_country;

-- US only.


-- Origin states
SELECT
    origin_state,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY origin_state
ORDER BY origin_state;

-- State / territory codes: AK, AL, AR, AZ, ...
