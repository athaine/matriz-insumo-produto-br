# Matriz de Insumo-Produto do Brasil (2015, nível 20) — validação e indicadores estruturais em R

Reprodução, em R, da cadeia de cálculo da Matriz de Insumo-Produto (MIP) publicada pelo IBGE
para 2015, nível de agregação de 20 setores/produtos, com validação algébrica da matriz de
Leontief oficial e cálculo de indicadores de encadeamento setorial.

## Motivação

Este repositório documenta, de forma reprodutível, a metodologia de estimação e validação de
matrizes insumo-produto nacionais — coeficientes técnicos, matriz inversa de Leontief,
multiplicadores e indicadores de encadeamento — a partir da base pública do Sistema de Contas
Nacionais do IBGE. O código não afirma nada que os dados originais não sustentem: quando uma
hipótese de cálculo foi testada e não se confirmou, isso está documentado, não escondido
(ver seção "O que este repositório não faz").

## Dados

Fonte: **IBGE, Diretoria de Pesquisas, Coordenação de Contas Nacionais** — Matriz de
Insumo-Produto 2015, nível 20.

O arquivo original (`data/raw/`) traz 15 tabelas em abas separadas:

| Abas | Conteúdo |
|---|---|
| 01 | Recursos de bens e serviços — inclui a Oferta a preço básico **e** a Produção das atividades em valores absolutos (produto × atividade) |
| 02 | Usos de bens e serviços — Consumo intermediário das atividades em valores absolutos (produto × atividade) |
| 03–04 | Oferta e demanda da produção nacional e importada, a preço básico |
| 05–10 | Destino de impostos e margens (comércio/transporte), nacional e importado |
| 11 | Matriz **Bn** — coeficientes técnicos dos insumos nacionais (produto × atividade) |
| 12 | Matriz **Bm** — coeficientes técnicos dos insumos importados |
| 13 | Matriz **D** — Market Share / participação setorial na produção (atividade × produto) |
| 14 | Matriz **D·Bn** — coeficientes técnicos intersetoriais (atividade × atividade) |
| 15 | Matriz de **Leontief** — (I − D·Bn)⁻¹, impacto intersetorial |

## O que este repositório faz

1. **Importa e organiza** as tabelas relevantes (`R/01_import_ibge.R`) em matrizes 20×20 com
   nomes de setor consistentes entre abas (`R/utils_setores.R`), e em formato tidy para
   relatório (`R/02_tidy_tabelas.R`).
2. **Recalcula `A = D %*% Bn`** a partir das matrizes oficiais D (Tabela 13) e Bn (Tabela 11),
   e compara com a Tabela 14 publicada — diferença máxima de `~1e-16` (precisão de máquina).
3. **Recalcula `L = (I - A)^-1`** a partir do `A` recalculado no passo anterior, e compara com
   a Tabela 15 (Leontief oficial) — diferença máxima de `~1e-15`. Ambas as validações estão em
   `R/03_validar_leontief.R` e cobertas por testes automatizados em `tests/testthat/`.
4. **Calcula indicadores de encadeamento** (`R/04_indicadores.R`) a partir da Leontief
   *recalculada* (não a importada diretamente — o pipeline é ponta a ponta):
   - multiplicador de produção de cada setor (soma da coluna de L);
   - índice de ligação para trás — poder de dispersão (Rasmussen-Hirschman);
   - índice de ligação para frente — sensibilidade de dispersão.
5. **Classifica setores-chave** (`R/05_setores_chave.R`): setor-chave, motriz, base ou
   independente, conforme os dois índices ficam acima ou abaixo da média (= 1).
6. **Documenta o método e os resultados** em `docs/nota_tecnica.Rmd`, incluindo as tabelas de
   validação e de classificação setorial.

## O que este repositório não faz (e por quê)

- **Não reconstrói a matriz Bn a partir de valores absolutos (Tabelas 01/02).** Testamos essa
  hipótese: `Bn[i,j] = Consumo_intermediário[i,j] / VBP[j]`, com o VBP obtido somando a coluna
  `j` do bloco "Produção das atividades" da Tabela 01. O resultado **não** reproduz a Tabela 11
  oficial (diferença de até ~0,2 em alguns coeficientes — muito acima de erro de arredondamento).
  Isso está documentado e reproduzível em `R/00_diagnostico_vbp.R`. A hipótese mais provável é
  que o VBP usado pelo IBGE nesse cálculo passa por ajustes (produção secundária por atividade,
  base de preços) que esta planilha de nível 20 não detalha o suficiente para replicar com
  segurança. Por isso o repositório parte das matrizes **já oficiais** (Bn, D) e valida
  algebricamente a etapa seguinte da cadeia (D·Bn e a inversa de Leontief) — que é a parte que
  os dados disponíveis permitem comprovar com rigor, sem reconstrução especulativa.
