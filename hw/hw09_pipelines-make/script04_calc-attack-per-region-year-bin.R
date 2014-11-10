library(plyr)
library(dplyr)

# read clean data
dat <- read.table("globalterrorismdb_clean.csv", header = TRUE, sep = ',')

# calculate the number of attacks in each region per year
regionYearAttacks <-
	dat %>%
	group_by(region, year) %>%
	summarize(nattacks = n())

# fix a little "problem" (well, a good problem), where some regions have years with 0 attacks
# this will cause some missing points in the plots which doesn't look nice, so we will
# just add a value of 0 for every region/year pair that doesn't exist
regionYearPossibilities <- merge(levels(dat$region), unique(dat$year))
regionYearAttacks <-
	regionYearAttacks %>%
	merge(regionYearPossibilities,
			  by.x = c('region', 'year'), by.y = c("x", "y"), all.y = TRUE)
regionYearAttacks$nattacks[is.na(regionYearAttacks$nattacks)] <- 0

# group the years into 5-year buckets, and see the different regions at each time frame
yearBucketSize <- 5
breaks <- seq(from = min(regionYearAttacks$year),
							to = max(regionYearAttacks$year),
							by = yearBucketSize)
bins <- cut(regionYearAttacks$year,
						breaks = breaks,
						include.lowest = TRUE,
						right = FALSE)
regionYearAttacks$bin <- bins

# since our buckets are 5-year intervals, data from 2011 did not fit into a bucket
# and will be discarded
regionYearAttacks <- regionYearAttacks[complete.cases(regionYearAttacks), ]

# create a dataframe where the data is binned by 5 years
attackByRegion5YearBin <-
	regionYearAttacks %>%
	group_by(region, bin) %>%
	summarise(nattacks = sum(nattacks))

# save the data
write.table(attackByRegion5YearBin, "attackByRegion5YearBin.csv", sep = ",", col.names = TRUE,
						row.names = FALSE, quote = TRUE)

# also save the order of region levels based on the total number of attacks
# (to make graphing it look nicer)
regionOrder <-
	attackByRegion5YearBin %>%
	group_by(region) %>%
	summarise(nattacks = sum(nattacks)) %>%
	arrange(nattacks) %>%
	dplyr::select(region) %>%
	first %>%
	rev
write.table(regionOrder, "attackByRegion5YearBin-regionOrder.txt", col.names = FALSE,
						row.names = FALSE, quote = TRUE)
