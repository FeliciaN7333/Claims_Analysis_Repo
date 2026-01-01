CREATE OR REPLACE VIEW public.cleaned_diagnosis_codes AS 
SELECT  
      d.diagnosis_code,
	  d.diagnosis_description,
	  d.chronic_flag,

	  -- Cleaned diagnosis code (trim + uppercase)
	  UPPER(TRIM(d.diagnosis_code)) AS diagnosis_code_clean,

	  -- Cleaned diagnosis description (trim only)
	  TRIM(d.diagnosis_description) AS diagnosis_description_clean,

	  -- Boolean helper: is this diagnosis chronic?
      -- 1 = chronic, 0 = not chronic, anything else/NULL = Unknown
	  CASE
	      WHEN d.chronic_flag = 1 THEN TRUE
		  WHEN d.chronic_flag = 0 THEN FALSE
		  ELSE NULL
	  END AS is_chronic,

	  -- Label helper for visuals / grouping
	  CASE 
	      WHEN d.chronic_flag = 1 THEN 'Chronic'
		  WHEN d.chronic_flag = 0 THEN 'Non-Chronic'
		  ELSE 'Unkown'
	  END AS chronic_category

FROM public.diagnosis_codes d;

SELECT * FROM public.cleaned_diagnosis_codes LIMIT 20;