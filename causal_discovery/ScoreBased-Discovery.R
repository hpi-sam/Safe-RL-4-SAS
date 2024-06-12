"
Score-Based Causal discovery for the programming skill and test Duration related factors

algorithm, #categorical[exogenous] 
shield_distance [exogenous]
speed [exogenous]
timeLoss [outcome]
rear_end_collisions [outcome]
lateral_collisions [outcome]
emergency_brakes [endogenous]
number_of_cars [exogenous]

\begin{list}

\item Hill-Climbing (hc): a hill climbing greedy search that explores the space of the directed acyclic graphs by single-arc addition, removal and reversals; with random restarts to avoid local optima. The optimized implementation uses score caching, score decomposability and score equivalence to reduce the number of duplicated tests.

\item Tabu Search (tabu): a modified hill-climbing able to escape local optima by selecting a network that minimally decreases the score function.

\end{list}

Pena JM (2008). Learning Gaussian Graphical Models of Gene Networks with False Discovery Rate Control. Proceedings of the Sixth European Conference on Evolutionary Computation, Machine Learning and Data Mining in Bioinformatics, 165–176.

Gasse M, Aussem A, Elghazel H (2014). A Hybrid Algorithm for Bayesian Network Structure Learning with Application to Multi-Label Learning. Expert Systems with Applications, 41(15):6755–6772.


The library used was bnlearn \cite{scutari2010learning}
https://www.bnlearn.com/documentation/man/structure.learning.html
Learning Bayesian Networks with the bnlearn R - https://arxiv.org/pdf/0908.3817.pdf

" 

#Load script for generating blacklists of edges 
source("C://Users//Christian//Documents//GitHub//Safe-RL-4-SAS//causal_discovery//util//GenerateGraphPlot.R")

library(bnlearn)
library(dplyr)

#Load only Consent data. No data from tasks, only from demographics and qualification test

path = "C://Users//Christian//Documents//GitHub//Safe-RL-4-SAS//causal_discovery//"
file = "causal_discovery_full_data.csv"
plots_folder = paste0(path,"graphs//")

df <- read.csv(paste0(path,file))
df$shield_distance <- as.numeric(df$shield_distance)
df$speed <- as.numeric(df$speed)
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
                speed,
                timeLoss,
                rear_end_collisions, 
                lateral_collisions,
                emergency_brakes
                #number_of_cars
  );

outcome_nodes = c("speed","rear_end_collisions","lateral_collisions")

head(df_selected)

#rowSums(is.na(df_selected))

#df[complete.cases(df_selected), ]

df_selected$algorithm <- as.factor(df_selected$algorithm)

node.names <- colnames(df_selected)

#shield and speed are not causally connected.
blacklist_1 <- data.frame(from = c("shield_distance"), 
                          to   = c("speed"))

blacklist_2 <- data.frame(from   = c("speed"),
                          to = c("shield_distance"))

#----------
#timeLoss is not parent of any variable,it is an outcome.
blacklist_3 <- data.frame(from = c("timeLoss"), 
                          to   = c("algorithm","shield_distance","speed","rear_end_collisions","lateral_collisions","emergency_brakes"))#,"number_of_cars"))
#----------
#collisions are independent from each other
blacklist_4 <- data.frame(from = c("lateral_collisions"), 
                          to   = c("rear_end_collisions"))

blacklist_5 <- data.frame(from   = c("rear_end_collisions"),
                          to = c("lateral_collisions"))
#-----------
#rear_end_collisions cannot cause shield_distance, speed, or timeLoss

blacklist_6 <- data.frame(from   = c("rear_end_collisions"),
                          to = c("shield_distance"))

blacklist_7 <- data.frame(from = c("rear_end_collisions"), 
                          to   = c("timeLoss"))

blacklist_8 <- data.frame(from   = c("rear_end_collisions"),
                          to = c("speed"))
#-----------
#lateral_collisions cannot cause shield_distance, speed, or timeLoss
blacklist_9 <- data.frame(from = c("lateral_collisions"), 
                          to   = c("speed"))

blacklist_10 <- data.frame(from = c("lateral_collisions"), 
                           to   = c("shield_distance"))

blacklist_11 <- data.frame(from = c("lateral_collisions"), 
                           to   = c("timeLoss"))

#-----------
#similarly, timeLoss cannot cause the collision types
blacklist_12 <- data.frame(from   = c("timeLoss"),
                           to = c("rear_end_collisions"))

blacklist_13 <- data.frame(from   = c("timeLoss"),
                           to = c("lateral_collisions"))
#----------

#number_of_cars cannot cause change on other exogeneous variables
blacklist_14 <- data.frame(from = c("number_of_cars"), 
                           to   = c("speed"))

blacklist_15 <- data.frame(from = c("number_of_cars"), 
                           to   = c("shield_distance"))

blacklist_16 <- data.frame(from = c("number_of_cars"), 
                           to   = c("algorithm"))

#----------

#number_of_cars cannot de caused by any other covariate
blacklist_17 <- data.frame(from   = c("algorithm","shield_distance","speed","rear_end_collisions","lateral_collisions","emergency_brakes"),
                           to = c("number_of_cars"))

#----------

#Task Accuracy can only be measured with all tasks data. 
#Here we are dealing only with programmer demographic data.

blacklist_all <- rbind(blacklist_1,blacklist_2,blacklist_3,blacklist_4,
                       blacklist_5,blacklist_6,blacklist_7,blacklist_8,
                       blacklist_9,blacklist_10,blacklist_11,blacklist_12,
                       blacklist_13)#blacklist_14,blacklist_15,blacklist_16)
                       #blacklist_17) 

#------------------------------------------
#HC Hill-Climbing
bn <- hc(df_selected,blacklist = blacklist_all)
plot(bn,main="All algorithms, Discovery method:HC")

#TABU
bn <-tabu(df_selected,blacklist = blacklist_all)
plot(bn,main="All algorithms, Discovery method:Tabu")

"
Both algorithms produced similar graph. The two differences were:
lateral_collision -> emergecy_brakes (Tabu), while in HC is the reverse.
shield_distance -> emergency_brakes (Tabu), while HC has no such edge.
"

#----------------------------------------------
#----------------------------------------------
#BY Algorithm

#Remove algorithm from blacklist, because we will filter by algorithm, 
#so we won't have this column in the selection dataset. 
#i.e., if we keep, it will through an error
blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("algorithm") ),]
blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("algorithm") ),]


#Hill-Climbing and Tabu
#Run structure discovery for each algorithm
#algorithms = c("trpo", "a2c",  "dqn",  "ppo") the others do not have much data yet.
algorithms = c("ppo")

for (i in 1:length(algorithms)) {
  choice = algorithms[i]
  df_algo <- df_selected[df_selected$algorithm==choice,]
  df_algo <- 
    dplyr::select(df_algo,
                  shield_distance,
                  speed,
                  timeLoss,
                  rear_end_collisions, 
                  lateral_collisions,
                  emergency_brakes
  );
  #HC
  bn <-hc(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: HC"))
  
  #TABU
  bn <-tabu(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: Tabu"))
  
}
"Results of Hill Climbing
years_prog -> test_duration, all except Grad_student and Professionals
years_prog -> adjusted_score, all except Grad_student
test_duration -> adjusted_score, all except Other and Programmer
age -> years_prog, all
age -> duration, none
age -> adjusted_score, all except Grad_student and Other

Results of Tabu produced the exact same results as Hill Climbing
"

#-------------------------------------------------------
