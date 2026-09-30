"""Create typed, standardized analytical CSVs without changing raw data.

Rules from the verified data documentation:
- Read the actual source filename `upcoming projects.csv` and write the requested
  standardized output name `upcoming_projects_cleaned.csv`.
- Remove `Unnamed: 0` only when its values are exactly the sequential row index.
- Standardize headers and convert recognized ID/numeric/date fields, retaining
  unparseable source values and logging them rather than silently replacing them.
- Preserve the department headcount, project department, and project date
  discrepancies as supplied. This pipeline reports them but does not resolve them.
- Write generated files only under `data/cleaned/`.
"""

from pathlib import Path
import re

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
CLEANED_DIR = PROJECT_ROOT / "data" / "cleaned"

TABLES = {
	"employees": {
		"source": "employees.csv",
		"output": "employees_cleaned.csv",
		"primary_key": "employee_id",
	},
	"departments": {
		"source": "departments.csv",
		"output": "departments_cleaned.csv",
		"primary_key": "department_id",
	},
	"projects": {
		"source": "projects.csv",
		"output": "projects_cleaned.csv",
		"primary_key": "project_id",
	},
	"project_assignments": {
		"source": "project_assignments.csv",
		"output": "project_assignments_cleaned.csv",
		"primary_key": "assignment_id",
	},
	"completed_projects": {
		"source": "completed_projects.csv",
		"output": "completed_projects_cleaned.csv",
		"primary_key": "project_id",
	},
	"upcoming_projects": {
		"source": "upcoming projects.csv",
		"output": "upcoming_projects_cleaned.csv",
		"primary_key": "project_id",
	},
}

NUMERIC_FIELDS = {
	"salary",
	"department_budget",
	"number_of_employees",
	"project_budget",
}

FOREIGN_KEYS = [
	("employees", "department_id", "departments", "department_id"),
	("projects", "department_id", "departments", "department_id"),
	("project_assignments", "employee_id", "employees", "employee_id"),
	("project_assignments", "project_id", "projects", "project_id"),
	("completed_projects", "project_id", "projects", "project_id"),
	("completed_projects", "department_id", "departments", "department_id"),
	("upcoming_projects", "project_id", "projects", "project_id"),
	("upcoming_projects", "department_id", "departments", "department_id"),
]


def snake_case(name):
	"""Normalize a source header to lowercase snake_case."""
	value = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", str(name).strip())
	value = re.sub(r"[^0-9a-zA-Z]+", "_", value)
	return value.strip("_").lower()


def add_validation(validations, table, check, affected_rows, notes, result=None):
	"""Append one machine-readable validation or transformation result."""
	if result is None:
		result = "ISSUE" if affected_rows else "PASS"
	validations.append(
		{
			"table": table,
			"check": check,
			"result": result,
			"affected_rows": int(affected_rows),
			"notes": notes,
		}
	)


def values_for_notes(series, mask, limit=10):
	values = series.loc[mask].drop_duplicates().head(limit).tolist()
	return [str(value) for value in values]


def read_sources(validations):
	"""Load source CSVs and apply only the verified index-column rule."""
	frames = {}
	original_column_counts = {}
	loaded_row_counts = {}

	for table, config in TABLES.items():
		source_path = RAW_DIR / config["source"]
		if not source_path.is_file():
			raise FileNotFoundError(f"Required raw CSV was not found: {source_path}")

		frame = pd.read_csv(source_path)
		original_column_counts[table] = len(frame.columns)
		loaded_row_counts[table] = len(frame)

		# The documentation verified this column as a sequential export index.
		# Remove it only if the current values still exactly match that pattern.
		index_column = "Unnamed: 0"
		if index_column in frame.columns:
			index_values = pd.to_numeric(frame[index_column], errors="coerce")
			expected_index = pd.Series(range(len(frame)), index=frame.index)
			is_verified_index = (
				index_values.notna().all()
				and index_values.is_unique
				and index_values.reset_index(drop=True).equals(
					expected_index.reset_index(drop=True)
				)
			)
			if is_verified_index:
				frame = frame.drop(columns=[index_column])
				add_validation(
					validations,
					table,
					"remove_verified_export_index",
					len(frame),
					"Removed `Unnamed: 0`; its values exactly matched 0 through row_count - 1.",
					result="INFO",
				)
			else:
				add_validation(
					validations,
					table,
					"preserve_unverified_index_like_column",
					0,
					"`Unnamed: 0` did not exactly match the sequential row index and was retained.",
					result="ISSUE",
				)

		old_columns = list(frame.columns)
		new_columns = [snake_case(column) for column in old_columns]
		if len(new_columns) != len(set(new_columns)):
			raise ValueError(
				f"Column standardization creates duplicate names in {config['source']}: "
				f"{new_columns}"
			)
		frame.columns = new_columns
		changed_columns = [
			f"{old} -> {new}"
			for old, new in zip(old_columns, new_columns)
			if old != new
		]
		if changed_columns:
			add_validation(
				validations,
				table,
				"standardize_column_names",
				0,
				"; ".join(changed_columns),
				result="INFO",
			)

		frames[table] = frame

	# Make the verified source filename discrepancy visible without renaming it.
	add_validation(
		validations,
		"upcoming_projects",
		"source_filename",
		0,
		"Read `upcoming projects.csv` with a space; only the cleaned output uses underscores.",
		result="ISSUE",
	)
	return frames, original_column_counts, loaded_row_counts


