# This script contains some common R code that is shared among the different scripts.
# It defines some common helper functions and variables that are used often.

if( exists("terrorismLoaded") ) {
  # if this script already ran, just revert the data object to its original processed form
  dat <- origDat
} else {
  
  # since this is a shared script, have a flag so that this is once ran once
  # (there's probably a more correct R way to do this but I don't know it)
  terrorismLoaded <- TRUE
  
  # make sure we have the necessary libraries loaded
  library(plyr)           # mainly for ddply
  library(ggplot2)
  library(RColorBrewer)
  
  # read the data
  dat <- read.table("globalterrorismdb_clean.csv", header = TRUE, sep = ',')
  
  # in many plyr functions I will add a column for a simple count or sum,
  # so instead of repeating that little piece of code every time, just make them functions
  plyrFxCount <- function(x, name="count") {
    df <- data.frame( nrow(x) )
    colnames(df)[1] <- name
    return(df)
  }
  plyrFxSum <- function(x, toSum, name="sum") {
    df <- data.frame( sum(x[toSum]) )
    colnames(df)[1] <- name
    return(df)
  }
  
  # reorder region levels by total number of attacks in each region
  regionAttackOrder = order(table(dat$region), decreasing=TRUE)
  regionAttackLevels = names(table(dat$region))[regionAttackOrder]
  dat$region <- factor(dat$region, levels = regionAttackLevels)
  
  regions = levels(dat$region)
  
  # create a color palette for the 12 regions. Sequential Brewer palettes only have 9 colours,
  # so add a few manually (also remove their yellow and gray because they're hard to see)
  regionCol <- c(brewer.pal(9, name="Set1")[c(-6, -9)], '#EEC900', '#00CED1','#7FFF00','#E9967A', '#2F4F4F')
  
  # reorder attack types by total number of attacks per type
  attackTypeOrder = order(table(dat$attacktype), decreasing=TRUE)
  attackTypeLevels = names(table(dat$attacktype))[attackTypeOrder]
  dat$attacktype <- factor(dat$attacktype, levels = attackTypeLevels)
  
  # we also need a colour palette for attack type, we'll just slice from the region colour palette
  attacktypeCol <- regionCol[1:length(levels(dat$attacktype))]
  
  # keep a reference to this version of the processed data, so that if some script changes it,
  # a subsequent script will get a fresh copy
  origDat <- dat
  
  # the results directory
  resultsDir <- 'results/'
}