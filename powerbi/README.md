# Power BI Reporting Layer

## Purpose

This folder specifies an interactive Power BI dashboard for descriptive analysis of employees, departments, projects, assignments, project budgets, salaries, and project status. It does not report revenue, actual spending, profit, ROI, or budget variance. The dataset contains project budgets but no actual project spending, revenue, or profit.

Power BI Desktop was not available in the build environment. No `.pbix` file, Power BI model, visuals, credentials, or refresh configuration were created or tested. The documents below are an implementation guide, not a completed Power BI report.

## MySQL Connection

In Power BI Desktop, use **Get Data > MySQL database** and connect to server `localhost` and database `financial_analytics`. Use Import mode for this portfolio report unless a specific DirectQuery requirement is later agreed. Install a compatible Oracle MySQL Connector/NET if Power BI requests it. Authenticate interactively in Power BI; do not store a password in this project.

Load these existing MySQL tables:

- `employees` (10 rows)
- `departments` (5 rows)
- `projects` (10 rows)
- `project_assignments` (10 rows)
- `completed_projects` (4 rows)
- `upcoming_projects` (6 rows)

Do not load or substitute the raw CSVs. The MySQL tables were verified from cleaned outputs in the prior project step.

## Data Model

Create the six relationships documented in [data_model.md](data_model.md). Use single-direction filtering from dimensions to facts. Do not add direct department relationships to the status tables: their source `department_id` values disagree with master project assignments for projects 201 and 204, and a direct path would create an ambiguous filter path through `projects`.

Create a reporting-only `Project Status` table by appending the rows of `completed_projects` and `upcoming_projects`, adding a constant `Status` value (`Completed` or `Upcoming`) before each append. Retain each status table's own project dates and department ID. The table is for status-based visuals; do not overwrite the master `projects` values. Relate it to `projects` by `project_id` with single-direction filtering from `projects` to `Project Status`. Use `projects.department_id` for master department reporting, and use the status tables directly on the data-quality page to show conflicting status-side values.

This append is a transparent reporting transformation, not a new source dataset. It preserves the six-row/ four-row status membership, dates, and department IDs. It does not infer status from dates.

## Dashboard Pages

Page layouts, visual fields, and slicers are specified in [dashboard_spec.md](dashboard_spec.md): Executive Overview, Department Analysis, and Project Analysis. Add a fourth Data Quality page if there is room; otherwise put a readable data-quality table on the Executive Overview page.

## DAX Measures

Use the beginner-friendly measures in [measures.md](measures.md). Project budget totals should use the master `projects` table to avoid adding duplicate project records from status tables. Employee counts by department must be calculated from employee records; display the source-reported department count separately where useful.

## Data-Quality Handling

Preserve and make visible:

- Sales reports 3 department employees; `employees` has 2 Sales employee rows.
- Project 201 has department 5 in `upcoming_projects` versus department 1 in master `projects`.
- Project 204 has department 5 in `completed_projects` versus department 1 in master `projects`.
- The start dates for all six upcoming-table projects differ from master project dates.
- Upcoming-table end dates are historical relative to the verified date 2026-09-30.

Do not reconcile these values, infer a current project status from dates, delete rows, or hide the reported Sales count. The source checks found no missing values, no exact duplicate rows, valid ID references, valid dates, and numeric non-negative budgets.

## Refresh Instructions

1. Open Power BI Desktop and connect to `localhost` / `financial_analytics` using the MySQL connector.
2. Import the six tables listed above and confirm their row counts.
3. Create the relationships in `data_model.md` with single-direction filtering.
4. Append completed and upcoming rows in Power Query, adding `Status` before appending. Retain status-table dates and department IDs; do not replace them with master values.
5. Create the measures in `measures.md`, then build the visuals and slicers in `dashboard_spec.md`.
6. Select **Refresh** in Desktop after the MySQL tables are updated. Review the row counts and data-quality comparisons after each refresh.
7. Save a `.pbix` locally only after testing visuals, filter behavior, and DAX results in Power BI Desktop.

No scheduled refresh, Power BI Service deployment, gateway, or real-time behavior is configured or claimed. Refresh in Desktop is a manual action requiring an available MySQL connection and appropriate credentials.

## Limitations

Power BI Desktop was unavailable here, so the model, append query, measures, visuals, slicers, and connection could not be built or validated in Power BI. The project contains implementation documentation only; it does not contain a `.pbix` file.