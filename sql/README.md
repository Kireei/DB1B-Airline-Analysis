# SQL

This folder contains the PostgreSQL workflow for the DB1B analysis.

Current files:
1. `01_schema.sql` — raw table definitions and ingestion notes
2. `02_data_understanding.sql` — grain, row counts, category inspection
3. `03_data_validation.sql` — nulls, ranges, anomalous values, cleaning scope
4. `04_baseline_analysis.sql` — high-level descriptive metrics
5. `05_exploratory_analysis.sql` — segmented comparisons and pattern exploration
6. `06_diagnostic_analysis.sql` — drill-down analysis for notable findings
7. `07_join_analysis.sql` — Ticket + Market + Coupon relational analysis

Completed SQL stages:
- Data understanding
- Data validation / cleaning investigation
- Baseline analysis
- Exploratory analysis
- Diagnostic analysis
- Relational JOIN analysis

Next stage:
- Pandas EDA and visualization

Keep SQL readable and grouped by business question. Add comments explaining the
purpose of each query, the grain of the result, relevant sample-size constraints,
and interpretation limits.
