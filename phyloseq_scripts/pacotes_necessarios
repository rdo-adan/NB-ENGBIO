# Instalar pacotes necessários

packages <- c("devtools", "BiocManager", "remotes")
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
  }
}
invisible(lapply(packages, install_if_missing)) # Verificando e instalando os pacotes

################
# Pacotes cran #
################

cran_packages <- c("vegan", "ggplot2", "ggpubr", "cowplot", "dplyr", "picante")
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
  }
}
invisible(lapply(cran_packages, install_if_missing)) # Verificando e instalando os pacotes

#######################
# Pacotes BiocManager #
#######################

bioc_packages <- c("DESeq2", "ANCOMBC", "phyloseq", "Maaslin2", "scater")
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
  }
}
invisible(lapply(bioc_packages, install_if_missing)) # Verificando e instalando os pacotes

##################
# Pacotes Github #
##################

if (!require("pairwiseAdonis", character.only = TRUE)) {
  devtools::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
}

######################
# Loading de pacotes #
######################

all_packages <- c("devtools", "BiocManager", "remotes", "vegan", "ggplot2", 
                  "ggpubr", "cowplot", "dplyr", "picante", "DESeq2", "ANCOMBC", 
                  "phyloseq", "Maaslin2", "scater", "pairwiseAdonis")

load_packages <- function(pkg) {
  if (require(pkg, character.only = TRUE)) {
    message(paste("Pacote", pkg, "carregado com sucesso."))
  } else {
    message(paste("Pacote", pkg, "não encontrado. Por favor, instale-o."))
  }
}

# Carregar os pacotes
invisible(lapply(all_packages, load_packages))

