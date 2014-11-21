library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)

DATA_DIR <- file.path("data")

getData <- function() {
	cDat <- read.table(file.path(DATA_DIR, "cancerData.csv"), sep = ",",
										 header = TRUE, row.names = NULL)
	
	cDatTypeOrder <- read.table(file.path(DATA_DIR,
																			"cancerData-order-cancerType.txt"),
																	header = FALSE, row.names = NULL, sep = ",")
	cDatTypeOrder <- cDatTypeOrder %>% first
	cDat <- cDat %>%
		mutate(cancerType = factor(cancerType, cDatTypeOrder))
}

getPlotCols <- function() {
	c22 <- c("dodgerblue2","#E31A1C", # red
					 "green4",
					 "#6A3D9A", # purple
					 "#FF7F00", # orange
					 "black","gold1",
					 "skyblue2","#FB9A99", # lt pink
					 "palegreen2",
					 "#CAB2D6", # lt purple
					 "#FDBF6F", # lt orange
					 "gray70", "khaki2", "maroon", "orchid1", "deeppink1", "blue1",
					 "darkturquoise", "green1", "yellow4", "brown")
	c22
}