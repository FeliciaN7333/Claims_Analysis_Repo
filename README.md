# Claims Analysis Project (Portfolio)
Healthcare claims analytics project focused on cost drivers, payment integrity (overpayments), provider performance, and member utilization.  
Built in **SQL (PostgreSQL)** with a **Power BI dashboard** (shared as screenshots).
 **Note:** Dataset is **synthetic** for portfolio use.

---

## Problem Statement
Healthcare payers must control medical costs, ensure accurate claim payments, and maintain audit ready data.  
This project analyzes (synthetic) claims data to identify cost drivers, flag potential overpayments, evaluate provider performance, and assess member utilization across chronic and non-chronic populations.  

Goal: produce analytics-ready outputs that support payment integrity, cost containment, and utilization management.

## Responsibilities
- Performed data validation + data quality checks in SQL
- Built analytics ready cleaned views for reporting
- Developed Power BI dashboard pages: Executive Summary, Cost Drivers, Overpayments, Provider Performance, Member Utilization
- Documented data quality issues, fixes, and methodology for audit ready analysis
 
 ---

## Data Dictionary
See: [documentation/data_dictionary/data_dictionary.md](documentation/data_dictionary/data_dictionary.md)

## Data Quality Issues + Fixes
See: [documentation/data_quality/Data_Quality_Log.pdf](documentation/data_quality/Data_Quality_Log.pdf)

## DQ Checklist (Reusable)
The standardized checklist I used for every table (kept in the same order; N/A where not applicable).  
See: [documentation/data_quality/dq_checklist.md](documentation/data_quality/dq_checklist.md)


## DQ SQL Scripts (Evidence)
- Claims DQ: [claims_dq.sql](sql/dq_checks/claims_dq.sql)
- Members DQ: [members_dq.sql](sql/dq_checks/members_dq.sql)
- Providers DQ: [providers_dq.sql](sql/dq_checks/providers_dq.sql)
- Diagnosis Codes DQ: [diagnosis_codes_dq.sql](sql/dq_checks/diagnosis_codes_dq.sql)

## SQL Cleaning (Cleaned Views)
Cleaned / standardized reporting views (used by Power BI and analysis queries).  
See: [sql/cleaning](sql/cleaning)

Cleaned view scripts:
- Claims: [cleaned_claims.sql](sql/cleaning/cleaned_claims.sql)
- Members: [cleaned_members.sql](sql/cleaning/cleaned_members.sql)
- Providers: [cleaned_providers.sql](sql/cleaning/cleaned_providers.sql)
- Diagnosis Codes: [cleaned_diagnosis_codes.sql](sql/cleaning/cleaned_diagnosis_codes.sql)


## Analysis Methodology
See: [documentation/methodology.md](documentation/methodology.md)

## Power BI Dashboard (Screenshots)
See: [visuals/power_bi_screenshots](visuals/power_bi_screenshots)

Dashboard pages:
- Executive Summary: [01_executive_summary.png](visuals/power_bi_screenshots/01_executive_summary.png)
- Cost Drivers: [02_cost_drivers.png](visuals/power_bi_screenshots/02_cost_drivers.png)
- Overpayments: [03_overpayments.png](visuals/power_bi_screenshots/03_overpayments.png)
- Provider Performance: [04_provider_performance.png](visuals/power_bi_screenshots/04_provider_performance.png)
- Member Utilization: [05_member_utilization_default.png](visuals/power_bi_screenshots/05_member_utilization_default.png)

## Dashboard Insights (Top 3)
1) **Payment Integrity:** Overall leakage is low (0.20%), but **40 paid > allowed** claims totaling **$28.34K** which makes them high confidence audit targets worth review (recoverable dollars + configuration validation).  
2) **Spend Concentration:** Spend is concentrated in **inpatient** services and the **65+** age segment. At the same time, **non-chronic members still account for 57% of total spend**, which means high cost is not limited to chronic members both **repeat utilization (chronic)** and **high cost episodes (non-chronic, often inpatient)** are key drivers (site of care + avoidable admissions focus).  
3) **Provider Concentration:** Most providers cluster in mid volume/mid paid ranges, but a few outliers show **unusually high claim volume** or **unusually high avg paid per claim**. These outliers explain where spend concentrates and are the best targets for follow up review (pricing, coding, and network contracting).

## Business Recommendations
1) **Payment Integrity (recoveries + controls):** Prioritize “paid > allowed” claims for audit/recovery review, validate root causes (pricing configuration vs coding/billing patterns), and implement an automated flag/control to reduce repeat leakage.
2) **Utilization Management (high-cost segments):** Focus on the biggest spend drivers **inpatient** & **65+**. Prioritize the two groups for review: (1) **chronic members** with repeat utilization patterns and (2) **non-chronic high-cost episodes** (often avoidable admissions or high cost settings). Use findings to support site-of-care guidance and reduce avoidable inpatient use where appropriate.
3) **Provider Performance (network + contracting):** Review top spend providers to determine whether cost is driven by **utilization (volume)**, **unit cost (paid per claim)**, or **service mix (inpatient heavy)**, then route findings to contracting/network teams for rate/terms review and to UM for steerage/policy follow up.

## Notes
- Report is shared via screenshots; slicers and interactivity were used during development.
- Dataset is synthetic, procedure/diagnosis code variety is smaller than production claims.
