Beautiful GDP vs Year
============================


```r
kDat <- read.delim("gapminderWithColorsAndSorted.txt", as.is = 7)  # protect colour
library(lattice)
str(kDat)
```

```
## 'data.frame':	1704 obs. of  7 variables:
##  $ country  : Factor w/ 142 levels "Afghanistan",..: 25 59 135 67 60 48 15 134 65 9 ...
##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 2 3 3 4 2 4 4 3 ...
##  $ year     : int  1952 1952 1952 1952 1952 1952 1952 1952 1952 1952 ...
##  $ pop      : num  5.56e+08 3.72e+08 1.58e+08 8.65e+07 8.21e+07 ...
##  $ lifeExp  : num  44 37.4 68.4 63 37.5 ...
##  $ gdpPercap: num  400 547 13990 3217 750 ...
##  $ color    : chr  "#40004B" "#460552" "#A50026" "#611A6D" ...
```

```r
jYear <- c(1952, 2007)
yDat <- subset(kDat, year %in% jYear)
str(yDat)
```

```
## 'data.frame':	284 obs. of  7 variables:
##  $ country  : Factor w/ 142 levels "Afghanistan",..: 25 59 135 67 60 48 15 134 65 9 ...
##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 2 3 3 4 2 4 4 3 ...
##  $ year     : int  1952 1952 1952 1952 1952 1952 1952 1952 1952 1952 ...
##  $ pop      : num  5.56e+08 3.72e+08 1.58e+08 8.65e+07 8.21e+07 ...
##  $ lifeExp  : num  44 37.4 68.4 63 37.5 ...
##  $ gdpPercap: num  400 547 13990 3217 750 ...
##  $ color    : chr  "#40004B" "#460552" "#A50026" "#611A6D" ...
```

```r

# start with simple scatterplot of gdp (log scale) vs year by continent
xyplot(lifeExp ~ gdpPercap | factor(year), yDat, aspect = 2/3, grid = TRUE, 
    scales = list(x = list(log = 10, equispaced.log = FALSE)))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-11.png) 

```r
# now add the panel function, no change seen xyplot(lifeExp ~ gdpPercap |
# factor(year), yDat, aspect = 2/3, grid = TRUE, scales = list(x = list(log
# = 10, equispaced.log = FALSE), panel = function(...) { panel.xyplot(...)
# }))

# again no change, adding x,y into the panel function xyplot(lifeExp ~
# gdpPercap | factor(year), yDat, aspect = 2/3, grid = TRUE, scales = list(x
# = list(log = 10, equispaced.log = FALSE), panel = function(x, y, ...) {
# panel.xyplot(x, y, ...)  }))

# getting more advanced: sizing each coutry by relative to its population
jCexDivisor <- 1500  # arbitrary scaling constant
jPch <- 21
xyplot(lifeExp ~ gdpPercap | factor(year), yDat, aspect = 2/3, grid = TRUE, 
    scales = list(x = list(log = 10, equispaced.log = FALSE)), cex = sqrt(yDat$pop/pi)/jCexDivisor, 
    panel = function(x, y, ..., cex, subscripts) {
        panel.xyplot(x, y, cex = cex[subscripts], pch = jPch, ...)
    })
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-12.png) 

```r

# getting beautiful: assigning each country a colour
jDarkGray <- "grey20"
xyplot(lifeExp ~ gdpPercap | factor(year), yDat, aspect = 2/3, grid = TRUE, 
    scales = list(x = list(log = 10, equispaced.log = FALSE)), cex = sqrt(yDat$pop/pi)/jCexDivisor, 
    fill.color = yDat$color, col = jDarkGray, panel = function(x, y, ..., cex, 
        fill.color, subscripts) {
        panel.xyplot(x, y, cex = cex[subscripts], pch = jPch, fill = fill.color[subscripts], 
            ...)
    })
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-13.png) 

```r

# adding a legend (key)
continentColors <- read.delim("gapminderContinentColors.txt", as.is = 3)  # protect colour
continentKey <- with(continentColors, list(x = 0.95, y = 0.05, corner = c(1, 
    0), text = list(as.character(continent)), points = list(pch = jPch, col = jDarkGray, 
    fill = color)))
xyplot(lifeExp ~ gdpPercap | factor(year), yDat, aspect = 2/3, grid = TRUE, 
    scales = list(x = list(log = 10, equispaced.log = FALSE)), cex = sqrt(yDat$pop/pi)/jCexDivisor, 
    fill.color = yDat$color, col = jDarkGray, key = continentKey, panel = function(x, 
        y, ..., cex, fill.color, subscripts) {
        panel.xyplot(x, y, cex = cex[subscripts], pch = jPch, fill = fill.color[subscripts], 
            ...)
    }, layout = c(1, 2))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-14.png) 


