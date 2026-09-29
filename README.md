# DB1B Airline Analysis

End-to-end data analysis portfolio project using the **U.S. Department of Transportation, Bureau of Transportation Statistics (BTS) DB1B Airline Origin & Destination Survey**.

## Project goal

This project is designed to practice how a data analyst works with large, real-world relational data:

- understand table grain and business definitions
- validate raw data before analysis
- use PostgreSQL for large-scale SQL analysis
- join multiple DB1B tables safely
- use Pandas for deeper EDA and visualization
- investigate notable patterns without overclaiming
- communicate findings through an executive-style summary

## Scope

Current analysis period: **2024 Q1-Q4**

Planned core tables:

- **DB1BTicket** — itinerary/ticket-level data
- **DB1BMarket** — directional market-level data
- **DB1BCoupon** — flight coupon/segment-level data

The raw source files contain millions of records and are not committed to this repository.

## Tools

- PostgreSQL 18
- pgAdmin 4
- Python
- Pandas
- Matplotlib
- Google Colab / Jupyter
- Git & GitHub

## Repository structure

```text
DB1B-Airline-Analysis/
│
├── data/
│   └── README.md
│
├── sql/
│   ├── README.md
│   ├── 01_schema.sql
│   ├── 02_data_understanding.sql
│   ├── 03_data_validation.sql
│   ├── 04_baseline_analysis.sql
│   ├── 05_exploratory_analysis.sql
│   ├── 06_diagnostic_analysis.sql
│   └── 07_join_analysis.sql
│
├── notebooks/
│   └── README.md
│
├── outputs/
│   └── README.md
│
├── images/
│   └── README.md
│
├── .gitignore
└── README.md
```

## Current progress

- [x] Download DB1BTicket 2024 Q1-Q4
- [x] Inspect DB1BTicket schema with Pandas
- [x] Load DB1BTicket 2024 Q1-Q4 into PostgreSQL
- [x] Validate row distribution by quarter
- [ ] Complete DB1BTicket data understanding
- [ ] Complete DB1BTicket data validation
- [ ] Import and validate DB1BMarket
- [ ] Import and validate DB1BCoupon
- [ ] Define table relationships and join grain
- [ ] Build baseline business analysis
- [ ] Perform exploratory and diagnostic analysis
- [ ] Continue analysis in Pandas
- [ ] Create final visualizations
- [ ] Write findings, limitations, and executive summary

## Analytical workflow

```text
Raw BTS files
    ↓
PostgreSQL raw tables
    ↓
Data understanding
    ↓
Data validation
    ↓
Relational JOIN analysis
    ↓
Baseline business metrics
    ↓
Exploratory / diagnostic analysis
    ↓
Pandas EDA & visualization
    ↓
Insights + limitations
    ↓
Executive summary
```

## Data source

U.S. Department of Transportation  
Bureau of Transportation Statistics (BTS)  
Airline Origin & Destination Survey (DB1B)

Raw data should be downloaded from the official BTS TranStats source. See `data/README.md` for project data-handling notes.

## Portfolio note

This repository intentionally emphasizes **reasoning and analytical workflow**, not only SQL syntax. SQL files will document the questions being answered, the grain used, validation logic, and limitations behind each result.
