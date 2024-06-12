"
Generate a plot and save to file
"

library(Rgraphviz)

#Example use
#bn_name="All algorithms hc";
#save_bayesian_net_plot(bayesian_net=bn,
#                       outcome_nodes=outcome_nodes,
#                       plot_title=bn_name,
#                       file_name=bn_name,
#                       folder=plots_folder)

save_bayesian_net_plot <- function(bayesian_net,outcome_nodes,plot_title, 
                                   file_name,folder){
  gR <- graphviz.plot(bn,render = FALSE,
                      main=plot_title,
                      shape=c("ellipse"));
  gR = layoutGraph(gR, attrs = list(graph = list(rankdir = "LR",nodesep=0.1)))
  
  graph.par(list(nodes=list(col="black", lty="solid", 
                            lwd=1, fontsize=10),
                 graph=list(cex.main=2.8)
  ))
  
  nodeRenderInfo(gR)$fill[outcome_nodes]="lightblue"
  
  png(filename=paste0(folder,file_name,".png"),
      height=200,width=600,antialias = "cleartype",
      res = 100,unit="mm",
      bg = "transparent");
  renderGraph(gR);
  dev.off();
}