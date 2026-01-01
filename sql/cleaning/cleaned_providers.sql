CREATE OR REPLACE VIEW public.cleaned_providers AS 
SELECT
    p.provider_id,
    p.provider_name,
    p.specialty,
    p.network_status,
    p.state,

    -- Clean provider name for display / grouping
    TRIM(p.provider_name) AS provider_name_clean,

    -- Standardized specialty for analysis
    CASE
        WHEN p.specialty IS NULL THEN 'Unknown'
        WHEN TRIM(p.specialty) ILIKE 'unknown' THEN 'Unknown'
        ELSE INITCAP(TRIM(p.specialty))
    END AS specialty_clean,

    -- Standardized network status
    CASE 
        WHEN p.network_status ILIKE 'in%' THEN 'In-Network'
        WHEN p.network_status ILIKE 'out%' THEN 'Out-of-Network'
        ELSE 'Other/Unknown'
    END AS network_status_clean,

    -- Boolean Helper for in-network vs not 
    CASE
        WHEN p.network_status ILIKE 'in%' THEN 'In-Network'
        WHEN p.network_status ILIKE 'out%' THEN 'Out-Network'
        ELSE NULL 
    END AS in_network_flag,

    -- Cleaned state code + simple validity check
    UPPER(TRIM(p.state)) AS state_clean,

    CASE 
        WHEN p.state IS NULL THEN TRUE 
        WHEN LENGTH(TRIM(p.state)) <> 2 THEN TRUE
        ELSE FALSE
    END AS invalid_state_flag

FROM public.providers p;
