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

if (!require("pacman")) install.packages("pacman")

source(here("causal_discovery", "util", "DataLoader.R"))
df_selected <- loadCSV()
blacklist_all <- loadBlacklist()

pacman::p_load(here)
here::i_am(paste("causal_discovery", "ConstraintBased-Discovery.R", sep = .Platform$file.sep))

pacman::p_load(bnlearn)

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
algorithms = c("trpo", "a2c",  "dqn",  "ppo")# the others do not have much data yet.
#algorithms = c("ppo")

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
