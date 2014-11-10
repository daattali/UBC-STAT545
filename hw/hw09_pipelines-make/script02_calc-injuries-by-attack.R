library(plyr)
library(dplyr)
library(tidyr)

# read clean data
dat <- read.table("globalterrorismdb_clean.csv", header = TRUE, sep = ',')

# add up all the number of people wounded/killed by each attack type over the years globally
injuryByAttack <-
	dat %>%
	group_by(attacktype) %>%
	summarize(nkill = round(sum(nkill)),
						nwound = round(sum(nwound)))

# tidy up the data into long form
injuryByAttack <-
	injuryByAttack %>%
	gather(stat, value, nkill, nwound)

# save the data
write.table(injuryByAttack, "injuryByAttack.csv", sep = ",", col.names = TRUE,
						row.names = FALSE, quote = TRUE)

# also save the order of attack type levels based on number of people killed
# (to make graphing it look nicer)
attackTypeOrder <-
	injuryByAttack %>%
	filter(stat == "nkill") %>%
	arrange(value) %>%
	dplyr::select(attacktype) %>%
	first %>%
	rev
write.table(attackTypeOrder, "attackTypeOrder.txt", col.names = FALSE,
						row.names = FALSE, quote = TRUE)
