# In this script, we explore some data about terrorism in Israel
# It is mostly a copy of a previous assignment, but I included it here for completeness

source('common.R')

# keep only information from Israel
israelDat <- subset(dat, country == 'Israel')

library(reshape)  # for melt

# reorder the levels of the attacktype factor according to which attack type was most frequent
attackTypeOrder = order(table(israelDat$attacktype), decreasing = TRUE)
attackTypeLevels = names(table(israelDat$attacktype))[attackTypeOrder]
israelDat$attacktype <- factor(israelDat$attacktype, levels = attackTypeLevels)
# make a pie chart of frequency of attack
ggplot(israelDat, aes(x = "", fill = attacktype)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y") +
  scale_fill_brewer("Attack Type", type = "qual", palette = 6) +
  ggtitle("Terrorist attacks in Israel since 1970") +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), panel.background = element_blank())
ggsave(paste0(resultsDir, 'israelAttacktypePie.png'))
dev.off()

# we can see bombings are by far the #1 most common attack, with armed assault
# and assassinations as the only significant runner ups
# Another important thing to look at is which attacks caused the most casualties.
# We can use plyr to calcuate the number of people killed/injured each year per attack type
attackDamage <- ddply(israelDat, ~year + attacktype,
                      summarize,
                      killed = sum(nkill, na.rm = TRUE),
                      wounded = sum(nwound, na.rm = TRUE))
ggplot(attackDamage, aes(x = year, y = killed, fill = attacktype)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(type = "qual", palette = 6) +
  ggtitle("Deaths in Israel by attack type") + xlab("Year") + ylab("Number killed") +
  theme(panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank())
ggsave(paste0(resultsDir, 'israelDeadAttacktypeYear.png'))
dev.off()

# we can see that bombings indeed killed the most people (although it seems like
# there were a few big deadly hostage situations in the 70's)
# Now let's look at data only from suicide bombings, comparing number of wounded and killed over time
bombingDamage <- subset(attackDamage, attacktype == 'Bombing/Explosion')
bombingDamage <- melt(data = bombingDamage, id.vars = c('year', 'attacktype'))
ggplot(bombingDamage, aes(x = year, y = value, color = variable)) +
  geom_line() +
  scale_x_continuous(name = "Year", breaks = seq(min(israelDat$year), max(israelDat$year), by = 5)) +
  ggtitle("Deaths and wounded by suicide bombings in Israel") + 
  ylab("Number of people") +
  scale_color_manual("Injury Type", values = c("black", "red")) +
  guides(color = guide_legend(reverse = TRUE)) +
  geom_point() +
  theme(panel.grid.minor.x = element_blank())
ggsave(paste0(resultsDir, 'israelBombingCasualties.png'))
dev.off()

# we can see that there was a huge escalation in the early 2000's, right when my dad decided to leave

# the last thing I want to look at is how many bombings happened in the city where I grew up,
# while I was growing up there
# We compute for every year how many bombings happened in Tel Aviv vs the rest of the country
israelBombings <- subset(israelDat, attacktype == 'Bombing/Explosion')
israelBombings <- droplevels(israelBombings)
myYearsBombings <- subset(israelBombings, year %in% seq(1988, 2002))
myYearsBombings <- myYearsBombings[,c('year','city')]
myYearsBombings <- droplevels(myYearsBombings)
myYearsBombings$inTA <- ifelse(myYearsBombings$city == 'Tel Aviv', 'Tel Aviv', 'Rest of Israel')

ggplot(myYearsBombings, aes(x = year, fill = inTA)) +
  geom_bar(binwidth = 1, color = "darkgrey", origin = min(myYearsBombings$year) - 0.5, position = "identity") +
  scale_x_continuous(name = "Year", breaks = seq(1988, 2002, by = 1)) +
  theme(axis.text.x = element_text(angle = 90)) +
  scale_fill_brewer("Location", type = "qual", palette = 3) +
  ylab("Number of bombings") +
  ggtitle("Sucide bombings in Israel between 1988-2002") +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor.x = element_blank())
ggsave(paste0(resultsDir, 'israelTelAvivBombings.png'))
dev.off()

# Just as a side note, 1993 was NOT some magical year of peace. All data from 1993
# was lost and not recovered by the providers of this dataset