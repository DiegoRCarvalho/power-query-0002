let
    // Carrega todas as tabelas identificadas dentro do PDF
    Fonte = Pdf.Tables(File.Contents("Z:\certificacao\ETL\power-query-0002\LISTA DE RESULTADO GERAL.pdf"), [Implementation="1.3"])
id
  Fonte