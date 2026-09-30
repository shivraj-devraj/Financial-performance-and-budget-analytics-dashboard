# DAX Measures

Create these measures in Power BI after loading the six MySQL tables and the reporting-only `Project Status` append. These measures use existing fields only. Project budget totals use master `projects` to avoid counting project rows more than once.

## Total Employees

```DAX
Total Employees =
DISTINCTCOUNT(employees[employee_id])
```

Counts employee records, respecting current department or job-title filter context.

## Total Departments

```DAX
Total Departments =
DISTINCTCOUNT(departments[department_id])
```

Counts departments in the current filter context.

## Total Projects

```DAX
Total Projects =
DISTINCTCOUNT(projects[project_id])
```

Counts master projects once each.

## Total Project Budget

```DAX
Total Project Budget =
SUM(projects[project_budget])
```

Totals recorded project budgets from the master project table. This is not actual spending, revenue, or profit.

## Completed Projects

```DAX
Completed Projects =
DISTINCTCOUNT(completed_projects[project_id])
```

Counts project IDs present in the completed status table.

## Upcoming Projects

```DAX
Upcoming Projects =
DISTINCTCOUNT(upcoming_projects[project_id])
```

Counts project IDs present in the upcoming status table; it does not determine status from dates.

## Average Salary

```DAX
Average Salary =
AVERAGE(employees[salary])
```

Returns the average supplied employee salary for the current filter context.

## Total Salary

```DAX
Total Salary =
SUM(employees[salary])
```

Totals supplied employee salary values. No currency unit is inferred.

## Average Project Budget

```DAX
Average Project Budget =
AVERAGE(projects[project_budget])
```

Returns the average recorded project budget from master projects.

## Reported Department Employee Count

```DAX
Reported Department Employee Count =
SUM(departments[number_of_employees])
```

Shows the count reported in the departments source table. On department-level visuals, compare this with `Total Employees`; Sales intentionally remains 3 reported versus 2 employee rows.

## Project Count by Status

```DAX
Project Count by Status =
DISTINCTCOUNT('Project Status'[project_id])
```

Use with `'Project Status'[Status]` in a visual to show counts from completed/upcoming table membership.

## Assigned Employee Count

```DAX
Assigned Employee Count =
DISTINCTCOUNT(project_assignments[employee_id])
```

Counts assigned employees in the current project context through the `projects` to `project_assignments` relationship.

## Derived Project Duration Column

Create this calculated column in the reporting-only `Project Status` table rather than a financial measure:

```DAX
Project Duration (Days) =
DATEDIFF('Project Status'[project_start_date], 'Project Status'[project_end_date], DAY)
```

This is elapsed calendar days derived from status-table dates. It does not change either source date.