# load required libraries
library(plyr)
library(lattice)

# read dataset
gDat <- read.delim("gapminderDataFiveYear.txt")

# quick 'n dirty check that nothing went horribly wrong with data import
str(gDat)

# drop Oceania because it has almost no data
nlevels(gDat$continent)
gDat <- droplevels(subset(gDat, continent != 'Oceania'))
nlevels(gDat$continent)

# ----- START of Rebecca's code - highest/lowest GDP per continent -----

# Write own function to produce a data frame in tall format
minmax <- function(x) {
  ## Make character vector to specify min and max
  factor = c("Min", "Max")
  ## Specify function to compute min and max (same order as line above)
  value = c(min(x$gdpPercap), max(x$gdpPercap))
  ## Make factor and value two columns in a data frame
  data.frame(factor, value)
}

# Use ddply to apply the function by continent
contMinMaxGdpTall <- ddply(gDat, ~continent, minmax)

# ----- END of Rebecca's code -----

# MY CODE - purely visual
barchart(value ~ reorder(continent, value) | factor, contMinMaxGdpTall,
         ylab = "GDP / cap",
         strip = strip.custom(factor.levels = c("Highest","Lowest")),
         main = "Highest and lowest GDP/capita per continent",
         col = "yellowgreen",
         border = "darkgreen"
)
numTicksFactor = 10000
numTicks = ceiling(max(contMinMaxGdpTall$value) / numTicksFactor)
highestGdpBarchart <- barchart(value ~ reorder(continent, value), contMinMaxGdpTall,
                               subset = (factor == 'Max'),
                               ylab = "GDP / cap",
                               ylim = c(0, numTicks * numTicksFactor),
                               scales = list(tick.number = numTicks),
                               panel = function(...){
                                 panel.barchart(...)
                                 #panel.grid = panel.grid(h = -(numTicks/2), v = FALSE)
                               },
                               col = "yellowgreen",
                               border="darkgreen",
                               main = "Highest GDP/capita per continent"
                      )
lowestGdpBarchart <- barchart(value ~ reorder(continent, value, min), contMinMaxGdpTall,
                              subset = (factor == 'Min'),
                              ylab = "GDP / cap",
                              col = "yellowgreen",
                              border="darkgreen",
                              main = "Lowest GDP/capita per continent"
                     )
plot(highestGdpBarchart, split = c(1, 1, 2, 1))
plot(lowestGdpBarchart, split = c(2, 1, 2, 1), newpage = FALSE)
bwplot(gdpPercap ~ continent, gDat, panel = panel.violin, col = "yellowgreen", border = "darkgreen",
       main = "GDP/capita spread in each continent")


# mean life expectancy per continent per year
contLifeExp <- ddply(gDat, continent ~ year, summarise, meanLifeExp = mean(lifeExp))
stripplot(meanLifeExp ~ reorder(continent, meanLifeExp), contLifeExp)
contLifeExp <- within(contLifeExp, continent <- reorder(continent,-meanLifeExp))
xyplot(meanLifeExp ~ year, contLifeExp,
       groups = continent,
       type = c("a", "p"),
       grid = "h",
       auto.key = list(lines = TRUE, points = FALSE, space = "right"),
       ylab = 'Mean life expectancy (years)',
       main = 'Mean life expectancy per continent'
)
  