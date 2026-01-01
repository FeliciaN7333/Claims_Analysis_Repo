/* =========================================================
   claims_analysis.sql
   Purpose: Power BI-ready analysis outputs from cleaned views
   Rule: NO cleaning logic here — analysis only.
   ========================================================= */


/* =========================================================
   SECTION 0 — QUICK DATASET KPIs (Executive Summary)
   Inputs: cleaned_claims
   ========================================================= */

-- =====================================================
-- EXEC KPI: Total Claims, Total Paid, Total Allowed
-- Power BI Visual: KPI Cards
-- Grain: One row = dataset-level summary (overall)
-- =====================================================
SELECT
    COUNT(*) AS total_claims,
    SUM(paid_amount) AS total_paid_amount,
    SUM(allowed_amount) AS total_allowed_amount
FROM cleaned_claims;

-- =====================================================
-- EXEC KPI: Overpayment Count + Dollars Overpaid
-- Power BI Visual: KPI Cards
-- Grain: One row = dataset-level summary (overall)
-- =====================================================
SELECT
    COUNT(*) FILTER (WHERE paid_gt_allowed = TRUE) AS overpaid_claim_count,
    SUM(paid_amount - allowed_amount)
        FILTER (WHERE paid_gt_allowed = TRUE) AS total_dollars_overpaid
FROM cleaned_claims;



/* =========================================================
   1) COST DRIVERS — Where is the money going?
   Inputs: cleaned_claims (+ joins)
   ========================================================= */

