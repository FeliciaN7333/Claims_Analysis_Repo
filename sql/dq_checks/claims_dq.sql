/* =========================================================
   dq_claims.sql
   Purpose: Data Quality checks for public.claims (raw table)
   Output: Results to review + log in the Data Quality Log
   Rule: This file ONLY checks data quality (no transformations)
   ========================================================= */


/* =========================================================
   1) TABLE OVERVIEW & STRUCTURE
   ========================================================= */

-- =====================================================
-- CLAIMS: Row Count
-- Purpose: Confirm table size and load completeness
-- =====================================================
SELECT
    COUNT(*) AS row_count
FROM public.claims;

-- =====================================================
-- CLAIMS: Column Overview
-- Purpose: Verify column names and data types match expectations
-- =====================================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'claims'
ORDER BY ordinal_position;


/* =========================================================
   2) MISSING VALUES CHECK
   ========================================================= */

-- =====================================================
-- CLAIMS: Null Counts by Column
-- Purpose: See which fields are missing data and how often
-- =====================================================
SELECT
    SUM(CASE WHEN claim_id IS NULL THEN 1 ELSE 0 END) AS claim_id_nulls,
    SUM(CASE WHEN member_id IS NULL THEN 1 ELSE 0 END) AS member_id_nulls,
    SUM(CASE WHEN provider_id IS NULL THEN 1 ELSE 0 END) AS provider_id_nulls,
    SUM(CASE WHEN claim_date IS NULL THEN 1 ELSE 0 END) AS claim_date_nulls,
    SUM(CASE WHEN claim_type IS NULL THEN 1 ELSE 0 END) AS claim_type_nulls,
    SUM(CASE WHEN allowed_amount IS NULL THEN 1 ELSE 0 END) AS allowed_amount_nulls,
    SUM(CASE WHEN paid_amount IS NULL THEN 1 ELSE 0 END) AS paid_amount_nulls,
    SUM(CASE WHEN diagnosis_code IS NULL THEN 1 ELSE 0 END) AS diagnosis_code_nulls,
    SUM(CASE WHEN procedure_code IS NULL THEN 1 ELSE 0 END) AS procedure_code_nulls
FROM public.claims;

-- =====================================================
-- CLAIMS: Rows with Any Null Values (Key Fields)
-- Purpose: Pull the actual rows that have missing required fields
-- =====================================================
SELECT *
FROM public.claims
WHERE claim_id IS NULL
   OR member_id IS NULL
   OR provider_id IS NULL
   OR claim_date IS NULL
   OR claim_type IS NULL
   OR allowed_amount IS NULL
   OR paid_amount IS NULL
   OR diagnosis_code IS NULL
   OR procedure_code IS NULL;


/* =========================================================
   3) DUPLICATE CHECKS
   ========================================================= */

-- =====================================================
-- CLAIMS: Duplicate Primary Key (claim_id)
-- Purpose: Confirm claim_id is unique (no duplicate claims)
-- =====================================================
SELECT
    claim_id,
    COUNT(*) AS dup_count
FROM public.claims
GROUP BY claim_id
HAVING COUNT(*) > 1;

-- =====================================================
-- CLAIMS: Fully Duplicate Rows
-- Purpose: Detect complete duplicate claim records (synthetic data can have these)
-- =====================================================
SELECT
    claim_id, member_id, provider_id, claim_date, claim_type,
    allowed_amount, paid_amount, diagnosis_code, procedure_code,
    COUNT(*) AS dup_count
FROM public.claims
GROUP BY
    claim_id, member_id, provider_id, claim_date, claim_type,
    allowed_amount, paid_amount, diagnosis_code, procedure_code
HAVING COUNT(*) > 1;


/* =========================================================
   4) UNEXPECTED / INVALID VALUES
   ========================================================= */

-- =====================================================
-- CLAIMS: Distinct Claim Types
-- Purpose: Confirm claim_type values look valid and expected
-- =====================================================
SELECT DISTINCT
    claim_type
FROM public.claims
ORDER BY claim_type;

-- =====================================================
-- CLAIMS: Unusual Diagnosis Code Length
-- Purpose: Find diagnosis codes that are too short/long to be realistic (often 3–7 chars)
-- =====================================================
SELECT DISTINCT
    diagnosis_code
