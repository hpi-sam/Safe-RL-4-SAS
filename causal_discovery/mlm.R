if (!require("pacman")) install.packages("pacman")

here::i_am(paste("causal_discovery", "mlm.R", sep = .Platform$file.sep))

pacman::p_load(here)
pacman::p_load(brms)

file = "causal_discovery_full_data.csv"
path = here("causal_discovery", file)

df <- read.csv(path)
df$shield_distance <- as.numeric(df$shield_distance)
df$speed <- as.numeric(df$speed)
df$timeLoss <- as.numeric(df$timeLoss)
df$rear_end_collisions <- as.numeric(df$rear_end_collisions)
df$lateral_collisions <- as.numeric(df$lateral_collisions)
df$emergency_brakes <- as.numeric(df$emergency_brakes)
df$number_of_cars <- as.numeric(df$number_of_cars)

df_selected <- dplyr::select(df,
                algorithm, #categorical
                shield_distance,
                speed,
                timeLoss,
                rear_end_collisions, 
                lateral_collisions,
                emergency_brakes,
                number_of_cars
  );

df_selected$algorithm <- as.factor(df_selected$algorithm)
node.names <- colnames(df_selected)

outcomes = c("timeLoss", "rear_end_collisions", "lateral_collisions", "emergency_breaks")
explanatory_variables = c("speed", "shield_distance", "speed+shield_distance")

df_a2c <- df_selected[df$algorithm == "a2c", ]
formula_a2c_timeLoss = timeLoss ~ speed + shield_distance + number_of_cars
formula_a2c_rear_end_collisions = rear_end_collisions ~ speed + shield_distance + number_of_cars
formula_a2c_lateral_collisions = lateral_collisions ~ speed + shield_distance + number_of_cars

# formula = reponse_variable ~ predictor variables + ( whatever is here is supposed to vary with group | group_variable)
formula = rear_end_collisions ~ speed + shield_distance + (rear_end_collisions | algorithm)

# 4 is the default number of chains, cores should be max(chains, available pc_cores)
fitted_model <- brm(formula, df_selected, cores = 4, chains = 4)
a2c_timeLoss_mlm <- brm(formula_a2c, df_a2c, cores = 4)
a2c_rear_end_collisions_mlm <- brm(formula_a2c_rear_end_collisions, df_a2c, cores = 4)
a2c_lateral_collisions_mlm <- brm(formula_a2c_lateral_collisions, df_a2c, cores = 4)


summary(a2c_rear_end_collisions_mlm, waic = TRUE)
plot(a2c_rear_end_collisions_mlm)
