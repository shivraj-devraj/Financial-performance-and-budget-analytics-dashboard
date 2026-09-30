-- Load only the cleaned CSV outputs. No statement writes to a CSV file.
-- Run the MySQL client with LOCAL INFILE enabled from the project root, for example:
-- mysql --local-infile=1 -u <user> -p < sql/insert_data.sql
-- Run the client from the workspace parent (the directory containing
-- Financial-Analytics-Dashboard) so the paths below resolve. The client and server must
-- permit LOCAL INFILE. These files use CRLF line endings and include headers.
-- Run create_database.sql and create_tables.sql first. Target tables should be
-- empty; this load intentionally does not truncate or silently replace rows.

USE financial_analytics;

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/departments_cleaned.csv'
INTO TABLE departments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(department_id, department_name, department_budget, head_of_department,
 number_of_employees, department_goals, location);

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/employees_cleaned.csv'
INTO TABLE employees
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(employee_id, first_name, last_name, email, job_title, salary, hire_date,
 department_id);

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/projects_cleaned.csv'
INTO TABLE projects
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(project_id, project_name, project_budget, start_date, end_date, department_id);

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/project_assignments_cleaned.csv'
INTO TABLE project_assignments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(assignment_id, employee_id, project_id);

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/completed_projects_cleaned.csv'
INTO TABLE completed_projects
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(project_id, project_name, project_budget, project_start_date,
 project_end_date, department_id);

LOAD DATA LOCAL INFILE 'Financial-Analytics-Dashboard/data/cleaned/upcoming_projects_cleaned.csv'
INTO TABLE upcoming_projects
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(project_id, project_name, project_budget, project_start_date,
 project_end_date, department_id, project_lead);
