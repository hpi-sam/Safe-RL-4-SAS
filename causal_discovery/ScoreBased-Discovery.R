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
#source("C://Users//Christian//Documents//GitHub//CausalModel_FaultUnderstanding//causal_discovery//GenerateBlacklists.R")

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

#------------------------------------------
#HC
bn <- hc(df_selected,blacklist = blacklist_all)
bn_name="E2 All Test_Score (hc)";
save_bayesian_net_plot(bayesian_net=bn,
                       outcome_node=outcomeNode,
                       plot_title=bn_name,
                       file_name=bn_name,
                       folder=plots_folder)
#TABU
bn <-tabu(df_selected,blacklist = blacklist_all)
bn_name="E2 All Test_Score (tabu)";
save_bayesian_net_plot(bayesian_net=bn,
                       outcome_node=outcomeNode,
                       plot_title=bn_name,
                       file_name=bn_name,
                       folder=plots_folder)
"
Both algorithms produced the same graph. It has two additional 
edges than the graph discovered by the CB algorithms. 
The two additional edges are years_prog->test_duration, age->test_score
"

#----------------------------------------------
#----------------------------------------------
#BY PROFESSION

df_selected <-
  dplyr::select(df_consent,
                profession,
                partic_age,
                progr_years,
                test_duration,
                test_score #outcome
  );

#Run structure discovery for each profession
professions = c("Other", "Undergraduate_Student","Graduate_Student","Hobbyist",
                "Programmer","Professional")

#Hill-Climbing and Tabu
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  partic_age,
                  progr_years,
                  test_duration,
                  test_score
    );
  #HC
  bn <-hc(df_prof,blacklist = blacklist_all)
  bn_name=paste("E2",choice," Test_Score (hc)");
  save_bayesian_net_plot(bayesian_net=bn,
                         outcome_node=outcomeNode,
                         plot_title=bn_name,
                         file_name=bn_name,
                         folder=plots_folder)
  #TABU
  bn <-tabu(df_prof,blacklist = blacklist_all)
  bn_name=paste("E2",choice," Test_Score (tabu)");
  save_bayesian_net_plot(bayesian_net=bn,
                         outcome_node=outcomeNode,
                         plot_title=bn_name,
                         file_name=bn_name,
                         folder=plots_folder)
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
#-------------------------------------------------------
#Using now the qualification_score

#---------------------------------------------------------------------
#Using now the qualification_score

df_consent <- rename(df_consent,orig_score=qualification_score)

df_selected <-
  dplyr::select(df_consent,
                years_prog,
                partic_age,
                test_duration,
                orig_score #outcome
  );


blacklist_all <- blacklist_E2_TestScore(node.names=colnames(df_selected), 
                                        outcome.node="orig_score")

#------------------------------------------
#Including Profession as Node

bn <- pc.stable(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, pc.stable algorithm")

bn <-iamb.fdr(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, iamb.fdr algorithm")

#-----------------------------------------
# Analysis by Profession

df_selected <-
  dplyr::select(df_consent,
                profession,
                years_prog,
                partic_age,
                test_duration,
                orig_score #outcome
  );

for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  partic_age,
                  test_duration,
                  orig_score
    );
  
  #HC
  bn <-pc.stable(df_prof,blacklist = blacklist_all)
  bn_name=paste("E2",choice," Original_Test_Score (hc)");
  save_bayesian_net_plot(bayesian_net=bn,
                         outcome_node="orig_score",
                         plot_title=bn_name,
                         file_name=bn_name,
                         folder=plots_folder)
  #TABU
  bn <-iamb.fdr(df_prof,blacklist = blacklist_all)
  bn_name=paste("E2",choice," Original_Test_Score (tabu)");
  save_bayesian_net_plot(bayesian_net=bn,
                         outcome_node="orig_score",
                         plot_title=bn_name,
                         file_name=bn_name,
                         folder=plots_folder)
}
"Qualification score results were identical to Adjusted score"

#------------------------------------------------------------------------
#------------------------------------------------------
#SPEED CLUSTERS
#Evaluate how fast and slow can explain test_score
#------------------------------------------------------

