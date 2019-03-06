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
# Read data from files

# Read data file
data.results <- read.csv("./data/metamodels.csv", header = TRUE)

# Change metamodel names
metamodel.factors <- list(OK  = "ordinary-kriging",
                          UK1 = "universal-kriging1", 
                          UK2 = "universal-kriging2",
                          BK  = "blind-kriging",
                          RBF = "rbf-gaussian")

levels(data.results$METAMODEL) <- metamodel.factors

# Compute objective function improvement
data.results <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::mutate(IMPROV.OBJ = 100 * ((max(BEST.OBJ) - BEST.OBJ) / max(BEST.OBJ))) %>%
  dplyr::ungroup()

# Remove repeated and problems with error
data.results <- data.results %>%
  dplyr::filter(!(PROB %in% c('schwefel', 'trid', 'sumsqu')))

data.results$PROB <- factor(data.results$PROB, unique(data.results$PROB))


# ==============================================================================
# Blox-plot

# Function used to group data
classify <- Vectorize(function(data) {
  result <- factor(levels = c("25%", "50%", "75%", "100%"), ordered = TRUE)
  if (data <= 0.25) {
    result <- "25%"
  } else if (data <= 0.50) {
    result <- "50%"
  } else if (data <= 0.75) {
    result <- "75%"
  } else {
    result <- "100%"
  }
  return(result)
}, vectorize.args = c("data"))

# Pre-process data
aggdata <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::mutate(PROGRESS = NEVAL / max(NEVAL),
                GROUP = classify(PROGRESS)) %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP, GROUP) %>%
  dplyr::filter(PROGRESS == max(PROGRESS))

# Plot data
for (prob in unique(aggdata$PROB)) {
  for (nvar in unique(aggdata$NVAR)) {
    fig <- ggplot2::ggplot(subset(subset(aggdata, PROB==prob), NVAR==nvar), 
                           ggplot2::aes(x=GROUP, y=IMPROV.OBJ, fill=METAMODEL)) +
      ggplot2::geom_boxplot() + 
      ggplot2::xlab("Function evalutions (%)") +
      ggplot2::ylab("Improv. over the best initial solution (%)") +
      ggplot2::scale_x_discrete(limits = c("25%", "50%", "75%", "100%")) +
      ggplot2::scale_fill_discrete(name = "Metamodel: ") +
      ggplot2::theme(legend.position = "bottom",
                     legend.direction = "horizontal",
                     text = element_text(size = 24))
    
    filename = paste("./figures/boxplot/boxplot_", as.character(prob), "_", as.character(nvar), ".pdf", sep="")
    ggplot2::ggsave(filename, plot=fig, width=10, height=7)
  }
}


# ==============================================================================
# Crossbar

# Pre-process data
aggdata <- data.results %>%
  
  # Normalized metamodel building time
  dplyr::group_by(PROB, NVAR, REP, METAMODEL) %>%
  dplyr::mutate(BUILD.TIME = mean(METAMODEL.TIME.S)) %>%
  dplyr::group_by(PROB, NVAR, REP) %>%
  dplyr::mutate(NORM.TIME = BUILD.TIME / max(BUILD.TIME)) %>%

  # Keep data from the last iteration
  dplyr::group_by(PROB, NVAR, REP, METAMODEL) %>%
  dplyr::filter(ITER == max(ITER)) %>%
  
  # Summarise results
  dplyr::group_by(METAMODEL) %>%
  dplyr::summarise(MEAN.IMPROV = mean(IMPROV.OBJ),
                   SE.IMPROV = sd(IMPROV.OBJ) / sqrt(n()),
                   MEAN.TIME = mean(NORM.TIME),
                   SE.TIME = sd(NORM.TIME) / sqrt(n()))

