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
    ),
    // Remove linhas que contêm o texto "CRITÉRIO DE DESEMPATE" (ruído no PDF)
    RemoverLinhasDeCriterioDeDesempate = Table.SelectRows(
        ExpandirDados,
        each not Text.Contains([Data.Column4], "CRITÉRIO DE DESEMPATE")
    ),

    // Usa a primeira linha de dados como cabeçalho da tabela
    CabecalhosPromovidos = Table.PromoteHeaders(RemoverLinhasDeCriterioDeDesempate, [PromoteAllScalars=true]),
    
    // Divide a coluna que contém nome da tabela + página no PDF (ex: "Table001 (Page 1)")
    DividirColunaPorDelimitador = Table.SplitColumn(
        CabecalhosPromovidos, 
        "Table001 (Page 1)", 
        Splitter.SplitTextByDelimiter("(", QuoteStyle.Csv), 
        {"Table001 (Page 1).1", "Table001 (Page 1).2"}
    ),

    // Remove o caractere “)” que sobra na parte da coluna com a página
    ValorSubstituido = Table.ReplaceValue(
        DividirColunaPorDelimitador,
        ")","",
        Replacer.ReplaceText,{"Table001 (Page 1).2"}
    ),

    // Remove a primeira parte ("Table001...") e mantém apenas a numeração da página
    RemoverColunasDesnecessarias2 = Table.RemoveColumns(ValorSubstituido,{"Table001 (Page 1).1"}),

    // Coloca cada palavra do campo NOME com inicial maiúscula
    ColocarCadaPalavraEmMaiuscula = Table.TransformColumns(RemoverColunasDesnecessarias2,{{"NOME", Text.Proper, type text}}),


    // Divide a coluna NOME em duas: Nome e Sobrenome (separador = espaço)
    DividirColunaPorDelimitador2 = Table.SplitColumn(
        ColocarCadaPalavraEmMaiuscula, 
        "NOME", 
        Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, false), 
        {"NOME.1", "NOME.2"}
    ),

    // Renomeia colunas para títulos mais claros
    ColunasRenomeadas = Table.RenameColumns(
        DividirColunaPorDelimitador2,{
            {"Table001 (Page 1).2", "Página"}, 
            {"CLAS.", "Classificação"}, 
            {"INSCRIÇÃO", "Inscrição"}, 
            {"NOME.1", "Nome"},
            {"NOME.2", "Sobrenome"}, 
            {"IDOSO", "Idoso"}, 
            {"EXPERIÊNCIA#(lf)PROFISSIONAL", "Experiência Profissional"}, 
            {"FORMAÇÃO#(lf)PROFISSIONAL", "Formação Profissional"}, 
            {"IDADE", "Idade"}, 
            {"JURADO", "Jurado"}, 
            {"TOTAL", "Total"}
        }
    ),

    // Remove linhas residuais que ainda repetem cabeçalhos (como “EXPERIÊNCIA PROFISSIONAL”)
    RemoverLinhasExperienciaProfissional = Table.SelectRows(
        ColunasRenomeadas, 
        each not Text.Contains([#"Experiência Profissional"], "EXPERIÊNCIA")
    ),

        // Define o tipo de cada coluna (texto, número, inteiro etc.)
    TipoAlterado = Table.TransformColumnTypes(
        RemoverLinhasExperienciaProfissional,{
            {"Página", type text}, 
            {"Classificação", Int64.Type}, 
            {"Inscrição", Int64.Type}, 
            {"Nome", type text}, 
            {"Sobrenome", type text}, 
            {"Idoso", type text}, 
            {"Experiência Profissional", type text}, 
            {"Formação Profissional", type text}, 
            {"Idade", type number}, 
            {"Jurado", type text}, 
            {"Total", Int64.Type}
        }
    ),

    // Cria nova coluna com a idade arredondada para cima
    AddColunaIdadeArredondada = Table.AddColumn(
        TipoAlterado,
        "Idade Arredondada",
        each Number.RoundUp([Idade], 0),
        Int64.Type
    )
    
in
  AddColunaIdadeArredondada