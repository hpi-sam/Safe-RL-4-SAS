install.packages("languageserver")
install.packages("jsonlite")
install.packages("rlang")

# sudo apt-get install gfortran libz-dev libblas-dev liblapack-dev
install.packages("brms")
install.packages("loo")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("preprocessCore")