FROM public.claims
WHERE diagnosis_code IS NOT NULL
  AND (LENGTH(diagnosis_code) < 3 OR LENGTH(diagnosis_code) > 7);

-- =====================================================
-- CLAIMS: Invalid Characters in Diagnosis Code
-- Purpose: Catch diagnosis codes that contain weird characters or formatting
-- =====================================================
SELECT DISTINCT
    diagnosis_code
FROM public.claims
WHERE diagnosis_code IS NOT NULL
  AND diagnosis_code !~ '^[A-Za-z0-9\.]+$';

-- =====================================================
-- CLAIMS: Placeholder / Junk Codes
-- Purpose: Identify obvious fake or placeholder diagnosis/procedure codes
-- Notes: Customize this list based on your dataset
-- =====================================================
SELECT *
FROM public.claims
WHERE diagnosis_code IN ('99999', 'XXXXX', 'UNKNOWN', 'UNKOWN')
   OR procedure_code IN ('99999', 'XXXXX', 'UNKNOWN', 'UNKOWN');


/* =========================================================
   5) OUTLIER CHECKS (Numeric)
   ========================================================= */

-- =====================================================
-- CLAIMS: Paid Amount Range Profile
-- Purpose: See min/max to spot extreme or suspicious values
-- =====================================================
SELECT
    MIN(paid_amount) AS min_paid_amount,
    MAX(paid_amount) AS max_paid_amount
FROM public.claims;

-- =====================================================
-- CLAIMS: Allowed Amount Range Profile
-- Purpose: See min/max to spot extreme or suspicious values
-- =====================================================
SELECT
    MIN(allowed_amount) AS min_allowed_amount,
    MAX(allowed_amount) AS max_allowed_amount
FROM public.claims;

-- =====================================================
-- CLAIMS: IQR Outliers — paid_amount
-- Purpose: Pull claims with unusually low/high paid amounts using IQR method
-- =====================================================
WITH stats AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY paid_amount) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY paid_amount) AS q3
    FROM public.claims
    WHERE paid_amount IS NOT NULL
),
bounds AS (
    SELECT
        q1,
        q3,
        (q3 - q1) AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM stats
)
SELECT
    c.*,
    b.lower_bound,
    b.upper_bound
FROM public.claims c
CROSS JOIN bounds b
WHERE c.paid_amount IS NOT NULL
  AND (c.paid_amount < b.lower_bound OR c.paid_amount > b.upper_bound)
ORDER BY c.paid_amount DESC;

-- =====================================================
-- CLAIMS: IQR Outliers — allowed_amount
-- Purpose: Pull claims with unusually low/high allowed amounts using IQR method
-- =====================================================
WITH stats AS (
    SELECT
        percentile_cont(0.25) WITHIN GROUP (ORDER BY allowed_amount) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY allowed_amount) AS q3
    FROM public.claims
    WHERE allowed_amount IS NOT NULL
),
bounds AS (
    SELECT
        q1,
        q3,
        (q3 - q1) AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM stats
)
SELECT
    c.*,
    b.lower_bound,
    b.upper_bound
FROM public.claims c
CROSS JOIN bounds b
WHERE c.allowed_amount IS NOT NULL
  AND (c.allowed_amount < b.lower_bound OR c.allowed_amount > b.upper_bound)
ORDER BY c.allowed_amount DESC;


/* =========================================================
   6) DATE VALIDITY CHECKS
   ========================================================= */

-- =====================================================
-- CLAIMS: Date Range Profile
-- Purpose: Confirm the overall claim_date range looks reasonable
-- =====================================================
SELECT
    MIN(claim_date) AS earliest_claim_date,
    MAX(claim_date) AS latest_claim_date
FROM public.claims;

-- =====================================================
-- CLAIMS: Future Dates
-- Purpose: Identify claims dated after today (usually invalid)
-- =====================================================
SELECT *
FROM public.claims
WHERE claim_date > CURRENT_DATE;


/* =========================================================
   7) HEALTHCARE-SPECIFIC VALIDATIONS
   ========================================================= */

