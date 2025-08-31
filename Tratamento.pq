let
    // Carrega todas as tabelas identificadas dentro do PDF
    Fonte = Pdf.Tables(File.Contents("Z:\certificacao\ETL\power-query-0002\LISTA DE RESULTADO GERAL.pdf"), [Implementation="1.3"]),

    // Mantém apenas os objetos que são do tipo "Table"
    SelecionarApenasTabelas = Table.SelectRows(Fonte, each ([Kind] = "Table")),

    // Remove colunas auxiliares que não serão usadas (Id e Kind)
    RemoverColunasDesnecessarias = Table.RemoveColumns(SelecionarApenasTabelas,{"Id", "Kind"}),

    // Expande o conteúdo das tabelas internas em colunas (Column1, Column2, ...)
    ExpandirDados = Table.ExpandTableColumn(
        RemoverColunasDesnecessarias, 
        "Data", 
        {"Column1","Column2","Column3","Column4","Column5","Column6","Column7","Column8","Column9"}, 
        {"Data.Column1","Data.Column2","Data.Column3","Data.Column4","Data.Column5","Data.Column6","Data.Column7","Data.Column8","Data.Column9"}
    )

in
  ExpandirDados