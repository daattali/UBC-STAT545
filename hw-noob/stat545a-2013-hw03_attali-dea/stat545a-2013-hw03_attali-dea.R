# data aggregation

gDat <- read.delim("gapminderDataFiveYear.txt")
str(gDat)
library(plyr)


firstLastYears = subset(gDat, year == min(year) | year == max(year))
avgGdpContinent <- ddply(firstLastYears, ~ year + continent, summarize, gdp = mean(gdpPercap))
print(avgGdpContinent)


lifeExpMeans <- arrange(ddply(gDat, .(continent,year), summarize, mean0 = mean(lifeExp), mean15 = mean(lifeExp, trim = 0.15), meanDiff = abs(mean0 - mean15), percentDiff = round(meanDiff / mean0 * 100,2)), desc(percentDiff))
print(head(lifeExpMeans))


worldRelativePop <- ddply(gDat, .(continent, year),
  function(.data) {
    .data <- as.list(.data)
    .data['continentPop'] <- sum(.data$pop)
    .data['worldPop'] <- sum(subset(gDat, year == .data$year[1])[['pop']])
    .data['percent'] <- round(as.numeric(.data['continentPop'])/as.numeric(.data['worldPop'])*100,2) 
    quickdf(.data[c("continentPop","worldPop",'percent')])
  }
)
worldRelativePop <- arrange(worldRelativePop, year, desc(percent))
print(head(worldRelativePop))


years <- unique(gDat$year)
allCountries = levels(gDat$country)
resultCountries = vector(mode = "character")
for (iCountry in allCountries) {
  for (idxYear in seq(years)[-1]) {
    prevYear = years[idxYear - 1]
    curYear = years[idxYear]
    prevYearData = gDat[intersect(which(gDat$year == prevYear), which(gDat$country == iCountry)),]
    curYearData = gDat[intersect(which(gDat$year == curYear), which(gDat$country == iCountry)),]
    prevPop = prevYearData[['pop']]
    curPop = curYearData[['pop']]
    if(prevPop >= curPop) {
      resultCountries = append(resultCountries, iCountry)
      break
    }
  }
}
print(resultCountries)


# min/max GDP of all continents in wide format 
ddply(gDat, ~ continent, summarize, minGdpPercap = min(gdpPercap), maxGdpPercap = max(gdpPercap))

# min/max GDP of all continents in tall format
ddply(gDat, ~ continent, function(x) {
  gdpPercap <- range(x$gdpPercap)
  return(data.frame(gdpPercap, stat = c("min", "max")))
})

# life expectancy per continent per year (changing to ddply makes it less nice)
daply(gDat, ~ continent + year, summarize, medLifeExp = median(lifeExp))

# proportion of countries with low life expectancy
subset(
  ddply(gDat, ~ continent + year, function(x) {
    lowCount = sum(x$lifeExp <= 45)
    lowProp = lowCount / nrow(x)
    c(count = lowCount, prop = lowProp)
  })
  , count > 0)

# again, in wide format
daply(gDat, ~ continent + year, function(x) {
  jCount <- sum(x$lifeExp <= 45)
  jTotal <- nrow(x)
  jProp <- jCount / jTotal
  return(sprintf("%1.2f (%d/%d)", jProp, jCount, jTotal))
})

