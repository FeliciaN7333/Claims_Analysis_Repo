# Analysis Methodology

## Goal
Turn raw (synthetic) claims data into clean, consistent reporting views, then answer common payer/TPA questions around:
- **Cost drivers** (where the money is going)
- **Payment integrity** (possible overpayments / exceptions)
- **Provider performance** (who drives cost and why)
- **Member utilization** (who uses care the most)

---

## Process (how the project was built)

### 1) Load and organize the data
Imported the main tables used in claims reporting:
- members
- claims
- providers
- diagnosis_codes

### 2) Run data quality checks (make sure the data is reliable)
Checked for common issues that can break reporting:
- row counts (sanity check)
- missing values (NULLs)
- duplicates
- invalid / unexpected values
- cross-table matches (ex: claims reference valid members/providers/diagnosis codes)

Any issues found were documented in the Data Quality Log.

### 3) Build a “clean” reporting layer
Created cleaned SQL views so Power BI and analysis queries always use consistent logic:
- kept NULLs when they truly mean “missing/unknown” (did **not** replace with 0)
- added reporting fields such as:
  - age buckets
  - chronic-condition flag
  - paid > allowed flag (payment exception indicator)

### 4) Write analysis queries with clear output levels
Built analysis queries with a clear “grain” so each result matches a dashboard visual, such as:
- **month-level** trends
- **provider-level** comparisons
- **member-level** utilization summaries

### 5) Create dashboard + summarize insights
Built Power BI pages and summarized results into:
- key insights (what stands out)
- actions/recommendations (what a claims team could do next)

---

## Where to find everything
- Cleaned SQL views: `sql/cleaning/`
- Analysis queries: `sql/analysis/`
- Data quality scripts: `sql/dq_checks/`
- Power BI screenshots: `visuals/power_bi_screenshots/`
- Data Quality Log: `documentation/data_quality/Data_Quality_Log.pdf`
 