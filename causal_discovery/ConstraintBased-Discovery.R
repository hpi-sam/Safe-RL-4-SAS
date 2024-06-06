
"
Causal discovery using Constraint-Based Algorithms 

speed [exogenous];
shield [exogenous];
algorithm [exogenous]
lateral_collisions [endogenous];
rear_collisions [endogenous]
time_loss [outcome];

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
#compare how professions are distinct in terms of adjusted_score and qualification_score

" 



library(bnlearn)
library(dplyr)

#Load only Consent data. No data from tasks, only from demographics and qualification test

path = "C://Users//Christian//Documents//GitHub//Safe-RL-4-SAS//causal_discovery//"
file = "causal_discovery_full_data.csv"

df <- read.csv(paste0(path,file))

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

#years_prog is not parent of age.
blacklist_1 <- data.frame(from = c("years_prog"), 
                          to   = c("age"))

#Prevent speed to be parents of age and years_prog and profession
blacklist_2 <- data.frame(from = c("speed"), 
                          to   = c("years_prog","age","profession"))

#profession has no parent nodes
blacklist_3 <- data.frame(from = node.names[-grep("profession", node.names)], 
                          to   = c("profession"))
#test_duration is not parent of age, years_prog, profession
blacklist_4 <- data.frame(from = c("test_duration"),
                          to   = c("profession","years_prog","age"))#,"is_fast"))
#adjusted_score cannot be parent of anyone
blacklist_5 <- data.frame(from = c("adjusted_score"),
                          to   = node.names[-grep("adjusted_score", node.names)])

#Task Accuracy can only be measured with all tasks data. 
#Here we are dealing only with programmer demographic data.

blacklist_all <- rbind(blacklist_1,blacklist_3,blacklist_4,blacklist_5) 

#------------------------------------------
#Including Profession as Node

bn <- pc.stable(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, pc.stable algorithm")

bn <-iamb(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, iamb algorithm")

bn <-iamb.fdr(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, iamb.fdr algorithm")

#-----------------------------------------
#BY PROFESSION

#Remove profession from blacklist
blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("profession") ),]
blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("profession") ),]
#blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("speed") ),]
#blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("speed") ),]


#Run structure discovery for each profession
professions = c("Other", "Undergraduate_Student","Graduate_Student","Hobbyist",
                "Programmer","Professional")

#PC-STABLE
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-pc.stable(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"Analysis of results of the PC algorithm
test duration seem relevant only for professional, undergrad, grad, hobbyist
only in undegrad that test duration is affected by years_prog"

#IAMB
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-iamb(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"Analysis of results of the Tabu algorithm
Test duration has not effect on adjusted_score for other and Programmer
Test duration has no parents for Graduate and Professional
Only in Hobbyists that test duration is a mediator for effect on adjusted_score
Test duration has years_prog as parent in Hobbyist, Undergrad, 
Programmer, and Other.
"


#----------------------------------
#IAMB.FDR
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-iamb.fdr(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}


#---------------------------------------------------------------------
#---------------------------------------------------------------------
#Using now the qualification_score

df_selected <-
  dplyr::select(df_consent,
                profession, #categorical
                age,
                years_prog,
                test_duration,
                speed, #or use is_fast, which is binary
                qualification_score #outcome
  );


node.names <- colnames(df_selected)

#years_prog is not parent of age.
blacklist_1 <- data.frame(from = c("years_prog"), 
                          to   = c("age"))
#profession has parent nodes
blacklist_2 <- data.frame(from = node.names[-grep("profession", node.names)], 
                          to   = c("profession"))
#test_duration is not parent of age, years_prog, profession
blacklist_3 <- data.frame(from = c("test_duration"),
                          to   = c("profession","years_prog","age"))
#qualification_score cannot be parent of anyone
blacklist_4 <- data.frame(from = c("qualification_score"),
                          to   = node.names[-grep("qualification_score", node.names)])
#Prevent speed to be parents of age and years_prog and profession
blacklist_5 <- data.frame(from = c("speed"), 
                          to   = c("years_prog","age","profession"))


blacklist_all <- rbind(blacklist_1,blacklist_2,blacklist_3,blacklist_4,blacklist_5) 


#------------------------------------------
#Including Profession as Node

bn <- pc.stable(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, pc.stable algorithm")

bn <-iamb(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, iamb algorithm")

bn <-iamb.fdr(df_selected,blacklist = blacklist_all)
plot(bn,main="All Professions, iamb.fdr algorithm")

#-----------------------------------------
#Remove Profession as Node

#Remove profession from blacklist
blacklist_all <- blacklist_all[!(blacklist_all$from %in% c("profession") ),]
blacklist_all <- blacklist_all[!(blacklist_all$to %in% c("profession") ),]

#PC-STABLE
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-pc.stable(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"Analysis of results of the PC algorithm
Test duration has not effect on adjusted_score for other and Programmer
Only in undegrad that test duration is affected by years_prog
Hence, qualification_Score and adjusted_score produced the same graphs with the PC algorithm
"

#IAMB
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-iamb(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}

"Analysis of results of the Tabu algorithm
Test duration has no effect on adjusted_score for other and Programmer
Test duration has no parents for Graduate and Professional
Only in Hobbyists that test duration is a mediator for effect on adjusted_score
Test duration has years_prog as parent in Hobbyist, Undergrad, 
Programmer, and Other.

Hence, qualification_score and adjusted_score produced the same graph with the tabu algorithm
"

#IAMB-FDR
for (i in 1:length(professions)) {
  choice = professions[i]
  df_prof <- df_selected[df_selected$profession==choice,]
  df_prof <- 
    dplyr::select(df_prof,
                  years_prog,
                  age,
                  speed,
                  test_duration,
                  adjusted_score
    );
  bn <-iamb.fdr(df_prof,blacklist = blacklist_all)
  plot(bn,main=choice)
  #graphviz.plot(bn,main=choice,shape="ellipse",layout = "circo");
}



