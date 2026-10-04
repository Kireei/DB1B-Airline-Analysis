-- DB1B Airline Analysis
-- 07_join_analysis.sql
--
-- Purpose:
-- Validate and analyze relationships across DB1BTicket, DB1BMarket, and DB1BCoupon.
--
-- Key grains:
-- DB1BTicket: 1 row = 1 itinerary
-- DB1BMarket: 1 row = 1 market within an itinerary
-- DB1BCoupon: 1 row = 1 coupon/segment
--
-- IMPORTANT:
-- JOINs can change grain and create double counting. Always document
-- relationship cardinality, target grain, and aggregation level.


-- F1) Basic Ticket <-> Market JOIN
SELECT
    t.itin_id,
    t.itin_fare,
    m.mkt_id,
    m.mkt_fare,
    m.mkt_distance,
    m.rp_carrier
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id
LIMIT 20;

-- Interpretation:
-- One itinerary can map to multiple market rows, so the JOIN result is
-- market-level rather than itinerary-level.


-- F2) Compare row counts before and after Ticket <-> Market JOIN
SELECT COUNT(*) AS total_ticket_rows
FROM db1b_ticket;

SELECT COUNT(*) AS total_market_rows
FROM db1b_market;

SELECT COUNT(*) AS total_join_ticket_market
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id;

-- Observed:
-- Ticket rows = 20,066,076
-- Market rows = 32,766,855
-- JOIN rows   = 32,766,855
--
-- Interpretation:
-- The JOIN follows the Market grain because every Market row has a matching
-- Ticket row.


-- F3) Double-counting risk for itinerary-level measures
SELECT SUM(itin_fare) AS ticket_itin_fare
FROM db1b_ticket;

SELECT SUM(t.itin_fare) AS joined_itin_fare
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id;

-- Interpretation:
-- SUM(itin_fare) becomes much larger after the JOIN because itinerary fare
-- repeats once for every matching Market row.


-- F4) Safe aggregation back to itinerary grain
SELECT
    t.itin_id,
    COUNT(m.mkt_id) AS market_count
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id
GROUP BY t.itin_id;

WITH x AS (
    SELECT
        t.itin_id,
        COUNT(m.mkt_id) AS market_count
    FROM db1b_ticket AS t
    JOIN db1b_market AS m
        ON t.itin_id = m.itin_id
    GROUP BY t.itin_id
)
SELECT AVG(market_count) AS avg_markets_per_itinerary
FROM x;

WITH x AS (
    SELECT
        t.itin_id,
        COUNT(m.mkt_id) AS market_count
    FROM db1b_ticket AS t
    JOIN db1b_market AS m
        ON t.itin_id = m.itin_id
    GROUP BY t.itin_id
)
SELECT SUM(market_count) AS total_market_rows_reconstructed
FROM x;

-- Observed:
-- AVG markets per itinerary ≈ 1.6329
-- SUM market_count = 32,766,855
--
-- Interpretation:
-- Aggregating by itin_id restores itinerary grain before subsequent analysis.


-- F5) Basic Market <-> Coupon JOIN
SELECT
    m.mkt_id,
    m.itin_id,
    c.seq_num,
    c.distance,
    c.fare_class,
    m.mkt_fare,
    m.mkt_distance
FROM db1b_market AS m
JOIN db1b_coupon AS c
    ON m.mkt_id = c.mkt_id
LIMIT 20;

-- Interpretation:
-- One Market can map to multiple Coupon rows.
-- Market-level values such as mkt_fare and mkt_distance repeat across Coupon
-- segments within the same Market.


-- F6) Validate Market.mkt_coupons against Coupon row counts
WITH coupon_count AS (
    SELECT
        mkt_id,
        COUNT(*) AS coupon_rows
    FROM db1b_coupon
    GROUP BY mkt_id
)
SELECT
    m.mkt_id,
    m.mkt_coupons,
    c.coupon_rows
FROM db1b_market AS m
JOIN coupon_count AS c
    ON m.mkt_id = c.mkt_id
WHERE m.mkt_coupons <> c.coupon_rows;

-- Observed:
-- 0 mismatch rows.
--
-- Interpretation:
-- Market.mkt_coupons is consistent with the number of Coupon rows per mkt_id.


-- F7) JOIN all three tables at Coupon/segment grain
SELECT
    c.itin_id,
    c.mkt_id,
    c.seq_num,
    t.itin_fare,
    m.mkt_fare,
    c.distance,
    c.origin,
    c.dest,
    c.rp_carrier
FROM db1b_coupon AS c
JOIN db1b_ticket AS t
    ON c.itin_id = t.itin_id
JOIN db1b_market AS m
    ON c.mkt_id = m.mkt_id
LIMIT 5;

-- Interpretation:
-- The result grain is one Coupon segment per row while carrying selected
-- itinerary-level and market-level attributes.


-- F8) Carrier with highest average segment distance for round-trip itineraries
SELECT
    c.rp_carrier,
    COUNT(*) AS segment_count,
    AVG(c.distance) AS avg_segment_distance
FROM db1b_coupon AS c
JOIN db1b_ticket AS t
    ON c.itin_id = t.itin_id
WHERE t.round_trip = 1
GROUP BY c.rp_carrier
ORDER BY avg_segment_distance DESC;

-- Observed top result:
-- HA has the highest average segment distance, about 1,880.36 miles, with
-- roughly 251k segment rows in the displayed result.
--
-- Interpretation:
-- This is a segment-level metric. It should not be confused with itinerary-level
-- distance or market-level distance.


-- ============================================================
-- Relational JOIN takeaways
-- ============================================================
--
-- 1. Ticket -> Market is one-to-many through itin_id.
-- 2. Market -> Coupon is one-to-many through mkt_id.
-- 3. JOINs change grain and can duplicate higher-level measures.
-- 4. Itinerary-level measures such as itin_fare should not be summed after a
--    one-to-many JOIN without first restoring itinerary grain.
-- 5. Market-level measures can repeat across Coupon rows.
-- 6. CTEs are useful for re-aggregating to the intended grain before analysis.
-- 7. The three-table JOIN is valid when Ticket joins on itin_id and Market joins
--    on mkt_id.
-- 8. Metric choice must match grain: Ticket, Market, and Coupon distances answer
--    different analytical questions.
