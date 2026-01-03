# Reusable Data Quality Checklist

**Rule:** Keep checks in the same order every time. If something doesn’t apply, write **N/A** (don’t delete it).  
**Goal:** Prove the table is trustworthy for claims reporting (cost, audit, utilization).

## The checklist (simplified)
1) **Structure**: row count + columns/datatypes  
2) **Missingness**: NULL counts + pull NULL rows for key fields  
3) **Duplicates**: duplicate primary keys + (optional) full-row duplicates  
4) **Invalid values**: unexpected categories, bad code formats, weird strings  
5) **Outliers (numeric)**: min/max, extreme amounts (optional IQR)  
6) **Date validity**: min/max dates, future dates (if table has dates)  
7) **Healthcare logic**: negatives, zero paid (if claims logic exists)  
8) **Cross-column consistency**: contradictions in the same row (paid>allowed, paid>0 but allowed NULL)  
9) **Cross-table integrity**: orphan IDs (claims without matching member/provider/diagnosis)

## Single SQL pattern sheet (placeholder names)
```sql
/* 1) STRUCTURE */
SELECT COUNT(*) AS row_count FROM table_name;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'table_name'
ORDER BY ordinal_position;

/* 2) MISSING VALUES (repeat SUM lines for your critical columns) */
SELECT
  SUM(CASE WHEN key_col IS NULL THEN 1 ELSE 0 END) AS key_col_nulls,
  SUM(CASE WHEN important_col IS NULL THEN 1 ELSE 0 END) AS important_col_nulls
FROM table_name;

SELECT *
FROM table_name
WHERE key_col IS NULL;

/* 3) DUPLICATES (primary key) */
SELECT primary_key, COUNT(*) AS cnt
FROM table_name
GROUP BY primary_key
HAVING COUNT(*) > 1;

/* 4) INVALID / UNEXPECTED VALUES (categoricals / codes) */
SELECT DISTINCT category_col
FROM table_name
ORDER BY 1;

SELECT *
FROM table_name
WHERE LENGTH(code_col) < 3;  -- example format check

/* 5) OUTLIERS (numeric) */
SELECT
  MIN(amount_col) AS min_amount,
  MAX(amount_col) AS max_amount
FROM table_name;

/* 6) DATE VALIDITY */
SELECT
  MIN(date_col) AS min_date,
  MAX(date_col) AS max_date
FROM table_name;

SELECT *
FROM table_name
WHERE date_col > CURRENT_DATE;

/* 7) HEALTHCARE LOGIC (claims tables) */
SELECT *
FROM claims
WHERE paid_amount < 0 OR allowed_amount < 0;

SELECT *
FROM claims
WHERE paid_amount = 0; -- optional (denials/zero-pay patterns)

/* 8) CROSS-COLUMN CONSISTENCY (same row contradictions) */
SELECT *
FROM claims
WHERE paid_amount > 0 AND allowed_amount IS NULL;

SELECT *
FROM claims
WHERE paid_amount > allowed_amount;

/* 9) CROSS-TABLE INTEGRITY (orphans) */
SELECT c.*
FROM claims c
LEFT JOIN members m ON c.member_id = m.member_id
WHERE m.member_id IS NULL;

SELECT c.*
FROM claims c
LEFT JOIN providers p ON c.provider_id = p.provider_id
WHERE p.provider_id IS NULL;

SELECT c.*
FROM claims c
LEFT JOIN diagnosis_codes d ON c.diagnosis_code = d.diagnosis_code
WHERE d.diagnosis_code IS NULL;