-- =====================================================
-- COST DRIVERS: Total Paid by Claim Type
-- Power BI Visual: Bar chart | X=claim_type | Y=total_paid_amount
-- Grain: One row = one claim_type
-- =====================================================
SELECT
    claim_type,
    SUM(paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count
FROM cleaned_claims
GROUP BY claim_type
ORDER BY total_paid_amount DESC;

-- =====================================================
-- COST DRIVERS: Total Paid by Month
-- Power BI Visual: Line chart | X=claim_month | Y=total_paid_amount
-- Grain: One row = one month
-- =====================================================
SELECT
    DATE_TRUNC('month', claim_date)::date AS claim_month,
    SUM(paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count
FROM cleaned_claims
GROUP BY 1
ORDER BY 1;

-- =====================================================
-- COST DRIVERS: Total Paid by Procedure Code (Top 25)
-- Power BI Visual: Bar chart | X=procedure_code | Y=total_paid_amount
-- Grain: One row = one procedure_code
-- =====================================================
SELECT
    procedure_code,
    SUM(paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count,
    AVG(paid_amount) AS avg_paid_amount
FROM cleaned_claims
GROUP BY procedure_code
ORDER BY total_paid_amount DESC
LIMIT 25;

-- =====================================================
-- COST DRIVERS: Total Paid by Provider (Top 25)
-- Inputs: cleaned_claims + cleaned_providers
-- Power BI Visual: Bar chart | X=provider_name | Y=total_paid_amount
-- Grain: One row = one provider
-- =====================================================
SELECT
    c.provider_id,
    p.provider_name,
    SUM(c.paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count,
    AVG(c.paid_amount) AS avg_paid_amount
FROM cleaned_claims c
LEFT JOIN cleaned_providers p
    ON c.provider_id = p.provider_id
GROUP BY c.provider_id, p.provider_name
ORDER BY total_paid_amount DESC
LIMIT 25;

-- =====================================================
-- COST DRIVERS: Spend by Chronic vs Non-Chronic
-- Inputs: cleaned_claims + cleaned_members
-- Power BI Visual: Donut or bar
-- Grain: One row = one chronic_status category
-- =====================================================
SELECT
    CASE
        WHEN m.has_chronic_condition = TRUE THEN 'Chronic'
        ELSE 'Non-Chronic'
    END AS chronic_status,
    SUM(c.paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count,
    AVG(c.paid_amount) AS avg_paid_amount
FROM cleaned_claims c
LEFT JOIN cleaned_members m
    ON c.member_id = m.member_id
GROUP BY 1
ORDER BY total_paid_amount DESC;

-- =====================================================
-- COST DRIVERS: Spend by Age Bucket
-- Inputs: cleaned_claims + cleaned_members
-- Power BI Visual: Bar chart | X=age_bucket | Y=total_paid_amount
-- Grain: One row = one age_bucket
-- =====================================================
SELECT
    COALESCE(m.age_bucket, 'Unknown') AS age_bucket,
    SUM(c.paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count,
    AVG(c.paid_amount) AS avg_paid_amount
FROM cleaned_claims c
LEFT JOIN cleaned_members m
    ON c.member_id = m.member_id
GROUP BY 1
ORDER BY total_paid_amount DESC;



/* =========================================================
   2) OVERPAYMENTS & ANOMALIES — Pricing Leakage
   Inputs: cleaned_claims
   ========================================================= */

-- =====================================================
-- OVERPAYMENTS: Overpaid Claims by Provider (Top 25)
-- Power BI Visual: Bar chart | X=provider_name | Y=total_overpaid_amount
-- Grain: One row = one provider
-- =====================================================
SELECT
    c.provider_id,
    p.provider_name,
    COUNT(*) AS overpaid_claim_count,
    SUM(c.paid_amount - c.allowed_amount) AS total_overpaid_amount,
    AVG(c.paid_amount - c.allowed_amount) AS avg_overpaid_amount
FROM cleaned_claims c
LEFT JOIN cleaned_providers p
    ON c.provider_id = p.provider_id
WHERE c.paid_gt_allowed = TRUE
GROUP BY c.provider_id, p.provider_name
ORDER BY total_overpaid_amount DESC
LIMIT 25;

-- =====================================================
-- OVERPAYMENTS: Overpayment by Procedure Code (Top 25)
-- Power BI Visual: Bar chart | X=procedure_code | Y=total_overpaid_amount
-- Grain: One row = one procedure_code
-- =====================================================
SELECT
    procedure_code,
    COUNT(*) AS overpaid_claim_count,
    SUM(paid_amount - allowed_amount) AS total_overpaid_amount
FROM cleaned_claims
WHERE paid_gt_allowed = TRUE
GROUP BY procedure_code
ORDER BY total_overpaid_amount DESC
LIMIT 25;

-- =====================================================
-- ANOMALIES: Claims by Anomaly Category
-- Power BI Visual: Bar chart
-- Grain: One row = one anomaly category
-- =====================================================
SELECT
    COALESCE(payment_anomaly_category, 'None') AS payment_anomaly_category,
    COUNT(*) AS claim_count,
    SUM(paid_amount) AS total_paid_amount
FROM cleaned_claims
GROUP BY 1
ORDER BY claim_count DESC;

-- =====================================================
-- ANOMALIES TREND: Overpaid Dollars by Month
-- Power BI Visual: Line chart
-- Grain: One row = one month
-- =====================================================
SELECT
    DATE_TRUNC('month', claim_date)::date AS claim_month,
    SUM(paid_amount - allowed_amount) AS total_overpaid_amount,
    COUNT(*) AS overpaid_claim_count
FROM cleaned_claims
WHERE paid_gt_allowed = TRUE
GROUP BY 1
ORDER BY 1;



/* =========================================================
   3) PROVIDER PERFORMANCE — Cost, volume, network impact
   Inputs: cleaned_claims + cleaned_providers
   ========================================================= */

-- =====================================================
-- PROVIDER PERFORMANCE: Cost & Volume by Provider
-- Power BI Visual: Scatter plot
-- Grain: One row = one provider
-- =====================================================
SELECT
    c.provider_id,
    p.provider_name,
    p.network_status,
    p.specialty_clean,
    COUNT(*) AS claim_count,
    SUM(c.paid_amount) AS total_paid_amount,
    SUM(c.allowed_amount) AS total_allowed_amount,
    AVG(c.paid_amount) AS avg_paid_amount,
    AVG(c.allowed_amount) AS avg_allowed_amount
FROM cleaned_claims c
LEFT JOIN cleaned_providers p
    ON c.provider_id = p.provider_id
GROUP BY
    c.provider_id,
    p.provider_name,
    p.network_status,
    p.specialty_clean
ORDER BY total_paid_amount DESC;

-- =====================================================
-- PROVIDER PERFORMANCE: In-Network vs Out-of-Network Spend
-- Power BI Visual: Bar chart
-- Grain: One row = one network_status
-- =====================================================
SELECT
    COALESCE(p.network_status, 'Unknown') AS network_status,
    SUM(c.paid_amount) AS total_paid_amount,
    COUNT(*) AS claim_count,
    AVG(c.paid_amount) AS avg_paid_amount
FROM cleaned_claims c
LEFT JOIN cleaned_providers p
    ON c.provider_id = p.provider_id
GROUP BY 1
ORDER BY total_paid_amount DESC;



/* =========================================================
   4) MEMBER UTILIZATION — High utilizers & segmentation
   Inputs: cleaned_claims + cleaned_members
   ========================================================= */

-- =====================================================
-- MEMBER UTILIZATION: Claims & Spend per Member (Top 50)
-- Power BI Visual: Table or bar
-- Grain: One row = one member
-- =====================================================
SELECT
    c.member_id,
    COUNT(*) AS claim_count,
    SUM(c.paid_amount) AS total_paid_amount,
    AVG(c.paid_amount) AS avg_paid_amount,
    MAX(m.risk_score) AS risk_score,
    MAX(m.has_chronic_condition::int) AS has_chronic_condition_flag,
    MAX(m.county) AS county
FROM cleaned_claims c
LEFT JOIN cleaned_members m
    ON c.member_id = m.member_id
GROUP BY c.member_id
ORDER BY total_paid_amount DESC
LIMIT 50;



/* =========================================================
   5) CODING & DATA QUALITY INSIGHTS — Completeness & risk
   Inputs: cleaned_claims
   ========================================================= */

-- =====================================================
-- CODING/DQ: Missing Procedure & Diagnosis Codes
-- Power BI Visual: KPI Cards
-- Grain: One row = dataset-level summary (overall)
-- =====================================================
SELECT
    SUM(CASE WHEN procedure_code IS NULL OR procedure_code = '' THEN 1 ELSE 0 END)
        AS missing_procedure_code_claims,
    SUM(CASE WHEN diagnosis_code IS NULL OR diagnosis_code = '' THEN 1 ELSE 0 END)
        AS missing_diagnosis_code_claims,
    COUNT(*) AS total_claims
FROM cleaned_claims;

-- =====================================================
-- CODING/DQ: Allowed Amount Missing or Zero
-- Power BI Visual: KPI Cards
-- Grain: One row = dataset-level summary (overall)
-- =====================================================
SELECT
    COUNT(*) FILTER (WHERE allowed_amount IS NULL) AS allowed_null_count,
    COUNT(*) FILTER (WHERE allowed_amount = 0) AS allowed_zero_count,
    COUNT(*) AS total_claims
FROM cleaned_claims;
