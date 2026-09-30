# Dataset Overview

The provided company/project budget dataset was read from `data/raw/` with Pandas. The six files contain 45 rows in total. The physical filename for the upcoming-project table is `upcoming projects.csv` (with a space); `upcoming_projects.csv` does not exist in the raw directory. The raw files were inspected without modification.

| File as found | Rows | Columns | Exact duplicate rows |
|---|---:|---:|---:|
| `employees.csv` | 10 | 8 | 0 |
| `departments.csv` | 5 | 7 | 0 |
| `projects.csv` | 10 | 7 | 0 |
| `project_assignments.csv` | 10 | 3 | 0 |
| `completed_projects.csv` | 4 | 6 | 0 |
| `upcoming projects.csv` | 6 | 7 | 0 |

Types below are Pandas dtypes inferred by `pandas.read_csv`; date columns are therefore `object` strings in the loaded frames, not Pandas datetime types.

# employees.csv

Likely primary key: `employee_id`. Likely foreign key: `department_id` references `departments.Department_ID`.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `employee_id` | int64 | 0 |
| `first_name` | object | 0 |
| `last_name` | object | 0 |
| `email` | object | 0 |
| `job_title` | object | 0 |
| `salary` | int64 | 0 |
| `hire_date` | object | 0 |
| `department_id` | int64 | 0 |

Sample records (first 3):

| employee_id | first_name | last_name | email | job_title | salary | hire_date | department_id |
|---:|---|---|---|---|---:|---|---:|
| 1001 | Liam | Brown | john.doe@example.com | Software Engineer | 85000 | 2018-05-12 | 1 |
| 1002 | Emma | Taylor | jane.smith@example.com | Marketing Manager | 78000 | 2020-03-10 | 2 |
| 1003 | Michael | Johnson | michael.johnson@example.com | Data Scientist | 95000 | 2016-09-01 | 3 |

# departments.csv

Likely primary key: `Department_ID`. `Number_of_Employees` is a reported count, not an identifier.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `Department_ID` | int64 | 0 |
| `Department_Name` | object | 0 |
| `Department_Budget` | int64 | 0 |
| `Head_of_Department` | object | 0 |
| `Number_of_Employees` | int64 | 0 |
| `Department_Goals` | object | 0 |
| `Location` | object | 0 |

Sample records (first 3):

| Department_ID | Department_Name | Department_Budget | Head_of_Department | Number_of_Employees | Department_Goals | Location |
|---:|---|---:|---|---:|---|---|
| 1 | Engineering | 1200000 | Alice Green | 2 | Develop new products | Building A |
| 2 | Marketing | 800000 | Bob White | 2 | Increase brand awareness | Building B |
| 3 | Sales | 600000 | Carol Black | 3 | Boost sales | Building C |

# projects.csv

Likely primary key: `project_id`. Likely foreign key: `department_id` references `departments.Department_ID`. `Unnamed: 0` contains the sequence 0 through 9 and is not the project key.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `Unnamed: 0` | int64 | 0 |
| `project_id` | int64 | 0 |
| `project_name` | object | 0 |
| `project_budget` | int64 | 0 |
| `start_date` | object | 0 |
| `end_date` | object | 0 |
| `department_id` | int64 | 0 |

Sample records (first 3):

| Unnamed: 0 | project_id | project_name | project_budget | start_date | end_date | department_id |
|---:|---:|---|---:|---|---|---:|
| 0 | 201 | Website Overhaul | 60000 | 2024-01-15 | 2025-06-30 | 1 |
| 1 | 202 | Social Media Strategy | 45000 | 2024-02-20 | 2025-09-10 | 2 |
| 2 | 203 | Product Launch | 80000 | 2024-03-30 | 2025-12-31 | 3 |

# project_assignments.csv

Likely primary key: `assignment_id`. Likely foreign keys: `employee_id` references `employees.employee_id`; `project_id` references `projects.project_id`. This table links employees and projects.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `assignment_id` | int64 | 0 |
| `employee_id` | int64 | 0 |
| `project_id` | int64 | 0 |

Sample records (first 3):

| assignment_id | employee_id | project_id |
|---:|---:|---:|
| 1 | 1001 | 201 |
| 2 | 1002 | 202 |
| 3 | 1003 | 203 |

# completed_projects.csv

Likely primary key: `project_id`. Likely foreign keys: `project_id` references `projects.project_id`; `department_id` references `departments.Department_ID`.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `project_id` | int64 | 0 |
| `project_name` | object | 0 |
| `project_budget` | int64 | 0 |
| `project_start_date` | object | 0 |
| `project_end_date` | object | 0 |
| `department_id` | int64 | 0 |

