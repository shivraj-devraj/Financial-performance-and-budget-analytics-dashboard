USE financial_analytics;

-- A. BASIC DATA VALIDATION

-- Summarize loaded entity counts and the master project budget total.
-- The total uses projects only to avoid double-counting status-table copies.
SELECT
	(SELECT COUNT(*) FROM employees) AS total_employees,
	(SELECT COUNT(*) FROM departments) AS total_departments,
	(SELECT COUNT(*) FROM projects) AS total_projects,
	(SELECT COUNT(*) FROM completed_projects) AS completed_project_count,
	(SELECT COUNT(*) FROM upcoming_projects) AS upcoming_project_count,
	(SELECT COALESCE(SUM(project_budget), 0) FROM projects) AS total_project_budget;

-- B. DEPARTMENT ANALYSIS

-- Compare employee rows and salary aggregates with each department's reported count.
SELECT
	d.department_id,
	d.department_name,
	d.number_of_employees AS reported_employee_count,
	COUNT(e.employee_id) AS employee_count_from_rows,
	AVG(e.salary) AS average_salary,
	SUM(e.salary) AS total_salary
FROM departments AS d
LEFT JOIN employees AS e
	ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.number_of_employees
ORDER BY d.department_id;

-- Show the recorded department budgets without deriving new financial measures.
SELECT
	department_id,
	department_name,
	department_budget
FROM departments
ORDER BY department_budget DESC;

-- Summarize master projects and their budgets by department.
SELECT
	d.department_id,
	d.department_name,
	COUNT(p.project_id) AS project_count,
	COALESCE(SUM(p.project_budget), 0) AS total_project_budget
FROM departments AS d
LEFT JOIN projects AS p
	ON p.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_project_budget DESC, d.department_id;

-- C. PROJECT ANALYSIS

-- List master projects with their department names.
SELECT
	p.project_id,
	p.project_name,
	d.department_name,
	p.project_budget,
	p.start_date,
	p.end_date
FROM projects AS p
JOIN departments AS d
	ON d.department_id = p.department_id
ORDER BY p.project_id;

-- Rank projects by their recorded budget.
SELECT
	project_id,
	project_name,
	project_budget,
	RANK() OVER (ORDER BY project_budget DESC) AS budget_rank
FROM projects
ORDER BY budget_rank, project_id;

-- List completed-table values alongside the master department for comparison.
SELECT
	cp.project_id,
	cp.project_name,
	cp.project_budget,
	cp.project_start_date,
	cp.project_end_date,
	cp.department_id AS completed_department_id,
	p.department_id AS master_department_id
FROM completed_projects AS cp
JOIN projects AS p
	ON p.project_id = cp.project_id
ORDER BY cp.project_id;

-- List upcoming-table values alongside master dates and department without reconciling them.
SELECT
	up.project_id,
	up.project_name,
	up.project_budget,
	up.project_start_date AS upcoming_start_date,
	p.start_date AS master_start_date,
	up.project_end_date AS upcoming_end_date,
	p.end_date AS master_end_date,
	up.department_id AS upcoming_department_id,
	p.department_id AS master_department_id
FROM upcoming_projects AS up
JOIN projects AS p
	ON p.project_id = up.project_id
ORDER BY up.project_id;

-- Calculate elapsed calendar days between each project's dates.
SELECT
	project_id,
	project_name,
	start_date,
	end_date,
	DATEDIFF(end_date, start_date) AS project_duration_days
FROM projects
ORDER BY project_id;

-- Count assigned employees per master project, including projects with no assignments.
SELECT
	p.project_id,
	p.project_name,
	COUNT(DISTINCT pa.employee_id) AS assigned_employee_count
FROM projects AS p
LEFT JOIN project_assignments AS pa
	ON pa.project_id = p.project_id
GROUP BY p.project_id, p.project_name
ORDER BY assigned_employee_count DESC, p.project_id;

-- D. EMPLOYEE ANALYSIS

-- List each employee with the department name.
SELECT
	e.employee_id,
	e.first_name,
	e.last_name,
	e.job_title,
	e.salary,
	d.department_name
FROM employees AS e
JOIN departments AS d
	ON d.department_id = e.department_id
ORDER BY e.employee_id;

-- Show employees and their assigned project names; an employee may appear more than once.
SELECT
	e.employee_id,
	e.first_name,
	e.last_name,
	p.project_id,
	p.project_name
FROM employees AS e
JOIN project_assignments AS pa
	ON pa.employee_id = e.employee_id
JOIN projects AS p
	ON p.project_id = pa.project_id
ORDER BY e.employee_id, p.project_id;

-- Find employees with no project assignment.
SELECT
	e.employee_id,
	e.first_name,
	e.last_name,
	e.job_title,
	e.department_id
FROM employees AS e
WHERE NOT EXISTS (
	SELECT 1
	FROM project_assignments AS pa
	WHERE pa.employee_id = e.employee_id
)
ORDER BY e.employee_id;

