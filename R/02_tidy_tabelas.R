# 02_tidy_tabelas.R
#
# Converte as matrizes brutas (data/processed/tabelas_raw.rds) em formato
# tidy (long), associando cada código de setor (A-T) ao seu nome, para uso
# nos relatórios e nas visualizações. As matrizes numéricas originais são
# preservadas como estavam — esta etapa só adiciona uma camada de leitura,
# não recalcula nada.

library(dplyr)
library(tidyr)
library(tibble)
source("R/utils_setores.R")

tabelas_raw <- readRDS("data/processed/tabelas_raw.rds")

matriz_para_tidy <- function(mat, nome_valor) {
  as.data.frame(mat) |>
    tibble::rownames_to_column("setor_linha") |>
    tidyr::pivot_longer(
      cols = -setor_linha,
      names_to = "setor_coluna",
      values_to = nome_valor
    ) |>
    dplyr::left_join(setores_nivel20, by = c("setor_linha" = "codigo")) |>
    dplyr::rename(descricao_linha = descricao) |>
    dplyr::left_join(setores_nivel20, by = c("setor_coluna" = "codigo")) |>
    dplyr::rename(descricao_coluna = descricao)
}

tabelas_tidy <- list(
  Bn     = matriz_para_tidy(tabelas_raw$Bn, "coeficiente_bn"),
  D      = matriz_para_tidy(tabelas_raw$D, "participacao_d"),
  A_ibge = matriz_para_tidy(tabelas_raw$A_ibge, "coeficiente_a_ibge"),
  L_ibge = matriz_para_tidy(tabelas_raw$L_ibge, "leontief_ibge")
)

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(tabelas_tidy, "data/processed/tabelas_tidy.rds")

message("Tabelas tidy salvas em data/processed/tabelas_tidy.rds")
