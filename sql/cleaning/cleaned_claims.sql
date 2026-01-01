CREATE OR REPLACE VIEW public.cleaned_claims AS 
SELECT 
	  c.provider_id,
	  c.claim_id,
	  c.member_id,
	  c.claim_date,
	  c.claim_type,
      c.paid_amount,
	  c.allowed_amount,
	  c.procedure_code,
	  c.diagnosis_code,

	  -- Payment status: Missing vs Reversal vs No Payment vs Paid 
	  CASE 
	      WHEN c.paid_amount IS NULL     THEN 'Missing'
	      WHEN c.paid_amount < 0         THEN 'Reversal'
		  WHEN c.paid_amount = 0         THEN 'No Payment'
		  ELSE 'Paid'
	  END AS payment_status,

	  -- Boolean flag: Did we pay more than allowed?
	  -- (NULL when either value is missing can't evaluate)
	  CASE 
	      WHEN c.paid_amount IS NULL OR c.allowed_amount IS NULL THEN NULL
		  WHEN c.paid_amount > c.allowed_amount THEN TRUE
		  ELSE FALSE
	 END AS paid_gt_allowed,

	 -- Payment anomaly categories
	 CASE 
	     WHEN c.paid_amount IS NULL
		     THEN 'Missing Paid'
		 WHEN c.allowed_amount IS NULL
		     THEN 'Missing Allowed'
	     WHEN c.paid_amount > 0 AND c.allowed_amount = 0 
		     THEN 'Paid>0, Allowed=0'
		 WHEN c.paid_amount > c.allowed_amount
		     THEN 'Paid>Allowed'
	     ELSE 'Normal'
	END AS payment_anomaly_category,

	-- Boolean flag for missing allowed amount 
	CASE 
	    WHEN c.allowed_amount IS NULL THEN TRUE
		ELSE FALSE
    END AS allowed_missing_flag,

	-- Date helpers for trends and time based analysis
	date_part('year', c.claim_date)::int AS claim_year,
	date_part('month', c.claim_date)::int AS claim_month,
	date_part('quarter', c.claim_date)::int AS claim_quarter,

	-- Coding completeness: do we have both procedure & diagnosis?
	CASE 
	    WHEN c.procedure_code IS NULL AND c.diagnosis_code IS NULL THEN 'No Codes'
		WHEN c.procedure_code IS NULL THEN 'Missing Procedure'
		WHEN c.diagnosis_code IS NULL THEN 'Missing Diagnosis'
		ELSE 'Both Present'
	END AS code_pair_status,

	-- Future dated claims
	CASE 
	    WHEN c.claim_date > CURRENT_DATE THEN TRUE 
		ELSE FALSE
    END AS future_date_flag 

FROM public.claims c;