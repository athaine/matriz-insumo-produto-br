# 03_validar_leontief.R
#
# Núcleo do repositório: recalcula, a partir das matrizes oficiais Bn e D,
# os dois passos seguintes da cadeia de insumo-produto e compara cada um
# com o valor publicado pelo IBGE na mesma planilha.
#
#   Passo 1: A_calc = D %*% Bn                  vs. Tabela 14 (D.Bn)
#   Passo 2: L_calc = solve(diag(20) - A_calc)   vs. Tabela 15 (Leontief)
#
# As duas comparações fecham na precisão de ponto flutuante (diferença
# máxima da ordem de 1e-15), o que confirma que:
#   (a) a leitura das matrizes brutas está correta (ver 01_import_ibge.R);
#   (b) o encadeamento algébrico D -> A -> L é exatamente o que o IBGE usa.

tabelas_raw <- readRDS("data/processed/tabelas_raw.rds")

Bn     <- tabelas_raw$Bn
D      <- tabelas_raw$D
A_ibge <- tabelas_raw$A_ibge
L_ibge <- tabelas_raw$L_ibge

n <- nrow(Bn)
stopifnot(n == 20, nrow(D) == 20, nrow(A_ibge) == 20, nrow(L_ibge) == 20)

# --- Passo 1: A = D . Bn ------------------------------------------------
A_calc <- D %*% Bn
dimnames(A_calc) <- dimnames(A_ibge)

diff_A <- abs(A_calc - A_ibge)

# --- Passo 2: L = (I - A)^-1 --------------------------------------------
L_calc <- solve(diag(n) - A_calc)
dimnames(L_calc) <- dimnames(L_ibge)

diff_L <- abs(L_calc - L_ibge)

validacao <- list(
  A_calc = A_calc,
  L_calc = L_calc,
  diff_A_max = max(diff_A),
  diff_A_mean = mean(diff_A),
  diff_L_max = max(diff_L),
  diff_L_mean = mean(diff_L)
)

cat("Validação D.Bn vs Tabela 14  -> diferença máxima:", format(validacao$diff_A_max, scientific = TRUE), "\n")
cat("Validação Leontief vs Tabela 15 -> diferença máxima:", format(validacao$diff_L_max, scientific = TRUE), "\n")

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(validacao, "data/processed/validacao_leontief.rds")

message("Validação concluída e salva em data/processed/validacao_leontief.rds")
