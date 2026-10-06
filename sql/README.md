# SQL

PostgreSQL scripts, run in this order:

1. `01_schema.sql`: raw tables for Ticket, Market and Coupon
2. `02_data_understanding.sql`: row counts, grain, category values
3. `03_data_validation.sql`: NULLs, ranges, unusual values, what gets filtered
4. `04_baseline_analysis.sql`: overall numbers
5. `05_exploratory_analysis.sql`: the same metrics split by segment
6. `06_diagnostic_analysis.sql`: closer look at selected findings
7. `07_join_analysis.sql`: Ticket, Market and Coupon joins

The comments under each query are the results from the 2024 data.
