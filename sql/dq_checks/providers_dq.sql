/* =========================================================
   dq_providers.sql
   Purpose: Data Quality checks for public.providers (raw table)
   Output: Results to review + log in the Data Quality Log
   Rule: This file ONLY checks data quality (no transformations)
   ========================================================= */


/* =========================================================
   1) TABLE OVERVIEW & STRUCTURE
   ========================================================= */

-- =====================================================
-- PROVIDERS: Row Count
-- Purpose: Confirm table size and load completeness
-- =====================================================
SELECT
    COUNT(*) AS row_count
FROM public.providers;

-- =====================================================
-- PROVIDERS: Column Overview
-- Purpose: Verify column names and data types match expectations
-- =====================================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'providers'
ORDER BY ordinal_position;


/* =========================================================
   2) MISSING VALUES CHECK
   ========================================================= */

-- =====================================================
-- PROVIDERS: Null Counts by Column
-- Purpose: See which fields are missing data and how often
-- =====================================================
SELECT
    SUM(CASE WHEN provider_id IS NULL THEN 1 ELSE 0 END) AS provider_id_nulls,
    SUM(CASE WHEN provider_name IS NULL THEN 1 ELSE 0 END) AS provider_name_nulls,
    SUM(CASE WHEN specialty IS NULL THEN 1 ELSE 0 END) AS specialty_nulls,
    SUM(CASE WHEN network_status IS NULL THEN 1 ELSE 0 END) AS network_status_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls
FROM public.providers;

-- =====================================================
-- PROVIDERS: Rows with Any Null Values
-- Purpose: Pull the actual rows that have missing required fields
-- =====================================================
SELECT *
FROM public.providers
WHERE provider_id IS NULL
   OR provider_name IS NULL
   OR specialty IS NULL
   OR network_status IS NULL
   OR state IS NULL;


/* =========================================================
   3) DUPLICATE CHECKS
   ========================================================= */

-- =====================================================
-- PROVIDERS: Duplicate Primary Key (provider_id)
-- Purpose: Confirm provider_id is unique (no duplicate providers)
-- =====================================================
SELECT
    provider_id,
    COUNT(*) AS dup_count
FROM public.providers
GROUP BY provider_id
HAVING COUNT(*) > 1;

-- =====================================================
-- PROVIDERS: Fully Duplicate Rows
-- Purpose: Detect redundant provider records
-- =====================================================
SELECT
    provider_id,
    provider_name,
    specialty,
    network_status,
    state,
    COUNT(*) AS dup_count
FROM public.providers
GROUP BY
    provider_id,
    provider_name,
    specialty,
    network_status,
    state
HAVING COUNT(*) > 1;


/* =========================================================
   4) UNEXPECTED / INVALID VALUES
   ========================================================= */

-- =====================================================
-- PROVIDERS: Distinct Network Status Values
-- Purpose: Check what values exist so we can spot unexpected categories
-- =====================================================
SELECT DISTINCT
    network_status
FROM public.providers
ORDER BY network_status;

-- =====================================================
-- PROVIDERS: Distinct Specialty Values
-- Purpose: Quick scan for placeholder or inconsistent specialty labels
-- =====================================================
SELECT DISTINCT
    specialty
FROM public.providers
ORDER BY specialty;

-- =====================================================
-- PROVIDERS: Distinct State Values
-- Purpose: Quick scan for obvious state anomalies
-- =====================================================
SELECT DISTINCT
    state
FROM public.providers
ORDER BY state;

-- =====================================================
-- PROVIDERS: Blank Provider Name
-- Purpose: Ensure provider_name is not empty or whitespace
-- =====================================================
SELECT *
FROM public.providers
WHERE provider_name IS NULL
   OR TRIM(provider_name) = '';

-- =====================================================
-- PROVIDERS: Specialty = 'Unknown'
-- Purpose: Identify providers with unknown specialty (review if acceptable)
-- =====================================================
SELECT *
FROM public.providers
WHERE specialty IS NOT NULL
  AND TRIM(specialty) ILIKE 'unknown';

-- =====================================================
-- PROVIDERS: Potentially Invalid State Codes
-- Purpose: Flag state values that are not 2-character codes
-- =====================================================
SELECT *
FROM public.providers
WHERE state IS NULL
   OR LENGTH(TRIM(state)) <> 2;


/* =========================================================
   5) OUTLIER CHECKS (Numeric)
   ========================================================= */

-- =====================================================
-- PROVIDERS: Outlier Detection
-- Notes:
-- No continuous numeric fields present
-- Outlier detection not applicable
-- =====================================================


/* =========================================================
   6) DATE VALIDITY CHECKS
   ========================================================= */

-- =====================================================
-- PROVIDERS: Date Fields
-- Notes:
-- No date columns present
-- Date validity checks not applicable
-- =====================================================


/* =========================================================
   7) HEALTHCARE-SPECIFIC VALIDATIONS
   ========================================================= */

-- =====================================================
-- PROVIDERS: Healthcare Transaction Logic
-- Notes:
-- No paid/allowed fields in providers table
-- Transaction-level healthcare checks not applicable
-- =====================================================


/* =========================================================
   8) CROSS-COLUMN CONSISTENCY
   ========================================================= */

-- =====================================================
-- PROVIDERS: Cross-Column Rules
-- Notes:
-- No additional IF-THEN dependencies identified beyond checks above
-- Cross-column consistency checks not applicable
-- =====================================================


/* =========================================================
   9) CROSS-TABLE INTEGRITY
   ========================================================= */

-- =====================================================
-- PROVIDERS: Cross-Table Integrity
-- Notes:
-- This table is referenced by claims, but does not reference other tables directly
-- Cross-table integrity checks are typically handled from the claims table side
-- Not applicable here
-- =====================================================


