# ==============================================================================
# Clear workspace

rm(list = ls())


# ==============================================================================
# Install dependencies

dependencies.list <- c(
  "dplyr",
  "xtable"
)

dependencies.missing <- dependencies.list[!(dependencies.list %in% installed.packages()[,"Package"])]
if (length(dependencies.missing) > 0) {
  install.packages(dependencies.missing)
}


# ==============================================================================
# Load libraries

suppressMessages(library(dplyr))
suppressMessages(library(xtable))


# ==============================================================================
# Read data from files

# Read data file
data.results <- read.csv("./data/metamodels.csv", header = TRUE)

# Remove repeated and problems and umbalanced data
data.results <- data.results %>%
  dplyr::filter(!(PROB %in% c('schwefel', 'trid', 'sumsqu'))) %>%
  dplyr::filter(!(PROB == 'zakharov' & NVAR == 20 & REP == 4))

data.results$PROB <- factor(data.results$PROB, unique(data.results$PROB))

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


# ===========================================================================
# Tables: Improvement in objective function

# Pre-process data
aggdata <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::filter(ITER == max(ITER)) %>%
  dplyr::group_by(PROB, NVAR, METAMODEL) %>%
  dplyr::summarise(MEAN.IMPROV.OBJ = mean(IMPROV.OBJ), 
                   STD.IMPROV.OBJ = sd(IMPROV.OBJ)) %>%
  dplyr::arrange(PROB, NVAR, METAMODEL)

table.results <- with(aggdata,
                      cbind(PROB     = aggdata$PROB[aggdata$METAMODEL == "OK"],
                            NVAR     = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK.MEAN  = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "OK"],
                            OK.STD   = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "OK"],
                            UK1.MEAN = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "UK1"],
                            UK1.STD  = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "UK1"],
                            UK2.MEAN = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "UK2"],
                            UK2.STD  = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "UK2"],
                            BK.MEAN  = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "BK"],
                            BK.STD   = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "BK"],
                            RBF.MEAN = aggdata$MEAN.IMPROV.OBJ[aggdata$METAMODEL == "RBF"],
                            RBF.STD = aggdata$STD.IMPROV.OBJ[aggdata$METAMODEL == "RBF"]))

xtable(table.results, digits = c(0,0,0,4,4,4,4,4,4,4,4,4,4))


# ===========================================================================
# Tables: Metamodel building time

# Pre-process data
aggdata <- data.results %>%
  dplyr::group_by(PROB, NVAR, METAMODEL, REP) %>%
  dplyr::summarise(BUILD.TIME = mean(METAMODEL.TIME.S)) %>%
  dplyr::group_by(PROB, NVAR, METAMODEL) %>%
  dplyr::summarise(MEAN.TIME = mean(BUILD.TIME),
                   STD.TIME = sd(BUILD.TIME)) %>%
  dplyr::arrange(PROB, NVAR, METAMODEL)

table.results <- with(aggdata,
                      cbind(PROB     = aggdata$PROB[aggdata$METAMODEL == "OK"],
                            NVAR     = aggdata$NVAR[aggdata$METAMODEL == "OK"],
                            OK.MEAN  = aggdata$MEAN.TIME[aggdata$METAMODEL == "OK"],
                            OK.STD   = aggdata$STD.TIME[aggdata$METAMODEL == "OK"],
                            UK1.MEAN = aggdata$MEAN.TIME[aggdata$METAMODEL == "UK1"],
                            UK1.STD  = aggdata$STD.TIME[aggdata$METAMODEL == "UK1"],
                            UK2.MEAN = aggdata$MEAN.TIME[aggdata$METAMODEL == "UK2"],
                            UK2.STD  = aggdata$STD.TIME[aggdata$METAMODEL == "UK2"],
                            BK.MEAN  = aggdata$MEAN.TIME[aggdata$METAMODEL == "BK"],
                            BK.STD   = aggdata$STD.TIME[aggdata$METAMODEL == "BK"],
                            RBF.MEAN = aggdata$MEAN.TIME[aggdata$METAMODEL == "RBF"],
                            RBF.STD  = aggdata$STD.TIME[aggdata$METAMODEL == "RBF"]))

xtable(table.results, digits = c(0,0,0,4,4,4,4,4,4,4,4,4,4))
