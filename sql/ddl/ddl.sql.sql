/* =====================================================
   File: ddl.sql
   Project: Claims Analytics Portfolio
   Purpose: Base database schema (DDL)
   ===================================================== */

-- ======================================
-- MEMBERS
-- ======================================
CREATE TABLE IF NOT EXISTS public.members
(
    member_id integer NOT NULL,
    age integer,
    gender character varying(10),
    county character varying(20),
    risk_score numeric(4,2),
    chronic_condition character varying(20),

    CONSTRAINT members_pkey PRIMARY KEY (member_id)
);

-- ========================================
-- PROVIDERS
-- ========================================
CREATE TABLE IF NOT EXISTS public.providers
(
    provider_id integer NOT NULL,
    provider_name character varying(100),
    specialty character varying(20),
    network_status character varying(20),
    state character varying(4),

    CONSTRAINT providers_pkey PRIMARY KEY (provider_id)
);

-- ========================================
-- DIAGNOSIS CODES
-- ========================================
CREATE TABLE IF NOT EXISTS public.diagnosis_codes
(
    diagnosis_code character varying(10) NOT NULL,
    diagnosis_description character varying(100),
    chronic_flag integer,

    CONSTRAINT diagnosis_codes_pkey PRIMARY KEY (diagnosis_code)
);

-- =====================================
-- CLAIMS
-- =====================================
CREATE TABLE IF NOT EXISTS public.claims
(
    claim_id integer NOT NULL,
    member_id integer,
    provider_id integer,
    claim_date date,
    claim_type character varying(20),
    allowed_amount numeric(10,2),
    paid_amount numeric(10,2),
    diagnosis_code character varying(10),
    procedure_code character varying(10),

    CONSTRAINT claims_pkey PRIMARY KEY (claim_id),

    CONSTRAINT claims_member_id_fkey FOREIGN KEY (member_id)
        REFERENCES public.members (member_id),

    CONSTRAINT claims_provider_id_fkey FOREIGN KEY (provider_id)
        REFERENCES public.providers (provider_id)
);