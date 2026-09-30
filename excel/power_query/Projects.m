let
    RootTable = Excel.CurrentWorkbook(){[Name="tblProjectRoot"]}[Content],
    ProjectRoot = Text.Trim(Text.From(RootTable{0}[ProjectRoot])),
    Csv = Csv.Document(
        File.Contents(ProjectRoot & "\data\cleaned\projects_cleaned.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Csv, [PromoteAllScalars = true]),
    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"project_name", each if _ = null then null else Text.Trim(_), type text}
        }
    ),
    TypedColumns = Table.TransformColumnTypes(
        TrimmedText,
        {
            {"project_id", Int64.Type},
            {"project_name", type text},
            {"project_budget", type number},
            {"start_date", type date},
            {"end_date", type date},
            {"department_id", Int64.Type}
        },
        "en-US"
    )
in
    TypedColumns