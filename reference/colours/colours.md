Colours in R
======================


```r
gDat <- read.delim("gapminderDataFiveYear.txt")

# change plotting symbol to circle (store original settings in opar)
opar <- par(pch = 19)

# some code that might be needed to make settings work in knitr ```{r
# include = FALSE} knit_hooks$set(setPch = function(before, options, envir)
# { if(before) par(pch = 19) }) opts_chunk$set(setPch = TRUE) ```

# keep 8 random countries and sort by gdp
nC <- 8
set.seed(8)
countriesToKeep <- as.character(sample(levels(gDat$country), size = nC))
jDat <- droplevels(subset(gDat, country %in% countriesToKeep & year == 2007))
jDat <- jDat[order(jDat$gdpPercap), ]

jXlim <- c(min(jDat$gdpPercap), max(jDat$gdpPercap))
jYlim <- c(min(jDat$lifeExp), max(jDat$lifeExp))

head(colors())
```

```
## [1] "white"         "aliceblue"     "antiquewhite"  "antiquewhite1"
## [5] "antiquewhite2" "antiquewhite3"
```

```r

jColors <- c("chartreuse3", "#0087FF", "darkgoldenrod1", "peachpuff3", "mediumorchid2", 
    "turquoise3", "wheat4", "slategray2")
plot(lifeExp ~ gdpPercap, jDat, log = "x", xlim = jXlim, ylim = jYlim, main = "Start your engines ...", 
    col = jColors)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-11.png) 

```r

# can specify colour with integer (indexing into the current palette, which
# can be seen with 'palette()')
plot(lifeExp ~ gdpPercap, jDat, log = "x", xlim = jXlim, ylim = jYlim, col = 1:nC, 
    main = "the default palette()")
# add names of default palette
with(jDat, text(x = gdpPercap, y = lifeExp, labels = paste(1:nC, palette()), 
    pos = c(4, rep(1, 7))))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-12.png) 

```r

# using predefined color schemes - Brewer
library(RColorBrewer)
display.brewer.all()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-13.png) 

```r
display.brewer.pal(n = 8, name = "Dark2")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-14.png) 

```r

jBrewColors <- brewer.pal(n = 8, name = "Dark2")
plot(lifeExp ~ gdpPercap, jDat, log = "x", xlim = jXlim, ylim = jYlim, col = jBrewColors, 
    main = "Dark2 qualitative palette from RColorBrewer")
with(jDat, text(x = gdpPercap, y = lifeExp, labels = jBrewColors, pos = c(4, 
    rep(1, 7))))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-15.png) 

```r

# more builtin colour function: rgb(), col2rgb(), convertColor(),
# colorspace()

# create continent colours using match() create a data frame with a colour
# for each continent
(jColors <- with(jDat, data.frame(continent = levels(continent), color = I(brewer.pal(nlevels(continent), 
    name = "Dark2")))))
```

```
##   continent   color
## 1  Americas #1B9E77
## 2      Asia #D95F02
## 3    Europe #7570B3
```

```r
data.frame(subset(jDat, select = c(country, continent)), matchRetVal = match(jDat$continent, 
    jColors$continent))
```

```
##          country continent matchRetVal
## 480  El Salvador  Americas           1
## 360   Costa Rica  Americas           1
## 1344      Serbia    Europe           3
## 1188      Panama  Americas           1
## 1512      Taiwan      Asia           2
## 540       France    Europe           3
## 804        Japan      Asia           2
## 1092 Netherlands    Europe           3
```

```r

plot(lifeExp ~ gdpPercap, jDat, log = "x", xlim = jXlim, ylim = jYlim, col = jColors$color[match(jDat$continent, 
    jColors$continent)], main = "custom color scheme based on Dark2", cex = 2)
legend(x = "bottomright", legend = as.character(jColors$continent), col = jColors$color, 
    pch = par("pch"), bty = "n", xjust = 1)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-16.png) 

```r

