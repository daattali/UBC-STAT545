## In this script, we will do some exploratory analysis on global terrorism using the
## global terrorism DB and ggplot2


source('common.R')

# Let's start with a very basic, yet upsetting, statistic in the data: the number of people
# wounded and killed by each attack type overall
attacktypeDamage <- ddply(dat, ~attacktype, function(x){
  df <- data.frame(c("nkill", "nwound"), c(sum(x$nkill), sum(x$nwound)));
  colnames(df)<-c("stat","value");
  return(df)
})

ggplot(attacktypeDamage, aes(x = attacktype, y = value, fill = stat)) +
  geom_bar(stat = "identity", position = position_dodge(width=0.9)) +
  coord_flip() +
  ggtitle("Number of People Wounded or Killed\nby Terrorist Attacks Since 1970") +
  xlab("") +
  ylab("# of People") +
  scale_fill_manual(name = "Injury Type", values = c("black", "red"), labels = c('Killed', 'Wounded')) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme(panel.grid.major.y = element_blank(),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'globalCasualtiesSince1970.png'))
dev.off()

# It is immediately visible that bombings and armed assaults are the attacks that have killed and injured
# the most people.  With bombings, there are far more people getting injured than dying, while with armed
# assault the fatalities are the highest.


## Now let's look at some region-level statistics

# let's get a quick overview of the regions, and see how many attacks happened in each 
regionTotal <- ddply(dat, ~region, plyrFxCount)
ggplot(regionTotal, aes(x = region, y = count, fill = region)) +
  geom_bar(stat="identity", show_guide=FALSE) +
  coord_flip() +
  ggtitle("Terrorist Attacks in World Regions Since 1970") +
  xlab("") +
  ylab("# of Attacks") +
  scale_fill_manual(values = regionCol) +
  theme(panel.grid.major.y = element_blank(),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'terrorismPerRegionTotal.png'))
dev.off()

# It looks like overall since 1970, there hasn't been one major region that suffered more
# than others. Every successvie region has less terror attacks than its previous, but the
# gap is never massive.
# Next we should zoom in and see what happens when we look at different years rather than combined history.


# calculate the number of attacks in each region per year
regionYear <- ddply(dat, region ~ year, plyrFxCount, "nattacks")

# fix a little "problem" (well, a good problem), where some regions have years with 0 attacks
# this will cause some missing points in the plots which doesn't look nice, so we will
# just add a value of 0 for every region/year pair that doesn't exist
regionYearPossibilities <- merge(regions, unique(dat$year))
regionYear <- merge(regionYear, regionYearPossibilities,
                    by.x = c('region','year'), by.y = c("x","y"), all.y = TRUE)
regionYear$nattacks[is.na(regionYear$nattacks)] <- 0

# let's look at the number of attacks per year in each world region
ggplot(regionYear, aes(x = year, y = nattacks, color = region)) +
  geom_line(show_guide=FALSE) +
  geom_point(show_guide=FALSE) +
  xlab("Year") + 
  ggtitle("Number of Terrorist Attacks in World Regions Since 1970") + 
  ylab("# of Attacks") +
  facet_wrap(~region) +
  scale_color_manual(values = regionCol) + 
  theme(strip.text = element_text(face="bold"),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'terrorismPerRegionYears.png'))
dev.off()

# This already reveals some interesting data.
# Central America seemed to be very unstable starting at the late 1970's and slowly getting better with time,
# until almost eliminating terrorist attacks before the new millenium.
# The Middle East and South Asia both had a surge in terrorist attacks since circa 2005, after both having relative
# quiet since the mid 90's.
# South America was was consistently pretty dangerous througout the 80's and 90's, and has calmed since.
# Western Europe is another region worth mentioning, that had many attacks up until the new millenium.
# The rest of the regions are worth glancing at, but are not as interesting.

# now let's look at the same plot, but with all the regions superposed
ggplot(regionYear, aes(x = year, y = nattacks, color = region)) +
  geom_line() +
  geom_point() +
  xlab("Year") + 
  ggtitle("Number of Terrorist Attacks in World Regions Since 1970") + 
  ylab("# of Attacks") +
  scale_color_manual(values = regionCol) + 
  theme(legend.justification = c(0,1), legend.position = c(0,1), legend.title = element_blank(),
        plot.title = element_text(face="bold")) +
  guides(col = guide_legend(ncol = 2))
ggsave(paste0(resultsDir, 'terrorismPerRegionYearsComb.png'))
dev.off()

# While this looks messy and a little harder to read, it is interesting to see global patterns.
# We can see that from the late 70's til the late 90's, many regions experienced higher terror attacks,
# and by 2000 most have achieved relative peace. Interestingly, the Middle East and South Asia (both of
# which also seemed to have much lower terrorist activity around the turn of the millenium) have both
# seen a sharp increase in the past decade.

# Another way to visualize this data would be to group the years into 5-year buckets,
# and see the different regions at each time frame
# To do this, we first create 5-year bins and append a bin to every observation
# This also results in the data having 9 bins, which is a nice number of panels to plot symmetrically :)
yearBucketSize <- 5
breaks <- seq(from = min(regionYear$year), to = max(regionYear$year), by = yearBucketSize)
bins <- cut(regionYear$year, breaks = breaks, include.lowest=TRUE, right=FALSE)
regionYear$bin <- bins

# since our buckets are 5-year intervals, data from 2011 did not fit into a bucket and will be discarded
regionYear <- regionYear[complete.cases(regionYear), ]

