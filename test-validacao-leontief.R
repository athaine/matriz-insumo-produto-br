library(testthat)

# Estes testes assumem que o pipeline (R/01 a R/05) já rodou e gravou seus
# resultados em data/processed/. Isso é verificado explicitamente abaixo em
# vez de silenciosamente recalcular tudo dentro do teste, para que uma
# falha aqui aponte com precisão se o problema é na leitura dos dados, no
# cálculo, ou no teste em si.

caminho_validacao <- "data/processed/validacao_leontief.rds"
caminho_indicadores <- "data/processed/indicadores.rds"
caminho_classificados <- "data/processed/setores_classificados.rds"

test_that("os artefatos do pipeline existem antes dos testes rodarem", {
  skip_if_not(
    file.exists(caminho_validacao),
    "Rode R/01_import_ibge.R a R/05_setores_chave.R antes de testar."
  )
  expect_true(file.exists(caminho_validacao))
})

skip_if_not(file.exists(caminho_validacao), "pipeline não executado")

validacao <- readRDS(caminho_validacao)
indicadores <- readRDS(caminho_indicadores)
classificados <- readRDS(caminho_classificados)

test_that("A = D . Bn reproduz a Tabela 14 do IBGE com alta precisão", {
  expect_lt(validacao$diff_A_max, 1e-8)
})

test_that("L = (I - A)^-1 reproduz a Tabela 15 (Leontief) do IBGE com alta precisão", {
  expect_lt(validacao$diff_L_max, 1e-8)
})

test_that("a matriz de Leontief recalculada é 20 x 20 e sem valores ausentes", {
  L <- validacao$L_calc
  expect_equal(dim(L), c(20L, 20L))
  expect_false(anyNA(L))
})

test_that("a diagonal da matriz de Leontief é sempre maior ou igual a 1", {
  # propriedade algébrica de (I - A)^-1 quando A tem entradas não-negativas
  # e soma de coluna < 1 (condição de Hawkins-Simon / estabilidade)
  L <- validacao$L_calc
  expect_true(all(diag(L) >= 1 - 1e-9))
})

test_that("os índices de ligação têm média igual a 1 por construção", {
  expect_equal(mean(indicadores$ligacao_para_tras), 1, tolerance = 1e-9)
  expect_equal(mean(indicadores$ligacao_para_frente), 1, tolerance = 1e-9)
})

test_that("todo setor é classificado em uma das 4 categorias esperadas", {
  expect_true(all(classificados$classe %in% c("Setor-chave", "Motriz", "Base", "Independente")))
  expect_equal(nrow(classificados), 20L)
})

test_that("pelo menos um setor é classificado como setor-chave", {
  # checagem de sanidade: com dados reais do Brasil (2015), sabemos que
  # existe mais de um setor-chave (ex.: Indústria de transformação);
  # se essa contagem cair para zero, é sinal de erro no cálculo dos
  # índices, não de um resultado economicamente plausível.
  n_chave <- sum(classificados$classe == "Setor-chave")
  expect_gt(n_chave, 0)
})
