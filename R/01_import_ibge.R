# 01_import_ibge.R
#
# Importa, do arquivo original do IBGE (data/raw/), as tabelas necessárias
# para a cadeia de validação:
#
#   Tabela 11 -> Bn  (coeficientes técnicos dos insumos nacionais, produto x atividade)
#   Tabela 13 -> D   (matriz de participação setorial / market share, atividade x produto)
#   Tabela 14 -> A_ibge (D.Bn, coeficientes técnicos intersetoriais, atividade x atividade)
#   Tabela 15 -> L_ibge (matriz de Leontief oficial, atividade x atividade)
#
# Também importa, só para o diagnóstico documentado em 00_diagnostico_vbp.R:
#   Tabela 01 -> bloco "Produção das atividades" (produto x atividade, valores absolutos)
#   Tabela 02 -> bloco "Consumo intermediário das atividades" (produto x atividade, valores absolutos)
#
# Nenhum valor é editado, arredondado ou reclassificado nesta etapa: a leitura
# é literal, célula a célula, do arquivo publicado pelo IBGE.

library(readxl)
source("R/utils_setores.R")

# Procura o arquivo do IBGE em data/raw/ (qualquer .xls ou .xlsx), sem depender
# do nome exato -- o nome muda conforme o download.
candidatos <- list.files("data/raw", pattern = "\\.xlsx?$", full.names = TRUE, ignore.case = TRUE)
candidatos <- candidatos[!grepl("^~\\$", basename(candidatos))]  # ignora temporarios do Excel

if (length(candidatos) == 0) {
  stop(
    "Nenhuma planilha .xls/.xlsx encontrada em: ", normalizePath("data/raw", mustWork = FALSE), "\n",
    "Coloque nessa pasta o arquivo da MIP 2015 nivel 20 do IBGE.",
    call. = FALSE
  )
}
if (length(candidatos) > 1) {
  message("Varias planilhas em data/raw/; usando a primeira: ", basename(candidatos[1]))
}
caminho_raw <- candidatos[1]
message("Lendo: ", caminho_raw)

tabelas_raw <- list(
  Bn     = ler_bloco_ibge(caminho_raw, sheet = "11"),
  D      = ler_bloco_ibge(caminho_raw, sheet = "13"),
  A_ibge = ler_bloco_ibge(caminho_raw, sheet = "14"),
  L_ibge = ler_bloco_ibge(caminho_raw, sheet = "15"),

  # blocos em valores absolutos (R$ 1.000.000), usados só no diagnóstico
  # de reconstrução de Bn a partir de dados brutos (ver 00_diagnostico_vbp.R)
  producao_atividades = ler_bloco_ibge(caminho_raw, sheet = "01", col_start = 8, col_end = 27),
  consumo_intermediario = ler_bloco_ibge(caminho_raw, sheet = "02", col_start = 3, col_end = 22)
)

# todas as colunas de dados usam os mesmos 20 códigos de setor A-T
for (nome in names(tabelas_raw)) {
  colnames(tabelas_raw[[nome]]) <- LETTERS[1:20]
}

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(tabelas_raw, "data/processed/tabelas_raw.rds")

message("Importação concluída: ", paste(names(tabelas_raw), collapse = ", "))
