if (!require("pacman")) install.packages("pacman")

source(here("causal_discovery", "util", "DataLoader.R"))
df_selected <- loadCSV()
blacklist_all <- loadBlacklist()

pacman::p_load(here)
here::i_am(paste("causal_discovery", "Causal-Discovery.R", sep = .Platform$file.sep))

value_iteration = "a2c+dqn"
policy_gradient = "ppo+trpo"

# value-iteration vs policy-gradient?
levels(df_selected$algorithm)[levels(df_selected$algorithm)=="a2c"] <- value_iteration
levels(df_selected$algorithm)[levels(df_selected$algorithm)=="dqn"] <- value_iteration
levels(df_selected$algorithm)[levels(df_selected$algorithm)=="ppo"] <- policy_gradient
levels(df_selected$algorithm)[levels(df_selected$algorithm)=="trpo"] <- policy_gradient

# ==============================================

pacman::p_load(bnlearn)

#Remove algorithm from blacklist, because we will filter by algorithm, 
#so we won't have this column in the selection dataset. 
#i.e., if we keep, it will through an error
blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("algorithm") ),]
blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("algorithm") ),]

algorithms = c(value_iteration, policy_gradient) 

#PC-STABLE
for (i in 1:length(algorithms)) {
  choice = algorithms[i]
  df_algo <- df_selected[df_selected$algorithm==choice,]
  df_algo <- 
    dplyr::select(df_algo,
                  shield_distance,
                  desired_speed,
                  average_speed,
                  timeLoss,
                  rear_end_collisions, 
                  lateral_collisions,
                  emergency_brakes,
                  number_of_cars
    );
  bn <-pc.stable(df_algo,blacklist = blacklist_all)
  png(filename = here("causal_discovery", "graphs", paste("graph", choice, "PC-Stable.png", sep = "_")))
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: pc-stable"))
  dev.off()
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

#IAMB
for (i in 1:length(algorithms)) {
  choice = algorithms[i]
  df_algo <- df_selected[df_selected$algorithm==choice,]
  df_algo <- 
    dplyr::select(df_algo,
                  shield_distance,
                  desired_speed,
                  average_speed,
                  timeLoss,
                  rear_end_collisions, 
                  lateral_collisions,
                  emergency_brakes,
                  number_of_cars
    );
  bn <-iamb(df_algo,blacklist = blacklist_all)
  png(filename = here("causal_discovery", "graphs", paste("graph", choice, "iamb.png", sep = "_")))
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: iamb"))
  dev.off()
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