#FAST
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_consent[df_consent$profession==choice,]
  median_membership <- median(df_prof$testDuration_fastMembership);
  df_prof <- df_prof[df_prof$testDuration_fastMembership>=median_membership,]
  df_selected <- 
    dplyr::select(df_prof,
                  progr_years,
                  partic_age,
                  test_duration,
                  test_score
    );
  
  blacklist_all <- blacklist_E2_TestScore(node.names=colnames(df_selected), 
                                          outcome.node="test_score")
  bn <- tabu(df_selected,blacklist = blacklist_all)
  bn_name=paste("E2 Fast (Median)",choice," Test_Score (tabu)");
  plot(bn,main=bn_name)
       
  # save_bayesian_net_plot(bayesian_net=bn,
  #                        outcome_node="test_score",
  #                        plot_title=bn_name,
  #                        file_name=bn_name,
  #                        folder=plots_folder)
  
}
plot(bn)

"
Results on FAST RESPONDERS

Mean as threshold: Graphs are identical to no clustering by answer speed.
Other: yoe -> score, age -> yoe
Undergrad: yoe -> score, age -> yoe, age->score, yoe->duration, duration->score
Grad: yoe -> score, age -> yoe, age->score
Hobbyist: yoe -> score, age -> yoe, age->score, yoe->duration, duration->score
Programmer: yoe -> score, age -> yoe,
Professional: yoe -> score, age -> yoe, age->score, duration->score

Median as threshold: 
Other: age->yoe->score
Undergrad: age->yoe->score; age->score
Grad: no edges
Hobbyist:age->yoe->score; age->score<-duration
Programmer: age->yoe->score; score<-duration
Professional: age->yoe->score; age->score
So, only hobbyist and programmer have an edge from duration->score
No profession has edges arriving at duration
Hence, when conditioning on duration, we would to have only
minor effect on hobbyist and programmer, but no effect on the other professions.
This implies that fast responders would have similar results 
as the aggregate data (not filter by speed). 

Moreover,looking at the variance of the fast responder duration, we have
"

#SLOW
i=1
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_consent[df_consent$profession==choice,]
  median_membership <- median(df_prof$testDuration_fastMembership);
  df_prof <- df_prof[df_prof$testDuration_fastMembership<median_membership,]
  df_selected <- 
    dplyr::select(df_prof,
                  progr_years,
                  partic_age,
                  test_duration,
                  test_score
    );
  
  blacklist_all <- blacklist_E2_TestScore(node.names=colnames(df_selected), 
                                          outcome.node="test_score")
  bn <- tabu(df_selected,blacklist = blacklist_all)
  bn_name=paste("E2 Slow (Median)",choice," Test_Score (tabu)");
  save_bayesian_net_plot(bayesian_net=bn,
                         outcome_node="test_score",
                         plot_title=bn_name,
                         file_name=bn_name,
                         folder=plots_folder)
  
}


"Graphs for FAST Mean and Median are identical to no clustering by answer speed.
Other: yoe -> score, age -> yoe
Undergrad: yoe -> score, age -> yoe, age->score, yoe->duration, duration->score
Grad: yoe -> score, age -> yoe, age->score
Hobbyist: yoe -> score, age -> yoe, age->score, yoe->duration, duration->score
Programmer: yoe -> score, age -> yoe,
Professional: yoe -> score, age -> yoe, age->score, duration->score
"


df_consent_slow <- df_consent[!df_consent$is_fast,]
df_consent_slow <-
  dplyr::select(df_consent_slow,
                years_prog,
                age,
                test_duration,
                adjusted_score #outcome
  );
bn <-tabu(df_consent_slow,blacklist = blacklist_all)
plot(bn,main="SLOW Answers (Tabu algorithm)")

"
SLOW answer present only the folling two edges
year_prog->adjusted_score, years_prog -> test_duration
"

#---------------------------------
#Analysis of SPEED cluster by Profession

#TABU FAST
df_consent_fast <- df_consent[df_consent$is_fast,]
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_consent_fast$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  test_duration,
                  adjusted_score
    );
  bn <-tabu(df_prof,blacklist = blacklist_all)
  plot(bn,main=paste(choice,"(fast answers)"))
}

"Fast answer cluster has same results as no clustering"


#TABU SLOW
df_consent_fast <- df_consent[!df_consent$is_fast,]
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_consent_slow$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  test_duration,
                  adjusted_score
    );
  bn <-tabu(df_prof,blacklist = blacklist_all)
  plot(bn,main=paste(choice,"(slow answers)"))
}

"Slow answer clustering graphs showed no edges"

#-------------------------------------------------------

#Remove profession from blacklist
#blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("profession") ),]
#blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("profession") ),]

