DATA_DIR <- file.path("data")

#+ load-libs, include = F
library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(rsalad)

tolowerfirst <- function(x) {
	return(paste0(tolower(substring(x, 1, 1)), substring(x, 2)))
}

deathsDat <- tbl_df(
	read.table(file.path(DATA_DIR, "cancerDeathsUS.txt"), header = T))
dDatClean <- deathsDat
colnames(dDatClean) <- tolowerfirst(colnames(dDatClean))
dDatClean <- dDatClean %>%
	dplyr::select(leading.Cancer.Sites, year, deaths) %>%
	rename(cancerLocation = leading.Cancer.Sites)
dDatClean <- dDatClean %>%
	filter(cancerLocation != "All Sites Combined") %>%
	droplevels

casesDat <- tbl_df(
	read.table(file.path(DATA_DIR, "cancerIncidenceUS.txt"), header = T))
cDatClean <- casesDat
colnames(cDatClean) <- tolowerfirst(colnames(cDatClean))
cDatClean <- cDatClean %>%
	dplyr::select(leading.Cancer.Sites, year, count) %>%
	rename(cancerLocation = leading.Cancer.Sites,
				 cases = count)
cDatClean <- cDatClean %>%
	filter(cancerLocation != "All Sites Combined") %>%
	droplevels

cDatClean$cancerLocation <-
	cDatClean$cancerLocation %>%
	revalue(c("Urinary Bladder, invasive and in situ" = "Urinary Bladder"))

cancerData <- left_join(dDatClean, cDatClean, by = c("cancerLocation", "year"))

cancerLocationsOrder <- cancerData %>%
	filter(year == max(year)) %>%
	arrange(desc(cases)) %>%
	first %>%
	as.character
cancerData$cancerLocation <-
	factor(cancerData$cancerLocation, levels = cancerLocationsOrder)

popData <- tbl_df(read.csv(file.path(DATA_DIR, "worldPopByYear.csv")))
yearMin <- min(cancerData$year)
yearMax <- max(cancerData$year)
popDataClean <- popData %>%
	filter(Country.Code == "USA") %>%
	gather(year, population, starts_with("X")) %>%
	dplyr::select(year, population) %>%
	mutate(year = extract_numeric(year)) %>%
	filter(year %in% yearMin:yearMax)

cancerData <-
	cancerData %>%
	left_join(popDataClean, by = "year") %>%
	mutate(mortalityRate = deaths/cases,
				 deathsPerM = deaths / (population/1000000)) %>%
	dplyr::select(-population)

cancerData <- cancerData %>%
	gather(stat, value, -year, -cancerLocation) %>%
	arrange(year)




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
ggplot(cancerData, aes(x = as.factor(year), y = value, group = cancerLocation,
											 col = cancerLocation)) +
	facet_wrap(~stat, scales = "free_y") +
	geom_point() +
	geom_line() +
	theme_bw() +
	rotateTextX() +
	scale_color_manual(values = c22)
	

a <- cancerData %>% filter(year >= 2003 & year <= 2007) %>%
	filter(stat != "cases") %>%
	filter(cancerLocation %in% levels(cancerData$cancerLocation)[1:3])
ggplot(a, aes(x = as.factor(year), y = value, group = cancerLocation,
											 col = cancerLocation)) +
	facet_wrap(~stat, scales = "free_y", ncol = 2) +
	geom_point() +
	geom_line() +
	theme_bw() +
	rotateTextX() +
	scale_color_manual(values = c22)

# give option to change from long to wide table format

aCombined <- a %>% group_by(year, stat) %>%
	summarise(value =
							ifelse(stat[1] != "mortalityRate",
										 sum(value),
										 mean(value)))