Sample records (first 3):

| project_id | project_name | project_budget | project_start_date | project_end_date | department_id |
|---:|---|---:|---|---|---:|
| 204 | CRM Integration | 50000 | 2022-01-20 | 2023-01-20 | 5 |
| 205 | Brand Repositioning | 70000 | 2022-04-01 | 2023-04-01 | 2 |
| 208 | Customer Support System | 55000 | 2022-12-15 | 2022-12-15 | 3 |

# upcoming_projects.csv

This section refers to the upcoming-project table. Its actual raw filename is `upcoming projects.csv` (with a space), not `upcoming_projects.csv`. Likely primary key: `project_id`. Likely foreign keys: `project_id` references `projects.project_id`; `department_id` references `departments.Department_ID`. `project_lead` is a text name; no employee ID is provided for a validated key relationship.

| Column | Pandas dtype | Missing values |
|---|---|---:|
| `project_id` | int64 | 0 |
| `project_name` | object | 0 |
| `project_budget` | int64 | 0 |
| `project_start_date` | object | 0 |
| `project_end_date` | object | 0 |
| `department_id` | int64 | 0 |
| `project_lead` | object | 0 |

Sample records (first 3):

| project_id | project_name | project_budget | project_start_date | project_end_date | department_id | project_lead |
|---:|---|---:|---|---|---:|---|
| 201 | Website Overhaul | 60000 | 2025-01-15 | 2025-06-30 | 5 | Alice Green |
| 202 | Social Media Strategy | 45000 | 2025-02-20 | 2025-09-10 | 2 | Bob White |
| 203 | Product Launch | 80000 | 2025-03-30 | 2025-12-31 | 3 | Carol Black |

# Table Relationships

- `departments.Department_ID` is the likely parent key for `employees.department_id`, `projects.department_id`, and the department IDs in both project status tables.
- `project_assignments.employee_id` links to `employees.employee_id`.
- `project_assignments.project_id` links to `projects.project_id`.
- `completed_projects.project_id` and the upcoming table's `project_id` link to `projects.project_id`.
- Employees and projects form a many-to-many relationship through `project_assignments`.
- The completed and upcoming project IDs are disjoint and together cover all 10 project IDs in `projects.csv`.

# Data Types

Pandas inferred integer columns as `int64` and text/date columns as `object`. Date strings in `hire_date`, project start dates, and project end dates parsed successfully as dates during validation. ID fields, budget fields, `salary`, and `Number_of_Employees` loaded as `int64`.

# Missing Values

No null values were detected in any column of the six CSVs. All 45 rows have populated values in every column.

# Duplicate Records

No exact duplicate rows were detected in any CSV. Likely key columns (`employee_id`, `Department_ID`, `project_id`, and `assignment_id`, as applicable) were non-null and unique in their respective tables. Some unrelated columns can also be unique in a small subset; key assignments above are based on table meaning and references, not uniqueness alone.

# Data Quality Issues

- `departments.csv` reports 3 employees for Sales (department 3), while `employees.csv` contains 2 employees in that department.
- `projects.csv` and the status tables disagree on department for project 204 (completed) and project 201 (upcoming).
- The upcoming table's `project_start_date` is one year later than `projects.csv.start_date` for each of its six projects.
- `projects.csv` contains an extra `Unnamed: 0` sequence column with values 0-9.
- The file intended as `upcoming_projects.csv` is physically named `upcoming projects.csv`.
- As of 2026-09-30, all end dates in the file labeled as upcoming projects are in the past; this may reflect a historical snapshot.

# Validation Findings

- All employee, department, project-assignment, and status-table foreign-key references checked were matched; no dangling employee, project, or department IDs were found.
- All employees have an assignment, and all project IDs are represented in `project_assignments.csv`.
- The completed and upcoming status tables have no overlapping project IDs, no IDs outside `projects.csv`, and together contain all 10 master project IDs.
- Project budgets in the master and status tables loaded as numeric integers; values range from 30,000 to 80,000, with no null, nonnumeric, or negative values.
- Department budgets loaded as numeric integers and range from 400,000 to 1,200,000.
- All date values parsed successfully. Every project start date is on or before its corresponding end date; same-day dates occur for project 208 in the master and completed tables.
- Aside from the department and upcoming start-date differences listed above, project names, budgets, and end dates match between `projects.csv` and the corresponding status rows.
