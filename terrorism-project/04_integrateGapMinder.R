## In this script, we integrate the terrorism data with country information from
## the GapMinder data to see if there are any interesting patterns to do with gdp per capita

source('common.R')

# read the gap minder data
gDat <- read.delim("gapminderDataFiveYear.txt")

# we're mostly interested in the GDP of the countries at just one timepoint,
# so keep a subset of gapminder data with only the latest year
gDatLast <- subset(gDat, year == max(year))

# In a different script, we looked at which countries had the most terrorist attacks. Another way
# to look at that could be to see which countries had the most attacks relatively to how big the country is.
# For example, if two countries have the sme number of terrorism acts, but one country has 100x the population
# of the other, then that could be seen as valuable information. To find this, we first merge data with GapMinder
# to find the population of each country at the last time that GapMinder has data for (2007), and divide the
# population by the number of attacks in that country. We then see who the top countries are.
countryAttacks <- ddply(dat, ~ country + region, plyrFxCount, "totAttacks")
countryAttacks <- merge(countryAttacks,
                        subset(gDatLast, select = c('country', 'pop')),
                        by.x = 'country',
                        by.y = 'country')
countryAttacks$popPerAttack <- round(countryAttacks$pop / countryAttacks$totAttacks)
countryAttacks <- arrange(countryAttacks, popPerAttack)
print(head(countryAttacks, n = 5))
write.table(countryAttacks, paste0(resultsDir, "countriesMostAttacksPerPop.txt"),
            quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

# Iraq seems to be the only country that is both in the top 10 most attacked and top 10 most
# attacked per population. We see that all these countries are either in the Middle East or
# South America.

# Now let's see if there's any correlation between a country's GDP and its terrorism history
countryAttacksGapMinder <-
  merge(countryAttacks,
  gDatLast,
  by.x = c('country'),
  by.y = c('country'))
ggplot(countryAttacksGapMinder, aes(x = gdpPercap, y = totAttacks, color = region)) +
  geom_point() +
  geom_point(aes(cex = 1.5), show_guide = FALSE) +  # little hack necessary to now show cex in legend
  xlab("GDP / Capita") + 
  ggtitle("Terrorist Attacks Since 1970 vs GDP of Attacked Country") + 
  ylab("# of Attacks") +
  scale_color_manual(name = 'Region', values = regionCol)
ggsave(paste0(resultsDir, 'numAttacksVsGDP.png'))
dev.off()

# This plot reveals, perhaps as we would have expected, that the countries with the most
# terrorist attacks are usually poorer countries. We can see that there are perhaps two
# outliers here, I would say that the two dots above 2000 attacks that are the the richer
# side seem to be outliers, so let's see which coutries those are.
print(subset(countryAttacksGapMinder, totAttacks > 2000 & gdpPercap > 27000))
# It looks like the US and Spain have a fairly high number of terror acts compared to
# other countries with a similarly high GDP.

# Next, I'd like to see the 100 deadliest terror attacks worldwide, and again see
# the correlation with GDP (since most attacks happen in poorer countriest, it is
# statistically expected to see more deadly attacks there as well)
mostNdeadly <- 100
deadliest <- head(arrange(dat, desc(nkill)), n = mostNdeadly)
deadliest <- merge(deadliest,
                   subset(gDatLast, select = c('country', 'gdpPercap')))
ggplot(deadliest, aes(x = gdpPercap, y = nkill, color = attacktype)) +
  geom_point() +
  geom_point(aes(cex = 1.5), show_guide = FALSE) +
  xlab("GDP / Capita") + 
  ggtitle(paste(mostNdeadly, "Most Deadly Terrorist Attacks vs. GDP of Attacked Country")) + 
  ylab("# Killed in Attack") +
  scale_color_manual(name = "Attack Type", values = attacktypeCol)
ggsave(paste0(resultsDir, 'deadliest100AttacksVsGDP.png'))
dev.off()

# Looking at this plot, we see (as suspected) that most of the 100 deadliest attacks were in poorer countries.
# It seems like with the exception of 4 attacks, the rest are all in countries with a lower GDP/cap than 15000.
# The few clear intereting outliers here are the two hijackings  and two bombings/explosions that we see
# on the right at 2 rich countries, and the single armed assault with over 1000 fatalities.
# Let's try to take a look at what attacks these were
print(subset(deadliest, nkill > 1000 | gdpPercap > 35000))
write.table(subset(deadliest, nkill > 1000 | gdpPercap > 35000),
            paste0(resultsDir, "deadliestAttacksOutliers.txt"),
            quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
# Let's look at these one by one:
# First, the single outlier among the poor counties is Rwanda.
# This is part of the Rwandan genocide from 1994. I'm not sure why this specific point is there,
# but the other 100,000s of people killed in that time are not in the data.
# Looking at the other 4 points, we realize they are actually 5 rows -- not 4 -- but two of them
# are the exactly same point and therefore are hiding each other. These 5 rows are only 3 separate events though.
# Three Of these come form 9/11 - the two towers are represented as two events, and the crash into the
# Pentagon is the the third one.  Looking at the actual data, we see that the authors of the database
# chose to take a reported number of casualties from the two towers and simply divide it by 2 to assign
# each tower an equal number of people. This is probably why the number of people killed is a fraction
# (1381.5).
# The other attack was also in the US, it's the Oklahoma City Bombing.
# The last very deadly attack in a developed country comes from Canada, and it is the 1985 Air India flight
# bombing. This is the largest mass murder in Canadian history.