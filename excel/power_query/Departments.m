let
    RootTable = Excel.CurrentWorkbook(){[Name="tblProjectRoot"]}[Content],
    ProjectRoot = Text.Trim(Text.From(RootTable{0}[ProjectRoot])),
    Csv = Csv.Document(
        File.Contents(ProjectRoot & "\data\cleaned\departments_cleaned.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Csv, [PromoteAllScalars = true]),
    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"department_name", each if _ = null then null else Text.Trim(_), type text},
            {"head_of_department", each if _ = null then null else Text.Trim(_), type text},
            {"department_goals", each if _ = null then null else Text.Trim(_), type text},
            {"location", each if _ = null then null else Text.Trim(_), type text}
        }
    ),
    TypedColumns = Table.TransformColumnTypes(
        TrimmedText,
        {
            {"department_id", Int64.Type},
            {"department_name", type text},
            {"department_budget", type number},
            {"head_of_department", type text},
            {"number_of_employees", Int64.Type},
            {"department_goals", type text},
            {"location", type text}
        },
        "en-US"
    )
in
    TypedColumns