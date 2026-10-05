# DB1B Airline Analysis

Portfolio project using the **U.S. Department of Transportation, Bureau of Transportation Statistics (BTS) DB1B Airline Origin and Destination Survey**.

The project focuses on airfare, distance, carrier behavior, trip structure, geography, and relationships between Ticket, Market, and Coupon tables.

## Project scope

- Period: **2024 Q1-Q4**
- Main tables:
  - **DB1BTicket**: itinerary level
  - **DB1BMarket**: market level
  - **DB1BCoupon**: coupon or segment level
- Main tools: PostgreSQL, pgAdmin, Python, Pandas, Matplotlib, Git, GitHub

Raw DB1B files are not committed because the source data is very large.

## Workflow

```text
Raw DB1B files
    ↓
PostgreSQL import
    ↓
Data understanding and validation
    ↓
Baseline analysis
    ↓
Exploratory analysis
    ↓
Diagnostic analysis
    ↓
Relational JOIN analysis
    ↓
Python EDA and visualization
    ↓
Final insights and limitations
```

## Repository structure

```text
DB1B-Airline-Analysis/
│
├── data/
│   ├── DATA_DICTIONARY.md
│   └── samples/
├── sql/
│   ├── 01_schema.sql
│   ├── 02_data_understanding.sql
│   ├── 03_data_validation.sql
│   ├── 04_baseline_analysis.sql
│   ├── 05_exploratory_analysis.sql
│   ├── 06_diagnostic_analysis.sql
│   └── 07_join_analysis.sql
│
├── notebooks/
│   └── 01_python_eda_visualization.ipynb
│
├── outputs/
├── images/
└── README.md
```

## Main findings

- The 2024 DB1BTicket table contains **20,066,076 itinerary records**.
- Q2 has the largest share of itinerary records, while Q4 has the highest average itinerary fare at about **456.59**.
- **WN** has the largest itinerary count.
- Round-trip itineraries are more common and have higher average total fare and distance, but slightly lower fare per mile than one-way itineraries.
- Two-coupon itineraries form the largest coupon group, with about **52.8%** of itinerary records.
- Average itinerary fare generally increases with distance group, while average fare per mile generally decreases.
- **AK** has the highest average itinerary fare among origin states that meet the project minimum sample threshold.
- WN has the largest carrier share in CA and TX across the four quarters in the exported comparison.
- At segment level, **HA** has the highest average round-trip segment distance in the exported carrier summary.

## Relational model

The project validated the following relationships:

```text
DB1BTicket
1 row = 1 itinerary
        |
        | 1 to many
        v
DB1BMarket
1 row = 1 market
        |
        | 1 to many
        v
DB1BCoupon
1 row = 1 coupon or segment
```

Important lesson from the JOIN stage: a correct join key is not enough. The output grain also needs to be understood because higher-level measures can be duplicated after a one-to-many JOIN.

## Python and visualization

PostgreSQL is used for the large raw tables and most aggregation work. Python uses smaller analytical CSV outputs exported from SQL.

The notebook in `notebooks/01_python_eda_visualization.ipynb` validates the exported summaries and creates charts for:

- quarter fare comparison
- distance group and fare
- distance group and fare per mile
- carrier volume
- one-way vs round-trip
- coupon distribution
- WN share in CA and TX
- round-trip segment distance by carrier

## Reproduce the project

There are two ways to review this project.

### Quick review

1. Open the SQL files to see the analytical workflow.
2. Inspect the small files in `data/samples/` to understand the source table structure.
3. Use the aggregated CSV files in `outputs/`.
4. Run `notebooks/01_python_eda_visualization.ipynb` to reproduce the charts.

This path does not require the full raw DB1B dataset.

### Full reproduction

1. Download DB1BTicket, DB1BMarket, and DB1BCoupon for 2024 Q1-Q4 from BTS.
2. Load the files into PostgreSQL using the schema in `sql/01_schema.sql`.
3. Run the SQL files in order from `02_data_understanding.sql` through `07_join_analysis.sql`.
4. Export the small aggregated query results or use the included `outputs/` files.
5. Run the Python notebook.

See `data/DATA_DICTIONARY.md` for table grain and relationship keys.

## Notes

This project is mainly descriptive and diagnostic. Findings such as higher fares, carrier differences, or distance patterns are treated as associations unless the analysis provides stronger evidence.

Aggregated CSV files are included only for reproducible charts. Raw multi-million-row DB1B files remain local.

## Data source

U.S. Department of Transportation  
Bureau of Transportation Statistics  
Airline Origin and Destination Survey (DB1B)

