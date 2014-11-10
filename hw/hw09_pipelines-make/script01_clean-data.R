library(plyr)

# read the raw input
dat <- read.csv("globalterrorismdb.csv", header = TRUE, na.strings = c("", "."))

# only keep the relevant columns that we are going to use
columnsKeep <- c("iyear", "imonth", "iday", "country_txt", "region_txt", "city",
								 "attacktype1_txt", "nkill", "nwound")
dat <- dat[columnsKeep]

# rename some columns
dat <- rename(dat, c("iyear" = "year", "imonth" = "month", "iday" = "day",
										 "country_txt" = "country", "region_txt" = "region", "attacktype1_txt" = "attacktype"))

# rename some factor levels
dat <- within(dat, attacktype <- revalue(attacktype,
																				 c("Hostage Taking (Kidnapping)" = "Hostage (Kidnapping)",
																				 	"Facility/Infrastructure Attack" = "Facility Attack",
																				 	"Hostage Taking (Barricade Incident)" = "Hostage (Barricade)"
																				 )))
dat <- within(dat, region <- revalue(region,
																		 c("Australasia & Oceania" = "Oceania",
																		 	"Central America & Caribbean" = "Central America",
																		 	"Middle East & North Africa" = "Middle East"
																		 )))

# replace NA values for number of killed/wounded with 0
# this isn't necessary always a smart thing to do, but it makes sense for the purposes of this analysis
dat$nkill[is.na(dat$nkill)] <- 0
dat$nwound[is.na(dat$nwound)] <- 0

# convert all post-USSR countries to USSR
levels(dat$region) <- c(levels(dat$region), 'USSR')
dat$region[dat$region == 'Central Asia'] <- 'USSR'
dat$region[dat$region == 'Russia & the Newly Independent States (NIS)'] <- 'USSR'
dat <- droplevels(dat)

# save the processed data frame, which happens to be exactly 10% of the original size
# note that we omit quotes to save file space, but keep them for cities because some
# city names contain commas
write.table(dat, "globalterrorismdb_clean.csv", sep=",", col.names=TRUE, row.names=FALSE,
						quote=which(colnames(dat) == 'city'))