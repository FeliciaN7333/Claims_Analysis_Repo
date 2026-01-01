# Claims Analysis Project (Portfolio)
Healthcare claims analytics project focused on cost drivers, payment integrity (overpayments), provider performance, and member utilization.  
Built in **SQL (PostgreSQL)** with a **Power BI dashboard** (shared as screenshots).

> **Note:** Dataset is **synthetic** for portfolio use.

---

## Problem Statement
Healthcare payers must control medical costs, ensure accurate claim payments, and maintain audit-ready data. This project analyzes claims data to identify cost drivers, detect potential overpayments, evaluate provider performance, and assess member utilization—especially for chronic-condition members.

The goal is to turn raw claims data into analytics-ready outputs that support payment integrity, cost containment, and utilization management.

## Responsibilities
- Performed data validation + data quality checks in SQL
- Built analytics-ready cleaned views for reporting
- Developed Power BI dashboard pages: Executive Summary, Cost Drivers, Overpayments, Provider Performance, Member Utilization
- Documented data quality issues, fixes, and methodology for audit-ready analysis
 
 ---

## Data Dictionary
See: documentation/data_dictionary/data_dictionary.md

## Data Quality Issues + Fixes
See: documentation/data_quality/Data_Quality_Log.pdf

## SQL Cleaning Steps
See: sql/cleaning/

## Analysis Methodology
See: documentation/methodology.md

## Dashboard Insights (Top 2�3)
1) Payment Integrity: (your 0.20% / .34K / 40 claims insight)
2) Spend Concentration: (65+ highest spend + chronic split)
3) Provider/Network Signal: (volume vs avg paid + in/out network comparison)

## Business Recommendations
(3�5 bullets)

## Notes
- Report shown via screenshots; slicers were used during development.
- Dataset is synthetic; procedure code count is smaller than production claims.
