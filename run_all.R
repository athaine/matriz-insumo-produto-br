# run_all.R
#
# Roda o pipeline completo, na ordem correta, a partir da raiz do projeto:
#   Rscript R/run_all.R

source("R/01_import_ibge.R")
source("R/02_tidy_tabelas.R")
source("R/03_validar_leontief.R")
source("R/04_indicadores.R")
source("R/05_setores_chave.R")

message("\nPipeline completo. Resultados em data/processed/.")
message("Para rodar o diagnóstico de reconstrução de Bn (opcional, documentação): R/00_diagnostico_vbp.R")
message("Para rodar os testes: testthat::test_dir('tests/testthat')")
