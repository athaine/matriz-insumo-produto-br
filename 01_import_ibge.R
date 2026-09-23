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

caminho_raw <- "data/raw/matriz_insumo_produto_2015_nivel20_ibge.xls"

stopifnot(file.exists(caminho_raw))

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
