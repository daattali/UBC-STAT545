Dean Attali
=================================
**STAT 545A hw 3**  
**Sept 22 2013**

Exercises done:
* Average GDP/cap in each continent when the data was first and last collected **(easy)**
* Trimmed mean statistics for life expectancy in each continent for every year **(fun)**
* Absolute and relative world population in each of the continents **(very fun)**
* A list of all countries that at some point had their population size decrease **(very fun)**

### Data initialization


```r
# load required libraries
library(plyr)
```

```
## Warning: package 'plyr' was built under R version 3.0.2
```

```r
library(xtable)
# import the data
gDat <- read.delim("gapminderDataFiveYear.txt")
# sanity check that import was successful
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


### Average GDP/cap in each continent when the data was first and last collected **(easy)**
In my previous assignment I worked out the GDP/cap in every continent per year using the 'aggregate' function. The goal here was just to show myself how awesome and easy plyr is to get the same data. We just look at the first and last year data.


```r
# get the data that only has the first and last years
firstLastYears = subset(gDat, year == min(year) | year == max(year))
# use plyr to pull out the wanted information
avgGdpContinent <- ddply(firstLastYears, ~year + continent, summarize, gdp = mean(gdpPercap))
avgGdpContinent <- xtable(avgGdpContinent)
print(avgGdpContinent, type = "html", include.rownames = FALSE)
```

<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Sat Oct 19 13:30:24 2013 -->
<TABLE border=1>
<TR> <TH> year </TH> <TH> continent </TH> <TH> gdp </TH>  </TR>
  <TR> <TD align="right"> 1952 </TD> <TD> Africa </TD> <TD align="right"> 1252.57 </TD> </TR>
  <TR> <TD align="right"> 1952 </TD> <TD> Americas </TD> <TD align="right"> 4079.06 </TD> </TR>
  <TR> <TD align="right"> 1952 </TD> <TD> Asia </TD> <TD align="right"> 5195.48 </TD> </TR>
  <TR> <TD align="right"> 1952 </TD> <TD> Europe </TD> <TD align="right"> 5661.06 </TD> </TR>
  <TR> <TD align="right"> 1952 </TD> <TD> Oceania </TD> <TD align="right"> 10298.09 </TD> </TR>
  <TR> <TD align="right"> 2007 </TD> <TD> Africa </TD> <TD align="right"> 3089.03 </TD> </TR>
  <TR> <TD align="right"> 2007 </TD> <TD> Americas </TD> <TD align="right"> 11003.03 </TD> </TR>
  <TR> <TD align="right"> 2007 </TD> <TD> Asia </TD> <TD align="right"> 12473.03 </TD> </TR>
  <TR> <TD align="right"> 2007 </TD> <TD> Europe </TD> <TD align="right"> 25054.48 </TD> </TR>
  <TR> <TD align="right"> 2007 </TD> <TD> Oceania </TD> <TD align="right"> 29810.19 </TD> </TR>
   </TABLE>


We can see from the table above that Oceania and Asia are the big winners of the 50 years, while Africa is the loser. Of course, visualizing it would be much nicer, but it is forbidden.

### Trimmed mean statistics for life expectancy in each continent for every year **(fun)**
Here, we comapre the mean life expectancy in eahc continent per year with the trimmed mean after removing 15% of lowest/highest values. We compute the difference between the trimmed mean and the regular mean, and calculate the percent difference between them.


```r
# compute the means and arrange the data by the highest percent difference
lifeExpMeans <- arrange(ddply(gDat, .(continent, year), summarize, mean0 = mean(lifeExp), 
    mean15 = mean(lifeExp, trim = 0.15), meanDiff = abs(mean0 - mean15), percentDiff = round(meanDiff/mean0 * 
        100, 2)), desc(percentDiff))
