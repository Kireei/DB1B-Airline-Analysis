# SQL

This folder contains the PostgreSQL workflow for the project.

1. `01_schema.sql`: raw table definitions and ingestion notes
2. `02_data_understanding.sql`: grain, row counts, and category checks
3. `03_data_validation.sql`: nulls, ranges, unusual values, and cleaning scope
4. `04_baseline_analysis.sql`: high-level descriptive metrics
5. `05_exploratory_analysis.sql`: segmented comparisons and pattern exploration
6. `06_diagnostic_analysis.sql`: drill-down analysis for selected findings
7. `07_join_analysis.sql`: Ticket, Market, and Coupon relationship analysis

The SQL files are kept readable and grouped by analytical question. Comments document the result grain, sample-size concerns, and interpretation limits.
