"
Causal discovery using Constraint-Based Algorithms 

algorithm, #categorical[exogenous] 
shield_distance [exogenous]
desired_speed [exogenous]
average_speed [endogenous]
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
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here)

source(here("causal_discovery", "util", "DataLoader.R"))
df_selected <- loadCSV()
blacklist_all <- loadBlacklist()

here::i_am(paste("causal_discovery", "ConstraintBased-Discovery.R", sep = .Platform$file.sep))

pacman::p_load(bnlearn)

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
algorithms = c("trpo", "a2c",  "dqn",  "ppo") 

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
                  emergency_brakes
                  #number_of_cars
    );
  bn <-pc.stable(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: pc-stable"))
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"ANALYSIS: Analysis of results of the PC algorithm"

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
                  emergency_brakes
                  #number_of_cars
    );
  bn <-iamb(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: iamb"))
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"ANALYSIS of results of the Tabu algorithm
"


#----------------------------------
#IAMB.FDR
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
  bn <-iamb.fdr(df_algo,blacklist = blacklist_all)
  plot(bn,main=paste0("RL Algorithm: ",choice,", Discovery Method: iamb.fdr"))  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

