/* =========================================================
   dq_members.sql
   Purpose: Data Quality checks for public.members (raw table)
   Output: Results to review + log in the Data Quality Log
   Rule: This file ONLY checks data quality (no transformations)
   ========================================================= */


/* =========================================================
   1) TABLE OVERVIEW & STRUCTURE
   ========================================================= */

-- =====================================================
-- MEMBERS: Row Count
-- Purpose: Confirm table size and load completeness
-- =====================================================
SELECT
    COUNT(*) AS row_count
FROM public.members;

-- =====================================================
-- MEMBERS: Column Overview
-- Purpose: Verify column names and data types match expectations
-- =====================================================
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'members'
ORDER BY ordinal_position;


/* =========================================================
   2) MISSING VALUES CHECK
   ========================================================= */

-- =====================================================
-- MEMBERS: Null Counts by Column
-- Purpose: See which fields are missing data and how often
-- =====================================================
SELECT
    SUM(CASE WHEN member_id IS NULL THEN 1 ELSE 0 END) AS member_id_nulls,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_nulls,
    SUM(CASE WHEN risk_score IS NULL THEN 1 ELSE 0 END) AS risk_score_nulls,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN county IS NULL THEN 1 ELSE 0 END) AS county_nulls,
    SUM(CASE WHEN chronic_condition IS NULL THEN 1 ELSE 0 END) AS chronic_condition_nulls
FROM public.members;

-- =====================================================
-- MEMBERS: Rows with Any Null Values
-- Purpose: Pull the actual rows that have missing required fields
-- Notes: Adjust which fields are “required” based on your dataset rules
-- =====================================================
SELECT *
FROM public.members
WHERE member_id IS NULL
   OR age IS NULL
   OR risk_score IS NULL
   OR gender IS NULL
   OR county IS NULL
   OR chronic_condition IS NULL;


/* =========================================================
   3) DUPLICATE CHECKS
   ========================================================= */

-- =====================================================
-- MEMBERS: Duplicate Primary Key (member_id)
-- Purpose: Confirm member_id is unique (no duplicate members)
-- =====================================================
SELECT
    member_id,
    COUNT(*) AS dup_count
FROM public.members
GROUP BY member_id
HAVING COUNT(*) > 1;

-- =====================================================
-- MEMBERS: Fully Duplicate Rows
-- Purpose: Detect redundant member records
-- =====================================================
SELECT
    member_id,
    age,
    risk_score,
    gender,
    county,
    chronic_condition,
    COUNT(*) AS dup_count
FROM public.members
GROUP BY
    member_id,
    age,
    risk_score,
    gender,
    county,
    chronic_condition
HAVING COUNT(*) > 1;


/* =========================================================
   4) UNEXPECTED / INVALID VALUES
   ========================================================= */

-- =====================================================
-- MEMBERS: Distinct Gender Values
-- Purpose: See what gender values exist so we can spot unexpected categories
-- =====================================================
SELECT DISTINCT
    gender
FROM public.members
ORDER BY gender;

-- =====================================================
-- MEMBERS: Unexpected Gender Values
-- Purpose: Identify rows where gender is not in the expected set
-- Notes: Expand allowed values if your dataset uses other categories
-- =====================================================
SELECT *
FROM public.members
WHERE gender IS NULL
   OR gender NOT IN ('Male', 'Female');

-- =====================================================
-- MEMBERS: Distinct County Values
-- Purpose: Quick scan for obvious county typos or blanks
-- =====================================================
SELECT DISTINCT
    county
FROM public.members
ORDER BY county;

-- =====================================================
-- MEMBERS: Distinct Chronic Condition Values
-- Purpose: Quick scan for placeholder text or unexpected entries
-- =====================================================
SELECT DISTINCT
    chronic_condition
FROM public.members
ORDER BY chronic_condition;

-- =====================================================
-- MEMBERS: Risk Score Values (Distinct)
-- Purpose: Quick scan to ensure risk_score values look reasonable
-- =====================================================
SELECT DISTINCT
    risk_score
FROM public.members
ORDER BY risk_score;

-- =====================================================
-- MEMBERS: Age Values (Distinct)
-- Purpose: Quick scan to ensure age values look reasonable
-- =====================================================
SELECT DISTINCT
    age
FROM public.members
ORDER BY age;


/* =========================================================
   5) OUTLIER CHECKS (Numeric)
   ========================================================= */

-- =====================================================
-- MEMBERS: Risk Score Range Check
-- Purpose: Flag risk_score values outside expected range (example: 0–5)
-- Notes: Adjust bounds if your dataset uses a different scale
-- =====================================================
SELECT *
FROM public.members
WHERE risk_score < 0
   OR risk_score > 5;

-- =====================================================
-- MEMBERS: Age Range Check
-- Purpose: Flag unrealistic ages (example: <0 or >99)
-- Notes: Adjust bounds if your dataset uses different age limits
-- =====================================================
SELECT *
FROM public.members
WHERE age < 0
   OR age > 99;


/* =========================================================
   6) DATE VALIDITY CHECKS
   ========================================================= */

-- =====================================================
-- MEMBERS: Date Fields
-- Notes:
-- No date columns present in this table
-- Date validity checks not applicable
-- =====================================================


/* =========================================================
   7) HEALTHCARE-SPECIFIC VALIDATIONS
   ========================================================= */

-- =====================================================
-- MEMBERS: Healthcare Transaction Logic
-- Notes:
-- No paid/allowed fields in members table
-- Transaction-level healthcare checks not applicable
-- =====================================================


/* =========================================================
   8) CROSS-COLUMN CONSISTENCY
   ========================================================= */

-- =====================================================
-- MEMBERS: Cross-Column Rules
-- Notes:
-- No explicit IF-THEN dependencies identified for this table
-- Cross-column consistency checks not applicable
-- =====================================================


/* =========================================================
   9) CROSS-TABLE INTEGRITY
   ========================================================= */

-- =====================================================
-- MEMBERS: Cross-Table Integrity
-- Notes:
-- This table is referenced by claims, but does not reference other tables directly
-- Cross-table integrity checks are typically handled from the claims table side
-- Not applicable here
-- =====================================================

