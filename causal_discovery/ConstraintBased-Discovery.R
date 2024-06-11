
"
Causal discovery using Constraint-Based Algorithms 

algorithm, #categorical[exogenous] 
shield_distance [exogenous]
speed [exogenous]
timeLoss [outcome]
rear_end_collisions [outcome]
lateral_collisions [outcome]
emergency_brakes [endogenous]
number_of_cars [exogenous]

Constraint-based algorithms execute a conditional independence tests
induced by each hypothetical graph. Because these tests are executed
sequentially (i.e., multiple times), there is a risk of false positives (i.e., false discovery)
by compounding errors. Therefore, algorithms try to minimize this risk
in various ways. To test the sensitivity of our data to this risk
we executed methods with increasingly power to mitigate false positives.

\begin{list}
\item PC (pc.stable), seminal constraint-based structure learning algorithm \cite{colombo2014order}
#Colombo D, Maathuis MH (2014). Order-Independent Constraint-Based Causal Structure Learning. Journal of Machine Learning Research, 15:3921–3962.

\item Incremental Association (iamb) is based on the Markov blanket detection algorithm \cite{tsamardinos2003algorithms} that executes a 
two-phase selection, more specifically a forward selection followed by a iteration to remove false positives.

Tsamardinos I, Aliferis CF, Statnikov A (2003). Algorithms for Large Scale Markov Blanket Discovery. Proceedings of the Sixteenth International Florida Artificial Intelligence Research Society Conference, 376–381.

\item Incremental Association with FDR (iamb.fdr) is an improvement on the IAMB. It adjusts the tests 
significance threshold with false discovery rate heuristics \cite{pena2008learning,gasse2014hybrid}

Pena JM (2008). Learning Gaussian Graphical Models of Gene Networks with False Discovery Rate Control. Proceedings of the Sixth European Conference on Evolutionary Computation, Machine Learning and Data Mining in Bioinformatics, 165–176.

Gasse M, Aussem A, Elghazel H (2014). A Hybrid Algorithm for Bayesian Network Structure Learning with Application to Multi-Label Learning. Expert Systems with Applications, 41(15):6755–6772.

\end{list}

The library used was bnlearn \cite{scutari2010learning}
https://www.bnlearn.com/documentation/man/structure.learning.html
Learning Bayesian Networks with the bnlearn R - https://arxiv.org/pdf/0908.3817.pdf

#TODO
#compare graphs produced by each of the methods. Check how sensitive they are to false discovery rate.

" 

library(bnlearn)
library(dplyr)

#Load only Consent data. No data from tasks, only from demographics and qualification test

path = "C://Users//Christian//Documents//GitHub//Safe-RL-4-SAS//causal_discovery//"
file = "causal_discovery_full_data.csv"

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
                emergency_brakes,
                number_of_cars
                );

head(df_selected)

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
                           to   = c("algorithm","shield_distance","speed","rear_end_collisions","lateral_collisions","emergency_brakes","number_of_cars"))
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
                       blacklist_13,blacklist_14,blacklist_15,blacklist_16,
                       blacklist_17) 

#-----------------------------------------
#Including algorithm as Node

bn <- pc.stable(df_selected,blacklist = blacklist_all)
plot(bn,main="All algorithms, pc.stable method")

bn <-iamb(df_selected,blacklist = blacklist_all)
plot(bn,main="All algorithms, iamb method")

bn <-iamb.fdr(df_selected,blacklist = blacklist_all)
plot(bn,main="All algorithms, iamb.fdr method")

#-----------------------------------------
#BY RL algorithm 

#Remove algorithm from blacklist, because we will filter by algorithm, 
#so we won't have this column in the selection dataset. 
#i.e., if we keep, it will through an error
blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("algorithm") ),]
blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("algorithm") ),]

#Run structure discovery for each algorithm
#algorithms = c("trpo", "a2c",  "dqn",  "ppo") the others do not have much data yet.
algorithms = c("ppo")

#PC-STABLE
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
                  emergency_brakes,
                  number_of_cars
    );
  bn <-pc.stable(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: pc-stable"))
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"ANALYSIS: Analysis of results of the PC algorithm test duration seem relevant
only for professional, undergrad, grad, hobbyist
only in undegrad that test duration is affected by years_prog"

#IAMB
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
                  emergency_brakes,
                  number_of_cars
    );
  bn <-iamb(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: iamb"))
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"ANALYSIS of results of the Tabu algorithm
Test duration has not effect on adjusted_score for other and Programmer
Test duration has no parents for Graduate and Professional
Only in Hobbyists that test duration is a mediator for effect on adjusted_score
Test duration has years_prog as parent in Hobbyist, Undergrad, 
Programmer, and Other.
"


#----------------------------------
#IAMB.FDR
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
                  emergency_brakes,
                  number_of_cars
    );
  bn <-iamb.fdr(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: iamb.fdr"))  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

