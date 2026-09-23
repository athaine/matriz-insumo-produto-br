# 00_diagnostico_vbp.R
#
# Este script não faz parte da cadeia de validação usada no repositório —
# ele documenta um teste que fizemos e descartamos, para justificar por que
# NÃO reconstruímos a matriz Bn a partir dos valores absolutos das
# Tabelas 01 e 02.
#
# Hipótese testada:
#   Bn[i, j] = Consumo_intermediario[i, j] / VBP[j]
# onde VBP[j] (Valor Bruto da Produção da atividade j) seria a soma, na
# coluna j, do bloco "Produção das atividades" da Tabela 01.
#
# Resultado: a matriz reconstruída NÃO reproduz a Tabela 11 oficial
# (diferença máxima da ordem de 0,1 a 0,2 em alguns coeficientes — muito
# acima do que seria erro de arredondamento). Isso indica que o VBP correto
# para esse cálculo envolve ajustes que a planilha nível 20 não detalha o
# suficiente para replicar com segurança (produção secundária por atividade,
# base de preços, ou reclassificações entre Tabelas 01-10 que exigiriam as
# tabelas de nível mais desagregado do IBGE, não incluídas neste arquivo).
#
# Por isso o repositório NÃO usa essa reconstrução: ele parte das matrizes
# já oficiais (Bn, D) e valida algebricamente a etapa seguinte da cadeia
# (D.Bn e a inversa de Leontief), que É auditável com os dados disponíveis
# — ver 03_validar_leontief.R.

source("R/utils_setores.R")

tabelas_raw <- readRDS("data/processed/tabelas_raw.rds")

vbp_por_atividade <- colSums(tabelas_raw$producao_atividades)

Bn_reconstruida <- tabelas_raw$consumo_intermediario /
  matrix(vbp_por_atividade, nrow = 20, ncol = 20, byrow = TRUE)
rownames(Bn_reconstruida) <- LETTERS[1:20]
colnames(Bn_reconstruida) <- LETTERS[1:20]

diferenca <- abs(Bn_reconstruida - tabelas_raw$Bn)

cat("Diagnóstico: reconstrução de Bn a partir de valores absolutos (Tabelas 01/02)\n")
cat("Diferença máxima vs. Tabela 11 oficial:", format(max(diferenca), scientific = TRUE), "\n")
cat("Diferença média vs. Tabela 11 oficial: ", format(mean(diferenca), scientific = TRUE), "\n")
cat("\nConclusão: diferença muito acima de erro de arredondamento.\n")
cat("A reconstrução NÃO é usada no restante do repositório (ver comentário no topo deste arquivo).\n")