- **Não estima matrizes inter-regionais** — o dado disponível nesta planilha é só nacional.
- **Não incorpora dados de emissões de GEE** (SEEG/BEN) — ficaria como extensão futura,
  condicionada à obtenção dessa base separadamente e à sua compatibilização setorial com a
  classificação nível 20 usada aqui.

## Estrutura

```
├── data/
│   ├── raw/                          # arquivo original do IBGE, intocado
│   └── processed/                    # .rds gerados pelo pipeline (não versionados)
├── R/
│   ├── utils_setores.R               # metadados dos 20 setores + leitura de blocos
│   ├── 00_diagnostico_vbp.R          # teste documentado que NÃO entra no pipeline principal
│   ├── 01_import_ibge.R
│   ├── 02_tidy_tabelas.R
│   ├── 03_validar_leontief.R         # núcleo: A = D.Bn, L = (I-A)^-1, comparação com IBGE
│   ├── 04_indicadores.R              # multiplicadores e índices de Rasmussen-Hirschman
│   ├── 05_setores_chave.R            # classificação setor-chave / motriz / base / independente
│   └── run_all.R                     # roda o pipeline 01 a 05 em sequência
├── tests/
│   ├── testthat.R
│   └── testthat/test-validacao-leontief.R
├── docs/
│   └── nota_tecnica.Rmd
├── DESCRIPTION
├── LICENSE
└── README.md
```

## Como reproduzir

### 1. Baixar o projeto
Na página do repositório, clique em **Code → Download ZIP** e extraia o arquivo.
(Se usa git: `git clone <url-do-repositorio>`.)

> **Atenção:** o ZIP do GitHub costuma extrair uma pasta dentro de outra
> (`matriz-insumo-produto-br/matriz-insumo-produto-br/`). A pasta do projeto é a
> **de dentro**, a que contém o `README.md`, as pastas `R/`, `data/`, `tests/` e o arquivo `.Rproj`.

### 2. Abrir o projeto
- **RStudio (recomendado):** dê dois cliques em `matriz-insumo-produto-br.Rproj`.
- **R puro:** use `setwd()` com o caminho da pasta do projeto no seu computador
  (dica: no Explorador de Arquivos, clique na barra de endereço, copie o caminho e troque `\` por `/`):
```r
  setwd("COLE/AQUI/O/CAMINHO/DA/PASTA/DO/PROJETO")
```

### 3. Instalar as dependências (só na primeira vez)
```r
install.packages(c("readxl", "dplyr", "tidyr", "tibble", "testthat", "rmarkdown", "knitr"))
```
> No Windows pode aparecer um aviso sobre o *Rtools*. Pode ignorar.

### 4. Rodar
```r
source("R/run_all.R")                        # pipeline completo
testthat::test_dir("tests/testthat")         # testes de validação
source("R/00_diagnostico_vbp.R")             # (opcional) diagnóstico de Bn
rmarkdown::render("docs/nota_tecnica.Rmd")   # nota técnica em HTML
```
O `run_all.R` imprime `Raiz do projeto: ...` no começo. Se esse caminho estiver certo, está tudo bem.

### Problemas comuns
| Mensagem | O que fazer |
|---|---|
| `Nao encontrei a raiz do projeto` | O R não está dentro da pasta do projeto. Use o passo 2. |
| `Nenhuma planilha .xls/.xlsx encontrada` | Coloque o arquivo da MIP 2015 nível 20 do IBGE em `data/raw/`. |
| `Pacotes faltando` | Rode o passo 3. |

## Dependências

R ≥ 4.2, `readxl`, `dplyr`, `tidyr`, `tibble`, `testthat`, `rmarkdown`, `knitr`.

## Licença

Código sob licença MIT (ver `LICENSE`). Dados originais são públicos, de titularidade do IBGE
(Diretoria de Pesquisas, Coordenação de Contas Nacionais).

## Referência

IBGE. **Matriz de Insumo-Produto — 2015**. Rio de Janeiro: IBGE, Coordenação de Contas
Nacionais. Link: https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9054-contas-regionais-do-brasil.html?edicao=45139&t=resultados

