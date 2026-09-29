-- DB1B Airline Analysis
-- 03_data_validation.sql
--
-- Purpose:
-- Validate completeness, duplication, ranges, and potentially anomalous values
-- before using DB1BTicket for business analysis.
--
-- Suggested checks:
-- - NULL counts and percentages
-- - repeated identifiers
-- - quarter/year coverage
-- - negative / zero / extreme numeric values
-- - categorical consistency
-- - csv_extra_column validation
--
-- Do not automatically delete or fix suspicious values.
-- First determine whether they are data-quality issues or valid DB1B behavior.


