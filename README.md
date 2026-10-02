# DB1B Airline Analysis

End-to-end data analysis portfolio project using the **U.S. Department of Transportation, Bureau of Transportation Statistics (BTS) DB1B Airline Origin & Destination Survey**.

## Project goal

This project is designed to practice how a data analyst works with large, real-world relational data:

- understand table grain and business definitions
- validate raw data before analysis
- investigate suspicious values before deciding whether to clean or filter them
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
- [x] Complete DB1BTicket data understanding
- [x] Complete DB1BTicket data validation
- [x] Complete DB1BTicket data-quality / cleaning investigation and analytical scope
- [x] Complete DB1BTicket baseline analysis
- [x] Complete DB1BTicket exploratory analysis
- [ ] Import and validate DB1BMarket
- [ ] Import and validate DB1BCoupon
- [ ] Define table relationships and join grain
- [x] Complete DB1BTicket diagnostic analysis
- [ ] Continue analysis in Pandas
- [ ] Create final visualizations
- [ ] Write findings, limitations, and executive summary

## Completed DB1BTicket validation findings

The current 2024 DB1BTicket validation stage produced several important analytical notes:

- **20,066,076 rows** were loaded across Q1-Q4.
- The checked business columns contained **no SQL NULL values** and no negative values in the validated numeric fields.
- **16,233 rows** have `itin_fare = 0`, approximately **0.0809%** of the dataset.
- The same **16,233 rows** also have `fare_per_mile = 0` in the checked results.
- **5,742 rows** have `miles_flown < 100`; the minimum observed value is 17 miles.
- `distance` and `miles_flown` are equal for **19,612,790** rows, while **453,286** rows have `distance > miles_flown`.
- Extreme `itin_fare` and `fare_per_mile` values are treated as investigation candidates, not automatically deleted as errors.
- Binary flags checked in this stage use the expected 0/1 domain.

### Analytical-scope decision

The raw DB1BTicket table is preserved. Unusual records are documented rather than deleted without evidence. Downstream analysis can apply explicit filters when the metric requires a narrower population—for example, a paid-fare analysis can use `itin_fare > 0` while data-quality analysis retains all records.

## Completed baseline findings

The DB1BTicket baseline analysis provides a descriptive picture of the 2024 data:

- **Q2** contains the largest share of itinerary records, at about **26.07%**.
- **WN** has the largest itinerary count.
- Among carriers with at least **200,000** itinerary records, **DL** has the highest average itinerary fare.
- Round-trip itinerary records are more numerous and have higher average total fare and distance than one-way records, while their average fare per mile is slightly lower.
- **2-coupon** itineraries form the largest coupon group, with about **10.60 million** records.
- Average itinerary fare generally increases across higher distance groups, while average fare per mile generally decreases.
- **CA** is the origin state with the largest itinerary count, at about **2.45 million** records.

## Completed exploratory findings

The exploratory stage tests whether baseline patterns remain visible after segmentation:

- Fare differences across quarters are relatively modest within the same distance groups.
- Carrier average fares differ within the same distance group, but sample size varies substantially across carrier-distance segments.
- Round-trip average fare is generally higher within many lower distance groups, while some higher groups show the opposite pattern.
- Within the same distance group, average itinerary fare generally rises as coupon count increases.
- **AK** has the highest average itinerary fare among origin states with at least **50,000** itinerary records.
- For the major carriers checked (**WN, AA, DL, UA, OO**), average fare per mile declines from distance groups 1 through 3.
- Among five major origin states, the dominant carrier by itinerary count is **WN in CA and TX, AA in FL, UA in IL, and DL in NY**.
- One-way vs round-trip composition differs by carrier; percentage shares are more informative than raw counts for cross-carrier comparison.
- Major carriers show broadly similar coupon-count patterns, although absolute itinerary volumes differ.
- Among `carrier × distance_group × round_trip` segments with at least **50,000** itineraries, **UA + distance group 11 + round-trip** has the highest observed average itinerary fare.

These exploratory findings identify patterns for later diagnostic analysis. They do not by themselves establish causal explanations.

## Completed diagnostic findings

The diagnostic stage drills into selected exploratory patterns and tests plausible explanations while keeping causal claims separate from descriptive evidence:

- Round-trip records show higher average coupon counts and fare-per-mile than one-way records within the same distance groups examined.
- At high distance groups, one-way samples are much smaller than round-trip samples; in some groups, one-way fare-per-mile is also higher.
- AK's high average itinerary fare appears alongside relatively high average distance and coupon counts in selected segments.
- The decline in average fare-per-mile across higher distance groups remains visible across several carriers, quarters, and trip types.
- Within matched distance groups, HA shows higher average fare-per-mile than G4 in the segments examined, while average distance does not always move in the same direction.
- WN has the highest observed carrier share in the CA and TX state-quarter comparisons shown when share is calculated against all carriers in the same state-quarter.
- Two-coupon itineraries are strongly represented in several high-volume segments, especially WN round-trip records in distance groups 2-4.
- Within UA + distance group 11 + round-trip, high average fares are not uniform across subsegments; some of the highest values are concentrated in specific origins, especially NJ in the displayed output.

These findings are diagnostic rather than causal: they identify factors and subsegments that may help explain the observed patterns, but they do not establish cause-and-effect relationships.

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
Data-quality investigation & analytical scope
    ↓
Baseline business metrics
    ↓
Exploratory analysis
    ↓
Diagnostic analysis
    ↓
Relational JOIN analysis
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

This repository intentionally emphasizes **reasoning and analytical workflow**, not only SQL syntax. SQL files document the questions being answered, the grain used, validation logic, analytical scope, and limitations behind each result.