def convert_types(frames, validations):
	"""Convert known numeric and date fields while preserving invalid text."""
	for table, frame in frames.items():
		for column in frame.columns:
			if column.endswith("_id") or column in NUMERIC_FIELDS:
				original = frame[column]
				converted = pd.to_numeric(original, errors="coerce")
				invalid = original.notna() & converted.isna()
				add_validation(
					validations,
					table,
					f"numeric_conversion:{column}",
					int(original.notna().sum()),
					(
						f"Converted populated values to numeric; invalid values retained as source text: "
						f"{values_for_notes(original, invalid)}"
					),
					result="ISSUE" if invalid.any() else "INFO",
				)
				if invalid.any():
					converted = converted.astype(object)
					converted.loc[invalid] = original.loc[invalid]
				frame[column] = converted

			if column.endswith("_date"):
				original = frame[column]
				converted = pd.to_datetime(original, errors="coerce")
				invalid = original.notna() & converted.isna()
				add_validation(
					validations,
					table,
					f"datetime_conversion:{column}",
					int(original.notna().sum()),
					(
						f"Converted populated values to datetime; invalid values retained as source text: "
						f"{values_for_notes(original, invalid)}"
					),
					result="ISSUE" if invalid.any() else "INFO",
				)
				if invalid.any():
					converted = converted.astype(object)
					converted.loc[invalid] = original.loc[invalid]
				frame[column] = converted


