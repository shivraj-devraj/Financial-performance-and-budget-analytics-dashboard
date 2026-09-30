let
    RootTable = Excel.CurrentWorkbook(){[Name="tblProjectRoot"]}[Content],
    ProjectRoot = Text.Trim(Text.From(RootTable{0}[ProjectRoot])),
    Csv = Csv.Document(
        File.Contents(ProjectRoot & "\data\cleaned\project_assignments_cleaned.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    PromotedHeaders = Table.PromoteHeaders(Csv, [PromoteAllScalars = true]),
    TypedColumns = Table.TransformColumnTypes(
        PromotedHeaders,
        {
            {"assignment_id", Int64.Type},
            {"employee_id", Int64.Type},
            {"project_id", Int64.Type}
        },
        "en-US"
    )
in
    TypedColumns