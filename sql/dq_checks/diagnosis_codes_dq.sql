/* =========================================================
   dq_diagnosis_codes.sql
   Purpose: Data Quality checks for diagnosis_codes reference table
   Rule: This file ONLY checks data quality (no transformations)
   ========================================================= */


/* =========================================================
   1) TABLE OVERVIEW & STRUCTURE
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Row Count
-- Purpose: Understand table size
-- =====================================================
SELECT
    COUNT(*) AS row_count
FROM public.diagnosis_codes;

-- =====================================================
-- DIAGNOSIS CODES: Column Overview
-- Purpose: Verify schema and data types
-- =====================================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'diagnosis_codes'
ORDER BY ordinal_position;


/* =========================================================
   2) MISSING VALUES CHECK
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Null Counts by Column
-- Purpose: Identify incomplete reference data
-- =====================================================
SELECT
    SUM(CASE WHEN chronic_flag IS NULL THEN 1 ELSE 0 END) AS chronic_flag_nulls,
    SUM(CASE WHEN diagnosis_code IS NULL THEN 1 ELSE 0 END) AS diagnosis_code_nulls,
    SUM(CASE WHEN diagnosis_description IS NULL THEN 1 ELSE 0 END) AS diagnosis_description_nulls
FROM public.diagnosis_codes;

-- =====================================================
-- DIAGNOSIS CODES: Rows with Any Null Values
-- Purpose: Inspect problematic records directly
-- =====================================================
SELECT *
FROM public.diagnosis_codes
WHERE chronic_flag IS NULL
   OR diagnosis_code IS NULL
   OR diagnosis_description IS NULL;


/* =========================================================
   3) DUPLICATE CHECKS
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Duplicate Primary Key (diagnosis_code)
-- Purpose: Ensure uniqueness of diagnosis codes
-- =====================================================
SELECT
    diagnosis_code,
    COUNT(*) AS duplicate_count
FROM public.diagnosis_codes
GROUP BY diagnosis_code
HAVING COUNT(*) > 1;

-- =====================================================
-- DIAGNOSIS CODES: Fully Duplicate Rows
-- Purpose: Detect redundant reference records
-- =====================================================
SELECT
    chronic_flag,
    diagnosis_code,
    diagnosis_description,
    COUNT(*) AS duplicate_count
FROM public.diagnosis_codes
GROUP BY
    chronic_flag,
    diagnosis_code,
    diagnosis_description
HAVING COUNT(*) > 1;


/* =========================================================
   4) UNEXPECTED / INVALID VALUES
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Distinct chronic_flag Values
-- Purpose: Check what values actually exist in chronic_flag
--          to confirm it only contains expected values
-- =====================================================
SELECT DISTINCT
    chronic_flag
FROM public.diagnosis_codes;

-- =====================================================
-- DIAGNOSIS CODES: Distinct diagnosis_code Values
-- Purpose: Scan for obvious anomalies
-- =====================================================
SELECT DISTINCT
    diagnosis_code
FROM public.diagnosis_codes;

-- =====================================================
-- DIAGNOSIS CODES: Distinct diagnosis_description Values
-- Purpose: Confirm diagnosis descriptions are populated
--          and free of obvious errors or placeholder text
-- =====================================================
SELECT DISTINCT
    diagnosis_description
FROM public.diagnosis_codes;

-- =====================================================
-- DIAGNOSIS CODES: Unusual Diagnosis Code Length
-- Purpose: ICD codes are typically 3–7 characters
-- =====================================================
SELECT DISTINCT
    diagnosis_code
FROM public.diagnosis_codes
WHERE diagnosis_code IS NOT NULL
  AND (LENGTH(diagnosis_code) < 3 OR LENGTH(diagnosis_code) > 7);

-- =====================================================
-- DIAGNOSIS CODES: Invalid Characters in Diagnosis Code
-- Purpose: Detect non-alphanumeric or malformed codes
-- =====================================================
SELECT DISTINCT
    diagnosis_code
FROM public.diagnosis_codes
WHERE diagnosis_code IS NOT NULL
  AND diagnosis_code !~ '^[A-Za-z0-9\.]+$';


/* =========================================================
   5) OUTLIER CHECKS (Numeric)
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Outlier Detection
-- Notes:
-- chronic_flag is a binary indicator (0/1)
-- No continuous numeric measures present
-- Outlier detection not applicable
-- =====================================================


/* =========================================================
   6) DATE VALIDITY CHECKS
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Date Fields
-- Notes:
-- No date columns present
-- Date validity checks not applicable
-- =====================================================


/* =========================================================
   7) HEALTHCARE-SPECIFIC VALIDATIONS
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Healthcare Transaction Logic
-- Notes:
-- This is a reference table (no paid/allowed fields)
-- Healthcare transaction checks not applicable
-- =====================================================


/* =========================================================
   8) CROSS-COLUMN CONSISTENCY
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Cross-Column Rules
-- Notes:
-- No explicit IF-THEN dependencies identified
-- Cross-column consistency checks not applicable
-- =====================================================


/* =========================================================
   9) CROSS-TABLE INTEGRITY
   ========================================================= */

-- =====================================================
-- DIAGNOSIS CODES: Cross-Table Integrity
-- Notes:
-- Reference table (no foreign keys to validate here)
-- Cross-table integrity checks not applicable
-- =====================================================