# Plot data
fig <- ggplot2::ggplot(aggdata,
                       ggplot2::aes(x    = MEAN.TIME,
                                    xmin = MEAN.TIME - SE.TIME,
                                    xmax = MEAN.TIME + SE.TIME,
                                    y    = MEAN.IMPROV, 
                                    ymin = MEAN.IMPROV - SE.IMPROV, 
                                    ymax = MEAN.IMPROV + SE.IMPROV,
                                    colour = METAMODEL)) +
  ggplot2::geom_point(shape = 22, size = 3) +
  ggplot2::geom_errorbarh(height = 0, size = 0.75) +
  ggplot2::geom_errorbar(width = 0, size = 0.75) +
  ggplot2::xlab("Model building runtime (normalized)") +
  ggplot2::ylab("Mean improv. over the best initial solution (%)") +
  ggplot2::scale_color_discrete(name = "Metamodel: ") +
  ggplot2::theme(legend.position="bottom",
                 legend.direction = "horizontal",
                 text = element_text(size = 20))

filename = "./figures/crossbar.pdf"
ggplot2::ggsave(filename, plot=fig, width=10, height=7)


# ==============================================================================
# Paired t-test (Bonferroni-corrected)

# Pre-process data
aggdata <- data.results %>%
  
  # Normalized metamodel building time
  dplyr::group_by(PROB, NVAR, REP, METAMODEL) %>%
  dplyr::mutate(BUILD.TIME = mean(METAMODEL.TIME.S)) %>%
  dplyr::group_by(PROB, NVAR, REP) %>%
  dplyr::mutate(NORM.TIME = BUILD.TIME / max(BUILD.TIME)) %>%
  
  # Keep data from the last iteration
  dplyr::group_by(PROB, NVAR, REP, METAMODEL) %>%
  dplyr::filter(ITER == max(ITER))

# Significance level (Bonferroni-corrected)
metamodels <- unique(aggdata$METAMODEL)
n.tests <- (length(metamodels) * (length(metamodels) - 1)) / 2
alpha <- 0.05 / n.tests

# Initialize structures to save results
results.improv <- data.frame(COMPARISON = character(0), 
                             ESTIMATE = numeric(),
                             CI.LB = numeric(),
                             CI.UB = numeric(),
                             P.VALUE = numeric(),
                             stringsAsFactors = FALSE)

results.time <- data.frame(COMPARISON = character(0), 
                           ESTIMATE = numeric(),
                           CI.LB = numeric(),
                           CI.UB = numeric(),
                           P.VALUE = numeric(),
                           stringsAsFactors = FALSE)

idx <- 1
for (idx1 in c(1:(length(metamodels)-1))) {
  for (idx2 in c((idx1 + 1):length(metamodels))) {
    
    mm1 <- metamodels[idx1]
    data.mm1 <- dplyr::filter(aggdata, METAMODEL == mm1)
    
    mm2 <- metamodels[idx2]
    data.mm2 <- dplyr::filter(aggdata, METAMODEL == mm2)
    
    # Improvement
    resp <- t.test(data.mm1$IMPROV.OBJ, data.mm2$IMPROV.OBJ,
                   alternative = "two.sided",
                   mu = 0,
                   paired = TRUE, 
                   var.equal = FALSE,
                   conf.level = 1.0 - alpha)
    
    comparison <- paste(mm1, "vs", mm2)
    p.value <- resp$p.value
    estimate <- resp$estimate
    ci.lb <- resp$conf.int[1]
    ci.ub <- resp$conf.int[2]
    
    results.improv[idx,] <- list(comparison, estimate, ci.lb, ci.ub, p.value)
    
    # Building time
    resp <- t.test(data.mm1$NORM.TIME, data.mm2$NORM.TIME,
                   alternative = "two.sided",
                   mu = 0,
                   paired = TRUE,
                   var.equal = FALSE,
                   conf.level = 1.0 - alpha)
    
    comparison <- paste(mm1, "vs", mm2)
    p.value <- resp$p.value
    estimate <- resp$estimate
    ci.lb <- resp$conf.int[1]
    ci.ub <- resp$conf.int[2]
    
    results.time[idx,] <- list(comparison, estimate, ci.lb, ci.ub, p.value)
    
    # Increment counter
    idx <- idx + 1
  }
}

