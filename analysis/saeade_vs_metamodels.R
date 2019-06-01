# ==============================================================================
# Clear workspace

rm(list = ls())


# ==============================================================================
# Install dependencies

dependencies.list <- c(
  "dplyr",
  "ggplot2",
  "xtable",
  "PMCMR"
)

dependencies.missing <- dependencies.list[!(dependencies.list %in% installed.packages()[,"Package"])]
if (length(dependencies.missing) > 0) {
  
  # Notify for missing libraries
  print("The following packages are required but are not installed:")
  print(dependencies.missing)
  dependencies.install <- readline(prompt = "Do you want them to be installed (Y/n)? ")
  if (any(tolower(dependencies.install) == c("y", "yes"))) {
    install.packages(dependencies.missing)
  }
}


# ==============================================================================
# Load libraries

suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(xtable))
suppressMessages(library(PMCMR))


# ==============================================================================
# Convergence (by poblem and size) of all metamodels against the SAEA-DE

# Join data from DE-best algorithm
mm.results <- read.csv("./data/metamodels.csv", header = TRUE, stringsAsFactors = FALSE)
de.results <- read.csv("./data/de.csv", header = TRUE, stringsAsFactors = FALSE)

de.results["MEAN.DIFF"] = numeric()
de.results["METAMODEL.TIME.S"] = numeric()
de.results["TOTAL.TIME.S"] = numeric()

aggdata <- union(mm.results, de.results)

# Remove repeated and problems and umbalanced data
aggdata <- aggdata %>%
  dplyr::filter(!(PROB %in% c('schwefel', 'trid', 'sumsqu'))) %>%
  dplyr::filter(!(PROB == 'zakharov' & NVAR == 20 & REP == 4))

aggdata$PROB <- factor(aggdata$PROB, unique(aggdata$PROB))

# Change metamodel names
aggdata$METAMODEL <- as.factor(aggdata$METAMODEL)
levels(aggdata$METAMODEL) <- list(OK  = "ordinary-kriging",
                                  UK1 = "universal-kriging1", 
                                  UK2 = "universal-kriging2",
                                  BK  = "blind-kriging",
                                  RBF = "rbf-gaussian",
                                  DE  = "DEbest")

# Compute objective function improvement
aggdata <- aggdata %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::mutate(IMPROV.OBJ = 100 * ((max(BEST.OBJ) - BEST.OBJ) / max(BEST.OBJ))) %>%
  dplyr::ungroup()

# Process data
aggdata <- aggdata %>%
  dplyr::group_by(PROB, NVAR, REP) %>%
  dplyr::mutate(REF.BEST.OBJ = max(BEST.OBJ), 
                REF.NEVAL = max(NEVAL)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(NORM.NEVAL = 100 * (NEVAL / REF.NEVAL)) %>%
  #dplyr::filter(NORM.NEVAL <= 50) %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, NORM.NEVAL) %>%
  dplyr::summarise(MEAN.IMPROV.OBJ = mean(IMPROV.OBJ), 
                   SE.IMPROV.OBJ = sd(IMPROV.OBJ) / sqrt(n()))

# Plot data
metamodels <- c('OK', 'UK1', 'UK2', 'BK', 'RBF')
for (metamodel in metamodels) {
  for (prob in unique(aggdata$PROB)) {
    
    # Filter metamodels
    aggdata2 <- aggdata %>%
      dplyr::filter(METAMODEL %in% c('DE', metamodel))
    
    aggdata2$METAMODEL <- factor(aggdata2$METAMODEL, unique(aggdata2$METAMODEL))
    
    fig <- ggplot2::ggplot(subset(aggdata2, PROB == prob),
                           ggplot2::aes(x    = NORM.NEVAL, 
                                        y    = MEAN.IMPROV.OBJ, 
                                        ymin = MEAN.IMPROV.OBJ - SE.IMPROV.OBJ, 
                                        ymax = MEAN.IMPROV.OBJ + SE.IMPROV.OBJ, 
                                        color = METAMODEL, 
                                        fill = METAMODEL)) +
      ggplot2::geom_line(size=1.7) +
      ggplot2::geom_ribbon(alpha=0.5) + 
      ggplot2::facet_wrap(~NVAR, scales = "fixed",
                          ncol = 1, nrow = length(unique(aggdata$NVAR))) +
      ggplot2::xlab("Function evaluations (%)") +
      ggplot2::ylab("Mean improv. over the best initial solution (%)") +
      ggplot2::scale_color_discrete(name = "Metamodel: ") + 
      ggplot2::scale_fill_discrete(name = "Metamodel: ") +
      ggplot2::theme(legend.position="bottom",
                     legend.direction = "horizontal",
                     text = element_text(size = 24))
    
    filename = paste("./figures/saeade/convergence-by-problem/convergence_SAEADE_vs_", metamodel, "_", as.character(prob), ".pdf", sep="")
    ggplot2::ggsave(filename, plot=fig, width=10, height=25)
    
    
    for (nvar in unique(aggdata$NVAR)) {
      
      fig <- ggplot2::ggplot(subset(subset(aggdata2, PROB == prob), NVAR == nvar),
                             ggplot2::aes(x    = NORM.NEVAL, 
                                          y    = MEAN.IMPROV.OBJ, 
                                          ymin = MEAN.IMPROV.OBJ - SE.IMPROV.OBJ, 
                                          ymax = MEAN.IMPROV.OBJ + SE.IMPROV.OBJ, 
                                          color = METAMODEL, 
                                          fill = METAMODEL)) +
        ggplot2::geom_line(size=1.7) +
        ggplot2::geom_ribbon(alpha=0.5) + 
        ggplot2::xlab("Function evaluations (%)") +
        ggplot2::ylab("Mean improv. over the best initial solution (%)") +
        ggplot2::scale_color_discrete(name = "Metamodel: ") + 
        ggplot2::scale_fill_discrete(name = "Metamodel: ") +
        ggplot2::theme(legend.position="bottom",
                       legend.direction = "horizontal",
                       text = element_text(size = 20))
      
      filename = paste("./figures/saeade/convergence/convergence_SAEADE_vs_", metamodel, "_", as.character(prob), "_", as.character(nvar), ".pdf", sep="")
      ggplot2::ggsave(filename, plot=fig, width=10, height=7)
      
    }
  }
}