-- =====================================================
-- CLAIMS: Negative Amounts
-- Purpose: Identify reversals or bad data (needs review)
-- =====================================================
SELECT *
FROM public.claims
WHERE paid_amount < 0
   OR allowed_amount < 0;

-- =====================================================
-- CLAIMS: Zero Paid Amounts
-- Purpose: Identify denials or $0 payments for review
-- =====================================================
SELECT *
FROM public.claims
WHERE paid_amount = 0;

-- =====================================================
-- CLAIMS: Extremely High Paid Amounts
-- Purpose: Flag unusually high payments for review (threshold can be adjusted)
-- =====================================================
SELECT *
FROM public.claims
WHERE paid_amount > 5000
ORDER BY paid_amount DESC;


/* =========================================================
   8) CROSS-COLUMN CONSISTENCY
   Purpose: Check “if X is true, then Y should also be true” within the same row
   ========================================================= */

-- =====================================================
-- CLAIMS: Paid Amount Greater Than Allowed Amount
-- Purpose: Find potential overpayments (paid should not exceed allowed)
-- =====================================================
SELECT *
FROM public.claims
WHERE paid_amount IS NOT NULL
  AND allowed_amount IS NOT NULL
  AND paid_amount > allowed_amount;

-- =====================================================
-- CLAIMS: Paid > 0 but Allowed Missing or Not Positive
-- Purpose: Catch pricing gaps that could break financial analysis
-- =====================================================
SELECT *
FROM public.claims
WHERE paid_amount > 0
  AND (allowed_amount IS NULL OR allowed_amount <= 0);

-- =====================================================
-- CLAIMS: Diagnosis & Procedure Must Travel Together
-- Purpose: Catch claims missing diagnosis or procedure when the other exists
-- =====================================================
SELECT *
FROM public.claims
WHERE (diagnosis_code IS NULL AND procedure_code IS NOT NULL)
   OR (diagnosis_code IS NOT NULL AND procedure_code IS NULL);

-- =====================================================
-- CLAIMS: Money Exists but Missing Member or Provider
-- Purpose: Ensure paid/allowed dollars tie to a member and provider (in the same row)
-- =====================================================
SELECT *
FROM public.claims
WHERE (paid_amount > 0 OR allowed_amount > 0)
  AND (member_id IS NULL OR provider_id IS NULL);


/* =========================================================
   9) CROSS-TABLE INTEGRITY
   Purpose: Check that IDs and relationships match across related tables (orphans, FK mismatches)
   ========================================================= */

-- =====================================================
-- CLAIMS: Orphan Provider Check
-- Purpose: Find claims where provider_id does not exist in providers table
-- =====================================================
SELECT c.*
FROM public.claims c
LEFT JOIN public.providers p
  ON c.provider_id = p.provider_id
WHERE c.provider_id IS NOT NULL
  AND p.provider_id IS NULL;

-- =====================================================
-- CLAIMS: Orphan Member Check
-- Purpose: Find claims where member_id does not exist in members table
-- =====================================================
SELECT c.*
FROM public.claims c
LEFT JOIN public.members m
  ON c.member_id = m.member_id
WHERE c.member_id IS NOT NULL
  AND m.member_id IS NULL;

-- =====================================================
-- CLAIMS: Orphan Diagnosis Check
-- Purpose: Find claims where diagnosis_code does not exist in diagnosis_codes table
-- =====================================================
SELECT c.*
FROM public.claims c
LEFT JOIN public.diagnosis_codes d
  ON c.diagnosis_code = d.diagnosis_code
WHERE c.diagnosis_code IS NOT NULL
  AND d.diagnosis_code IS NULL;

-- =====================================================
-- CLAIMS: Chronic Diagnosis on Claim but Member Not Marked Chronic
-- Purpose: Catch cases where claim diagnosis is chronic but member record says NULL/None
-- =====================================================
SELECT DISTINCT
    c.member_id,
    m.chronic_condition,
    c.diagnosis_code,
    d.chronic_flag
FROM public.claims c
JOIN public.members m
  ON c.member_id = m.member_id
JOIN public.diagnosis_codes d
  ON c.diagnosis_code = d.diagnosis_code
WHERE d.chronic_flag = 1
  AND (m.chronic_condition IS NULL OR m.chronic_condition ILIKE 'none');



