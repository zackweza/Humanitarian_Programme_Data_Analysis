-- HUMANITARIAN PROGRAM SAMPLE DATABASE
-- Database: humanitarian_program

USE humanitarian_program;

-- Inspect current database and records
SELECT DATABASE();
SHOW DATABASES;
SHOW TABLES;
SELECT * FROM jurisdiction_hierarchy;
SELECT * FROM village_locations;
SELECT * FROM partners;
SELECT * FROM beneficiary_partner_data;
   SELECT * FROM jurisdiction_hierarchy
   WHERE district_name = 'District A';
-- Create tables only if missing. This does not alter existing table definitions.
CREATE TABLE IF NOT EXISTS jurisdiction_hierarchy (
    district_id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    district_name VARCHAR(100) NOT NULL UNIQUE,
    district_population INT NOT NULL
);

CREATE TABLE IF NOT EXISTS village_locations (
    village_id INT AUTO_INCREMENT PRIMARY KEY,
    village_name VARCHAR(100) NOT NULL,
    district_id INT NOT NULL,
    village_population INT NOT NULL,
    FOREIGN KEY (district_id) REFERENCES jurisdiction_hierarchy(district_id)
);

CREATE TABLE IF NOT EXISTS partners (
    partner_id INT AUTO_INCREMENT PRIMARY KEY,
    partner_name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS beneficiary_partner_data (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    partner_id INT NOT NULL,
    village_id INT NOT NULL,
    beneficiaries INT NOT NULL,
    beneficiary_type VARCHAR(50) NOT NULL,
    FOREIGN KEY (partner_id) REFERENCES partners(partner_id),
    FOREIGN KEY (village_id) REFERENCES village_locations(village_id)
);

-- Check table structures
DESCRIBE jurisdiction_hierarchy;
DESCRIBE village_locations;
DESCRIBE partners;
DESCRIBE beneficiary_partner_data;

-- Insert districts; update existing districts with matching unique names
INSERT INTO jurisdiction_hierarchy
    (region_name, district_name, district_population)
VALUES
    ('Middle Shabelle', 'Balcad', 50000),
    ('Middle Shabelle', 'Jowhar', 60000),
    ('Hiraan', 'Beledweyn', 70000)
ON DUPLICATE KEY UPDATE
    region_name = VALUES(region_name),
    district_population = VALUES(district_population);

-- Insert partners without duplicating existing partner names
INSERT INTO partners (partner_name)
VALUES ('World Vision'), ('CARE'), ('IRC')
ON DUPLICATE KEY UPDATE partner_name = VALUES(partner_name);

-- Insert villages by matching district names; skip villages already present
INSERT INTO village_locations (village_name, district_id, village_population)
SELECT s.village_name, d.district_id, s.village_population
FROM (
    SELECT 'Dharkenley' AS village_name, 'Balcad' AS district_name, 5000 AS village_population
    UNION ALL SELECT 'Bulo-Kahin', 'Balcad', 4200
    UNION ALL SELECT 'Hilo Kelyo', 'Balcad', 3800
    UNION ALL SELECT 'Xubow', 'Jowhar', 6000
    UNION ALL SELECT 'Xiintooy', 'Jowhar', 4500
    UNION ALL SELECT 'Dhagax Jebis', 'Jowhar', 5200
    UNION ALL SELECT 'Filtare', 'Jowhar', 3900
    UNION ALL SELECT 'Howl-Wadaag', 'Jowhar', 4700
    UNION ALL SELECT 'Balcad', 'Jowhar', 5500
    UNION ALL SELECT 'Mareeray', 'Jowhar', 4300
    UNION ALL SELECT 'Kulmis', 'Jowhar', 6058
    UNION ALL SELECT 'Sabuun', 'Jowhar', 5100
    UNION ALL SELECT 'Bayaxaw', 'Beledweyn', 3600
    UNION ALL SELECT 'Bayaxawo', 'Beledweyn', 4000
) AS s
JOIN jurisdiction_hierarchy AS d ON d.district_name = s.district_name
WHERE NOT EXISTS (
    SELECT 1 FROM village_locations AS v
    WHERE v.village_name = s.village_name
);

-- Insert beneficiary activity by looking up partner and village IDs.
-- Skip exact matching activity records that already exist.
INSERT INTO beneficiary_partner_data
    (partner_id, village_id, beneficiaries, beneficiary_type)
SELECT p.partner_id, v.village_id, s.beneficiaries, s.beneficiary_type
FROM (
    SELECT 'World Vision' AS partner_name, 'Dharkenley' AS village_name, 1200 AS beneficiaries, 'Individuals' AS beneficiary_type
    UNION ALL SELECT 'World Vision', 'Bulo-Kahin', 350, 'Households'
    UNION ALL SELECT 'CARE', 'Dharkenley', 800, 'Individuals'
    UNION ALL SELECT 'CARE', 'Hilo Kelyo', 250, 'Households'
    UNION ALL SELECT 'IRC', 'Xubow', 1500, 'Individuals'
    UNION ALL SELECT 'IRC', 'Xiintooy', 300, 'Households'
    UNION ALL SELECT 'World Vision', 'Dhagax Jebis', 900, 'Individuals'
    UNION ALL SELECT 'CARE', 'Filtare', 450, 'Households'
    UNION ALL SELECT 'IRC', 'Howl-Wadaag', 1100, 'Individuals'
    UNION ALL SELECT 'World Vision', 'Balcad', 700, 'Households'
    UNION ALL SELECT 'CARE', 'Mareeray', 600, 'Individuals'
    UNION ALL SELECT 'IRC', 'Kulmis', 400, 'Households'
    UNION ALL SELECT 'World Vision', 'Sabuun', 1000, 'Individuals'
    UNION ALL SELECT 'CARE', 'Bayaxaw', 500, 'Households'
    UNION ALL SELECT 'IRC', 'Bayaxawo', 1300, 'Individuals'
    UNION ALL SELECT 'World Vision', 'Dharkenley', 700, 'Households'
    UNION ALL SELECT 'CARE', 'Bulo-Kahin', 550, 'Individuals'
    UNION ALL SELECT 'IRC', 'Hilo Kelyo', 900, 'Individuals'
) AS s
JOIN partners AS p ON p.partner_name = s.partner_name
JOIN village_locations AS v ON v.village_name = s.village_name
WHERE NOT EXISTS (
    SELECT 1
    FROM beneficiary_partner_data AS b
    WHERE b.partner_id = p.partner_id
      AND b.village_id = v.village_id
      AND b.beneficiaries = s.beneficiaries
      AND b.beneficiary_type = s.beneficiary_type
);

-- Review sample records
SELECT * FROM jurisdiction_hierarchy WHERE district_name = 'Balcad';
SELECT DISTINCT beneficiary_type FROM beneficiary_partner_data;

-- Validate record counts
SELECT COUNT(*) AS total_districts FROM jurisdiction_hierarchy;
SELECT COUNT(*) AS total_villages FROM village_locations;
SELECT COUNT(*) AS total_partners FROM partners;
SELECT COUNT(*) AS total_activity_records FROM beneficiary_partner_data;
SELECT COUNT(*) AS total_records
FROM humanitarian_program.jurisdiction_hierarchy;

-- Final joined query for analysis
SELECT
    j.region_name,
    j.district_name,
    v.village_name,
    p.partner_name,
    b.beneficiaries,
    b.beneficiary_type
FROM beneficiary_partner_data AS b
JOIN partners AS p ON b.partner_id = p.partner_id
JOIN village_locations AS v ON b.village_id = v.village_id
JOIN jurisdiction_hierarchy AS j ON v.district_id = j.district_id
ORDER BY j.region_name, j.district_name, v.village_name, p.partner_name;UPDATE beneficiary_partner_data
SET beneficiary_type = 'Individual'
WHERE record_id > 0 AND beneficiary_type = 'Individuals';

UPDATE beneficiary_partner_data
SET beneficiary_type = 'Household'
WHERE record_id > 0 AND beneficiary_type = 'Households';



/*
PROJECT: Advanced Humanitarian Programme Analysis
DATABASE: humanitarian_program

USE humanitarian_program;

-- =========================================================
-- SECTION 1: ADVANCED AGGREGATION
-- GROUP BY, HAVING, CASE WHEN
-- =========================================================

-- 1A. Partner performance: individual beneficiaries, villages, districts.
SELECT
    p.partner_name,
    SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
             THEN bpd.beneficiaries ELSE 0 END) AS total_individual_beneficiaries,
    COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN bpd.village_id END) AS villages_served,
    COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN vl.district_id END) AS districts_reached,
    CASE
        WHEN SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                      THEN bpd.beneficiaries ELSE 0 END) >= 1000 THEN 'High reach'
        WHEN SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                      THEN bpd.beneficiaries ELSE 0 END) >= 500 THEN 'Medium reach'
        ELSE 'Low reach'
    END AS reach_category
FROM partners p
LEFT JOIN beneficiary_partner_data bpd ON bpd.partner_id = p.partner_id
LEFT JOIN village_locations vl ON vl.village_id = bpd.village_id
GROUP BY p.partner_id, p.partner_name
ORDER BY total_individual_beneficiaries DESC;

-- 1B. Partners meeting a target of at least 500 individual beneficiaries.
-- Change 500 if your assignment specifies a different target.
SELECT
    p.partner_name,
    SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
             THEN bpd.beneficiaries ELSE 0 END) AS total_individual_beneficiaries
FROM partners p
JOIN beneficiary_partner_data bpd ON bpd.partner_id = p.partner_id
GROUP BY p.partner_id, p.partner_name
HAVING SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                THEN bpd.beneficiaries ELSE 0 END) >= 500
ORDER BY total_individual_beneficiaries DESC;

-- 1C. District totals and coverage rate.
SELECT
    j.region_name,
    j.district_name,
    j.district_population,
    COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                      THEN bpd.beneficiaries ELSE 0 END), 0) AS individual_beneficiaries,
    ROUND(
        100.0 * COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                                  THEN bpd.beneficiaries ELSE 0 END), 0)
        / NULLIF(j.district_population, 0), 2
    ) AS coverage_rate_pct,
    CASE
        WHEN 100.0 * COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                                       THEN bpd.beneficiaries ELSE 0 END), 0)
             / NULLIF(j.district_population, 0) >= 75 THEN 'Target met'
        ELSE 'Below target'
    END AS target_status
FROM jurisdiction_hierarchy j
LEFT JOIN village_locations vl ON vl.district_id = j.district_id
LEFT JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
GROUP BY j.district_id, j.region_name, j.district_name, j.district_population
ORDER BY coverage_rate_pct DESC;


-- =========================================================
-- SECTION 2: UNION AND UNION ALL
-- =========================================================

-- 2A. One combined report of villages and partner activity.
-- UNION ALL preserves every activity row and also lists villages with no activity.
SELECT
    vl.village_name,
    j.district_name,
    p.partner_name,
    bpd.beneficiary_type,
    bpd.beneficiaries,
    'Recorded activity' AS activity_status
FROM village_locations vl
JOIN jurisdiction_hierarchy j ON j.district_id = vl.district_id
JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
JOIN partners p ON p.partner_id = bpd.partner_id

UNION ALL

SELECT
    vl.village_name,
    j.district_name,
    NULL AS partner_name,
    NULL AS beneficiary_type,
    NULL AS beneficiaries,
    'No recorded activity' AS activity_status
FROM village_locations vl
JOIN jurisdiction_hierarchy j ON j.district_id = vl.district_id
WHERE NOT EXISTS (
    SELECT 1
    FROM beneficiary_partner_data bpd
    WHERE bpd.village_id = vl.village_id
)
ORDER BY district_name, village_name, partner_name;

-- 2B. UNION removes duplicate district names; UNION ALL keeps duplicates.
-- These examples illustrate the difference.
SELECT district_name AS district
FROM jurisdiction_hierarchy
UNION
SELECT district_name AS district
FROM jurisdiction_hierarchy;

SELECT district_name AS district
FROM jurisdiction_hierarchy
UNION ALL
SELECT district_name AS district
FROM jurisdiction_hierarchy;


-- =========================================================
-- SECTION 3: SUBQUERIES
-- =========================================================

-- 3A. Villages with individual beneficiary totals above the average
-- village-level individual beneficiary total.
SELECT
    village_totals.village_name,
    village_totals.district_name,
    village_totals.individual_beneficiaries
FROM (
    SELECT
        vl.village_id,
        vl.village_name,
        j.district_name,
        SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                 THEN bpd.beneficiaries ELSE 0 END) AS individual_beneficiaries
    FROM village_locations vl
    JOIN jurisdiction_hierarchy j ON j.district_id = vl.district_id
    LEFT JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
    GROUP BY vl.village_id, vl.village_name, j.district_name
) AS village_totals
WHERE village_totals.individual_beneficiaries > (
    SELECT AVG(per_village.individual_beneficiaries)
    FROM (
        SELECT
            vl2.village_id,
            SUM(CASE WHEN bpd2.beneficiary_type = 'Individual'
                     THEN bpd2.beneficiaries ELSE 0 END) AS individual_beneficiaries
        FROM village_locations vl2
        LEFT JOIN beneficiary_partner_data bpd2 ON bpd2.village_id = vl2.village_id
        GROUP BY vl2.village_id
    ) AS per_village
)
ORDER BY village_totals.individual_beneficiaries DESC;

-- 3B. Partners whose individual reach is above the average partner reach.
SELECT
    partner_totals.partner_name,
    partner_totals.individual_beneficiaries
FROM (
    SELECT
        p.partner_id,
        p.partner_name,
        SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                 THEN bpd.beneficiaries ELSE 0 END) AS individual_beneficiaries
    FROM partners p
    LEFT JOIN beneficiary_partner_data bpd ON bpd.partner_id = p.partner_id
    GROUP BY p.partner_id, p.partner_name
) AS partner_totals
WHERE partner_totals.individual_beneficiaries > (
    SELECT AVG(per_partner.individual_beneficiaries)
    FROM (
        SELECT
            p2.partner_id,
            SUM(CASE WHEN bpd2.beneficiary_type = 'Individual'
                     THEN bpd2.beneficiaries ELSE 0 END) AS individual_beneficiaries
        FROM partners p2
        LEFT JOIN beneficiary_partner_data bpd2 ON bpd2.partner_id = p2.partner_id
        GROUP BY p2.partner_id
    ) AS per_partner
)
ORDER BY partner_totals.individual_beneficiaries DESC;


-- =========================================================
-- SECTION 4: COMMON TABLE EXPRESSIONS (CTEs)
-- =========================================================

-- 4A. District-level impact using a CTE.
WITH district_impact AS (
    SELECT
        j.district_id,
        j.region_name,
        j.district_name,
        j.district_population,
        COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                          THEN bpd.beneficiaries ELSE 0 END), 0) AS individual_beneficiaries,
        COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN bpd.partner_id END) AS number_of_partners
    FROM jurisdiction_hierarchy j
    LEFT JOIN village_locations vl ON vl.district_id = j.district_id
    LEFT JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
    GROUP BY j.district_id, j.region_name, j.district_name, j.district_population
)
SELECT
    region_name,
    district_name,
    district_population,
    individual_beneficiaries,
    ROUND(100.0 * individual_beneficiaries / NULLIF(district_population, 0), 2) AS coverage_rate_pct,
    number_of_partners
FROM district_impact
ORDER BY coverage_rate_pct DESC;


-- =========================================================
-- SECTION 5: WINDOW FUNCTIONS
-- RANK, ROW_NUMBER, PARTITION BY
-- =========================================================

USE humanitarian_program;

-- 5A. Rank partners by individual beneficiaries overall.
WITH partner_totals AS (
    SELECT
        p.partner_id,
        p.partner_name,
        COALESCE(
            SUM(
                CASE
                    WHEN bpd.beneficiary_type = 'Individual'
                    THEN bpd.beneficiaries
                    ELSE 0
                END
            ), 0
        ) AS individual_beneficiaries
    FROM partners p
    LEFT JOIN beneficiary_partner_data bpd
        ON bpd.partner_id = p.partner_id
    GROUP BY p.partner_id, p.partner_name
)
SELECT
    partner_name,
    individual_beneficiaries,
    RANK() OVER (
        ORDER BY individual_beneficiaries DESC
    ) AS partner_rank,
    ROW_NUMBER() OVER (
        ORDER BY individual_beneficiaries DESC, partner_name
    ) AS row_number
FROM partner_totals
ORDER BY partner_rank, partner_name;

-- 5B. Rank partners within each district.
WITH district_partner_totals AS (
    SELECT
        j.district_id,
        j.district_name,
        p.partner_id,
        p.partner_name,
        SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                 THEN bpd.beneficiaries ELSE 0 END) AS individual_beneficiaries
    FROM jurisdiction_hierarchy j
    JOIN village_locations vl ON vl.district_id = j.district_id
    JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
    JOIN partners p ON p.partner_id = bpd.partner_id
    GROUP BY j.district_id, j.district_name, p.partner_id, p.partner_name
)
SELECT
    district_name,
    partner_name,
    individual_beneficiaries,
    RANK() OVER (
        PARTITION BY district_id
        ORDER BY individual_beneficiaries DESC
    ) AS rank_within_district,
    ROW_NUMBER() OVER (
        PARTITION BY district_id
        ORDER BY individual_beneficiaries DESC, partner_name
    ) AS row_within_district
FROM district_partner_totals
ORDER BY district_name, rank_within_district, partner_name;


-- =========================================================
-- SECTION 6: VIEWS
-- partner_summary and district_summary
-- =========================================================

CREATE OR REPLACE VIEW partner_summary AS
SELECT
    p.partner_id,
    p.partner_name,
    COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                      THEN bpd.beneficiaries ELSE 0 END), 0) AS total_individual_beneficiaries,
    COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN bpd.village_id END) AS villages_served,
    COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN vl.district_id END) AS districts_reached
FROM partners p
LEFT JOIN beneficiary_partner_data bpd ON bpd.partner_id = p.partner_id
LEFT JOIN village_locations vl ON vl.village_id = bpd.village_id
GROUP BY p.partner_id, p.partner_name;

CREATE OR REPLACE VIEW district_summary AS
SELECT
    j.district_id,
    j.region_name,
    j.district_name,
    j.district_population,
    COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                      THEN bpd.beneficiaries ELSE 0 END), 0) AS individual_beneficiaries,
    ROUND(
        100.0 * COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                                  THEN bpd.beneficiaries ELSE 0 END), 0)
        / NULLIF(j.district_population, 0), 2
    ) AS coverage_rate_pct,
    COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN bpd.partner_id END) AS number_of_partners
FROM jurisdiction_hierarchy j
LEFT JOIN village_locations vl ON vl.district_id = j.district_id
LEFT JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
GROUP BY j.district_id, j.region_name, j.district_name, j.district_population;

-- Check the views.
SELECT * FROM partner_summary ORDER BY total_individual_beneficiaries DESC;
SELECT * FROM district_summary ORDER BY coverage_rate_pct DESC;


-- =========================================================
-- SECTION 7: TRIGGERS
-- 7A reject negative beneficiary values
-- 7B log newly inserted activity records
-- =========================================================

CREATE TABLE IF NOT EXISTS beneficiary_activity_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    partner_name VARCHAR(150) NOT NULL,
    village_name VARCHAR(100) NOT NULL,
    beneficiaries INT NOT NULL,
    inserted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_reject_negative_beneficiaries_insert;
DROP TRIGGER IF EXISTS trg_reject_negative_beneficiaries_update;
DROP TRIGGER IF EXISTS trg_log_beneficiary_insert;

DELIMITER $$

CREATE TRIGGER trg_reject_negative_beneficiaries_insert
BEFORE INSERT ON beneficiary_partner_data
FOR EACH ROW
BEGIN
    IF NEW.beneficiaries < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Beneficiaries cannot be negative';
    END IF;
END$$

CREATE TRIGGER trg_reject_negative_beneficiaries_update
BEFORE UPDATE ON beneficiary_partner_data
FOR EACH ROW
BEGIN
    IF NEW.beneficiaries < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Beneficiaries cannot be negative';
    END IF;
END$$

CREATE TRIGGER trg_log_beneficiary_insert
AFTER INSERT ON beneficiary_partner_data
FOR EACH ROW
BEGIN
    INSERT INTO beneficiary_activity_log (
        partner_name,
        village_name,
        beneficiaries,
        inserted_at
    )
    SELECT
        p.partner_name,
        vl.village_name,
        NEW.beneficiaries,
        NOW()
    FROM partners p
    JOIN village_locations vl
    WHERE p.partner_id = NEW.partner_id
      AND vl.village_id = NEW.village_id;
END$$

DELIMITER ;

-- Inspect the log table. It will receive entries when new activity rows are inserted.
SELECT * FROM beneficiary_activity_log ORDER BY inserted_at DESC;
SELECT *
FROM beneficiary_activity_log;

-- =========================================================
-- SECTION 8: STORED PROCEDURES
-- GetPartnerReport(partner_name)
-- GetDistrictImpact(district_name)
-- =========================================================

DROP PROCEDURE IF EXISTS GetPartnerReport;
DROP PROCEDURE IF EXISTS GetDistrictImpact;

DELIMITER $$

CREATE PROCEDURE GetPartnerReport(IN input_partner_name VARCHAR(150))
BEGIN
    WITH partner_totals AS (
        SELECT
            p.partner_id,
            p.partner_name,
            COALESCE(SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                              THEN bpd.beneficiaries ELSE 0 END), 0) AS total_individual_beneficiaries,
            COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN bpd.village_id END) AS villages_served,
            COUNT(DISTINCT CASE WHEN bpd.beneficiaries > 0 THEN vl.district_id END) AS districts_reached
        FROM partners p
        LEFT JOIN beneficiary_partner_data bpd ON bpd.partner_id = p.partner_id
        LEFT JOIN village_locations vl ON vl.village_id = bpd.village_id
        GROUP BY p.partner_id, p.partner_name
    ),
    ranked_partners AS (
        SELECT
            partner_totals.*,
            RANK() OVER (ORDER BY total_individual_beneficiaries DESC) AS partner_rank
        FROM partner_totals
    )
    SELECT
        partner_name,
        total_individual_beneficiaries,
        villages_served,
        districts_reached,
        partner_rank
    FROM ranked_partners
    WHERE partner_name = input_partner_name;
END$$

CREATE PROCEDURE GetDistrictImpact(IN input_district_name VARCHAR(100))
BEGIN
    SELECT
        region_name,
        district_name,
        district_population,
        individual_beneficiaries,
        coverage_rate_pct,
        number_of_partners
    FROM district_summary
    WHERE district_name = input_district_name;
END$$

DELIMITER ;

-- Example calls: replace names with values that exist in your tables.
-- CALL GetPartnerReport('Partner Name');
-- CALL GetDistrictImpact('District Name');


-- =========================================================
-- SECTION 9: ADVANCED CHALLENGES
-- =========================================================

-- 9A. Highest-beneficiary partner in each district.
-- RANK returns ties if multiple partners share the highest total.
WITH district_partner_totals AS (
    SELECT
        j.district_id,
        j.district_name,
        p.partner_id,
        p.partner_name,
        SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                 THEN bpd.beneficiaries ELSE 0 END) AS individual_beneficiaries
    FROM jurisdiction_hierarchy j
    JOIN village_locations vl ON vl.district_id = j.district_id
    JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
    JOIN partners p ON p.partner_id = bpd.partner_id
    GROUP BY j.district_id, j.district_name, p.partner_id, p.partner_name
),
ranked AS (
    SELECT
        district_partner_totals.*,
        RANK() OVER (
            PARTITION BY district_id
            ORDER BY individual_beneficiaries DESC
        ) AS district_rank
    FROM district_partner_totals
)
SELECT
    district_name,
    partner_name,
    individual_beneficiaries
FROM ranked
WHERE district_rank = 1
ORDER BY district_name, partner_name;

-- 9B. Districts whose coverage is above the average district coverage rate.
SELECT
    district_name,
    region_name,
    district_population,
    individual_beneficiaries,
    coverage_rate_pct
FROM district_summary
WHERE coverage_rate_pct > (
    SELECT AVG(coverage_rate_pct)
    FROM district_summary
)
ORDER BY coverage_rate_pct DESC;

-- 9C. Partners who are the top partner in at least one district.
WITH district_partner_totals AS (
    SELECT
        j.district_id,
        j.district_name,
        p.partner_id,
        p.partner_name,
        SUM(CASE WHEN bpd.beneficiary_type = 'Individual'
                 THEN bpd.beneficiaries ELSE 0 END) AS individual_beneficiaries
    FROM jurisdiction_hierarchy j
    JOIN village_locations vl ON vl.district_id = j.district_id
    JOIN beneficiary_partner_data bpd ON bpd.village_id = vl.village_id
    JOIN partners p ON p.partner_id = bpd.partner_id
    GROUP BY j.district_id, j.district_name, p.partner_id, p.partner_name
),
ranked AS (
    SELECT
        district_partner_totals.*,
        RANK() OVER (
            PARTITION BY district_id
            ORDER BY individual_beneficiaries DESC
        ) AS district_rank
    FROM district_partner_totals
)
SELECT DISTINCT
    partner_name
FROM ranked
WHERE district_rank = 1
ORDER BY partner_name;


SELECT 'Hello Zack' AS test;




-- Confirm beneficiary type
SELECT
    beneficiary_type,
    COUNT(*) AS record_count,
    SUM(beneficiaries) AS total_beneficiaries
FROM beneficiary_partner_data
GROUP BY beneficiary_type;
-- check district population
SELECT
    district_name,
    district_population
FROM jurisdiction_hierarchy
WHERE district_population IS NULL
   OR district_population <= 0;
   
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