# 05_setores_chave.R
#
# Classifica os 20 setores segundo o critério clássico de Rasmussen-Hirschman
# (ligação para trás e para frente, cada uma normalizada pela média = 1):
#
#   Setor-chave       : ligação para trás > 1  E  ligação para frente > 1
#                        (compra muito de outros setores E é muito comprado
#                        por eles — choques nele se propagam nos dois sentidos)
#   Setor motriz      : ligação para trás > 1  E  ligação para frente <= 1
#                        (puxa a cadeia de fornecedores, mas não é insumo
#                        importante para o resto da economia)
#   Setor base        : ligação para trás <= 1 E  ligação para frente > 1
#                        (fornece insumo para muitos setores, mas compra
#                        pouco de terceiros)
#   Independente      : ligação para trás <= 1 E  ligação para frente <= 1

library(dplyr)

indicadores <- readRDS("data/processed/indicadores.rds")

setores_classificados <- indicadores |>
  dplyr::mutate(
    classe = dplyr::case_when(
      ligacao_para_tras > 1 & ligacao_para_frente > 1  ~ "Setor-chave",
      ligacao_para_tras > 1 & ligacao_para_frente <= 1 ~ "Motriz",
      ligacao_para_tras <= 1 & ligacao_para_frente > 1 ~ "Base",
      TRUE ~ "Independente"
    )
  ) |>
  dplyr::arrange(dplyr::desc(ligacao_para_tras))

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(setores_classificados, "data/processed/setores_classificados.rds")

message("Classificação de setores-chave (2015, nível 20):")
print(
  setores_classificados |> dplyr::select(codigo, descricao, classe, ligacao_para_tras, ligacao_para_frente),
  n = 20
)

setores_chave <- setores_classificados |> dplyr::filter(classe == "Setor-chave")
message("\nSetores-chave identificados: ", nrow(setores_chave))
print(setores_chave |> dplyr::select(codigo, descricao))
