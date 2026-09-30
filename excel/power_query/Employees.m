let
    RootTable = Excel.CurrentWorkbook(){[Name="tblProjectRoot"]}[Content],
    ProjectRoot = Text.Trim(Text.From(RootTable{0}[ProjectRoot])),
    Csv = Csv.Document(
        File.Contents(ProjectRoot & "\data\cleaned\employees_cleaned.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Csv, [PromoteAllScalars = true]),
    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"first_name", each if _ = null then null else Text.Trim(_), type text},
            {"last_name", each if _ = null then null else Text.Trim(_), type text},
            {"email", each if _ = null then null else Text.Trim(_), type text},
            {"job_title", each if _ = null then null else Text.Trim(_), type text}
        }
    ),
    TypedColumns = Table.TransformColumnTypes(
        TrimmedText,
        {
            {"employee_id", Int64.Type},
            {"first_name", type text},
            {"last_name", type text},
            {"email", type text},
            {"job_title", type text},
            {"salary", type number},
            {"hire_date", type date},
            {"department_id", Int64.Type}
        },
        "en-US"
    )
in
    TypedColumns