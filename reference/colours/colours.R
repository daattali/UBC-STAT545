gDat <- read.delim(file.path("data", "gapminderDataFiveYear.txt"))

# change plotting symbol to circle (store original settings in opar)
opar <- par(pch = 19)

# keep 8 random countries and sort by gdp
nC <- 8
set.seed(8)
countriesToKeep <- as.character(sample(levels(gDat$country), size = nC))
jDat <- droplevels(subset(gDat, country %in% countriesToKeep & year == 2007))
jDat <- jDat[order(jDat$gdpPercap), ]

jXlim <- c(min(jDat$gdpPercap), max(jDat$gdpPercap))
jYlim <- c(min(jDat$lifeExp), max(jDat$lifeExp))

head(colors())

jColors <- c('chartreuse3', '#0087FF', 'darkgoldenrod1', 'peachpuff3',
             'mediumorchid2', 'turquoise3', 'wheat4', 'slategray2')
plot(lifeExp ~ gdpPercap, jDat, log = 'x', xlim = jXlim, ylim = jYlim,
     main = "Start your engines ...", col = jColors)

# can specify colour with integer (indexing into the current palette, which can be seen with 'palette()')
plot(lifeExp ~ gdpPercap, jDat, log = 'x', xlim = jXlim, ylim = jYlim,
     col = 1:nC, main = 'the default palette()')
# add names of default palette
with(jDat, text(x = gdpPercap, y = lifeExp, labels = paste(1:nC, palette()), pos = c(4, rep(1,7))))

# using predefined color schemes - Brewer
library(RColorBrewer)
display.brewer.all()
display.brewer.pal(n = 8, name = 'Dark2')

jBrewColors <- brewer.pal(n = 8, name = "Dark2")
plot(lifeExp ~ gdpPercap, jDat, log = 'x', xlim = jXlim, ylim = jYlim,
     col = jBrewColors, main = 'Dark2 qualitative palette from RColorBrewer')
with(jDat, text(x = gdpPercap, y = lifeExp, labels = jBrewColors,
                pos = c(4, rep(1,7))))

# more builtin colour function: rgb(), col2rgb(), convertColor(), colorspace()

# create continent colours using match()
# create a data frame with a colour for each continent
(jColors <-
   with(jDat,
        data.frame(continent = levels(continent),
                   color = I(brewer.pal(nlevels(continent), name = 'Dark2')))))
data.frame(subset(jDat, select = c(country, continent)),
           matchRetVal = match(jDat$continent, jColors$continent))

plot(lifeExp ~ gdpPercap, jDat, log = 'x', xlim = jXlim, ylim = jYlim,
     col = jColors$color[match(jDat$continent, jColors$continent)],
     main = 'custom color scheme based on Dark2', cex = 2)
legend(x = 'bottomright', 
       legend = as.character(jColors$continent),
       col = jColors$color, pch = par("pch"), bty = 'n', xjust = 1)

# create continent colours using merge()
(jDatColor <- merge(jDat, jColors))
plot(lifeExp ~ gdpPercap, jDatColor, log = 'x', xlim = jXlim, ylim = jYlim,
     col = color,
     main = 'custom color scheme based on Dark2', cex = 2)
legend(x = 'bottomright', 
       legend = as.character(jColors$continent),
       col = jColors$color, pch = par("pch"), bty = 'n', xjust = 1)


# reset the settings
par(opar)


# LATTICE
library(lattice)

# drop oceania
jDat <- droplevels(subset(gDat, continent != "Oceania"))

# inspect lattice settings
show.settings()
str(trellis.par.get(), max.level = 1)
str(trellis.par.get("superpose.symbol"))

# change plot points symbol, size, colour
xyplot(lifeExp ~ gdpPercap | continent, jDat,
       group = country, subset = year == 2007,
       scales = list(x = list(log = 10, equispaced.log = FALSE)),
       par.settings = list(superpose.symbol = list(pch = 19, cex = 1.5,
                                                   col = c("orange", "blue"))))

# use predefined set of colours
countryColors <- read.delim(file = file.path("data", "gapminderCountryColors.txt"), as.is = 3)
str(countryColors)
countryColors <- countryColors[match(levels(jDat$country), countryColors$country), ]
str(countryColors)
xyplot(lifeExp ~ gdpPercap | continent, jDat,
       group = country, subset = year == 2007,
       scales = list(x = list(log = 10, equispaced.log = FALSE)),
       par.settings = list(superpose.symbol = list(pch = 19, cex = 1,
                                                   col = countryColors$color)))

# storing graphical parameters for reuse
(continentColors <- read.delim(file = file.path("data", "gapminderContinentColors.txt"), as.is = 3))
(continentColors <- continentColors[match(levels(jDat$continent), continentColors$continent), ])
coolNewPars <-list(superpose.symbol = list(
  pch = 21, cex = 2, col = "gray20", fill = continentColors$color))
xyplot(lifeExp ~ gdpPercap, jDat,
       subset = year == 2007,
       scales = list(x = list(log = 10, equispaced.log = FALSE)),
       group = continent, auto.key = list(columns = 4),
       par.settings = coolNewPars)

# change the actual lattice theme (and restore later)
otp <- trellis.par.get() # store the original theme
trellis.par.set(superpose.symbol = list(
  pch = 19, cex = 1, col = countryColors$color))
xyplot(lifeExp ~ gdpPercap | continent, jDat,
       group = country, subset = year == 2007,
       scales = list(x = list(log = 10, equispaced.log = FALSE)))
trellis.par.set(otp)


# GGPLOT2
library(ggplot2)

jDat <- droplevels(subset(gDat, continent != "Oceania"))

jYear <- 2007
q <- ggplot(subset(jDat, year == jYear),
            aes(x = gdpPercap, y = lifeExp)) + scale_x_log10()
q + geom_point(pch = 21, size = 8, fill = "darkorchid1")
q + geom_point(aes(size = sqrt(pop/pi)), pch = 21)
(r <- q +
   geom_point(aes(size = sqrt(pop/pi)), pch = 21, show_guide = FALSE) +
   scale_size_continuous(range=c(1,40)))
(r <- r + facet_wrap(~ continent))
r + aes(fill = continent)

countryColors <- read.delim(file = file.path("data", "gapminderCountryColors.txt"), as.is = 3)
jColors <- countryColors$color
names(jColors) <- countryColors$country
r + aes(fill = country) + scale_fill_manual(values = jColors)

# again, but unhide small countries by reordering rows based on population
jDat <- jDat[with(jDat, order(year, -1 * pop)), ]
ggplot(subset(jDat, year == jYear),
       aes(x = gdpPercap, y = lifeExp)) + scale_x_log10() +
  geom_point(aes(size = sqrt(pop/pi)), pch = 21, show_guide = FALSE) +
  scale_size_continuous(range=c(1,40)) +
  facet_wrap(~ continent) +
  aes(fill = country) + scale_fill_manual(values = jColors)