# Plot of confidence intervals (improvement)
results.improv$COMPARISON <- as.factor(results.improv$COMPARISON)
fig <- ggplot2::ggplot(results.improv, 
                       ggplot2::aes(x = COMPARISON, y = ESTIMATE, ymin = CI.LB, ymax = CI.UB)) +
  ggplot2::geom_hline(yintercept = 0, size = 1.3, col = 2, linetype = 2) +
  ggplot2::geom_pointrange(fatten = 2, size = 1.3) +
  ggplot2::coord_flip() +
  ggplot2::xlab("Comparison") +
  ggplot2::ylab("Mean difference in percentage improvement") +
  ggplot2::theme(text = element_text(size = 24),
                 legend.position = "none",
                 panel.background = ggplot2::element_blank(),
                 panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1))

filename = "./figures/ci-improv.pdf"
ggplot2::ggsave(filename, plot=fig, width=10, height=7)

# Plot (time)
results.time$COMPARISON <- as.factor(results.time$COMPARISON)
fig <- ggplot2::ggplot(results.time, 
                       ggplot2::aes(x = COMPARISON, y = ESTIMATE, ymin = CI.LB, ymax = CI.UB)) +
  ggplot2::geom_hline(yintercept = 0, size = 1.3, col = 2, linetype = 2) +
  ggplot2::geom_pointrange(fatten = 2, size = 1.3) +
  ggplot2::coord_flip() +
  ggplot2::xlab("Comparison") +
  ggplot2::ylab("Mean difference in normalized building time") +
  ggplot2::theme(text = element_text(size = 24),
                 legend.position = "none",
                 panel.background = ggplot2::element_blank(),
                 panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1))

filename = "./figures/ci-time.pdf"
ggplot2::ggsave(filename, plot=fig, width=10, height=7)


# ==============================================================================
# Convergence

# Join data from DE-best algorithm
mm.results <- read.csv("./data/metamodels.csv", header = TRUE, stringsAsFactors = FALSE)
de.results <- read.csv("./data/de.csv", header = TRUE, stringsAsFactors = FALSE)

de.results["MEAN.DIFF"] = numeric()
de.results["METAMODEL.TIME.S"] = numeric()
de.results["TOTAL.TIME.S"] = numeric()

aggdata <- union(mm.results, de.results)

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

# Remove repeated and problems with error
aggdata <- aggdata %>%
  dplyr::filter(!(PROB %in% c('schwefel', 'trid', 'sumsqu')))

aggdata$PROB <- factor(aggdata$PROB, unique(aggdata$PROB))

# Process data
aggdata <- aggdata %>%
  dplyr::group_by(PROB, NVAR, REP) %>%
  dplyr::mutate(REF.BEST.OBJ = max(BEST.OBJ), 
                REF.NEVAL = max(NEVAL)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(NORM.NEVAL = 100 * (NEVAL / REF.NEVAL)) %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, NORM.NEVAL) %>%
  dplyr::summarise(MEAN.IMPROV.OBJ = mean(IMPROV.OBJ), 
                   SE.IMPROV.OBJ = sd(IMPROV.OBJ) / sqrt(n()))

