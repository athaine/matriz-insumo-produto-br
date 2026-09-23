# run_all.R
#
# Roda o pipeline completo, na ordem correta, a partir da raiz do projeto
# (a pasta que contém 'R', 'data' e 'tests'):
#   source("R/run_all.R")     # dentro do R/RStudio
#   Rscript R/run_all.R       # pelo terminal

# --- localizar a raiz do projeto (funciona mesmo se o R abrir em R/ ou numa subpasta) ---
local({
  dir <- normalizePath(getwd(), winslash = "/")
  repeat {
    if (file.exists(file.path(dir, "R", "utils_setores.R"))) { setwd(dir); break }
    pai <- dirname(dir)
    if (pai == dir) {
      stop(
        "Nao encontrei a raiz do projeto a partir de: ", getwd(), "\n",
        "Abra o arquivo matriz-insumo-produto-br.Rproj (RStudio) ou use setwd() para a pasta ",
        "que contem 'R', 'data' e 'tests' (a pasta que tem o README.md).",
        call. = FALSE
      )
    }
    dir <- pai
  }
  message("Raiz do projeto: ", getwd())
})

# --- checagem: pacotes instalados? -----------------------------------------
pacotes <- c("readxl", "dplyr", "tidyr", "tibble")
faltando <- pacotes[!vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltando) > 0) {
  stop(
    "Pacotes faltando: ", paste(faltando, collapse = ", "), ".\n",
    "Instale com: install.packages(c(", paste0("\"", faltando, "\"", collapse = ", "), "))",
    call. = FALSE
  )
}

source("R/01_import_ibge.R")
source("R/02_tidy_tabelas.R")
source("R/03_validar_leontief.R")
source("R/04_indicadores.R")
source("R/05_setores_chave.R")

message("\nPipeline completo. Resultados em data/processed/.")
message("Para rodar o diagnóstico de reconstrução de Bn (opcional, documentação): source('R/00_diagnostico_vbp.R')")
message("Para rodar os testes: testthat::test_dir('tests/testthat')")