# now make a new data frame where the data is already grouped into 5-year bins
regionYearBin <- ddply(regionYear, region ~ bin, plyrFxSum, "nattacks", "nattacks")
ggplot(regionYearBin, aes(x = region, y = nattacks, fill = region)) +
  geom_bar(stat = "identity", show_guide=FALSE) +
  facet_wrap(~bin, ncol = 4) +
  ylab("# of Attacks") + 
  ggtitle("Number of Terrorist Attacks in World Regions\nin 5-Year Intervals Since 1970") + 
  xlab("") +
  coord_flip() +  # to make the bars horizontal so that reading the regions is easier
  scale_fill_manual(values = regionCol) +
  theme(panel.background = element_rect(fill='#EEEEEE'),
        panel.grid.major.y = element_blank(),
        strip.text = element_text(face="bold"),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'terrorismPerRegion5Year.png'))
dev.off()

# From this set of plots it is much clearer what the terrorist activity situation was at different
# regions at different time periods. Similar patterns emerge (which makes sense because we are looking
# at the same data), but it's even more clear now how bad South Asia and the Middle East are getting
# recently, and how Central America has improved drastically since the 1980's.
# We can also see how Oceania and East Asia are the "boring" observations once again, so if you're looking for
# a safe place, you know where to go.

# One interesting question that could be asked is whether there is much variation within the different
# regions, ie. are a few countries the cause of most terrorism in a region. Let's see!
countriesTotal <- ddply(dat, .(country, region), plyrFxCount, "nattacks")
ggplot(countriesTotal, aes(x = nattacks, y = region, color = region, cex = 1.7)) +
  geom_jitter(position = position_jitter(height = 0.4), show_guide=FALSE) +
  ggtitle("Variation in Number of Attacks in Different Countries\nWithin Each Region Since 1970") +
  xlab("# of Attacks") +
  ylab("") +
  scale_color_manual(values = regionCol) +
  theme(panel.grid.minor.x = element_blank(), panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "#EEEEEE"),
        panel.background = element_rect(fill = '#FCFCFC', colour = '#D3D3D3'),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'countryVariationPerRegion.png'))
dev.off()

# This does indeed show that ususually there are just a few countries where most of the terrorism
# happens, whereas most other countries in the region are safer. It would be interesting to see
# which countries are the ones that are hit the hardest.  By visual inspection, we can see that
# there are never more than 5 countries in a region that are extremely worse than the rest, so
# let's pick out the highest 5 per region. We'll also drop the 3 boring continents to make the
# resulting table a little bit easier to digest, and there isn't much useful information there.
boringRegions <- rev(levels(countriesTotal$region))[1:3]
countriesTotalSubset <- subset(countriesTotal, !(region %in% boringRegions))
topNcountries <- 5
topNcountriesRegion <-
  ddply(countriesTotalSubset, ~region, function(x) {
    x <- arrange(x, -nattacks)
    x <- head(x, n = topNcountries)
    return(x)
  })
# rearrange the columns to have the region first, easier to look at in table format  
topNcountriesRegion <- subset(topNcountriesRegion, select = c("region", "country", "nattacks"))
colnames(topNcountriesRegion) <- c('Region', 'Country', '# Attacks')
write.table(topNcountriesRegion, paste0(resultsDir, "countriesMostAttackedPerRegion.txt"),
            quote = FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)

# Ouch. Looks like Iraq is the unlucky country that attracted the most terrorism acts in the world.
# The rest of the Middle East isn't doing amazing, but noone is close to Iraq in that geographic area.
# In South Asia, India and Pakistan, and to a lesser extend Afghanistan and Sri Lanka, are the ones
# responsible for most of the terrorism.
# Colombia is the terror master of South America, and Peru also got a lot of suffering.
# In Western Europe, it is North Ireland and Spain that sustained most of the damage, while in
# Central America it is El Salvador.
# In Sub-Saharan Africa, South Africa is the country that has the most terrorism activities.
# The Philippines and Thailand are the two countries most prone to terror attacks in Southeast Asia,
# while in North America it is the United States.
# Lastly, out of all the Soviet Union countries, Russia seems to be the one that suffered the most
# from terrorism.

# Another possibly interesting piece of information to look at is what kinds of terror attacks
# are most common at each region
regionAttacktype <- ddply(dat, region ~ attacktype, plyrFxCount)
ggplot(regionAttacktype, aes(x = attacktype, y = count, fill = attacktype)) +
  geom_bar(stat="identity", show_guide=FALSE) +
  facet_wrap(~region) +
  coord_flip() +
  ggtitle("Terrorist Attack Types in World Regions Since 1970") +
  xlab("") +
  ylab("# of Attacks") +
  scale_fill_manual(values = attacktypeCol) +
  theme(panel.grid.major.y = element_blank(),
        strip.text = element_text(face="bold"),
        plot.title = element_text(face="bold"))
ggsave(paste0(resultsDir, 'attackTypesPerRegion.png'))
dev.off()

# These plots reveal a few interesting bits of information. Firstly, we can see that almost everywhere
# in the world bombings are the most common, followed by armed assaults and assassinations. Facility attacks
# and hostake kidnappings are the next most common attacks, while the rest are are very minimal. It is interesting
# to note that Central America is the only place where armed assault is more common than bombings, and that
# in Africa and Southeast Asia there are as many armed assaults as bombings.
# Another observation that stands out is the facility attacks in North America. where it is almost the most
# common form of terrorism, slightly less than bombings.