-- Compare average recorded salary by job title.
SELECT
	job_title,
	COUNT(*) AS employee_count,
	AVG(salary) AS average_salary
FROM employees
GROUP BY job_title
ORDER BY average_salary DESC, job_title;

-- List the five highest-paid employees.
SELECT
	employee_id,
	first_name,
	last_name,
	job_title,
	salary
FROM employees
ORDER BY salary DESC, employee_id
LIMIT 5;

-- E. DATA QUALITY ANALYSIS

-- Identify departments where the reported headcount differs from employee rows.
SELECT
	d.department_id,
	d.department_name,
	d.number_of_employees AS reported_employee_count,
	COUNT(e.employee_id) AS observed_employee_count,
	COUNT(e.employee_id) - d.number_of_employees AS count_difference
FROM departments AS d
LEFT JOIN employees AS e
	ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.number_of_employees
HAVING COUNT(e.employee_id) <> d.number_of_employees
ORDER BY d.department_id;

-- Check project 201's upcoming department against the master project department.
SELECT
	up.project_id,
	up.department_id AS upcoming_department_id,
	p.department_id AS master_department_id,
	CASE
		WHEN up.department_id = p.department_id THEN 'MATCH'
		ELSE 'MISMATCH'
	END AS department_check
FROM upcoming_projects AS up
JOIN projects AS p
	ON p.project_id = up.project_id
WHERE up.project_id = 201;

-- Check project 204's completed department against the master project department.
SELECT
	cp.project_id,
	cp.department_id AS completed_department_id,
	p.department_id AS master_department_id,
	CASE
		WHEN cp.department_id = p.department_id THEN 'MATCH'
		ELSE 'MISMATCH'
	END AS department_check
FROM completed_projects AS cp
JOIN projects AS p
	ON p.project_id = cp.project_id
WHERE cp.project_id = 204;

-- Show upcoming-project dates that differ from the master project dates.
SELECT
	up.project_id,
	up.project_name,
	p.start_date AS master_start_date,
	up.project_start_date AS upcoming_start_date,
	p.end_date AS master_end_date,
	up.project_end_date AS upcoming_end_date
FROM upcoming_projects AS up
JOIN projects AS p
	ON p.project_id = up.project_id
WHERE NOT (up.project_start_date <=> p.start_date)
   OR NOT (up.project_end_date <=> p.end_date)
ORDER BY up.project_id;

-- F. BUSINESS-STYLE DESCRIPTIVE ANALYSIS

-- Rank departments by project budget total from the master projects table.
WITH department_project_totals AS (
	SELECT
		d.department_id,
		d.department_name,
		COALESCE(SUM(p.project_budget), 0) AS total_project_budget
	FROM departments AS d
	LEFT JOIN projects AS p
		ON p.department_id = d.department_id
	GROUP BY d.department_id, d.department_name
)
SELECT
	department_id,
	department_name,
	total_project_budget,
	DENSE_RANK() OVER (ORDER BY total_project_budget DESC) AS budget_rank
FROM department_project_totals
ORDER BY budget_rank, department_id;

-- Rank departments by average employee salary using employee records.
WITH department_salary_averages AS (
	SELECT
		d.department_id,
		d.department_name,
		AVG(e.salary) AS average_salary
	FROM departments AS d
	LEFT JOIN employees AS e
		ON e.department_id = d.department_id
	GROUP BY d.department_id, d.department_name
)
SELECT
	department_id,
	department_name,
	average_salary,
	DENSE_RANK() OVER (ORDER BY average_salary DESC) AS salary_rank
FROM department_salary_averages
ORDER BY salary_rank, department_id;

-- Rank projects by budget and show the owning department.
SELECT
	p.project_id,
	p.project_name,
	d.department_name,
	p.project_budget,
	DENSE_RANK() OVER (ORDER BY p.project_budget DESC) AS budget_rank
FROM projects AS p
JOIN departments AS d
	ON d.department_id = p.department_id
ORDER BY budget_rank, p.project_id;

-- Rank projects by assigned employee count, retaining projects with zero assignments.
WITH project_assignment_counts AS (
	SELECT
		p.project_id,
		p.project_name,
		COUNT(DISTINCT pa.employee_id) AS assigned_employee_count
	FROM projects AS p
	LEFT JOIN project_assignments AS pa
		ON pa.project_id = p.project_id
	GROUP BY p.project_id, p.project_name
)
SELECT
	project_id,
	project_name,
	assigned_employee_count,
	DENSE_RANK() OVER (ORDER BY assigned_employee_count DESC) AS assignment_rank
FROM project_assignment_counts
ORDER BY assignment_rank, project_id;

-- Compare recorded project budget totals by status table, without treating them as actual spend.
SELECT
	status,
	COUNT(*) AS project_count,
	SUM(project_budget) AS recorded_project_budget_total
FROM (
	SELECT 'completed' AS status, project_budget FROM completed_projects
	UNION ALL
	SELECT 'upcoming' AS status, project_budget FROM upcoming_projects
) AS status_budgets
GROUP BY status
ORDER BY status;