lifeExpMeans <- xtable(lifeExpMeans)
print(lifeExpMeans, type = "html", include.rownames = FALSE)
```

<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Sat Oct 19 13:30:24 2013 -->
<TABLE border=1>
<TR> <TH> continent </TH> <TH> year </TH> <TH> mean0 </TH> <TH> mean15 </TH> <TH> meanDiff </TH> <TH> percentDiff </TH>  </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 2002 </TD> <TD align="right"> 53.33 </TD> <TD align="right"> 52.04 </TD> <TD align="right"> 1.29 </TD> <TD align="right"> 2.42 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 2007 </TD> <TD align="right"> 54.81 </TD> <TD align="right"> 53.75 </TD> <TD align="right"> 1.06 </TD> <TD align="right"> 1.93 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1977 </TD> <TD align="right"> 59.61 </TD> <TD align="right"> 60.55 </TD> <TD align="right"> 0.94 </TD> <TD align="right"> 1.57 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1997 </TD> <TD align="right"> 53.60 </TD> <TD align="right"> 52.85 </TD> <TD align="right"> 0.75 </TD> <TD align="right"> 1.40 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1952 </TD> <TD align="right"> 46.31 </TD> <TD align="right"> 45.79 </TD> <TD align="right"> 0.52 </TD> <TD align="right"> 1.13 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1952 </TD> <TD align="right"> 64.41 </TD> <TD align="right"> 65.11 </TD> <TD align="right"> 0.70 </TD> <TD align="right"> 1.09 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1957 </TD> <TD align="right"> 66.70 </TD> <TD align="right"> 67.34 </TD> <TD align="right"> 0.64 </TD> <TD align="right"> 0.95 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1987 </TD> <TD align="right"> 64.85 </TD> <TD align="right"> 65.45 </TD> <TD align="right"> 0.60 </TD> <TD align="right"> 0.93 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 2002 </TD> <TD align="right"> 69.23 </TD> <TD align="right"> 69.88 </TD> <TD align="right"> 0.64 </TD> <TD align="right"> 0.93 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1982 </TD> <TD align="right"> 66.23 </TD> <TD align="right"> 66.82 </TD> <TD align="right"> 0.59 </TD> <TD align="right"> 0.90 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 2007 </TD> <TD align="right"> 70.73 </TD> <TD align="right"> 71.33 </TD> <TD align="right"> 0.61 </TD> <TD align="right"> 0.86 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1982 </TD> <TD align="right"> 62.62 </TD> <TD align="right"> 63.15 </TD> <TD align="right"> 0.53 </TD> <TD align="right"> 0.84 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1992 </TD> <TD align="right"> 66.54 </TD> <TD align="right"> 67.09 </TD> <TD align="right"> 0.55 </TD> <TD align="right"> 0.83 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1972 </TD> <TD align="right"> 57.32 </TD> <TD align="right"> 57.79 </TD> <TD align="right"> 0.47 </TD> <TD align="right"> 0.82 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1962 </TD> <TD align="right"> 68.54 </TD> <TD align="right"> 69.10 </TD> <TD align="right"> 0.56 </TD> <TD align="right"> 0.82 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1987 </TD> <TD align="right"> 53.34 </TD> <TD align="right"> 52.92 </TD> <TD align="right"> 0.42 </TD> <TD align="right"> 0.80 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1972 </TD> <TD align="right"> 62.39 </TD> <TD align="right"> 62.89 </TD> <TD align="right"> 0.50 </TD> <TD align="right"> 0.80 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1987 </TD> <TD align="right"> 68.09 </TD> <TD align="right"> 68.63 </TD> <TD align="right"> 0.54 </TD> <TD align="right"> 0.79 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1957 </TD> <TD align="right"> 41.27 </TD> <TD align="right"> 40.95 </TD> <TD align="right"> 0.31 </TD> <TD align="right"> 0.76 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1977 </TD> <TD align="right"> 64.39 </TD> <TD align="right"> 64.88 </TD> <TD align="right"> 0.49 </TD> <TD align="right"> 0.76 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1997 </TD> <TD align="right"> 68.02 </TD> <TD align="right"> 68.54 </TD> <TD align="right"> 0.52 </TD> <TD align="right"> 0.76 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1992 </TD> <TD align="right"> 69.57 </TD> <TD align="right"> 70.05 </TD> <TD align="right"> 0.49 </TD> <TD align="right"> 0.70 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1997 </TD> <TD align="right"> 71.15 </TD> <TD align="right"> 71.63 </TD> <TD align="right"> 0.48 </TD> <TD align="right"> 0.68 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1967 </TD> <TD align="right"> 69.74 </TD> <TD align="right"> 70.20 </TD> <TD align="right"> 0.46 </TD> <TD align="right"> 0.66 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1962 </TD> <TD align="right"> 43.32 </TD> <TD align="right"> 43.04 </TD> <TD align="right"> 0.28 </TD> <TD align="right"> 0.65 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1982 </TD> <TD align="right"> 51.59 </TD> <TD align="right"> 51.26 </TD> <TD align="right"> 0.33 </TD> <TD align="right"> 0.65 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1957 </TD> <TD align="right"> 49.32 </TD> <TD align="right"> 49.00 </TD> <TD align="right"> 0.32 </TD> <TD align="right"> 0.65 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1967 </TD> <TD align="right"> 60.41 </TD> <TD align="right"> 60.79 </TD> <TD align="right"> 0.38 </TD> <TD align="right"> 0.63 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 2002 </TD> <TD align="right"> 72.42 </TD> <TD align="right"> 72.85 </TD> <TD align="right"> 0.43 </TD> <TD align="right"> 0.60 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1977 </TD> <TD align="right"> 49.58 </TD> <TD align="right"> 49.30 </TD> <TD align="right"> 0.28 </TD> <TD align="right"> 0.56 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1962 </TD> <TD align="right"> 51.56 </TD> <TD align="right"> 51.29 </TD> <TD align="right"> 0.27 </TD> <TD align="right"> 0.53 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1972 </TD> <TD align="right"> 70.78 </TD> <TD align="right"> 71.14 </TD> <TD align="right"> 0.37 </TD> <TD align="right"> 0.52 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 2007 </TD> <TD align="right"> 73.61 </TD> <TD align="right"> 73.99 </TD> <TD align="right"> 0.38 </TD> <TD align="right"> 0.51 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1967 </TD> <TD align="right"> 45.33 </TD> <TD align="right"> 45.11 </TD> <TD align="right"> 0.22 </TD> <TD align="right"> 0.49 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1972 </TD> <TD align="right"> 47.45 </TD> <TD align="right"> 47.22 </TD> <TD align="right"> 0.23 </TD> <TD align="right"> 0.49 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1962 </TD> <TD align="right"> 58.40 </TD> <TD align="right"> 58.68 </TD> <TD align="right"> 0.28 </TD> <TD align="right"> 0.48 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1952 </TD> <TD align="right"> 39.14 </TD> <TD align="right"> 38.95 </TD> <TD align="right"> 0.19 </TD> <TD align="right"> 0.47 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1997 </TD> <TD align="right"> 75.51 </TD> <TD align="right"> 75.85 </TD> <TD align="right"> 0.35 </TD> <TD align="right"> 0.46 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1992 </TD> <TD align="right"> 74.44 </TD> <TD align="right"> 74.77 </TD> <TD align="right"> 0.33 </TD> <TD align="right"> 0.45 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1987 </TD> <TD align="right"> 73.64 </TD> <TD align="right"> 73.97 </TD> <TD align="right"> 0.33 </TD> <TD align="right"> 0.44 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1982 </TD> <TD align="right"> 72.81 </TD> <TD align="right"> 73.09 </TD> <TD align="right"> 0.29 </TD> <TD align="right"> 0.39 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1952 </TD> <TD align="right"> 53.28 </TD> <TD align="right"> 53.10 </TD> <TD align="right"> 0.18 </TD> <TD align="right"> 0.34 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1977 </TD> <TD align="right"> 71.94 </TD> <TD align="right"> 72.18 </TD> <TD align="right"> 0.25 </TD> <TD align="right"> 0.34 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 2002 </TD> <TD align="right"> 76.70 </TD> <TD align="right"> 76.94 </TD> <TD align="right"> 0.24 </TD> <TD align="right"> 0.31 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 2007 </TD> <TD align="right"> 77.65 </TD> <TD align="right"> 77.89 </TD> <TD align="right"> 0.24 </TD> <TD align="right"> 0.31 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1957 </TD> <TD align="right"> 55.96 </TD> <TD align="right"> 56.02 </TD> <TD align="right"> 0.05 </TD> <TD align="right"> 0.10 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1967 </TD> <TD align="right"> 54.66 </TD> <TD align="right"> 54.71 </TD> <TD align="right"> 0.05 </TD> <TD align="right"> 0.09 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1992 </TD> <TD align="right"> 53.63 </TD> <TD align="right"> 53.66 </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 0.06 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1952 </TD> <TD align="right"> 69.25 </TD> <TD align="right"> 69.25 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1957 </TD> <TD align="right"> 70.30 </TD> <TD align="right"> 70.30 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1962 </TD> <TD align="right"> 71.09 </TD> <TD align="right"> 71.09 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1967 </TD> <TD align="right"> 71.31 </TD> <TD align="right"> 71.31 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1972 </TD> <TD align="right"> 71.91 </TD> <TD align="right"> 71.91 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1977 </TD> <TD align="right"> 72.85 </TD> <TD align="right"> 72.85 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1982 </TD> <TD align="right"> 74.29 </TD> <TD align="right"> 74.29 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1987 </TD> <TD align="right"> 75.32 </TD> <TD align="right"> 75.32 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1992 </TD> <TD align="right"> 76.94 </TD> <TD align="right"> 76.94 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1997 </TD> <TD align="right"> 78.19 </TD> <TD align="right"> 78.19 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 2002 </TD> <TD align="right"> 79.74 </TD> <TD align="right"> 79.74 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 2007 </TD> <TD align="right"> 80.72 </TD> <TD align="right"> 80.72 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
   </TABLE>


We can see that even after trimming 15% from both ends of the life expectancies in each continent, the most difference between the trimmed mean and the real mean is less than 2.5%. This means (pun non-intended) that there isn't a huge variability in lif expectancies between the different countries within each continent in a given year. It's visible that Africa has the largest such variability, as 3 of the top 5 rows belong to Africa. It's also nice to see how Oceania has 0% difference because there are not enough countries in it to trim, so the trimmed mean uses the same data as the real mean.

### Absolute and relative world population in each of the continents **(very fun)**
Here we look at the total population of each continent in every year, and compare that to the world's total population. The data is arranged by year, where in each year group the continents are arranged from most populous to least.


```r
worldRelativePop <- ddply(gDat, .(continent, year), function(.data) {
    .data <- as.list(.data)
    .data["continentPop"] <- sum(.data$pop)
    .data["worldPop"] <- sum(subset(gDat, year == .data$year[1])[["pop"]])
    .data["percent"] <- round(as.numeric(.data["continentPop"])/as.numeric(.data["worldPop"]) * 
        100, 2)
    quickdf(.data[c("continentPop", "worldPop", "percent")])
})
worldRelativePop <- arrange(worldRelativePop, year, desc(percent))
worldRelativePop <- xtable(worldRelativePop)
print(worldRelativePop, type = "html", include.rownames = FALSE)
```

<!-- html table generated in R 3.0.1 by xtable 1.7-1 package -->
<!-- Sat Oct 19 13:30:24 2013 -->
<TABLE border=1>
<TR> <TH> continent </TH> <TH> year </TH> <TH> continentPop </TH> <TH> worldPop </TH> <TH> percent </TH>  </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1952 </TD> <TD align="right"> 1395357352.00 </TD> <TD align="right"> 2406957151.00 </TD> <TD align="right"> 57.97 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1952 </TD> <TD align="right"> 418120846.00 </TD> <TD align="right"> 2406957151.00 </TD> <TD align="right"> 17.37 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1952 </TD> <TD align="right"> 345152446.00 </TD> <TD align="right"> 2406957151.00 </TD> <TD align="right"> 14.34 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1952 </TD> <TD align="right"> 237640501.00 </TD> <TD align="right"> 2406957151.00 </TD> <TD align="right"> 9.87 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1952 </TD> <TD align="right"> 10686006.00 </TD> <TD align="right"> 2406957151.00 </TD> <TD align="right"> 0.44 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1957 </TD> <TD align="right"> 1562780599.00 </TD> <TD align="right"> 2664404580.00 </TD> <TD align="right"> 58.65 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1957 </TD> <TD align="right"> 437890351.00 </TD> <TD align="right"> 2664404580.00 </TD> <TD align="right"> 16.43 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1957 </TD> <TD align="right"> 386953916.00 </TD> <TD align="right"> 2664404580.00 </TD> <TD align="right"> 14.52 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1957 </TD> <TD align="right"> 264837738.00 </TD> <TD align="right"> 2664404580.00 </TD> <TD align="right"> 9.94 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1957 </TD> <TD align="right"> 11941976.00 </TD> <TD align="right"> 2664404580.00 </TD> <TD align="right"> 0.45 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1962 </TD> <TD align="right"> 1696357182.00 </TD> <TD align="right"> 2899782974.00 </TD> <TD align="right"> 58.50 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1962 </TD> <TD align="right"> 460355155.00 </TD> <TD align="right"> 2899782974.00 </TD> <TD align="right"> 15.88 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1962 </TD> <TD align="right"> 433270254.00 </TD> <TD align="right"> 2899782974.00 </TD> <TD align="right"> 14.94 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1962 </TD> <TD align="right"> 296516865.00 </TD> <TD align="right"> 2899782974.00 </TD> <TD align="right"> 10.23 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1962 </TD> <TD align="right"> 13283518.00 </TD> <TD align="right"> 2899782974.00 </TD> <TD align="right"> 0.46 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1967 </TD> <TD align="right"> 1905662900.00 </TD> <TD align="right"> 3217478384.00 </TD> <TD align="right"> 59.23 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1967 </TD> <TD align="right"> 481178958.00 </TD> <TD align="right"> 3217478384.00 </TD> <TD align="right"> 14.96 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1967 </TD> <TD align="right"> 480746623.00 </TD> <TD align="right"> 3217478384.00 </TD> <TD align="right"> 14.94 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1967 </TD> <TD align="right"> 335289489.00 </TD> <TD align="right"> 3217478384.00 </TD> <TD align="right"> 10.42 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1967 </TD> <TD align="right"> 14600414.00 </TD> <TD align="right"> 3217478384.00 </TD> <TD align="right"> 0.45 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1972 </TD> <TD align="right"> 2150972248.00 </TD> <TD align="right"> 3576977158.00 </TD> <TD align="right"> 60.13 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1972 </TD> <TD align="right"> 529384210.00 </TD> <TD align="right"> 3576977158.00 </TD> <TD align="right"> 14.80 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1972 </TD> <TD align="right"> 500635059.00 </TD> <TD align="right"> 3576977158.00 </TD> <TD align="right"> 14.00 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1972 </TD> <TD align="right"> 379879541.00 </TD> <TD align="right"> 3576977158.00 </TD> <TD align="right"> 10.62 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1972 </TD> <TD align="right"> 16106100.00 </TD> <TD align="right"> 3576977158.00 </TD> <TD align="right"> 0.45 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1977 </TD> <TD align="right"> 2384513556.00 </TD> <TD align="right"> 3930045807.00 </TD> <TD align="right"> 60.67 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1977 </TD> <TD align="right"> 578067699.00 </TD> <TD align="right"> 3930045807.00 </TD> <TD align="right"> 14.71 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1977 </TD> <TD align="right"> 517164531.00 </TD> <TD align="right"> 3930045807.00 </TD> <TD align="right"> 13.16 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1977 </TD> <TD align="right"> 433061021.00 </TD> <TD align="right"> 3930045807.00 </TD> <TD align="right"> 11.02 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1977 </TD> <TD align="right"> 17239000.00 </TD> <TD align="right"> 3930045807.00 </TD> <TD align="right"> 0.44 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1982 </TD> <TD align="right"> 2610135582.00 </TD> <TD align="right"> 4289436840.00 </TD> <TD align="right"> 60.85 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1982 </TD> <TD align="right"> 630290920.00 </TD> <TD align="right"> 4289436840.00 </TD> <TD align="right"> 14.69 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1982 </TD> <TD align="right"> 531266901.00 </TD> <TD align="right"> 4289436840.00 </TD> <TD align="right"> 12.39 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1982 </TD> <TD align="right"> 499348587.00 </TD> <TD align="right"> 4289436840.00 </TD> <TD align="right"> 11.64 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1982 </TD> <TD align="right"> 18394850.00 </TD> <TD align="right"> 4289436840.00 </TD> <TD align="right"> 0.43 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1987 </TD> <TD align="right"> 2871220762.00 </TD> <TD align="right"> 4691477418.00 </TD> <TD align="right"> 61.20 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1987 </TD> <TD align="right"> 682753971.00 </TD> <TD align="right"> 4691477418.00 </TD> <TD align="right"> 14.55 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1987 </TD> <TD align="right"> 574834110.00 </TD> <TD align="right"> 4691477418.00 </TD> <TD align="right"> 12.25 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1987 </TD> <TD align="right"> 543094160.00 </TD> <TD align="right"> 4691477418.00 </TD> <TD align="right"> 11.58 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1987 </TD> <TD align="right"> 19574415.00 </TD> <TD align="right"> 4691477418.00 </TD> <TD align="right"> 0.42 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1992 </TD> <TD align="right"> 3133292191.00 </TD> <TD align="right"> 5110710260.00 </TD> <TD align="right"> 61.31 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1992 </TD> <TD align="right"> 739274104.00 </TD> <TD align="right"> 5110710260.00 </TD> <TD align="right"> 14.47 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1992 </TD> <TD align="right"> 659081517.00 </TD> <TD align="right"> 5110710260.00 </TD> <TD align="right"> 12.90 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1992 </TD> <TD align="right"> 558142797.00 </TD> <TD align="right"> 5110710260.00 </TD> <TD align="right"> 10.92 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1992 </TD> <TD align="right"> 20919651.00 </TD> <TD align="right"> 5110710260.00 </TD> <TD align="right"> 0.41 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 1997 </TD> <TD align="right"> 3383285500.00 </TD> <TD align="right"> 5515204472.00 </TD> <TD align="right"> 61.34 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 1997 </TD> <TD align="right"> 796900410.00 </TD> <TD align="right"> 5515204472.00 </TD> <TD align="right"> 14.45 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 1997 </TD> <TD align="right"> 743832984.00 </TD> <TD align="right"> 5515204472.00 </TD> <TD align="right"> 13.49 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 1997 </TD> <TD align="right"> 568944148.00 </TD> <TD align="right"> 5515204472.00 </TD> <TD align="right"> 10.32 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 1997 </TD> <TD align="right"> 22241430.00 </TD> <TD align="right"> 5515204472.00 </TD> <TD align="right"> 0.40 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 2002 </TD> <TD align="right"> 3601802203.00 </TD> <TD align="right"> 5886977579.00 </TD> <TD align="right"> 61.18 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 2002 </TD> <TD align="right"> 849772762.00 </TD> <TD align="right"> 5886977579.00 </TD> <TD align="right"> 14.43 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 2002 </TD> <TD align="right"> 833723916.00 </TD> <TD align="right"> 5886977579.00 </TD> <TD align="right"> 14.16 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 2002 </TD> <TD align="right"> 578223869.00 </TD> <TD align="right"> 5886977579.00 </TD> <TD align="right"> 9.82 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 2002 </TD> <TD align="right"> 23454829.00 </TD> <TD align="right"> 5886977579.00 </TD> <TD align="right"> 0.40 </TD> </TR>
  <TR> <TD> Asia </TD> <TD align="right"> 2007 </TD> <TD align="right"> 3811953827.00 </TD> <TD align="right"> 6251013179.00 </TD> <TD align="right"> 60.98 </TD> </TR>
  <TR> <TD> Africa </TD> <TD align="right"> 2007 </TD> <TD align="right"> 929539692.00 </TD> <TD align="right"> 6251013179.00 </TD> <TD align="right"> 14.87 </TD> </TR>
  <TR> <TD> Americas </TD> <TD align="right"> 2007 </TD> <TD align="right"> 898871184.00 </TD> <TD align="right"> 6251013179.00 </TD> <TD align="right"> 14.38 </TD> </TR>
  <TR> <TD> Europe </TD> <TD align="right"> 2007 </TD> <TD align="right"> 586098529.00 </TD> <TD align="right"> 6251013179.00 </TD> <TD align="right"> 9.38 </TD> </TR>
  <TR> <TD> Oceania </TD> <TD align="right"> 2007 </TD> <TD align="right"> 24549947.00 </TD> <TD align="right"> 6251013179.00 </TD> <TD align="right"> 0.39 </TD> </TR>
   </TABLE>


There might be a nicer, easier way to achieve this, but I didn't know how. I was trying to use plain old 'summarize', but summarize did not let me aggregate the total population of all continents in each of the years. I'm not sure if this kinf of splitting is available with plyr. Since I couldn't get what I wanted with pylr, I looked at the source code of the summarize function and was able to alter it a little bit to get what I needed.  
We can see that Asia is consistently by far the most populated continent, always making up ~60% of the world population.  
__One very interesting observation is how Europe, America, and Africa changed spots over time. In the 1950's, Europe was the most populated, followed by America and Africa. As the years go by, America's relative population remains fairly constant at around 14.5%, Europe's relative population decreases, and Africa's increases. This trend consistently continues throughout the years without exception, until at the last data point in 2007 the rankings of the three continents is completely flipped from the beginning - Africa followed by America followed by Europe__

### A list of all countries that at some point had their population size decrease (very fun)
The world can be a very cruel place. Many countries have gone through genocides, massive natural disasters, or other events that have caused them to lose a significant portion of their population. For example, the Khmer Rouge in Cambodia killed off a large fraction of the Cambodian population in the 1970's. As a result, the country's population actually shrank from 1972 to 1977. It is interesting to see what other countries went through a population decrease at some point.


```r
# get all the years that we have data for
years <- unique(gDat$year)
# get a list of all countries
allCountries = levels(gDat$country)
# initialize a vector for the poor countries that experienced a population
# decrease
resultCountries = vector(mode = "character")

