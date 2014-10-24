## clean all output from previous runs of scripts
## there is one final we create in the main directory (the processed dataset),
## but the rest of the output is all in the 'results' directory
outputs <- c("globalterrorismdb_clean.csv")
file.remove(outputs)
unlink("results", recursive = TRUE)

# now re-create the results directory
dir.create(file.path("results"), showWarnings = FALSE)

# script 0 only has to be run once on a machine, it simply installs all required packages
#source("00_installPackages.R")

## run all scripts
source("01_preprocessData.R")   ## can take up to a minute to run because of reading a big dataset
source("02_analysisPlots.R")    ## analyse global terrorism using plots
source("03_analysisMaps.R")     ## show terrorism on a world map
source("04_integrateGapMinder.R")  ## analyse terrorism vs GDP
source("05_israel.R")           ## terrorism in Israel