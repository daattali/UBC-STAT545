



# Homework 7 - Data wrangling and manipulation
Dean Attali  
Oct 2014 

Last updated: 2014-11-08 12:10:48

## Overview
In this assignment, I found a dataset with information about cancer incidences
and used various libraries (`plyr`, `dplyr`, `tidyr`, `ggplot2`) to manipulate
the data and perform some basic data exploration

## Datasets
I downloaded two datasets from [the United States CDC](http://wonder.cdc.gov/cancer.html)
that describe cancer occurrences in the US between 1999 to 2011. One dataset
holds the number of cancer cases per cancer type, while the other dataset
holds the number of deaths per cancer type.  

I also downloaded data from [The World Bank](http://data.worldbank.org/)
that provides the population of every country in every year over the past several
decades.  I only used the US data from it to know what the total US population
was at every year that we have cancer data for.

## Getting down to business
Less talkin', more codin'!




### Read and clean the datasets
#### Dataset 1 - Number of cancer deaths



Read in the dataset that contains the number of deaths per cancer type per year
(I convert the dataframe to a tbl_df just for better visualization purposes)


```r
(deathsDat <- tbl_df(
	read.table(file.path(DATA_DIR, "cancerDeathsUS.txt"), header = T)))
```

```
## Source: local data frame [299 x 5]
## 
##    Leading.Cancer.Sites Leading.Cancer.Sites.Code Year Year.Code Deaths
## 1    All Sites Combined                        00 1999      1999 549829
## 2    All Sites Combined                        00 2000      2000 553080
## 3    All Sites Combined                        00 2001      2001 553760
## 4    All Sites Combined                        00 2002      2002 557264
## 5    All Sites Combined                        00 2003      2003 556890
## 6    All Sites Combined                        00 2004      2004 553880
## 7    All Sites Combined                        00 2005      2005 559303
## 8    All Sites Combined                        00 2006      2006 559880
## 9    All Sites Combined                        00 2007      2007 562867
## 10   All Sites Combined                        00 2008      2008 565460
## ..                  ...                       ...  ...       ...    ...
```

```r
(levels(deathsDat$Leading.Cancer.Sites))
```

```
##  [1] "All Sites Combined"             "Brain and Other Nervous System"
##  [3] "Breast"                         "Cervix Uteri"                  
##  [5] "Colon and Rectum"               "Corpus Uteri"                  
##  [7] "Esophagus"                      "Gallbladder"                   
##  [9] "Kidney and Renal Pelvis"        "Larynx"                        
## [11] "Leukemias"                      "Liver"                         
## [13] "Lung and Bronchus"              "Melanoma of the Skin"          
## [15] "Myeloma"                        "Non-Hodgkin Lymphoma"          
## [17] "Oral Cavity and Pharynx"        "Ovary"                         
## [19] "Pancreas"                       "Prostate"                      
## [21] "Stomach"                        "Thyroid"                       
## [23] "Urinary Bladder"
```

```r
(unique(deathsDat$Year))
```

```
##  [1] 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011
```

We can see the dataset has 299 observations and 5
variables.  There are 23 different
cancer sites for the years 1999 to 2011.



I want to do a little bit of cleaning:  
- change the column names to begin with a lower-case letter (personal preference)
(I'm using a function that I wrote, look at the source of the script to see it)  
- drop the two columns that represent "codes", they aren't needed
- rename the column that has periods in its name (personal preference)
- remove the "All Sites Combined" level


```r
dDatClean <- deathsDat
colnames(dDatClean) <- tolowerfirst(colnames(dDatClean))
dDatClean <- dDatClean %>%
	dplyr::select(leading.Cancer.Sites, year, deaths) %>%
	rename(cancerLocation = leading.Cancer.Sites)
dDatClean <- dDatClean %>%
	filter(cancerLocation != "All Sites Combined") %>%
	droplevels
print(dDatClean)
```

```
## Source: local data frame [286 x 3]
## 
##                    cancerLocation year deaths
## 1  Brain and Other Nervous System 1999  12765
## 2  Brain and Other Nervous System 2000  12655
## 3  Brain and Other Nervous System 2001  12609
## 4  Brain and Other Nervous System 2002  12830
## 5  Brain and Other Nervous System 2003  12901
## 6  Brain and Other Nervous System 2004  12829
## 7  Brain and Other Nervous System 2005  13152
## 8  Brain and Other Nervous System 2006  12886
## 9  Brain and Other Nervous System 2007  13234
## 10 Brain and Other Nervous System 2008  13724
## ..                            ...  ...    ...
```

Looks good!
#### Dataset 2 - Number of cancer cases



Read in the dataset that contains the number of incidences per cancer type per year
I will perform the same basic cleaning as on the previous dataset, since they
both came from the same source and have the same structure


```r
casesDat <- tbl_df(
	read.table(file.path(DATA_DIR, "cancerIncidenceUS.txt"), header = T))
cDatClean <- casesDat
colnames(cDatClean) <- tolowerfirst(colnames(cDatClean))
cDatClean <- cDatClean %>%
	dplyr::select(leading.Cancer.Sites, year, count) %>%
	rename(cancerLocation = leading.Cancer.Sites,
				 cases = count)
cDatClean <- cDatClean %>%
	filter(cancerLocation != "All Sites Combined") %>%
	droplevels
print(cDatClean)
```

```
## Source: local data frame [286 x 3]
## 
##                    cancerLocation year cases
## 1  Brain and Other Nervous System 1999 17359
## 2  Brain and Other Nervous System 2000 17979
## 3  Brain and Other Nervous System 2001 17748
## 4  Brain and Other Nervous System 2002 18495
## 5  Brain and Other Nervous System 2003 19437
## 6  Brain and Other Nervous System 2004 20427
## 7  Brain and Other Nervous System 2005 20473
## 8  Brain and Other Nervous System 2006 20701
## 9  Brain and Other Nervous System 2007 21110
## 10 Brain and Other Nervous System 2008 21456
## ..                            ...  ...   ...
```

```r
print(levels(cDatClean$cancerLocation))
```

```
##  [1] "Brain and Other Nervous System"       
##  [2] "Breast"                               
##  [3] "Cervix Uteri"                         
##  [4] "Colon and Rectum"                     
##  [5] "Corpus Uteri"                         
##  [6] "Esophagus"                            
##  [7] "Gallbladder"                          
##  [8] "Kidney and Renal Pelvis"              
##  [9] "Larynx"                               
## [10] "Leukemias"                            
## [11] "Liver"                                
## [12] "Lung and Bronchus"                    
## [13] "Melanoma of the Skin"                 
## [14] "Myeloma"                              
## [15] "Non-Hodgkin Lymphoma"                 
## [16] "Oral Cavity and Pharynx"              
## [17] "Ovary"                                
## [18] "Pancreas"                             
## [19] "Prostate"                             
## [20] "Stomach"                              
## [21] "Thyroid"                              
## [22] "Urinary Bladder, invasive and in situ"
```

Looks good! This dataset has the exact same dimensions as the deaths dataset,
which is what we expected. 
### Get the two datasets ready to be merged
Next I'd like to take these two datasets and merge them together.  Specifically,
for every combination of cancer location + year, I want to merge the two datasets
so that I will have the number of cases and deaths in the same dataframe.
In order for this to work, we need to make sure that the two sources have exactly
the same levels for the cancer location and year variables. But there is a small
problem with the current data that you might have noticed - one of the cancer
locations is represented with a different name in the two datasets.  
To demonstrate this, here is the set difference between the union of the cancer
locations in both datasets and the intersection of them (ie. this shows
which cancer locations are not shared by the two)


```r
setdiff(
	union(levels(dDatClean$cancerLocation),
				levels(cDatClean$cancerLocation)),
	intersect(levels(dDatClean$cancerLocation),
						levels(cDatClean$cancerLocation)))
```

```
## [1] "Urinary Bladder"                      
## [2] "Urinary Bladder, invasive and in situ"
```


There is an easy fix: just change the name of that level in one of the datasets
to match the other


```r
identical(levels(cDatClean$cancerLocation), levels(dDatClean$cancerLocation))
```

```
## [1] FALSE
```

```r
cDatClean$cancerLocation <-
	cDatClean$cancerLocation %>%
	revalue(c("Urinary Bladder, invasive and in situ" = "Urinary Bladder"))
identical(levels(cDatClean$cancerLocation), levels(dDatClean$cancerLocation))
```

```
## [1] TRUE
```

Now we have proof that the levels are identical
### Do the Join (aka merge)
Now the two datasets are ready to be merged together. There are many R ways
to do this, but I will use the `dplyr::left_join` approach.


```r
cancerData <- left_join(dDatClean, cDatClean, by = c("cancerLocation", "year"))
print(cancerData)
```

```
## Source: local data frame [286 x 4]
## 
##                    cancerLocation year deaths cases
## 1  Brain and Other Nervous System 1999  12765 17359
## 2  Brain and Other Nervous System 2000  12655 17979
## 3  Brain and Other Nervous System 2001  12609 17748
## 4  Brain and Other Nervous System 2002  12830 18495
## 5  Brain and Other Nervous System 2003  12901 19437
## 6  Brain and Other Nervous System 2004  12829 20427
## 7  Brain and Other Nervous System 2005  13152 20473
## 8  Brain and Other Nervous System 2006  12886 20701
## 9  Brain and Other Nervous System 2007  13234 21110
## 10 Brain and Other Nervous System 2008  13724 21456
## ..                            ...  ...    ...   ...
```

Success! That was easy.
### Tidying the data
Now that we have a dataset with the number of cases and deaths of every major
cancer in the US per year, we need to get the data into a tidy form so that it
will be easier to do compuations/visualization on it.  Right now the data is in
a fat/wide format, and we want to get it to a long/tall format.  Another thing
I want to do is to sort the observations by year instead of by cancer type.


```r
cancerData <- cancerData %>%
	gather(stat, freq, deaths, cases) %>%
	arrange(year, cancerLocation)
print(cancerData)
```

```
## Source: local data frame [572 x 4]
## 
##                    cancerLocation year   stat   freq
## 1  Brain and Other Nervous System 1999 deaths  12765
## 2  Brain and Other Nervous System 1999  cases  17359
## 3                          Breast 1999 deaths  41528
## 4                          Breast 1999  cases 185254
## 5                    Cervix Uteri 1999 deaths   4204
## 6                    Cervix Uteri 1999  cases  12782
## 7                Colon and Rectum 1999 deaths  57222
## 8                Colon and Rectum 1999  cases 140888
## 9                    Corpus Uteri 1999 deaths   3121
## 10                   Corpus Uteri 1999  cases  31982
## ..                            ...  ...    ...    ...
```

Hooray for `tidyr`! Also, doesn't this row ordering make you happier?
(Perhaps for you it doesn't....?)
### Plot the data and save figure to file
I'd like to plot the number of cases/deaths for every cancer type in each year
as a line graph, with each cancer type being a line.

#### Re-order cancer type levels
In order to get the legend in the plot to nicely match up with the order
of the data in the plot, we need to rearrange the order of the cancer type
factor (currently it's alphabetical). To do this, I first construct a vector
holding the order of the cancer types by which one had the most cases in the
most recent timepoint, and then I recreate the factor using this ordering. 


```r
cancerLocationsOrder <- cancerData %>%
	filter(stat == "cases",
				 year == max(year)) %>%
	arrange(desc(freq)) %>%
	first %>%
	as.character
cancerData$cancerLocation <-
	factor(cancerData$cancerLocation, levels = cancerLocationsOrder)
```

For brevity, I am not printing out the new order, but the plot will give
us confirmation that it worked
### Plot (providing 22 custom colours)
I couldn't find a pre-defined colour palette that I was satisfied with that
had so many colours, so I created one. Usually when dealing with less levels,
it's better to use an existing palette, such as from `RColorBrewer`.  
After plotting, I also save the plot as a PDF


```r
c22 <- c("dodgerblue2","#E31A1C", # red
				 "green4",
				 "#6A3D9A", # purple
				 "#FF7F00", # orange
				 "black","gold1",
				 "skyblue2","#FB9A99", # lt pink
				 "palegreen2",
				 "#CAB2D6", # lt purple
				 "#FDBF6F", # lt orange
				 "gray70", "khaki2", "maroon", "orchid1", "deeppink1", "blue1",
				 "darkturquoise", "green1", "yellow4", "brown")
p <-
	ggplot(cancerData, aes(x = year, y = freq)) +
	geom_point(aes(col = cancerLocation, group = cancerLocation), size = 2) +
	geom_line(aes(col = cancerLocation, group = cancerLocation), size = 0.7) +
	facet_wrap(~ stat) +
	theme_bw(15) +
	scale_colour_manual(values = c22)
print(p)
```

<img src="markdown-figs/plot-basic-data-1.png" title="plot of chunk plot-basic-data" alt="plot of chunk plot-basic-data" style="display: block; margin: auto;" />

```r
ggsave(file.path(HW_DIR, "cancerTypesStats.pdf"), p)
```

```
## Saving 11 x 7 in image
```

This is perhaps not the bestest way to show this data, but it suffices
as a basic way to see the data.  It's interesting how lung and bronchus cancers
have so many more deaths than any other cancer, even though there are two other
cancers with similar incidences. I will not make any more comments about the
plot since the purpose of this assignment is more about data manipulation than plotting
### Practice with ddply, lapply, dlply, batch reading of files
Just as a fun exercise, now I will take the cancer data, split it up by
cancer location, and write the output of every cancer type to a separate file.
Then I will read all the files and concatenate them together to recreate the
original data.
First use `ddply` to write a file for every cancer type


```r
invisible( # invisible = I don't want to see the output from ddply
	ddply(cancerData, ~cancerLocation,
				function(x) {
					fileName <- file.path(
						HW_DIR,
						paste0("cDatTest-", gsub(" ", "_", x$cancerLocation[1]), ".csv"))
					write.table(dplyr::select(x, -cancerLocation),
											fileName,
											quote = F, sep = ",", row.names = F)
				}
	)
)
```

Now let's see that these files were actually created


```r
cancerFiles <- list.files(HW_DIR, pattern = "^cDatTest-.*csv$", full.names = T)
print(basename(cancerFiles))
```

```
##  [1] "cDatTest-Brain_and_Other_Nervous_System.csv"
##  [2] "cDatTest-Breast.csv"                        
##  [3] "cDatTest-Cervix_Uteri.csv"                  
##  [4] "cDatTest-Colon_and_Rectum.csv"              
##  [5] "cDatTest-Corpus_Uteri.csv"                  
##  [6] "cDatTest-Esophagus.csv"                     
##  [7] "cDatTest-Gallbladder.csv"                   
##  [8] "cDatTest-Kidney_and_Renal_Pelvis.csv"       
##  [9] "cDatTest-Larynx.csv"                        
## [10] "cDatTest-Leukemias.csv"                     
## [11] "cDatTest-Liver.csv"                         
## [12] "cDatTest-Lung_and_Bronchus.csv"             
## [13] "cDatTest-Melanoma_of_the_Skin.csv"          
## [14] "cDatTest-Myeloma.csv"                       
## [15] "cDatTest-Non-Hodgkin_Lymphoma.csv"          
## [16] "cDatTest-Oral_Cavity_and_Pharynx.csv"       
## [17] "cDatTest-Ovary.csv"                         
## [18] "cDatTest-Pancreas.csv"                      
## [19] "cDatTest-Prostate.csv"                      
## [20] "cDatTest-Stomach.csv"                       
## [21] "cDatTest-Thyroid.csv"                       
## [22] "cDatTest-Urinary_Bladder.csv"
```

Next we use `ldply` to read all the files and form a dataframe by concatenating
the information in each file.


```r
cancerFilesData <- ldply(cancerFiles, function(x) {
	tmpData <- read.table(file.path(x), header = T, sep = ",", row.names = NULL)
	cancerLoc <- gsub(".*cDatTest-(.*).csv$", "\\1", x)
	cancerLoc <- gsub("_", " ", cancerLoc)
	tmpData <- tmpData %>% mutate(cancerLocation = cancerLoc)
})
cancerFilesData$cancerLocation <- as.factor(cancerFilesData$cancerLocation)
```

Note that we could have also used `lapply` instead of `ldply`, but the resulting
object would be a list holding all the dataframes, and we would have to call
`dplyr::rbind_all` on it in order to make a dataframe from it.  Using `ldply`
is a nice convenient way to do it easier - it takes a list (of files), creates
a dataframe from every item (the dataframe for a specific cancer type), and
combines them all together into a dataframe. That's the plyr way!  
Let's just make sure our new dataset that we read matches the old one


```r
all.equal(cancerData, cancerFilesData)
```

```
## [1] TRUE
```

Awesome. Now to get rid of this huge mess, let's delete all these files


```r
file.remove(cancerFiles)
```

```
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [15] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
```

### Data manipulation and reshaping
Suppose I don't care about the specific cancer types, but I just want to know
how many US citizens had or died from cancer each year.  I will show two
equivalent ways to approach this: using `plyr::ddply` and `dplyr::group_by`.
I personally perfer the `ddply` way, but I'm not sure if it's because it's
objectively more elegant or if it's because I'm more used to it.


```r
cancersByYearPlyr <- ddply(cancerData,
													 .(year, stat),
													 summarize,
													 freq = sum(freq))
cancersByYearDplyr <- cancerData %>%
	group_by(year, stat) %>%
	summarize(freq = sum(freq)) %>%
	ungroup
```

Let's make sure that both methods resulted in the same dataframe


```r
identical(data.frame(cancersByYearPlyr), data.frame(cancersByYearDplyr))
```

```
## [1] TRUE
```

We should also see what they actually look like to ensure it's what we wanted


```r
print(head(cancersByYearDplyr))
```

```
## Source: local data frame [6 x 3]
## 
##   year   stat    freq
## 1 1999 deaths  479018
## 2 1999  cases 1116438
## 3 2000 deaths  485245
## 4 2000  cases 1163306
## 5 2001 deaths  485963
## 6 2001  cases 1173494
```

Yup, looks good. 
Now I want to calculate the mortality rate from cancer in each year. I can't
figure out a nice way to do it within tidy data, so my solution is to reshape
the data to be wide in order to perform the calculation.  I also add a
_mortalityRateDrop_ variable that shows how much mortality rate changed from
the previous year, which isn't terribly useful but I just wanted to use the
`dplyr::lag` function.


```r
cancersByYear <- cancersByYearPlyr
cancersByYear <- tbl_df(cancersByYear) %>%
	spread(stat, freq) %>%
	mutate(mortalityRate = deaths/cases,
				 mortalityRateDrop = lag(mortalityRate) - mortalityRate)
print(cancersByYear)
```

```
## Source: local data frame [13 x 5]
## 
##    year deaths   cases mortalityRate mortalityRateDrop
## 1  1999 479018 1116438     0.4290592                NA
## 2  2000 485245 1163306     0.4171258      0.0119333579
## 3  2001 485963 1173494     0.4141163      0.0030095408
## 4  2002 488864 1198921     0.4077533      0.0063630008
## 5  2003 488507 1248859     0.3911627      0.0165906516
## 6  2004 486177 1290606     0.3767044      0.0144582214
## 7  2005 490538 1313481     0.3734641      0.0032403315
## 8  2006 490534 1346799     0.3642221      0.0092419707
## 9  2007 493117 1384417     0.3561911      0.0080310398
## 10 2008 495310 1397595     0.3544017      0.0017894212
## 11 2009 496099 1407871     0.3523753      0.0020263444
## 12 2010 501960 1389071     0.3613638     -0.0089884938
## 13 2011 503039 1389143     0.3621218     -0.0007580082
```

### Add another source of data
One other thing I wanted to do is see how much of the population is affected
relative to the population size. I will read the file containing country populations
at different years, and extract from it only the US data for the relevant years,
and tidy it up a bit.  This example shows some more ways to be fancy with
`tidyr::gather`, `dplyr::mutate` and `dplyr::filter`


```r
popData <- tbl_df(read.csv(file.path(DATA_DIR, "worldPopByYear.csv")))
print(popData)
```

```
## Source: local data frame [258 x 58]
## 
##            Country.Name Country.Code    Indicator.Name Indicator.Code
## 1                 Aruba          ABW Population, total    SP.POP.TOTL
## 2               Andorra          AND Population, total    SP.POP.TOTL
## 3           Afghanistan          AFG Population, total    SP.POP.TOTL
## 4                Angola          AGO Population, total    SP.POP.TOTL
## 5               Albania          ALB Population, total    SP.POP.TOTL
## 6         Andean Region          ANR Population, total    SP.POP.TOTL
## 7            Arab World          ARB Population, total    SP.POP.TOTL
## 8  United Arab Emirates          ARE Population, total    SP.POP.TOTL
## 9             Argentina          ARG Population, total    SP.POP.TOTL
## 10              Armenia          ARM Population, total    SP.POP.TOTL
## ..                  ...          ...               ...            ...
## Variables not shown: X1960 (dbl), X1961 (dbl), X1962 (dbl), X1963 (dbl),
##   X1964 (dbl), X1965 (dbl), X1966 (dbl), X1967 (dbl), X1968 (dbl), X1969
##   (dbl), X1970 (dbl), X1971 (dbl), X1972 (dbl), X1973 (dbl), X1974 (dbl),
##   X1975 (dbl), X1976 (dbl), X1977 (dbl), X1978 (dbl), X1979 (dbl), X1980
##   (dbl), X1981 (dbl), X1982 (dbl), X1983 (dbl), X1984 (dbl), X1985 (dbl),
##   X1986 (dbl), X1987 (dbl), X1988 (dbl), X1989 (dbl), X1990 (dbl), X1991
##   (dbl), X1992 (dbl), X1993 (dbl), X1994 (dbl), X1995 (dbl), X1996 (dbl),
##   X1997 (dbl), X1998 (dbl), X1999 (dbl), X2000 (dbl), X2001 (dbl), X2002
##   (dbl), X2003 (dbl), X2004 (dbl), X2005 (dbl), X2006 (dbl), X2007 (dbl),
##   X2008 (dbl), X2009 (dbl), X2010 (dbl), X2011 (dbl), X2012 (dbl), X2013
##   (dbl)
```

```r
yearMin <- min(cancerData$year)
yearMax <- max(cancerData$year)
popDataClean <- popData %>%
	filter(Country.Code == "USA") %>%
	gather(year, population, starts_with("X")) %>%
	dplyr::select(year, population) %>%
	mutate(year = extract_numeric(year)) %>%
	filter(year %in% yearMin:yearMax)
print(popDataClean)
```

```
## Source: local data frame [13 x 2]
## 
##    year population
## 1  1999  279040000
## 2  2000  282162411
## 3  2001  284968955
## 4  2002  287625193
## 5  2003  290107933
## 6  2004  292805298
## 7  2005  295516599
## 8  2006  298379912
## 9  2007  301231207
## 10 2008  304093966
## 11 2009  306771529
## 12 2010  309326295
## 13 2011  311582564
```

### Calculate deaths per million
Next we add the population of the US to every row, and now we can calculate
cancer deaths per million people. I'll remove the _population_ variable
after using it because it won't be needed any more


```r
cancersByYear <- cancersByYear %>%
	left_join(popDataClean, by = "year") %>%
	mutate(deathsPerM = deaths / (population/1000000)) %>%
	dplyr::select(-population)
print(cancersByYear)
```

```
## Source: local data frame [13 x 6]
## 
##    year deaths   cases mortalityRate mortalityRateDrop deathsPerM
## 1  1999 479018 1116438     0.4290592                NA   1716.664
## 2  2000 485245 1163306     0.4171258      0.0119333579   1719.737
## 3  2001 485963 1173494     0.4141163      0.0030095408   1705.319
## 4  2002 488864 1198921     0.4077533      0.0063630008   1699.656
## 5  2003 488507 1248859     0.3911627      0.0165906516   1683.880
## 6  2004 486177 1290606     0.3767044      0.0144582214   1660.411
## 7  2005 490538 1313481     0.3734641      0.0032403315   1659.934
## 8  2006 490534 1346799     0.3642221      0.0092419707   1643.991
## 9  2007 493117 1384417     0.3561911      0.0080310398   1637.005
## 10 2008 495310 1397595     0.3544017      0.0017894212   1628.806
## 11 2009 496099 1407871     0.3523753      0.0020263444   1617.161
## 12 2010 501960 1389071     0.3613638     -0.0089884938   1622.752
## 13 2011 503039 1389143     0.3621218     -0.0007580082   1614.465
```

Very nice (well, we're looking at numbers of deaths... so I guess "nice"
isn't the right word to describe what we're seeing. But data-wise, very nice!)  
Now if we want to plot this information, it will be much easier to do so if we
get it back into a tidy tall/long format. So let's do that.


```r
cancersByYear <- cancersByYear %>%
	gather(stat, value, -year) %>%
	arrange(year)
print(head(cancersByYear))
```

```
## Source: local data frame [6 x 3]
## 
##   year              stat        value
## 1 1999            deaths 4.790180e+05
## 2 1999             cases 1.116438e+06
## 3 1999     mortalityRate 4.290592e-01
## 4 1999 mortalityRateDrop           NA
## 5 1999        deathsPerM 1.716664e+03
## 6 2000            deaths 4.852450e+05
```

Alright, we're ready to plot. In this tidy format, it's very trivial to plot
all the pieces of information for a given year. I will be omitting the 
mortalityRateDrop variable since it's not that informative and plotting
4 variables looks much better than 5 (a 2x2 square vs ... awkwardness) 


```r
p <-
	ggplot(cancersByYear %>% filter(stat != "mortalityRateDrop")) +
	geom_point(aes(x = as.factor(year), y = value), size = 3) + 
	geom_line(aes(x = as.factor(year), y = value, group = 1)) + 
	facet_wrap(~ stat, scales = "free_y") +
	theme_bw(20) +
	theme(axis.text.x = element_text(angle = 270, vjust = 0.5)) +
	xlab("year")
print(p)
```

<img src="markdown-figs/plot-big-data-1.png" title="plot of chunk plot-big-data" alt="plot of chunk plot-big-data" style="display: block; margin: auto;" />

```r
ggsave(file.path(HW_DIR, "cancerCombinedStats.pdf"), p)
```

```
## Saving 11 x 7 in image
```

So pretty! And we're done!

---------------------
### Aside: Trick to reorder levels of factor based on dataframe row order
If you have a dataframe arranged in a specific way and you want the levels
of a factor to be ordered in the same order as the rows are, use
`df <- mutate(df, col = factor(col, col))`  
Example:


```r
df <- data.frame(
	num = 5:1,
	word = c("five", "four", "three", "two", "one"))
levels(df$word)
```

```
## [1] "five"  "four"  "one"   "three" "two"
```

Levels are alphabetical by default


```r
df$word
```

```
## [1] five  four  three two   one  
## Levels: five four one three two
```

Right now the order (of the dataframe) is 5,4,3,2,1


```r
df <- df %>%
	arrange(num) %>%   # rearrange the df in the order we want (1,2,3,4,5)
	mutate(word = factor(word, word)) # this line reorders the factor in the same order
levels(df$word)
```

```
## [1] "one"   "two"   "three" "four"  "five"
```

Now the levels are 1,2,3,4,5
