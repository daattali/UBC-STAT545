## In this script, we will do some analysis on global terrorist with the use of geographical maps

source('common.R')

# load the maps data
library(maps)
library(mapdata)
data(world.cities)

library(fBasics)  # for making a colour palette

# First thing I would like to see is where the most dangerous cities are
# One tiny thing that makes this a little tricky is that we can't straight up use a city
# count because there are cities with the same name in different countries, and we don't
# want to combine them. But running ddply to count the attacks in every city per country
# seems to take a very long time. So instead, do a compromise: first list all the city names
# that had <100 attacks, and then grab only those cities from the data. The data will now
# contain many cities with lots of attacks, but also some cities who just happen to share
# names with unfortunate cities, but at least now the dataset is much smaller so
# running ddply is instantaneous.
cities <- table(dat$city)
cities <- sort(cities[cities > 100], decreasing = TRUE)
cities <- cities[-which(names(cities) == 'Unknown')]  ## remove the 'Unknown' city
cityNames <- names(cities)
datcities <- subset(dat, city %in% cityNames)
cityAttacks <- ddply(datcities, country~city, plyrFxCount, "totAttacks")
# grab the top 20 cities with most terrorist attacks
topNcities <- 20
cityAttacks <- head(arrange(cityAttacks, totAttacks, decreasing = TRUE), n=topNcities)

# Before mapping these cities, let's take a look at who they are
print(cityAttacks)
write.table(cityAttacks, paste0(resultsDir, "citiesMostAttacked.txt"), quote = FALSE, sep = "\t",
            col.names = TRUE, row.names = FALSE)
# Once again, Iraq tops the list :(  Baghdad is by far the most terror-attacked city in the world

# To find the cities on a map, we need to merge data with the "world.cities" dataset. But the names
# of the cities don't always match (world.cities tries to be clever and use non-English names), so
# we need to do some manual conversion of city names so that the merging will work properly
cityNameMapping <- c(Bayrut = "Beirut", "Guatemala" = "Guatemala City", "al-Mawsil" = "Mosul")
world.cities <- within(world.cities,
                       name <- revalue(name, cityNameMapping))
cityAttacksFullInfo <- merge(cityAttacks, world.cities,
                             by.x = c('country', 'city'),
                             by.y = c('country.etc', 'name'))
# we also need to manually add Belfast, because in world.cities its under UK whereas the GTD has it
# as Norhtern Ireland
belfast <- cbind(cityAttacks[cityAttacks$city == 'Belfast', ],
                 world.cities[world.cities$name=='Belfast' & world.cities$country.etc == 'UK', ])
belfast$capital <- 1  # world.cities considers only considers London to be a capital in the UK
cityAttacksFullInfo <- rbind(cityAttacksFullInfo,
                             subset(belfast, select = -c(country.etc, name)))

# Now we have all the data we need, but just one last thing:
# We will make a red colour palette where every city will get matches
# with a successively more intense red, where super red (almost brown) = most attacks
cityAttacksFullInfo <- arrange(cityAttacksFullInfo, totAttacks)
cityHeatColorRank <- seqPalette(nrow(cityAttacksFullInfo), name = "Reds")
cityAttacksFullInfo$col <- cityHeatColorRank
# Note that the list is sorted with the most attacks LAST, so that cities with a higher
# red intensity (more attacks) will get drawn on top of other cities

# alright, no more data cleaning. Time to map!
map('worldHires',fill = TRUE, col = '#FCFCFC')
points(x = cityAttacksFullInfo$long,
       y = cityAttacksFullInfo$lat, 
       col = 'black', pch = 21, cex = 2,
       bg = cityAttacksFullInfo$col)
title(paste('Top', topNcities, 'Most Terror-Attacked Cities'))
dev.print(png, paste0(resultsDir, "mapTop", topNcities, "DangerousCities.png"),
          width = 500, height = 300)
dev.off()

# The darkest spot, in the middle east, is Baghdad, and the other fairly dark
# spot in the region (at the North-West corner of Europe) is Belfast. The rest
# of the high intensity reds are mostly in Central/South America, and the lower ones are in Europe.
# There is also a lone point in Southeast Asia, in Manila (Philippines)

# Before continuing, one thing that I noticed when looking at the names of those 20 cities
# is that I recognize a lot of them as big/capital cities.  Just out of curiosity, let's
# plot exactly how many of those top 20 are actually the capital city of their countries
capitalCounts <- table(cityAttacksFullInfo$capital)
names(capitalCounts) <- c('Non-Capital', 'Capital City')
capitalCounts <- as.data.frame(capitalCounts)
capitalCounts$Var1 <- factor(capitalCounts$Var1, levels = rev(levels(capitalCounts$Var1)))
ggplot(capitalCounts, aes(x = Var1, y = Freq, fill = Var1)) +
  geom_bar(stat = "identity", width=0.5, show_guide = FALSE) +
  ggtitle(paste('Distribution of Capital Cities in Top', topNcities,
                'Most Terror-Attacked Cities')) +
  xlab('') +
  ylab(paste('# of Cities in Top', topNcities)) +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor.y = element_blank()) +
  scale_fill_manual(values = c('cyan3', 'turquoise'))
ggsave(paste0(resultsDir, "capitalsAttacked.png"))
dev.off()  

# Wow, 15 out of the 20 most terror filled cities are indeed capital cities.
# Looks like terrorists really choose cities of high impact (duh..)

# Next I would like to plot the intensity of how dangerous each world region is recently
# We will look at data since year 2000 (inclusive), and shade each region with an intensity
# of red. Unlike with the cities, where the intensities were divided into 20 uniform intervals,
# now I want to actually see how the regions compare in absolute terms, so the colour intensities
# will be given according to how many attacks happened, not just according to the region's rank.
dangerYear <- 2000
regionDanger <- ddply(subset(dat, year >= dangerYear), ~ region, plyrFxCount, "tot")
heatColors <- seqPalette(max(regionDanger$tot), name = "Reds")
regionDanger$col <- heatColors[regionDanger$tot]

# we have the data, now map it!
# note that since we are using names from the GTD and trying to use them on the "mapdata" data,
# we do need to perform a few little hacks.
#  - mapdata only knows about a country named 'USSR'
#  - mapdata spells 'United States' as 'USA'
#  - GTD does not have Greenland (maybe it's under Denmark?) and because of that, when shading
#    the map, there is a huge unshaded area there, so I manually add Greenland to Europe
map('worldHires')
for(i in 1:nrow(regionDanger)){
  regionCountries <- subset(dat, region == regionDanger[i,'region'])$country
  regionCountries <- as.character(unique(regionCountries))
  
  # the little hackings we need to do just to get the map to look nice...
  if (regionDanger[i, 'region'] == 'USSR') {
    regionCountries <- 'USSR'
  } else if (regionDanger[i, 'region'] == 'North America') {
    regionCountries <- c(regionCountries, 'USA')
  } else if (regionDanger[i, 'region'] == 'Western Europe') {
    regionCountries <- c(regionCountries, 'Greenland')
  }

  map('worldHires',
      regions = regionCountries,
      add = TRUE,
      col = regionDanger[i, 'col'], 
      fill = TRUE)
}
title('Heatmap of Terrorist Attacks\nin World Regions Since 2000')
dev.print(png, paste0(resultsDir, "mapRegionIntensities.png"), width = 500, height = 330)
dev.off()

# This shows pretty clearly how the Middle East and South Asia are so
# much worse off in terms of terrorism than the rest of the world. The
# only good thing to take from this map is that at least terrorists
# didn't get to Anteractica yet! Although Oceania, East Asia, and North
# America also seem fairly safe since 2000.