# create continent colours using merge()
(jDatColor <- merge(jDat, jColors))
```

```
##   continent     country year       pop lifeExp gdpPercap   color
## 1  Americas El Salvador 2007   6939688   71.88      5728 #1B9E77
## 2  Americas  Costa Rica 2007   4133884   78.78      9645 #1B9E77
## 3  Americas      Panama 2007   3242173   75.54      9809 #1B9E77
## 4      Asia      Taiwan 2007  23174294   78.40     28718 #D95F02
## 5      Asia       Japan 2007 127467972   82.60     31656 #D95F02
## 6    Europe      Serbia 2007  10150265   74.00      9787 #7570B3
## 7    Europe      France 2007  61083916   80.66     30470 #7570B3
## 8    Europe Netherlands 2007  16570613   79.76     36798 #7570B3
```

```r
plot(lifeExp ~ gdpPercap, jDatColor, log = "x", xlim = jXlim, ylim = jYlim, 
    col = color, main = "custom color scheme based on Dark2", cex = 2)
legend(x = "bottomright", legend = as.character(jColors$continent), col = jColors$color, 
    pch = par("pch"), bty = "n", xjust = 1)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-17.png) 

```r


# reset the settings
par(opar)


# LATTICE
library(lattice)

# drop oceania
jDat <- droplevels(subset(gDat, continent != "Oceania"))

# inspect lattice settings
show.settings()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-18.png) 

```r
str(trellis.par.get(), max.level = 1)
```

```
## List of 35
##  $ grid.pars        : list()
##  $ fontsize         :List of 2
##  $ background       :List of 2
##  $ panel.background :List of 1
##  $ clip             :List of 2
##  $ add.line         :List of 4
##  $ add.text         :List of 5
##  $ plot.polygon     :List of 5
##  $ box.dot          :List of 5
##  $ box.rectangle    :List of 5
##  $ box.umbrella     :List of 4
##  $ dot.line         :List of 4
##  $ dot.symbol       :List of 5
##  $ plot.line        :List of 4
##  $ plot.symbol      :List of 6
##  $ reference.line   :List of 4
##  $ strip.background :List of 2
##  $ strip.shingle    :List of 2
##  $ strip.border     :List of 4
##  $ superpose.line   :List of 4
##  $ superpose.symbol :List of 6
##  $ superpose.polygon:List of 5
##  $ regions          :List of 2
##  $ shade.colors     :List of 2
##  $ axis.line        :List of 4
##  $ axis.text        :List of 5
##  $ axis.components  :List of 4
##  $ layout.heights   :List of 19
##  $ layout.widths    :List of 15
##  $ box.3d           :List of 4
##  $ par.xlab.text    :List of 5
##  $ par.ylab.text    :List of 5
##  $ par.zlab.text    :List of 5
##  $ par.main.text    :List of 5
##  $ par.sub.text     :List of 5
```

```r
str(trellis.par.get("superpose.symbol"))
```

```
## List of 6
##  $ alpha: num [1:7] 1 1 1 1 1 1 1
##  $ cex  : num [1:7] 0.8 0.8 0.8 0.8 0.8 0.8 0.8
##  $ col  : chr [1:7] "#0080ff" "#ff00ff" "darkgreen" "#ff0000" ...
##  $ fill : chr [1:7] "#CCFFFF" "#FFCCFF" "#CCFFCC" "#FFE5CC" ...
##  $ font : num [1:7] 1 1 1 1 1 1 1
##  $ pch  : num [1:7] 1 1 1 1 1 1 1
```

```r

# change plot points symbol, size, colour
xyplot(lifeExp ~ gdpPercap | continent, jDat, group = country, subset = year == 
    2007, scales = list(x = list(log = 10, equispaced.log = FALSE)), par.settings = list(superpose.symbol = list(pch = 19, 
    cex = 1.5, col = c("orange", "blue"))))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-19.png) 

```r

# use predefined set of colours
countryColors <- read.delim(file = "gapminderCountryColors.txt", as.is = 3)
str(countryColors)
```