def validate_tables(frames, validations):
	"""Check row-level completeness, keys, references, dates, and budgets."""
	for table, frame in frames.items():
		# Report nulls per field and exact duplicate rows without deleting data.
		for column in frame.columns:
			missing_mask = frame[column].isna()
			add_validation(
				validations,
				table,
				f"missing_values:{column}",
				int(missing_mask.sum()),
				f"Missing cells: {int(missing_mask.sum())}.",
			)

		duplicate_mask = frame.duplicated(keep=False)
		add_validation(
			validations,
			table,
			"duplicate_rows",
			int(duplicate_mask.sum()),
			"Rows participating in an exact duplicate: "
			f"{int(duplicate_mask.sum())}.",
		)

		# Validate each documented primary key and all ID-shaped fields.
		primary_key = TABLES[table]["primary_key"]
		key_missing = frame[primary_key].isna()
		key_duplicate = frame[primary_key].duplicated(keep=False)
		add_validation(
			validations,
			table,
			f"primary_key:{primary_key}",
			int((key_missing | key_duplicate).sum()),
			f"Null key rows: {int(key_missing.sum())}; duplicate key rows: {int(key_duplicate.sum())}.",
		)

		for column in [name for name in frame.columns if name.endswith("_id")]:
			numeric = pd.to_numeric(frame[column], errors="coerce")
			invalid = frame[column].notna() & (
				numeric.isna() | numeric.mod(1).ne(0) | numeric.le(0)
			)
			add_validation(
				validations,
				table,
				f"invalid_ids:{column}",
				int(invalid.sum()),
				"IDs must be populated positive whole numbers; invalid values: "
				f"{values_for_notes(frame[column], invalid)}.",
			)

		for column in [name for name in frame.columns if "budget" in name]:
			numeric = pd.to_numeric(frame[column], errors="coerce")
			invalid_numeric = frame[column].notna() & numeric.isna()
			negative = numeric.lt(0).fillna(False)
			add_validation(
				validations,
				table,
				f"negative_or_nonnumeric_budget:{column}",
				int((invalid_numeric | negative).sum()),
				"Nonnumeric values: "
				f"{values_for_notes(frame[column], invalid_numeric)}; negative values: "
				f"{values_for_notes(frame[column], negative)}.",
			)

		for column in [name for name in frame.columns if name.endswith("_date")]:
			invalid = frame[column].notna() & pd.to_datetime(
				frame[column], errors="coerce"
			).isna()
			add_validation(
				validations,
				table,
				f"invalid_dates:{column}",
				int(invalid.sum()),
				f"Unparseable non-null date values: {values_for_notes(frame[column], invalid)}.",
			)

		date_pairs = [
			("start_date", "end_date"),
			("project_start_date", "project_end_date"),
		]
		for start_column, end_column in date_pairs:
			if start_column in frame.columns and end_column in frame.columns:
				starts = pd.to_datetime(frame[start_column], errors="coerce")
				ends = pd.to_datetime(frame[end_column], errors="coerce")
				invalid_order = starts.notna() & ends.notna() & starts.gt(ends)
				add_validation(
					validations,
					table,
					f"start_after_end:{start_column},{end_column}",
					int(invalid_order.sum()),
					"Rows with start date later than end date: "
					f"{values_for_notes(frame[TABLES[table]['primary_key']], invalid_order)}.",
				)

	# Check every relationship documented for the six source tables.
	for child_table, child_column, parent_table, parent_column in FOREIGN_KEYS:
		child = frames[child_table]
		parent = frames[parent_table]
		unmatched = child[child_column].notna() & ~child[child_column].isin(
			set(parent[parent_column].dropna())
		)
		add_validation(
			validations,
			child_table,
			f"foreign_key:{child_column}->{parent_table}.{parent_column}",
			int(unmatched.sum()),
			"Unmatched values: "
			f"{values_for_notes(child[child_column], unmatched)}.",
		)

	# Preserve and report the documented department headcount discrepancy.
	employees = frames["employees"]
	departments = frames["departments"]
	observed_counts = employees.groupby("department_id").size()
	count_mismatches = []
	for _, row in departments.iterrows():
		department_id = row["department_id"]
		reported = pd.to_numeric(
			pd.Series([row["number_of_employees"]]), errors="coerce"
		).iloc[0]
		observed = int(observed_counts.get(department_id, 0))
		if pd.isna(reported) or reported != observed:
			count_mismatches.append(
				f"department_id={department_id}: reported={reported}, observed={observed}"
			)
	add_validation(
		validations,
		"departments",
		"reported_vs_observed_employee_count",
		len(count_mismatches),
		"; ".join(count_mismatches) if count_mismatches else "All department counts match.",
	)

	# Compare status rows with the master while retaining both source values.
	master = frames["projects"].drop_duplicates("project_id", keep="first")
	master = master.set_index("project_id")
	field_pairs = [
		("project_name", "project_name"),
		("project_budget", "project_budget"),
		("department_id", "department_id"),
		("start_date", "project_start_date"),
		("end_date", "project_end_date"),
	]
	status_differences = {}
	for table in ("completed_projects", "upcoming_projects"):
		frame = frames[table]
		differences = []
		for _, row in frame.iterrows():
			project_id = row["project_id"]
			if pd.isna(project_id) or project_id not in master.index:
				continue
			master_row = master.loc[project_id]
			changed_fields = []
			for master_column, status_column in field_pairs:
				if status_column not in frame.columns:
					continue
				left = master_row[master_column]
				right = row[status_column]
				both_missing = pd.isna(left) and pd.isna(right)
				if not both_missing and str(left) != str(right):
					changed_fields.append(status_column)
			if changed_fields:
				differences.append(
					f"project_id={project_id}: {', '.join(changed_fields)}"
				)
		status_differences[table] = differences
		add_validation(
			validations,
			table,
			"project_values_vs_master",
			len(differences),
			"; ".join(differences)
			if differences
			else "Compared fields match projects.csv.",
		)

	# Confirm the status tables remain a complete, non-overlapping partition.
	master_ids = set(frames["projects"]["project_id"].dropna())
	completed_ids = set(frames["completed_projects"]["project_id"].dropna())
	upcoming_ids = set(frames["upcoming_projects"]["project_id"].dropna())
	overlap = completed_ids & upcoming_ids
	uncovered = master_ids - completed_ids - upcoming_ids
	outside_master = (completed_ids | upcoming_ids) - master_ids
	partition_issues = overlap | uncovered | outside_master
	add_validation(
		validations,
		"project_status_tables",
		"status_id_partition",
		len(partition_issues),
		f"Overlap={sorted(overlap)}; not in either status table={sorted(uncovered)}; "
		f"not in projects.csv={sorted(outside_master)}.",
	)

	# Report entities not represented by an assignment, without dropping them.
	assigned_employee_ids = set(frames["project_assignments"]["employee_id"].dropna())
	assigned_project_ids = set(frames["project_assignments"]["project_id"].dropna())
	unassigned_employees = set(employees["employee_id"].dropna()) - assigned_employee_ids
	unassigned_projects = set(frames["projects"]["project_id"].dropna()) - assigned_project_ids
	add_validation(
		validations,
		"project_assignments",
		"employee_assignment_coverage",
		len(unassigned_employees),
		f"Employees without an assignment: {sorted(unassigned_employees)}.",
	)
	add_validation(
		validations,
		"project_assignments",
		"project_assignment_coverage",
		len(unassigned_projects),
		f"Projects without an assignment: {sorted(unassigned_projects)}.",
	)

	# The table name is retained as source metadata; date values are not changed.
	upcoming = frames["upcoming_projects"]
	end_dates = pd.to_datetime(upcoming["project_end_date"], errors="coerce")
	past_end_dates = end_dates.notna() & end_dates.lt(pd.Timestamp.today().normalize())
	add_validation(
		validations,
		"upcoming_projects",
		"upcoming_label_vs_run_date",
		int(past_end_dates.sum()),
		"End dates before run date "
		f"{pd.Timestamp.today().date()}: "
		f"{values_for_notes(upcoming['project_id'], past_end_dates)}. "
		"This is reported only; no status reclassification is performed.",
	)


