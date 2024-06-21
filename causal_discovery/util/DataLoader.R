if (!require("pacman")) install.packages("pacman")
pacman::p_load(here)
here::i_am(paste("causal_discovery", "util", "DataLoader.R", sep = .Platform$file.sep))

pacman::p_load(dplyr)

loadCSV <- function(){
  
  #Load only Consent data. No data from tasks, only from demographics and qualification test
  file = "causal_discovery_new_data.csv"
  path = here("causal_discovery", file)
  
  df <- read.csv(path)
  df$shield_distance <- as.numeric(df$shield_distance)
  df$desired_speed <- as.numeric(df$desired_speed)
  df$average_speed <- as.numeric(df$average_speed)
  df$timeLoss <- as.numeric(df$timeLoss)
  df$rear_end_collisions <- as.numeric(df$rear_end_collisions)
  df$lateral_collisions <- as.numeric(df$lateral_collisions)
  df$emergency_brakes <- as.numeric(df$emergency_brakes)
  df$number_of_cars <- as.numeric(df$number_of_cars)
  
  head(df)
  
  df_selected <-
    dplyr::select(df,
                  algorithm, #categorical
                  shield_distance,
                  desired_speed,
                  average_speed,
                  timeLoss,
                  rear_end_collisions, 
                  lateral_collisions,
                  emergency_brakes
#                  number_of_cars
    );
  
  df_selected$algorithm <- as.factor(df_selected$algorithm)
  
  return(df_selected)
}

loadBlacklist <- function(){
  #shield and desired_speed are not causally connected.
  blacklist_1 <- data.frame(from = c("shield_distance"), 
                            to   = c("desired_speed"))
  
  blacklist_2 <- data.frame(from   = c("desired_speed"),
                            to = c("shield_distance"))
  
  #----------
  #timeLoss is not parent of any variable,it is an outcome.
  blacklist_3 <- data.frame(from = c("timeLoss"), 
                            to   = c("algorithm","shield_distance","desired_speed", "average_speed","rear_end_collisions","lateral_collisions","emergency_brakes"))#,"number_of_cars"))
  #----------
  #collisions are independent from each other
  blacklist_4 <- data.frame(from = c("lateral_collisions"), 
                            to   = c("rear_end_collisions"))
  
  blacklist_5 <- data.frame(from   = c("rear_end_collisions"),
                            to = c("lateral_collisions"))
  #-----------
  #rear_end_collisions cannot cause shield_distance, desired_speed, or timeLoss
  
  blacklist_6 <- data.frame(from   = c("rear_end_collisions"),
                            to = c("shield_distance"))
  
  blacklist_8 <- data.frame(from   = c("rear_end_collisions"),
                            to = c("desired_speed"))
  #-----------
  #lateral_collisions cannot cause shield_distance, desired_speed, or timeLoss
  blacklist_9 <- data.frame(from = c("lateral_collisions"), 
                            to   = c("desired_speed"))
  
  blacklist_10 <- data.frame(from = c("lateral_collisions"), 
                             to   = c("shield_distance"))
  
  #-----------
  #similarly, timeLoss cannot cause the collision types
  blacklist_12 <- data.frame(from   = c("timeLoss"),
                             to = c("rear_end_collisions"))
  
  blacklist_13 <- data.frame(from   = c("timeLoss"),
                             to = c("lateral_collisions"))
  #----------
  #similarly, emergency_brakes cannot be caused the collision types
  blacklist_14 <- data.frame(from   = c("rear_end_collisions"),
                             to = c("emergency_brakes"))
  
  blacklist_15 <- data.frame(from   = c("lateral_collisions"),
                             to = c("emergency_brakes"))
  
  #----------
  
  
  #number_of_cars cannot cause change on other exogeneous variables
  #blacklist_16 <- data.frame(from = c("number_of_cars"), 
  #                           to   = c("desired_speed"))
  
  #blacklist_17 <- data.frame(from = c("number_of_cars"), 
  #                           to   = c("shield_distance"))
  
  #blacklist_18 <- data.frame(from = c("number_of_cars"), 
  #                           to   = c("algorithm"))
  
  #----------
  
  #number_of_cars cannot de caused by any other covariate
  #blacklist_19 <- data.frame(from   = c("algorithm","shield_distance","desired_speed", "average_speed","rear_end_collisions","lateral_collisions","emergency_brakes"),
  #                           to = c("number_of_cars"))
  
  #----------
  
  #Task Accuracy can only be measured with all tasks data. 
  #Here we are dealing only with programmer demographic data.
  
  blacklist_all <- rbind(blacklist_1,blacklist_2,blacklist_3,blacklist_4,
                         blacklist_5,blacklist_6,blacklist_8,
                         blacklist_9,blacklist_10,blacklist_12,
                         blacklist_13,blacklist_14,blacklist_15)
  #blacklist_16,blacklist_17,blacklist_18,blacklist_19) 
  return(blacklist_all)
}