```
## 'data.frame':	142 obs. of  3 variables:
##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ country  : Factor w/ 142 levels "Afghanistan",..: 95 39 43 28 118 121 127 69 86 3 ...
##  $ color    : chr  "#7F3B08" "#833D07" "#873F07" "#8B4107" ...
```

```r
countryColors <- countryColors[match(levels(jDat$country), countryColors$country), 
    ]
str(countryColors)
```

```
## 'data.frame':	140 obs. of  3 variables:
##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 4 1 1 2 4 3 3 4 1 ...
##  $ country  : Factor w/ 142 levels "Afghanistan",..: 1 2 3 4 5 7 8 9 10 11 ...
##  $ color    : chr  "#874D96" "#D2ECB1" "#A34F06" "#C96C0C" ...
```

```r
xyplot(lifeExp ~ gdpPercap | continent, jDat, group = country, subset = year == 
    2007, scales = list(x = list(log = 10, equispaced.log = FALSE)), par.settings = list(superpose.symbol = list(pch = 19, 
    cex = 1, col = countryColors$color)))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-110.png) 

```r

# storing graphical parameters for reuse
(continentColors <- read.delim(file = "gapminderContinentColors.txt", as.is = 3))
```

```
##   continent nCountries   color
## 1    Africa         52 #7F3B08
## 2  Americas         25 #A50026
## 3      Asia         33 #40004B
## 4    Europe         30 #276419
## 5   Oceania          2 #313695
```

```r
(continentColors <- continentColors[match(levels(jDat$continent), continentColors$continent), 
    ])
```

```
##   continent nCountries   color
## 1    Africa         52 #7F3B08
## 2  Americas         25 #A50026
## 3      Asia         33 #40004B
## 4    Europe         30 #276419
```

```r
coolNewPars <- list(superpose.symbol = list(pch = 21, cex = 2, col = "gray20", 
    fill = continentColors$color))
xyplot(lifeExp ~ gdpPercap, jDat, subset = year == 2007, scales = list(x = list(log = 10, 
    equispaced.log = FALSE)), group = continent, auto.key = list(columns = 4), 
    par.settings = coolNewPars)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-111.png) 

```r

# change the actual lattice theme (and restore later)
otp <- trellis.par.get()  # store the original theme
trellis.par.set(superpose.symbol = list(pch = 19, cex = 1, col = countryColors$color))
xyplot(lifeExp ~ gdpPercap | continent, jDat, group = country, subset = year == 
    2007, scales = list(x = list(log = 10, equispaced.log = FALSE)))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-112.png) 

```r
trellis.par.set(otp)


# GGPLOT2
library(ggplot2)

jDat <- droplevels(subset(gDat, continent != "Oceania"))

jYear <- 2007
q <- ggplot(subset(jDat, year == jYear), aes(x = gdpPercap, y = lifeExp)) + 
    scale_x_log10()
q + geom_point(pch = 21, size = 8, fill = "darkorchid1")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-113.png) 

```r
q + geom_point(aes(size = sqrt(pop/pi)), pch = 21)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-114.png) 

```r
(r <- q + geom_point(aes(size = sqrt(pop/pi)), pch = 21, show_guide = FALSE) + 
    scale_size_continuous(range = c(1, 40)))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-115.png) 

```r
(r <- r + facet_wrap(~continent))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-116.png) 

```r
r + aes(fill = continent)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-117.png) 

```r

countryColors <- read.delim(file = "gapminderCountryColors.txt", as.is = 3)
jColors <- countryColors$color
names(jColors) <- countryColors$country
r + aes(fill = country) + scale_fill_manual(values = jColors)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-118.png) 

```r

# again, but unhide small countries by reordering rows based on population
jDat <- jDat[with(jDat, order(year, -1 * pop)), ]
ggplot(subset(jDat, year == jYear), aes(x = gdpPercap, y = lifeExp)) + scale_x_log10() + 
    geom_point(aes(size = sqrt(pop/pi)), pch = 21, show_guide = FALSE) + scale_size_continuous(range = c(1, 
    40)) + facet_wrap(~continent) + aes(fill = country) + scale_fill_manual(values = jColors)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-119.png) 