# Plot data
for (prob in unique(aggdata$PROB)) {

  fig <- ggplot2::ggplot(subset(aggdata, PROB == prob),
                         ggplot2::aes(x    = NORM.NEVAL, 
                                      y    = MEAN.IMPROV.OBJ, 
                                      ymin = MEAN.IMPROV.OBJ - SE.IMPROV.OBJ, 
                                      ymax = MEAN.IMPROV.OBJ + SE.IMPROV.OBJ, 
                                      color = METAMODEL, 
                                      fill = METAMODEL)) +
    ggplot2::geom_line(size=1.7) +
    #ggplot2::geom_ribbon(alpha=0.5) + 
    ggplot2::facet_wrap(~NVAR, scales = "fixed",
                        ncol = 1, nrow = length(unique(aggdata$NVAR))) +
    ggplot2::xlab("Function evaluations (%)") +
    ggplot2::ylab("Mean improv. over the best initial solution (%)") +
    ggplot2::scale_color_discrete(name = "Metamodel: ") + 
    ggplot2::scale_fill_discrete(name = "Metamodel: ") +
    ggplot2::theme(legend.position="bottom",
                   legend.direction = "horizontal",
                   text = element_text(size = 24))
  
  filename = paste("./figures/convergence-by-problem/convergence_", as.character(prob), ".pdf", sep="")
  ggplot2::ggsave(filename, plot=fig, width=10, height=25)
  
  
  for (nvar in unique(aggdata$NVAR)) {
    
    fig <- ggplot2::ggplot(subset(subset(aggdata, PROB == prob), NVAR == nvar),
                           ggplot2::aes(x    = NORM.NEVAL, 
                                        y    = MEAN.IMPROV.OBJ, 
                                        ymin = MEAN.IMPROV.OBJ - SE.IMPROV.OBJ, 
                                        ymax = MEAN.IMPROV.OBJ + SE.IMPROV.OBJ, 
                                        color = METAMODEL, 
                                        fill = METAMODEL)) +
      ggplot2::geom_line(size=1.7) +
      #ggplot2::geom_ribbon(alpha=0.5) + 
      ggplot2::xlab("Function evaluations (%)") +
      ggplot2::ylab("Mean improv. over the best initial solution (%)") +
      ggplot2::scale_color_discrete(name = "Metamodel: ") + 
      ggplot2::scale_fill_discrete(name = "Metamodel: ") +
      ggplot2::theme(legend.position="bottom",
                     legend.direction = "horizontal",
                     text = element_text(size = 20))
    
    filename = paste("./figures/convergence/convergence_", as.character(prob), "_", as.character(nvar), ".pdf", sep="")
    ggplot2::ggsave(filename, plot=fig, width=10, height=7)
    
  }
}


# ===========================================================================
# Tables: Improvement in objective function

# Pre-process data
aggdata <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::filter(ITER == max(ITER)) %>%
  dplyr::group_by(NVAR, METAMODEL) %>%
  dplyr::summarise(MEAN.IMPROV.OBJ = mean(IMPROV.OBJ), 
                   STD.IMPROV.OBJ = sd(IMPROV.OBJ))

# Mean
table.results <- with(aggdata,
                      cbind(NVAR = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "OK"],
                            UK1 = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "UK1"],
                            UK2 = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "UK2"],
                            BK = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "BK"],
                            RBF = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "RBF"]))
xtable(table.results, digits = c(6,0,4,4,4,4,4))

# Standard deviation
table.results <- with(aggdata,
                      cbind(NVAR = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "OK"],
                            UK1 = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "UK1"],
                            UK2 = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "UK2"],
                            BK = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "BK"],
                            RBF = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "RBF"]))
xtable(table.results, digits = c(6,0,4,4,4,4,4))


# ===========================================================================
# Tables: Metamodel building time

# Pre-process data
aggdata <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::summarise(BUILD.TIME = mean(METAMODEL.TIME.S)) %>%
  dplyr::group_by(NVAR, METAMODEL) %>%
  dplyr::summarise(MEAN.TIME = mean(BUILD.TIME),
                   STD.TIME = sd(BUILD.TIME))

# Mean time
table.results <- with(aggdata,
                      cbind(NVAR = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK = aggdata$MEAN.TIME[aggdata$METAMODEL == "OK"],
                            UK1 = aggdata$MEAN.TIME[aggdata$METAMODEL == "UK1"],
                            UK2 = aggdata$MEAN.TIME[aggdata$METAMODEL == "UK2"],
                            BK = aggdata$MEAN.TIME[aggdata$METAMODEL == "BK"],
                            RBF = aggdata$MEAN.TIME[aggdata$METAMODEL == "RBF"]))
xtable(table.results, digits = c(6,0,4,4,4,4,4))

# Std time
table.results <- with(aggdata,
                      cbind(NVAR = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK = aggdata$STD.TIME[aggdata$METAMODEL == "OK"],
                            UK1 = aggdata$STD.TIME[aggdata$METAMODEL == "UK1"],
                            UK2 = aggdata$STD.TIME[aggdata$METAMODEL == "UK2"],
                            BK = aggdata$STD.TIME[aggdata$METAMODEL == "BK"],
                            RBF = aggdata$STD.TIME[aggdata$METAMODEL == "RBF"]))
xtable(table.results, digits = c(6,0,4,4,4,4,4))
