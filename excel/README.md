# Excel Reporting Layer

## Purpose

This workbook provides a formula-based snapshot of the cleaned company, employee, and project data. It contains descriptive reporting only. Project budgets are planned/reported budgets; the dataset does not contain actual project spending, revenue, or profit.

## Source Datasets

The workbook and all Power Query scripts use only these cleaned files:

- `data/cleaned/employees_cleaned.csv`
- `data/cleaned/departments_cleaned.csv`
- `data/cleaned/projects_cleaned.csv`
- `data/cleaned/project_assignments_cleaned.csv`
- `data/cleaned/completed_projects_cleaned.csv`
- `data/cleaned/upcoming_projects_cleaned.csv`

The workbook includes a static snapshot copied from those files when it was generated. A hidden `Source Data` sheet holds its source tables; a hidden `Config` sheet contains the `tblProjectRoot` table used by the M scripts.

## Power Query Transformations

Six standalone M scripts are in `excel/power_query/`. Each reads its corresponding cleaned CSV using the root path in `tblProjectRoot`, promotes headers, trims text fields where present, and converts IDs, numeric fields, and dates to appropriate types. They do not filter or delete rows and do not reconcile documented source differences. `Projects.m` reads `projects_cleaned.csv`; `UpcomingProjects.m` reads `upcoming_projects_cleaned.csv`.

## Report Sheets

- **Executive Summary:** employee, department, project, project-budget, completed, and upcoming KPIs; project-status, project-budget-by-department, and employee-count-by-department charts.
- **Department Analysis:** headcount, average and total salary, project count, and total project budget by department.
- **Project Analysis:** project, department, budget, status, dates, derived duration in days, and assigned employee count.
- **Employee Analysis:** employee name, job title, department, salary, and assigned project count; includes the no-assignment result.
- **Data Quality:** verified issues and successful validation checks.
- **Data Dictionary:** dataset, column, type, description, and source.

## Excel Features

The workbook uses Excel Tables for the source and report ranges, structured-reference formulas including `COUNTIFS`, `SUMIFS`, `AVERAGEIFS`, and `XLOOKUP`, basic conditional formatting, and standard charts. Duration is explicitly labeled as derived (`End Date - Start Date`). PivotTables, PivotCharts, and slicers are not included because this environment cannot run native Excel authoring/refresh automation.

## Data-Quality Handling

The workbook preserves and flags the documented issues:

- Sales reports 3 employees while the employee rows contain 2 for Sales.
- Project 201 has department 5 in the upcoming table and department 1 in master projects.
- Project 204 has department 5 in completed projects and department 1 in master projects.
- All six upcoming project start dates differ from the corresponding master dates.
- Upcoming project end dates are before the documentation's validation date, 2026-09-30.
- No missing values or exact duplicate rows were found; IDs resolve, dates are valid, and budgets are numeric and non-negative.

No values were reconciled or silently changed. No revenue, actual expense, actual cost, profit, variance, ROI, or other unsupported financial measure is calculated.

## Limitations

`Financial_Analytics_Report.xlsx` is a generated static snapshot with formulas and charts; it does not contain executable Power Query connections and has not been refreshed by Microsoft Excel. The Python workbook library used here can create the workbook structure but cannot author or execute Excel's Power Query mashup connections. Excel will recalculate formulas when the workbook opens; this environment could not verify that recalculation in Excel.

Power Query M scripts are separate text files, not embedded queries. The workbook's formula report will not automatically update merely by refreshing a separately added query. Replace or reconnect the source tables in Excel as part of adopting the queries, then verify the report formulas and charts.

## How to Use and Refresh in Excel

1. Keep the workbook in the project folder. If the project moves, unhide the `Config` sheet and update the single value in `tblProjectRoot[ProjectRoot]` to the absolute project-folder path.
2. In Excel, open **Data > Get Data > From Other Sources > Blank Query**, then open **Advanced Editor**.
3. Open the corresponding `.m` file from `excel/power_query/`, copy its complete contents into Advanced Editor, and select **Done**. Name the query for its dataset.
4. Repeat for all six files. Choose **Close & Load To...** and load each query as a table on a separate worksheet. Verify row counts against the source counts below and preserve the query's output values as provided.
5. To use refreshed query output in the report, reconnect the report formulas/charts to the loaded tables in Excel and verify totals and data-quality findings. The generated workbook has no automatic query-to-report wiring, so **Refresh All alone will not refresh its static snapshot**.

For this generated snapshot, formula cells are set to recalculate when opened in Excel. The report counts are based on the six cleaned datasets: employees 10, departments 5, projects 10, assignments 10, completed projects 4, and upcoming projects 6.