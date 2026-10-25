-- Confirm beneficiary type
SELECT
    beneficiary_type,
    COUNT(*) AS record_count,
    SUM(beneficiaries) AS total_beneficiaries
FROM beneficiary_partner_data
GROUP BY beneficiary_type;
-- Validation finding: Beneficiary types
-- Individual: 42 records, 56,250 reported beneficiaries
-- Household: 27 records, 12,450 reported beneficiaries
-- Total: 69 records, 68,700 reported beneficiaries
-- Both beneficiary types appear in the query results.
-- Compare these totals with the source data before final approval.

-- check district population
SELECT
    district_name,
    district_population
FROM jurisdiction_hierarchy
WHERE district_population IS NULL
   OR district_population <= 0;
  
  
  -- Validation finding: District population
-- No records returned with NULL, zero, or negative population.
-- All district population values pass this validation check.
   -- logging behaviour
   SELECT *
FROM beneficiary_activity_log
ORDER BY inserted_at DESC;

USE humanitarian_program;

SELECT
    bpd.partner_id,
    p.partner_name,
    bpd.village_id,
    v.village_name,
    bpd.beneficiaries,
    bpd.beneficiary_type
FROM beneficiary_partner_data AS bpd
JOIN partners AS p
    ON bpd.partner_id = p.partner_id
JOIN village_locations AS v
    ON bpd.village_id = v.village_id
LIMIT 5;

-- Check for missing or invalid beneficiary records
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN partner_id IS NULL THEN 1 ELSE 0 END)
        AS missing_partner_id,
    SUM(CASE WHEN village_id IS NULL THEN 1 ELSE 0 END)
        AS missing_village_id,
    SUM(CASE WHEN beneficiaries IS NULL THEN 1 ELSE 0 END)
        AS missing_beneficiaries,
    SUM(CASE WHEN beneficiaries <= 0 THEN 1 ELSE 0 END)
        AS invalid_beneficiary_counts
FROM beneficiary_partner_data;
-- Validation finding: Beneficiary data quality
-- Total records: 69
-- Missing partner IDs: 0
-- Missing village IDs: 0
-- Missing beneficiary counts: 0
-- Zero or negative beneficiary counts: 0
-- All 69 records passed these four checks.