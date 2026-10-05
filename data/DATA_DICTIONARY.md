# Data Dictionary

This project uses three DB1B tables with different grains.

## DB1BTicket

**Grain:** 1 row = 1 itinerary  
**Main key:** `itin_id`

Important columns:

| Column | Meaning |
|---|---|
| `itin_id` | Itinerary identifier |
| `coupons` | Number of coupon or segment records in the itinerary |
| `quarter` | Quarter of the year |
| `origin` | Origin airport code |
| `origin_state` | Origin state code |
| `round_trip` | 0 = one-way, 1 = round-trip |
| `rp_carrier` | Reporting carrier |
| `itin_fare` | Itinerary fare |
| `fare_per_mile` | Fare per mile |
| `distance` | Itinerary distance |
| `distance_group` | Distance bucket |
| `miles_flown` | Miles flown |

## DB1BMarket

**Grain:** 1 row = 1 market within an itinerary  
**Main key:** `mkt_id`  
**Relationship key:** `itin_id`

Important columns:

| Column | Meaning |
|---|---|
| `itin_id` | Links Market to Ticket |
| `mkt_id` | Market identifier |
| `mkt_coupons` | Number of coupon rows in the market |
| `origin` | Market origin airport |
| `dest` | Market destination airport |
| `rp_carrier` | Reporting carrier |
| `mkt_fare` | Market fare |
| `mkt_distance` | Market distance |
| `mkt_distance_group` | Market distance bucket |
| `mkt_miles_flown` | Market miles flown |
| `non_stop_miles` | Non-stop market distance |

## DB1BCoupon

**Grain:** 1 row = 1 coupon or segment  
**Composite key used for validation:** `itin_id + mkt_id + seq_num`  
**Relationship keys:** `itin_id`, `mkt_id`

Important columns:

| Column | Meaning |
|---|---|
| `itin_id` | Links Coupon to Ticket |
| `mkt_id` | Links Coupon to Market |
| `seq_num` | Coupon sequence number |
| `coupons` | Itinerary coupon count |
| `origin` | Segment origin airport |
| `dest` | Segment destination airport |
| `rp_carrier` | Reporting carrier |
| `fare_class` | Fare class |
| `distance` | Segment distance |
| `distance_group` | Segment distance bucket |

## Validated relationships

```text
DB1BTicket
1 itinerary
    |
    | 1 to many through itin_id
    v
DB1BMarket
1 market
    |
    | 1 to many through mkt_id
    v
DB1BCoupon
1 coupon or segment
```

The project also checked that:
- every Market `itin_id` has a matching Ticket
- every Ticket `itin_id` appears in Market
- `mkt_coupons` matches the number of Coupon rows per `mkt_id`
- the validated Coupon composite key has no duplicate rows in the tested data

The sample CSV files are only small examples of the source structure. They are not intended to reproduce the full SQL results.