# go through every country, and see if its population in the previous data
# year is larger than the current population. If that is true for any given
# year, add the country to our results list
for (iCountry in allCountries) {
    for (idxYear in seq(years)[-1]) {
        prevYear = years[idxYear - 1]
        curYear = years[idxYear]
        prevYearData = gDat[intersect(which(gDat$year == prevYear), which(gDat$country == 
            iCountry)), ]
        curYearData = gDat[intersect(which(gDat$year == curYear), which(gDat$country == 
            iCountry)), ]
        prevPop = prevYearData[["pop"]]
        curPop = curYearData[["pop"]]
        if (prevPop >= curPop) {
            resultCountries = append(resultCountries, iCountry)
            break
        }
    }
}
print(resultCountries)
```

```
##  [1] "Afghanistan"            "Bosnia and Herzegovina"
##  [3] "Bulgaria"               "Cambodia"              
##  [5] "Croatia"                "Czech Republic"        
##  [7] "Equatorial Guinea"      "Germany"               
##  [9] "Guinea-Bissau"          "Hungary"               
## [11] "Ireland"                "Kuwait"                
## [13] "Lebanon"                "Lesotho"               
## [15] "Liberia"                "Montenegro"            
## [17] "Poland"                 "Portugal"              
## [19] "Romania"                "Rwanda"                
## [21] "Serbia"                 "Slovenia"              
## [23] "Somalia"                "South Africa"          
## [25] "Switzerland"            "Trinidad and Tobago"   
## [27] "West Bank and Gaza"
```

There might be a non-forloop way to do this, but I couldn't figure it out.  
As we can see, there are 27 countries that as some point had their population decrease, and Cambodia is indeed one of them.  
I wanted to show this data in a dataframe, but I'm on a plane without WiFi at midnight before this is due, and I can't find out how to build a data frame from scratch, so I'll just leave it as a list :)
