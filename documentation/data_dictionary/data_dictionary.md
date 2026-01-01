# Data Dictionary

This project uses a synthetic healthcare claims dataset modeled around common payer/TPA workflows.
The tables below represent the core entities used to build analytics-ready views and Power BI dashboards.

---

## members
**Grain:** 1 row per member

| Column | Type | Description | Example |
|---|---|---|---|
| member_id | integer | Unique member identifier | 100449 |
| age | integer | Member age | 67 |
| age_bucket | text | Binned age group used for reporting | 65+ |
| gender | text | Member gender category | Female |
| county | text | Member county (used for slicers/segmentation) | Harris |
| risk_score | numeric | Risk score used for utilization stratification | 0.92 |
| chronic_condition | text | Chronic condition indicator/category (includes None/NULL rules) | None / Diabetes |
| has_chronic_condition_flag | integer/boolean | Derived flag: 1 if chronic_condition present, else 0 | 1 |

---

## providers
**Grain:** 1 row per provider

| Column | Type | Description | Example |
|---|---|---|---|
| provider_id | integer | Unique provider identifier | 136 |
| provider_name | text | Provider display name (if available) | Provider 136 |
| specialty | text | Provider specialty/category (if available) | Cardiology |
| network_status | text | Network designation used for comparisons | In-Network |

---

## diagnosis_codes
**Grain:** 1 row per diagnosis code

| Column | Type | Description | Example |
|---|---|---|---|
| diagnosis_code | text | ICD-style diagnosis code | E11.9 |
| diagnosis_desc | text | Diagnosis description (if available) | Type 2 diabetes mellitus |

---

## claims
**Grain:** 1 row per claim (or claim line, depending on source).  
In this portfolio dataset, claims are treated at the claim level for reporting.

| Column | Type | Description | Example |
|---|---|---|---|
| claim_id | integer/text | Unique claim identifier | 550012 |
| member_id | integer | Member linked to the claim | 100449 |
| provider_id | integer | Provider linked to the claim | 136 |
| service_date | date | Date of service | 2025-05-14 |
| service_month | text | Derived month label for trending | 2025-05 |
| claim_type | text | Service setting/category | Inpatient |
| procedure_code | text | CPT/HCPCS-style procedure code | 99241 |
| diagnosis_code | text | Diagnosis code on the claim | E11.9 |
| allowed_amount | numeric | Allowed amount (pricing baseline) | 1240.50 |
| paid_amount | numeric | Paid amount (actual payment) | 1300.50 |
| payment_status | text | Derived: flags missing paid amounts | Missing / Paid |
| paid_gt_allowed_flag | boolean | Derived: TRUE when paid_amount > allowed_amount | TRUE |

---

## Derived fields used in reporting (high impact)
These are created in cleaned/analysis views for dashboard consistency.

| Field | Built From | Purpose |
|---|---|---|
| age_bucket | members.age | Stable reporting groups (18–34, 35–49, 50–64, 65+) |
| service_month | claims.service_date | Monthly trend charts |
| payment_status | claims.paid_amount | Separates true $0 from missing paid values |
| paid_gt_allowed_flag | paid_amount vs allowed_amount | Payment integrity / overpayment targeting |
| has_chronic_condition_flag | members.chronic_condition | Enables chronic vs non-chronic segmentation |

---

## Notes
- Dataset is **synthetic** for portfolio use.
- “NULL vs None” is preserved intentionally to distinguish *missing clinical data* from *no chronic condition present* (see Data Quality Log).
