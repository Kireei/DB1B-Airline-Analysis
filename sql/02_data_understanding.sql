-- DB1B Airline Analysis
-- 02_data_understanding.sql
--
-- Purpose:
-- Understand DB1BTicket before attempting business analysis.
--
-- Source:
-- U.S. Department of Transportation, Bureau of Transportation Statistics (BTS)
-- DB1B Airline Origin & Destination Survey, 2024 Q1-Q4.
--
-- Grain conclusion:
-- 1 row represents 1 itinerary / ticket record in DB1BTicket.
-- This is supported by the uniqueness check on itin_id below.

-- 1) Total row count
SELECT COUNT(*) AS total_data
FROM db1b_ticket;

-- Result:
-- 20,066,076 rows


-- 2) Distribution by quarter
SELECT
    quarter,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY quarter
ORDER BY quarter;

-- Results:
-- Q1 = 4,533,056
-- Q2 = 5,231,861
-- Q3 = 5,114,707
-- Q4 = 5,186,452


-- 3) Check whether itin_id is unique
SELECT
    itin_id,
    COUNT(*) AS occurrences
FROM db1b_ticket
GROUP BY itin_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Result:
-- No rows returned.
-- No repeated itin_id values were found in the 2024 DB1BTicket data.


-- 4) Explore key categorical fields

-- Binary indicators
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

-- Result:
-- round_trip, on_line, and bulk_fare contain values 0 and 1 only.


-- Itinerary geography type
SELECT
    itin_geo_type,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY itin_geo_type
ORDER BY itin_geo_type;

-- Result:
-- itin_geo_type contains values 1 and 2.


-- Reporting carrier codes
SELECT
    rp_carrier,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY rp_carrier
ORDER BY rp_carrier;

-- Result:
-- Carrier codes include values such as 3M, 9E, AA, AS, B6, and others.


-- Origin country
SELECT
    origin_country,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY origin_country
ORDER BY origin_country;

-- Result:
-- origin_country contains US only.


-- Origin state codes
SELECT
    origin_state,
    COUNT(*) AS total_rows
FROM db1b_ticket
GROUP BY origin_state
ORDER BY origin_state;

-- Result:
-- Values are U.S. state / territory codes such as AK, AL, AR, AZ, etc.
