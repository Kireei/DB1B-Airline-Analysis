# Data

Source: U.S. Department of Transportation, Bureau of Transportation Statistics, Airline Origin and Destination Survey (DB1B).

Project period: 2024 Q1-Q4.

Main source tables:
- DB1BTicket
- DB1BMarket
- DB1BCoupon

Raw files are intentionally not committed because they are very large.

## Included samples

Small sample files are included so the table structure can be inspected without downloading the full raw dataset:

- `samples/sample_ticket.csv`
- `samples/sample_market.csv`
- `samples/sample_coupon.csv`

These sample rows are for structure and grain inspection only. Full SQL results require the complete BTS DB1B files.

See `DATA_DICTIONARY.md` for the table grain, relationship keys, and important columns.
