# Dashboard Specification

Use a restrained three-page report with consistent department and status colors. All budget charts must be labeled **Project Budget** or **Project Budget Total**, never revenue or actual spending. Use the measures in `measures.md` and keep data-quality explanations readable.

## Page 1: Executive Overview

### KPI Cards

- Total Employees
- Total Departments
- Total Projects
- Total Project Budget
- Completed Projects
- Upcoming Projects

### Visuals

1. **Project Count by Status:** clustered column or donut using `Project Status[Status]` and `[Project Count by Status]`.
2. **Project Budget by Department:** bar chart using `departments[department_name]` and `SUM(projects[project_budget])`; department assignment is from master `projects`.
3. **Employee Count by Department:** bar chart using department name and `[Total Employees]`, which counts employee rows rather than the reported department count.
4. **Project Budget by Project:** bar chart using project name and `SUM(projects[project_budget])`.

### Slicers

- Department: `departments[department_name]`.
- Status: `Project Status[Status]`; confirm visual interactions because status filtering does not flow backward through the single-direction relationship.
- Job Title: `employees[job_title]`; apply to employee-related visuals only unless another tested interaction is explicitly configured.

Add a compact note or link to the Data Quality page: five documented discrepancies are preserved, and project budgets do not represent actual spending.

## Page 2: Department Analysis

### Department Table

Use one row per `departments[department_id]`, with:

- Department Name
- Employee Count: `[Total Employees]`, derived from employees
- Reported Employee Count: `[Reported Department Employee Count]`, retained from departments
- Average Salary: `[Average Salary]`
- Total Salary: `[Total Salary]`
- Project Count: distinct project ID count from master `projects`
- Total Project Budget: sum of master `projects[project_budget]`

Keep both employee counts visible or show the reported count in a nearby data-quality callout. Sales must visibly show observed 2 and reported 3.

### Visuals

1. Employee Count by Department.
2. Average Salary by Department.
3. Total Salary by Department.
4. Project Budget by Department.
5. Project Count by Department.

### Department Slicer

- Department: `departments[department_name]`.

## Page 3: Project Analysis

### Project Table

Use one row per `Project Status[project_id]`, related to master `projects`:

- Project ID
- Project Name
- Department: master department from `projects.department_id`; keep the status source department ID visible in a separate comparison or the Data Quality page.
- Project Budget: master `projects[project_budget]`.
- Status: `Project Status[Status]`, based on status-table membership.
- Start Date and End Date: status-table dates. Master dates remain available in `projects` and are compared on the Data Quality page.
- Project Duration: `Project Duration (Days)`, explicitly derived from status-table dates.
- Assigned Employee Count: `[Assigned Employee Count]`.

### Visuals

1. Project Budget by Project.
2. Project Count by Status.
3. Project Budget by Department.
4. Derived Project Duration by Project.

### Slicers

- Department: master department through `projects`.
- Status: `Project Status[Status]`.
- Project Name: master `projects[project_name]`.

Test slicer interactions in Desktop. Do not enable bidirectional relationships simply to make every slicer affect every visual.

## Data Quality Section or Page

If a fourth page is practical, show a table with issue, source values, comparison, and handling. Otherwise place the same content in a compact section on Page 1. Include:

- Sales reports 3 employees while there are 2 Sales employee rows.
- Project 201: upcoming department 5 versus master department 1.
- Project 204: completed department 5 versus master department 1.
- All six upcoming start dates differ from their master project dates by one calendar year.
- Upcoming project end dates are before validation date 2026-09-30.
- No missing values or exact duplicate rows were detected; ID references resolve; dates are valid; budgets are numeric and non-negative.

Do not silently correct values, infer status from dates, or label budgets as actual costs.