# utils_setores.R
#
# Metadados fixos dos 20 setores (nível 20 da classificação IBGE, ordem A-T) e
# uma função utilitária para ler blocos 20x20 das planilhas do IBGE.
#
# Os códigos e nomes abaixo foram conferidos diretamente contra o cabeçalho
# das Tabelas 11, 13, 14 e 15 do arquivo original — não são um dicionário
# genérico copiado de outra fonte.

setores_nivel20 <- tibble::tibble(
  codigo = LETTERS[1:20],
  descricao = c(
    "Agricultura, pecuária, produção florestal, pesca e aquicultura",
    "Indústrias extrativas",
    "Indústrias de transformação",
    "Eletricidade e gás",
    "Água, esgoto, atividades de gestão de resíduos e descontaminação",
    "Construção",
    "Comércio; reparação de veículos automotores e motocicletas",
    "Transporte, armazenagem e correio",
    "Alojamento e alimentação",
    "Informação e comunicação",
    "Atividades financeiras, de seguros e serviços relacionados",
    "Atividades imobiliárias",
    "Atividades científicas, profissionais e técnicas",
    "Atividades administrativas e serviços complementares",
    "Administração pública, defesa e seguridade social",
    "Educação",
    "Saúde humana e serviços sociais",
    "Artes, cultura, esporte e recreação",
    "Outras atividades de serviços",
    "Serviços domésticos"
  )
)

#' Lê um bloco 20x20 (ou 20 x n_col) de uma aba do arquivo IBGE
#'
#' As Tabelas 11 (Bn), 13 (D), 14 (D.Bn) e 15 (Leontief) do arquivo de nível
#' 20 do IBGE têm todas o mesmo layout: título em L1, cabeçalho em L3:L4,
#' e os dados dos 20 setores em L6:L25. As colunas de dados começam na
#' coluna C (3) e vão até a V (22) para as matrizes 20x20.
#'
#' Esse layout foi conferido manualmente célula a célula antes de escrever
#' esta função — não é um "skip" arbitrário.
#'
#' @param path caminho do arquivo .xls original do IBGE
#' @param sheet nome da aba ("01" a "15")
#' @param col_start coluna inicial dos dados (padrão 3 = coluna C)
#' @param col_end coluna final dos dados (padrão 22 = coluna V)
#' @return matriz numérica 20 x n_col, com nomes de linha = códigos de setor
ler_bloco_ibge <- function(path, sheet, col_start = 3, col_end = 22) {
  bruto <- readxl::read_excel(
    path,
    sheet = sheet,
    range = readxl::cell_limits(c(6, 1), c(25, col_end)),
    col_names = FALSE
  )

  codigos <- bruto[[1]]
  stopifnot(identical(codigos, LETTERS[1:20]))

  mat <- as.matrix(bruto[, col_start:col_end])
  mat <- apply(mat, 2, as.numeric)
  rownames(mat) <- codigos
  mat
}