def write_outputs(frames, validations, original_column_counts, loaded_row_counts):
	"""Write cleaned datasets and their validation summary under data/cleaned."""
	CLEANED_DIR.mkdir(parents=True, exist_ok=True)
	validation_frame = pd.DataFrame(
		validations,
		columns=["table", "check", "result", "affected_rows", "notes"],
	)

	for table, frame in frames.items():
		output_path = CLEANED_DIR / TABLES[table]["output"]
		frame.to_csv(output_path, index=False)

	validation_frame.to_csv(
		CLEANED_DIR / "data_validation_summary.csv", index=False
	)

	print("Cleaning summary")
	for table, frame in frames.items():
		missing_values = int(frame.isna().sum().sum())
		duplicate_rows = int(frame.duplicated().sum())
		print(
			f"- {table}: rows loaded={loaded_row_counts[table]}, "
			f"rows written={len(frame)}, "
			f"columns before/after={original_column_counts[table]}/{len(frame.columns)}, "
			f"missing values={missing_values}, duplicate rows={duplicate_rows}"
		)

	issues = validation_frame[validation_frame["result"] == "ISSUE"]
	print(
		f"Validation issues detected: {len(issues)} checks "
		f"({int(issues['affected_rows'].sum())} affected rows across checks)."
	)
	for _, issue in issues.iterrows():
		print(
			f"- {issue['table']} / {issue['check']}: "
			f"{issue['affected_rows']} affected; {issue['notes']}"
		)
	print(f"Validation summary written to: {CLEANED_DIR / 'data_validation_summary.csv'}")


def main():
	validations = []
	frames, original_column_counts, loaded_row_counts = read_sources(validations)
	convert_types(frames, validations)
	validate_tables(frames, validations)
	write_outputs(frames, validations, original_column_counts, loaded_row_counts)


if __name__ == "__main__":
	main()
