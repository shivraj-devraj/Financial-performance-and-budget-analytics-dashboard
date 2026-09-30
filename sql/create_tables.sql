-- Create the six analytical tables using columns present in the cleaned CSVs.
USE financial_analytics;

CREATE TABLE IF NOT EXISTS departments (
	department_id INT NOT NULL,
	department_name VARCHAR(100) NOT NULL,
	department_budget DECIMAL(15, 2) NOT NULL,
	head_of_department VARCHAR(150) NOT NULL,
	number_of_employees INT NOT NULL,
	department_goals TEXT NOT NULL,
	location VARCHAR(100) NOT NULL,
	PRIMARY KEY (department_id),
	INDEX idx_departments_name (department_name)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS employees (
	employee_id INT NOT NULL,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	email VARCHAR(254) NOT NULL,
	job_title VARCHAR(150) NOT NULL,
	salary DECIMAL(12, 2) NOT NULL,
	hire_date DATE NOT NULL,
	department_id INT NOT NULL,
	PRIMARY KEY (employee_id),
	INDEX idx_employees_department_id (department_id),
	INDEX idx_employees_job_title (job_title),
	CONSTRAINT fk_employees_department
		FOREIGN KEY (department_id) REFERENCES departments (department_id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS projects (
	project_id INT NOT NULL,
	project_name VARCHAR(200) NOT NULL,
	project_budget DECIMAL(15, 2) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	department_id INT NOT NULL,
	PRIMARY KEY (project_id),
	INDEX idx_projects_department_id (department_id),
	INDEX idx_projects_budget (project_budget),
	INDEX idx_projects_dates (start_date, end_date),
	CONSTRAINT fk_projects_department
		FOREIGN KEY (department_id) REFERENCES departments (department_id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS project_assignments (
	assignment_id INT NOT NULL,
	employee_id INT NOT NULL,
	project_id INT NOT NULL,
	PRIMARY KEY (assignment_id),
	INDEX idx_project_assignments_employee_id (employee_id),
	INDEX idx_project_assignments_project_id (project_id),
	CONSTRAINT fk_project_assignments_employee
		FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
	CONSTRAINT fk_project_assignments_project
		FOREIGN KEY (project_id) REFERENCES projects (project_id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS completed_projects (
	project_id INT NOT NULL,
	project_name VARCHAR(200) NOT NULL,
	project_budget DECIMAL(15, 2) NOT NULL,
	project_start_date DATE NOT NULL,
	project_end_date DATE NOT NULL,
	department_id INT NOT NULL,
	PRIMARY KEY (project_id),
	INDEX idx_completed_projects_department_id (department_id),
	INDEX idx_completed_projects_end_date (project_end_date),
	CONSTRAINT fk_completed_projects_project
		FOREIGN KEY (project_id) REFERENCES projects (project_id),
	CONSTRAINT fk_completed_projects_department
		FOREIGN KEY (department_id) REFERENCES departments (department_id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS upcoming_projects (
	project_id INT NOT NULL,
	project_name VARCHAR(200) NOT NULL,
	project_budget DECIMAL(15, 2) NOT NULL,
	project_start_date DATE NOT NULL,
	project_end_date DATE NOT NULL,
	department_id INT NOT NULL,
	project_lead VARCHAR(150) NOT NULL,
	PRIMARY KEY (project_id),
	INDEX idx_upcoming_projects_department_id (department_id),
	INDEX idx_upcoming_projects_dates (project_start_date, project_end_date),
	CONSTRAINT fk_upcoming_projects_project
		FOREIGN KEY (project_id) REFERENCES projects (project_id),
	CONSTRAINT fk_upcoming_projects_department
		FOREIGN KEY (department_id) REFERENCES departments (department_id)
) ENGINE = InnoDB;
