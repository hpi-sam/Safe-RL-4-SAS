install.packages("languageserver")
install.packages("jsonlite")
install.packages("rlang")
install.packages("caret")

# sudo apt-get install gfortran libz-dev libblas-dev liblapack-dev
install.packages("brms")
install.packages("loo")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("preprocessCore")

library('brms')
library("loo")
library("preprocessCore")
library("caret")

get_r_eff_values <- function(model){
  n_samples <- nrow(data)
  log_likelihoods = log_lik((model))
  rows <- nrow(log_likelihoods)
  chain_ids <- rep(1:2, each = rows/2)
  eff_samples <- relative_eff(log_lik(model), chain_id = chain_ids)
  r_eff_values <- eff_samples / n_samples
  r_eff_values
}

df <- read.csv("/Users/finn/Documents/beste_ergebnisse_leaderboard_towns_raw.csv")
df <- transform(df, scenario = as.character(scenario))

# df$mix_percentage <- predict(preProcess(as.data.frame(df$mix_percentage), method=c("range")), df$mix_percentage)

# df_scores <- df[c(1:720), c(2:4, 10, 11, 17, 18, 21)]
df_scores <- df[c(1:720), c(28, 29)]
df_rest <- df[c(1:720), c(1:27, 30, 31)]
process <- preProcess(as.data.frame(df_scores), method=c("range"))
df_norm <- predict(process, as.data.frame(df_scores))
# df_categorical <- df[c(1:720), c(24:28)]
# df_norm <- as.data.frame(normalize.quantiles(as.matrix(df_scores)))
df_norm <- data.frame(df_norm, df_rest)

#if norm wanted
df <- df_norm

# which scores
# wrong naming --> Better name would be outcome variables
independent_variable_names <- c("num_collisions_weighted", "distance_driven", "lane_scores_weighted", "mean_brake_path_shortage_weighted", "mean_stop_and_go_score_weighted")
sink(file = "/Users/finn/Documents/results_norm_weighted.txt")
for (variable_name in independent_variable_names) {
  independent_variables <- as.list(c(variable_name))
  
  # TODO: build lm models
  
  # build the mlm models
  # better naming: explanatory_variables
  variables <- as.list(c("forecast",
                         "mix_percentage",
                         "time",
                         "forecast+mix_percentage",
                         "forecast+time",
                         "mix_percentage+time",
                         "forecast+mix_percentage+time") # only load balance
  )

  # "Experiment" is cluster variable --> Should be number_of_cars
  mlm_models <- lapply(paste(independent_variables, " ~ 1 + ", variables, " + (1 + ", variables, " | Experiment)"), as.formula)
  mlm_models <- append(mlm_models, lapply(paste(independent_variables, " ~ 1 + (1 | Experiment)"), as.formula))
  
  mlm_fitted_models <- lapply(mlm_models, function(x) brm(x, data = df, warmup = 1000, iter = 3000, chains = 2, init="random", cores = 4)) 
  
  print(paste('###', variable_name))
  print(mlm_fitted_models)
  
  # waic and loo-cv (psis)
  loo_results <- lapply(mlm_fitted_models, function(x) loo(log_lik(x), r_eff = get_r_eff_values(x)))
  names(loo_results) <- append(variables, c("intercept_only"))
  print(loo_compare(loo_results))
  
  waic_results <- lapply(mlm_fitted_models, function(x) waic(log_lik(x)))
  print(waic_results)
}
sink()