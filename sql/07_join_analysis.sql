-- Joins across db1b_ticket, db1b_market and db1b_coupon.
--
-- db1b_ticket: 1 row = 1 itinerary
-- db1b_market: 1 row = 1 market within an itinerary
-- db1b_coupon: 1 row = 1 coupon / segment
--
-- Joining down a level repeats the upper-level values, so sums and counts
-- have to be done at the right grain.


-- F1) Ticket <-> Market
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

-- An itinerary can have several markets, so each row here is a market.


-- F2) Row counts before and after the Ticket <-> Market join
SELECT COUNT(*) AS total_ticket_rows
FROM db1b_ticket;

SELECT COUNT(*) AS total_market_rows
FROM db1b_market;

SELECT COUNT(*) AS total_join_ticket_market
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id;

-- Ticket rows = 20,066,076
-- Market rows = 32,766,855
-- Join rows   = 32,766,855
--
-- Join rows = market rows, so every market row has a matching ticket.


-- F2b) Does every ticket have at least one market row?
SELECT COUNT(*) AS tickets_without_market
FROM db1b_ticket AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM db1b_market AS m
    WHERE m.itin_id = t.itin_id
);

-- 0, so every itinerary also appears in Market.


-- F3) Double counting itin_fare after the join
SELECT SUM(itin_fare) AS ticket_itin_fare
FROM db1b_ticket;

SELECT SUM(t.itin_fare) AS joined_itin_fare
FROM db1b_ticket AS t
JOIN db1b_market AS m
    ON t.itin_id = m.itin_id;

-- The joined sum is much larger: itin_fare is repeated once for every market
-- of the itinerary.


-- F4) Aggregating back to one row per itinerary
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

-- Markets per itinerary: 1.6329 on average
-- Sum of market_count:   32,766,855 (same as the market row count in F2)


-- F5) Market <-> Coupon
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

-- A market can have several coupons; mkt_fare and mkt_distance repeat on each
-- of them.


-- F6) Does mkt_coupons match the number of coupon rows?
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

-- 0 rows, so it matches for every market.


-- F6b) Is itin_id + mkt_id + seq_num unique in Coupon?
SELECT COUNT(*) AS duplicate_keys
FROM (
    SELECT itin_id, mkt_id, seq_num
    FROM db1b_coupon
    GROUP BY itin_id, mkt_id, seq_num
    HAVING COUNT(*) > 1
) AS d;

-- 0 duplicates.


-- F7) All three tables at coupon grain
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

-- One row per coupon, with the itinerary fare and market fare attached.


-- F8) Average segment distance per carrier, round-trip itineraries only
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

-- HA is highest: about 1,880.36 miles over roughly 251k segments.
-- This is distance per segment, not per itinerary or per market.
