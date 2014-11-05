ggplot2
========================================================

```r
gDat <- read.delim("gapminderDataFiveYear.txt")
str(gDat)
```

```
## 'data.frame':	1704 obs. of  6 variables:
##  $ country  : Factor w/ 142 levels "Afghanistan",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##  $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
##  $ continent: Factor w/ 5 levels "Africa","Americas",..: 3 3 3 3 3 3 3 3 3 3 ...
##  $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
##  $ gdpPercap: num  779 821 853 836 740 ...
```

```r

library(ggplot2)

ggplot(gDat, aes(x = gdpPercap, y = lifeExp))  # error!
```

```
## Error: No layers in plot
```

```r
p <- ggplot(gDat, aes(x = gdpPercap, y = lifeExp))  # just initializes
p + layer(geom = "point")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-11.png) 

```r
p + geom_point()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-12.png) 

```r

ggplot(gDat, aes(x = log10(gdpPercap), y = lifeExp)) + geom_point()  # the usual crappy axis tick marks that come from 'direct' log transform
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-13.png) 

```r
p + geom_point() + scale_x_log10()  # a bit better
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-14.png) 

```r
ggplot(gDat, aes(x = gdpPercap, y = lifeExp, color = continent)) + geom_point() + 
    scale_x_log10()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-15.png) 

```r
p + geom_point() + scale_x_log10() + aes(color = continent)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-16.png) 

```r
p + geom_point(size = 3) + scale_x_log10() + aes(color = continent, shape = continent)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-17.png) 

```r

ggplot(gDat, aes(x = gdpPercap, y = lifeExp)) + geom_point(alpha = (1/8)) + 
    scale_x_log10()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-18.png) 

```r

p + geom_point() + scale_x_log10() + aes(color = continent) + geom_smooth()
```

```
## geom_smooth: method="auto" and size of largest group is <1000, so using
## loess. Use 'method = x' to change the smoothing method.
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-19.png) 

```r
p + geom_point() + scale_x_log10() + aes(color = continent) + geom_smooth(method = "lm")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-110.png) 

```r

ggplot(subset(gDat, country == "Zimbabwe"), aes(x = year, y = lifeExp)) + geom_line() + 
    geom_point(shape = 3)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-111.png) 

```r

# stripplots of lifeExp by continent
ggplot(gDat, aes(x = continent, y = lifeExp)) + geom_point()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-112.png) 

```r
ggplot(gDat, aes(x = continent, y = lifeExp)) + geom_jitter(position = position_jitter(width = 0.2))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-113.png) 

```r
ggplot(gDat, aes(x = continent, y = lifeExp)) + geom_boxplot()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-114.png) 

```r

# distribution of a quant var
ggplot(gDat, aes(x = lifeExp)) + geom_histogram(binwidth = 3, fill = "blue", 
    colour = "darkblue")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-115.png) 

```r
ggplot(gDat, aes(x = lifeExp)) + geom_density()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-116.png) 

```r
ggplot(gDat, aes(x = lifeExp, fill = continent)) + geom_histogram() + scale_fill_brewer(palette = "Set1")
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust
## this.
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-117.png) 

```r
ggplot(gDat, aes(x = lifeExp, color = continent)) + geom_density() + scale_color_manual(values = c("red", 
    "green", "blue", "black", "yellow"))
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-118.png) 

```r

ggplot(gDat, aes(x = gdpPercap, y = lifeExp)) + scale_x_log10() + geom_bin2d()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-119.png) 

```r
ggplot(gDat, aes(x = gdpPercap, y = lifeExp)) + geom_point() + scale_x_log10() + 
    facet_wrap(~continent)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-120.png) 

```r
ggplot(subset(gDat, year == 2007), aes(x = gdpPercap, y = lifeExp, colour = continent, 
    size = sqrt(pop))) + geom_point() + scale_x_log10()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-121.png) 

```r

notheme <- ggplot(subset(gDat, year == 2007), aes(x = gdpPercap, y = lifeExp, 
    color = continent)) + geom_point(shape = 3, size = 1.5) + facet_wrap(~continent) + 
    scale_x_log10()
my_theme <- theme(legend.key = element_rect(fill = NA), legend.position = "bottom", 
    strip.background = element_rect(fill = NA), axis.title.y = element_text(angle = 0))
notheme
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-122.png) 

```r
notheme + my_theme
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-123.png) 

```r
library(ggthemes)
```

```
## Warning: package 'ggthemes' was built under R version 3.0.2
```

```r
notheme + theme_stata()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-124.png) 

```r
notheme + theme_excel()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-125.png) 

```r
notheme + theme_wsj()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-126.png) 

```r
notheme + theme_solarized()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-127.png) 

```r

library(plyr)
library(reshape)
```

```
## Warning: package 'reshape' was built under R version 3.0.2
```

```
## Attaching package: 'reshape'
## 
## The following object is masked from 'package:plyr':
## 
## rename, round_any
```

```r
contGdps <- ddply(subset(gDat, year == 2007 & continent != "Oceania"), ~continent, 
    summarize, minGdp = min(gdpPercap), meanGdp = mean(gdpPercap), maxGdp = max(gdpPercap))
contGdps <- melt(contGdps, id.vars = "continent")
ggplot(contGdps, aes(continent, value, fill = variable)) + geom_bar(stat = "identity")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-128.png) 

```r
ggplot(contGdps, aes(continent, value, fill = variable)) + geom_bar(stat = "identity", 
    position = "dodge")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-129.png) 

