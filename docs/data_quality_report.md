# Data Quality Report

The following issues were verified by reading the six raw CSVs with Pandas. No raw file was changed, and no inconsistency was automatically corrected.

Issue: Upcoming-project filename differs from the expected name

Source: `data/raw/`

Evidence: The actual file is `upcoming projects.csv` (with a space). No `upcoming_projects.csv` (with an underscore) exists.

Impact: Scripts or documentation that use the expected underscore filename will not find the actual file.

Recommended handling: Preserve the source file unchanged. Confirm the intended filename and make downstream readers use the verified physical name unless an explicit, separately approved rename is made.

Issue: Extra index-like column in the projects table

Source: `data/raw/projects.csv`

Evidence: The table has an `Unnamed: 0` column containing the sequence 0 through 9 in its 10 rows, in addition to `project_id`.

Impact: The exported row index may be mistaken for a business field or used as a key.

Recommended handling: Confirm that this column is an export index; if so, exclude it in a future import or cleaned output without changing the raw file.

Issue: Reported Sales employee count does not match employee records

Source: `data/raw/departments.csv`; compared with `data/raw/employees.csv`

Evidence: Department 3 (Sales) reports `Number_of_Employees = 3`; grouping employee rows by `department_id` yields 2 employees. The other four department counts match.

Impact: Department headcount summaries based on the reported count will disagree with counts derived from employee records.

Recommended handling: Confirm which source is authoritative and document the chosen headcount definition before reporting; do not alter either raw value during exploration.

Issue: Completed project department differs from the master project record

Source: `data/raw/completed_projects.csv`; compared with `data/raw/projects.csv`

Evidence: Project 204, CRM Integration, has `department_id = 5` in `completed_projects.csv` and `department_id = 1` in `projects.csv`. Its name, budget, and dates match.

Impact: Department-level project attribution differs depending on which table is used.

Recommended handling: Verify the correct department with the dataset owner and retain the discrepancy in analysis until confirmed.

Issue: Upcoming project department differs from the master project record

Source: Actual upcoming table `data/raw/upcoming projects.csv`; compared with `data/raw/projects.csv`

Evidence: Project 201, Website Overhaul, has `department_id = 5` in the upcoming table and `department_id = 1` in `projects.csv`.

Impact: Department-level attribution for project 201 is inconsistent across the two tables.

Recommended handling: Verify the intended department with the dataset owner; do not infer which value is correct from the other fields.

Issue: Upcoming project start dates differ from the master project dates

Source: Actual upcoming table `data/raw/upcoming projects.csv`; compared with `data/raw/projects.csv`

Evidence: For all six upcoming project IDs (201, 202, 203, 206, 207, and 210), the status table's `project_start_date` is exactly one calendar year later than `projects.csv.start_date`. Names, budgets, and end dates match for these rows.

Impact: Timeline analyses can produce different start dates depending on the source table.

Recommended handling: Confirm whether these are revised dates or an inconsistency. Keep both source values visible until clarified.

Issue: Upcoming label is stale relative to the current date

Source: Actual upcoming table `data/raw/upcoming projects.csv`; current date 2026-09-30

Evidence: All six rows have end dates from 2025-06-30 through 2025-12-31, which are before 2026-09-30.

Impact: Treating these rows as currently upcoming would misstate their temporal status. This may instead be a historical dataset snapshot.

Recommended handling: Establish the dataset's as-of date and intended meaning of the table label before using it for current-status reporting; do not reclassify records automatically.

## Checks With No Issue Found

- No null values or exact duplicate rows were detected in any of the six CSVs.
- All checked employee, department, and project ID references resolve to a matching row; no unmatched employee, project, or department IDs were found.
- The completed and upcoming project IDs are disjoint and together cover the 10 IDs in `projects.csv`.
- Budget fields loaded as numeric values. Project budgets range from 30,000 to 80,000; no null, nonnumeric, or negative project budgets were found.
- All dates parsed successfully, and no project start date is later than its end date.
