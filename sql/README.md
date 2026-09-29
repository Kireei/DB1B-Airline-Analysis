# SQL

This folder contains the PostgreSQL workflow for the DB1B analysis.

Planned files:
1. `01_schema.sql` — raw table definitions and ingestion notes
2. `02_data_understanding.sql` — grain, row counts, category inspection
3. `03_data_validation.sql` — nulls, duplicates, ranges, anomalous values
4. `04_baseline_analysis.sql` — high-level market and fare metrics
5. `05_exploratory_analysis.sql` — deeper SQL exploration
6. `06_diagnostic_analysis.sql` — drill-down analysis for notable findings
7. `07_join_analysis.sql` — Ticket + Market + Coupon relational analysis

Keep SQL readable and grouped by business question. Add comments explaining the purpose of each query.
