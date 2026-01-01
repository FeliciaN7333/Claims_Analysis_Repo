CREATE OR REPLACE VIEW public.cleaned_members AS
SELECT
    m.member_id,
    m.age,
    m.risk_score, 
    m.gender,
    m.county,
    m.chronic_condition,

    -- Standardized gender bucket for analysis
    CASE 
        WHEN m.gender ILIKE 'male'   THEN 'Male'
        WHEN m.gender ILIKE 'female' THEN 'Female'
        WHEN m.gender IS NULL        THEN 'Unknown'
        ELSE 'Other'
    END AS gender_clean,
	
	-- Age buckets for cost-by-age-group analysis
	CASE
	    WHEN m.age IS NULL           THEN 'Unknown'     
        WHEN m.age < 18              THEN '0-17'
		WHEN m.age BETWEEN 18 AND 34 THEN '18-34'
		WHEN m.age BETWEEN 35 AND 49 THEN '35-49'
		WHEN m.age BETWEEN 50 AND 64 THEN '50-64'
		ELSE '65+'
	END AS age_bucket,
	
	-- Risk tiers for cost-by-risk-level analysis
	CASE
	    WHEN m.risk_score IS NULL   THEN 'Unkown'
		WHEN m.risk_score < 1.0     THEN 'Low'
		WHEN m.risk_score < 2.0     THEN 'Medium'
		ELSE 'High'
	END AS risk_level,
	
	-- Helper flag: does this member have any chronic condition recorded?
    -- We are NOT collapsing NULL and 'None' in the main column.    
    CASE 
        WHEN m.chronic_condition IS NULL THEN FALSE
        WHEN m.chronic_condition ILIKE 'none' THEN FALSE
        ELSE TRUE
    END AS has_chronic_condition
FROM public.members m; 