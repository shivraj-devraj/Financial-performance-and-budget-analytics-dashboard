# Power BI Data Model

Load only the six verified MySQL tables in database `financial_analytics`. Use single-direction filtering from the one-side table to the many-side table. Each listed key is unique in its one-side table based on the verified cleaned data.

## Relationships

| One-side table and key | Many-side table and key | Cardinality | Meaning |
|---|---|---|---|
| `departments.department_id` | `employees.department_id` | One-to-many | One department can be referenced by many employees. |
| `departments.department_id` | `projects.department_id` | One-to-many | A master project belongs to the department recorded in `projects`. |
| `employees.employee_id` | `project_assignments.employee_id` | One-to-many | One employee can have one or more assignment rows. |
| `projects.project_id` | `project_assignments.project_id` | One-to-many | One project can have one or more assignment rows. |
| `projects.project_id` | `completed_projects.project_id` | One-to-one for present rows | The completed table is a status subset keyed by the same project ID. |
| `projects.project_id` | `upcoming_projects.project_id` | One-to-one for present rows | The upcoming table is a status subset keyed by the same project ID. |

For the one-to-one status relationships, filter from `projects` to each status table. Each project appears in exactly one status table in the verified data; four are completed and six are upcoming.

## Project Status Reporting Table

Create a query named `Project Status` by appending `completed_projects` and `upcoming_projects` in Power Query:

1. Add a text column `Status` with value `Completed` to the completed query.
2. Add a text column `Status` with value `Upcoming` to the upcoming query.
3. Append the two queries using their shared columns: `project_id`, `project_name`, `project_budget`, `project_start_date`, `project_end_date`, `department_id`, and `Status` (the completed query has no `project_lead`; keep that separate rather than fabricating a value).
4. Name the appended output `Project Status`. It contains 10 records if the source counts remain unchanged.
5. Optionally add the derived whole-number column `Project Duration (Days)` as `Duration.Days([project_end_date] - [project_start_date])`. Keep the label explicit that this is elapsed days derived from the status-table dates.

This is a reporting transformation based on status-table membership. It does not infer status from dates or replace dates/departments with master values. To use the required seven-column project status shape without introducing nulls for `project_lead`, omit `project_lead` from both inputs to the append and retain the source `upcoming_projects.project_lead` in its original table.

## Ambiguous Department Attribution

Do not create direct relationships from `departments` to `completed_projects` or `upcoming_projects`. The status tables have their own `department_id`, which is a valid department key but does not always match master project assignment: project 204 is department 5 in `completed_projects` and department 1 in `projects`; project 201 is department 5 in `upcoming_projects` and department 1 in `projects`.

Relating status tables to both `departments` and `projects` can create multiple filter paths. For main department slicing, use the verified master path `departments -> projects -> Project Status`. Keep status-side department IDs visible in data-quality comparisons and do not treat them as corrected. Employee department analysis uses `departments -> employees`.

## Filter Flow

- Department slicers based on `departments.department_name` filter employees and master projects.
- Status slicers based on `Project Status[Status]` filter status-based visuals. Because the relationship to `projects` is single-direction, do not assume a status selection filters back through the model to every master-table visual; configure visual interactions or measures deliberately in Desktop.
- Job title slicers based on `employees[job_title]` filter employee visuals. Do not expect them to filter project visuals through the assignment bridge unless a clear, tested report need justifies a different filter design.

Keep the model single-direction and simple. Avoid bidirectional relationships to work around slicer behavior because they can create ambiguous filter paths.