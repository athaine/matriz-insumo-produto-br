# 04_indicadores.R
#
# Calcula, a partir da matriz de Leontief RECALCULADA e já validada em
# 03_validar_leontief.R (não a Tabela 15 importada diretamente — o ponto é
# usar o resultado do seu próprio pipeline), os indicadores estruturais
# clássicos de insumo-produto:
#
#   - Multiplicador de produção do setor j: soma da coluna j de L
#     (impacto total, direto + indireto, de uma unidade a mais de demanda
#     final pelo produto do setor j sobre o valor da produção de toda a
#     economia).
#   - Índice de ligação para trás (poder de dispersão, Rasmussen-Hirschman):
#     multiplicador do setor j normalizado pela média dos multiplicadores.
#   - Índice de ligação para frente (sensibilidade de dispersão):
#     soma da linha i de L, normalizada pela média das somas de linha.

library(dplyr)
source("R/utils_setores.R")

validacao <- readRDS("data/processed/validacao_leontief.rds")
L <- validacao$L_calc

multiplicador_producao <- colSums(L)
ligacao_frente_bruta   <- rowSums(L)

indicadores <- tibble::tibble(
  codigo = colnames(L),
  multiplicador = multiplicador_producao,
  ligacao_para_tras = multiplicador_producao / mean(multiplicador_producao),
  ligacao_para_frente = ligacao_frente_bruta / mean(ligacao_frente_bruta)
) |>
  dplyr::left_join(setores_nivel20, by = "codigo") |>
  dplyr::relocate(descricao, .after = codigo) |>
  dplyr::arrange(dplyr::desc(ligacao_para_tras))

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(indicadores, "data/processed/indicadores.rds")

message("Indicadores de encadeamento calculados para ", nrow(indicadores), " setores.")
print(indicadores, n = 20)
