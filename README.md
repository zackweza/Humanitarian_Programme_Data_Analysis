# Advanced Humanitarian Programme Analysis

## 1. Project Overview

This project uses MySQL to analyze humanitarian programme data across districts, villages, and implementing partners. It applies advanced SQL techniques to evaluate beneficiary reach, compare partner performance, assess district-level coverage, and support data-quality validation.

## 2. Project Objectives

- Analyze beneficiary reach by partner, village, and district.
- Compare individual and household beneficiary records.
- Identify leading partners within districts.
- Assess district population data and beneficiary coverage.
- Apply database objects and advanced SQL techniques to support reporting and data integrity.

## 3. Database Structure

The project uses the `humanitarian_program` database, with four core tables:

| Table | Purpose |
|---|---|
| `jurisdiction_hierarchy` | Stores regions, districts, and district populations. |
| `village_locations` | Stores villages, their district relationships, and village populations. |
| `partners` | Stores humanitarian partner details. |
| `beneficiary_partner_data` | Stores partner-level beneficiary records by village and beneficiary type. |

The project also includes a `beneficiary_activity_log` table for recording new beneficiary insertions.

## 4. SQL Techniques Used

- Aggregation with `GROUP BY`, `HAVING`, and conditional aggregation using `CASE`.
- `UNION` and `UNION ALL`.
- Subqueries for comparative analysis.
- Common Table Expressions (CTEs).
- Window functions, including `RANK()` and `ROW_NUMBER()`.
- Views for reusable reporting.
- Triggers for beneficiary validation and activity logging.
- Stored procedures for partner and district reporting.

## 5. Data Quality and Validation

The validation checks recorded 69 beneficiary-partner records:

- 42 records classified as `Individual`, totaling 56,250 beneficiaries.
- 27 records classified as `Household`, totaling 12,450 beneficiaries.
- No missing partner IDs, missing village IDs, missing beneficiary counts, or zero/negative beneficiary counts were found in the checks performed.
- The district population check returned no districts with missing or non-positive population values.

These findings describe the checks performed on the available data. Beneficiary counts should not automatically be interpreted as unique people without confirmation from the source data.

## 6. Reporting and Analysis

The project includes analysis for partner reach, district-level coverage, partner rankings, and the highest-beneficiary partner in each district. Stored procedures are provided for partner reports and district impact reports.

Coverage rates should be interpreted in the context of the source data. Values above 100% may require investigation into how beneficiaries are counted and how population estimates were defined.

## 7. How to Run

1. Install MySQL Server and MySQL Workbench.
2. Open the SQL submission file: `Advanced_Humanitarian_Programme_Analysis.sql`.
3. Confirm that the `humanitarian_program` database and its existing tables match the expected schema.
4. Execute the script in sections and review the results and execution messages.
5. Test the stored procedures using valid partner and district names from the database.

**Important:** The script includes database setup statements and operations that may drop and recreate views, triggers, or stored procedures. Review the script before rerunning it against a database containing important data.

## 8. Project Deliverables

- `Advanced_Humanitarian_Programme_Analysis.sql` — main SQL script.
- `README.md` — project documentation.

## 9. Conclusion

This project demonstrates the use of advanced MySQL features to validate humanitarian programme records, analyze partner performance, and develop reusable reporting logic for district-level decision-making.
