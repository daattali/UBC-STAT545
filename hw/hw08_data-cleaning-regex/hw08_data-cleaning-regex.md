



# Homework 8 - Data cleaning
Dean Attali  
Nov 1 2014 

Last updated: 2014-11-07 23:56:26

## Overview
In this assignment I will clean up a dirty dataset to get it ready for analysis
using various string operations and regexes.  



### Loading dirty Gapminder
I will load the data with `strip.white` = TRUE and FALSE and compare the difference
#### strip.white = FALSE


```r
gDatRaw <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                      header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                      strip.white = FALSE)
```

#### strip.white = TRUE


```r
gDatRawStrip <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                      header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                      strip.white = TRUE)
```

#### Comparing strip.white versions
Let's do a very high-level inspection of the two


```r
str(gDatRaw)
```

```
## 'data.frame':	1698 obs. of  5 variables:
##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##  $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
##  $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
##  $ gdpPercap: num  779 821 853 836 740 ...
##  $ region   : chr  "Asia_Afghanistan" "Asia_Afghanistan" "Asia_Afghanistan" "Asia_Afghanistan" ...
```

```r
str(gDatRawStrip)
```

```
## 'data.frame':	1698 obs. of  5 variables:
##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##  $ pop      : num  8425333 9240934 10267083 11537966 13079460 ...
##  $ lifeExp  : num  28.8 30.3 32 34 36.1 ...
##  $ gdpPercap: num  779 821 853 836 740 ...
##  $ region   : chr  "Asia_Afghanistan" "Asia_Afghanistan" "Asia_Afghanistan" "Asia_Afghanistan" ...
```

Based on this, we can't really see any difference.  Let's dig deeper.


```r
all.equal(gDatRaw, gDatRawStrip)
```

```
## [1] "Component \"region\": 5 string mismatches"
```

Ah, it looks like some regions are not identical.  
To try to find the mismatching regions, I will find the difference between
the union of the regions in both datasets and the intersection of the regions 


```r
setdiff(union(gDatRaw$region, gDatRawStrip$region),
        intersect(gDatRaw$region, gDatRawStrip$region))
```

```
## [1] "Americas_Colombia    "     "    Asia_Jordan"          
## [3] "    Asia_Korea, Dem. Rep."
```

Now we see the difference. There are some regions that have extra whitespace
in the beginning/end of the region string.
Conclusion: according to the `read.table` documentation, `strip.white` strips
leading and trailing whitespace from unquoted character fields. That's pretty
self-explanatory, but it's nice to see it in action: when `strip.white = FALSE`,
some regions had extra unwanted whitespace. In our case, we don't care about
leading/trailing whitespace, so we want to work with the dataset that was
read using `whitespace = TRUE` - the version that removed whitespace. 


```r
gDat <- gDatRawStrip
```

### Splitting or merging the columns
Let's look at a bit of the data to see if any columns need to be split/merged


```r
head(gDat)
```

```
##   year      pop lifeExp gdpPercap           region
## 1 1952  8425333  28.801  779.4453 Asia_Afghanistan
## 2 1957  9240934  30.332  820.8530 Asia_Afghanistan
## 3 1962 10267083  31.997  853.1007 Asia_Afghanistan
## 4 1967 11537966  34.020  836.1971 Asia_Afghanistan
## 5 1972 13079460  36.088  739.9811 Asia_Afghanistan
## 6 1977 14880372  38.438  786.1134 Asia_Afghanistan
```

The _region_ column seems to be holding two pieces of information that could
be split (continent and country). Let's try using `tidyr::separate` to do that  
> `tidyr` is awesome! Two weeks ago I wouldn't have known to do this :)


```r
gDat <-
  gDat %>%
  separate("region", c("continent", "country"), sep = "_")
```

```
## Error: Values not split into 2 pieces at 361, 362, 363, 364, 365, 366
```

Hmm... there's some problem with a few of the rows.  Let's have a look at one
of these rows to see if it can give us any insight into why the `separate`
didnt work.


```r
gDat[361, ]
```

```
##     year     pop lifeExp gdpPercap
## 361 1952 2977019  40.477  1388.595
##                                                                       region
## 361 Africa_Cote dIvoire\n1957\t3300000\t42.469\t1500.895925\tAfrica_Cote dIvoire
```

Well, there's clearly a problem with the _region_ value of this observation...
It looks like the import was messed up on Cote d'Ivoire.  We can see that the
apostrophe is missing from the country's name, so an educated guess here would
be that the import step choked on the apostrophe/single quote.  
Upon looking at the `read.table` documentation, I learned that by default
it uses both souble and single quotes as quoting characters.  In our dataset
we don't have any quotes so I should disable them. Let's try doing data import 
again (with strip.white = TRUE) and also setting the quote character to nothing.


```r
gDat <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                   header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                   strip.white = TRUE, quote = "")
```

Now let's try splitting up the _region_ column again


```r
gDat <-
  gDat %>%
  separate("region", c("continent", "country"), sep = "_")
head(gDat)
```

```
##   year      pop lifeExp gdpPercap continent     country
## 1 1952  8425333  28.801  779.4453      Asia Afghanistan
## 2 1957  9240934  30.332  820.8530      Asia Afghanistan
## 3 1962 10267083  31.997  853.1007      Asia Afghanistan
## 4 1967 11537966  34.020  836.1971      Asia Afghanistan
## 5 1972 13079460  36.088  739.9811      Asia Afghanistan
## 6 1977 14880372  38.438  786.1134      Asia Afghanistan
```

Success!
### Missing values
Now we will see if there are any missing (NA or empty) values in the data
and attempt to fill them properly.  

To find out which rows (if any) have missing values, I use the `apply` function
to iterate row-by-row and see if there are any NA or empty strings.
Then based on the result we can see which rows contain missing values.


```r
rowsMissing <-
  apply(gDat, 1, function(row) {
    sum(is.na(row)) > 0 | sum(row == "") > 0
  })
gDat[which(rowsMissing), ]
```

```
##     year      pop lifeExp gdpPercap continent country
## 241 1952 14785584   68.75  11367.16            Canada
## 242 1957 17010154   69.96  12489.95            Canada
## 243 1962 18985849   71.30  13462.49            Canada
```

Alright, so it looks like a few of Canada's rows are missing the continent variable.  
For the sake of programming, let's play dumb and pretend we don't know where
Canada is. We'll first find out what continent the other Canada rows use,
and then use that value to fill in the blanks


```r
gDat %>%
  filter(country == "Canada") %>%
  dplyr::select(continent) %>%
  first()
```

```
##  [1] ""         ""         ""         "Americas" "Americas" "Americas"
##  [7] "Americas" "Americas" "Americas" "Americas" "Americas" "Americas"
```

```r
gDat[which(rowsMissing), "continent"] <- "Americas"
```

Now just a final check to make sure there are no more missing values


```r
rowsMissing <-
  apply(gDat, 1, function(row) {
    sum(is.na(row)) > 0 | sum(row == "") > 0
  })
gDat[which(rowsMissing), ]
```

```
## [1] year      pop       lifeExp   gdpPercap continent country  
## <0 rows> (or 0-length row.names)
```

Great!
### Inconsistent spelling/capitalization
Ah, the worst part of dealing with human-entered data...   
There are two character variables, _continent_ and _country_, so that's
where we will look for potential problems.  First let's examine the continents


```r
unique(gDat$continent)
```

```
## [1] "Asia"     "Europe"   "Africa"   "Americas" "Oceania"
```

Well, the continents looks pretty good, there are only a few of them and it's
easy enough to visually see that they are all legitimately unique continents.  

With countries we will need to follow a more complicated approach since there
are many countries and it's hard to visually look at all the names and find duplicates.
We know that every country should have one row per year. So if we know how many
years we have, we know how many observations per country we expect.  So how many
years are there in the data?


```r
length(unique(gDat$year))
```

```
## [1] 12
```

Ok, this means we expect 12 rows for every country.  
So now to know which countries have more than one spelling, we simply count how
many observations each country has, and note the ones that don't match the expected.


```r
which(table(gDat$country) != length(unique(gDat$year)))
```

```
##         Central african republic         Central African Republic 
##                               22                               23 
##                            china                            China 
##                               26                               27 
##                 Congo, Dem. Rep.       Congo, Democratic Republic 
##                               30                               31 
##                    Cote d'Ivoire                     Cote d'Ivore 
##                               34                               35 
## Democratic Republic of the Congo 
##                               39
```

This looks pretty good, we can see that _Central African Republic_ and "_China_
have multiple names that are simply different cases, the _Democratic Republic of
Congo_ has 3 conflicting names, and _Cote d'Ivoire_ has two names.  The integers
that we see here are the index of the country in the data, which isn't very useful.
If we want to know which spelling is the correct one for each country, we can
see how many rows correspond to each of the spellings, and combined with common sense
we can determine how to correct the other values.


```r
table(gDat$country)[table(gDat$country) != length(unique(gDat$year))]
```

```
## 
##         Central african republic         Central African Republic 
##                                4                                8 
##                            china                            China 
##                                4                                8 
##                 Congo, Dem. Rep.       Congo, Democratic Republic 
##                               10                                1 
##                    Cote d'Ivoire                     Cote d'Ivore 
##                               11                                1 
## Democratic Republic of the Congo 
##                                1
```

Now we can see that _Congo, Dem. Rep._ seems to be the consensus name for that
country, and that _Cote d'Ivore_ is probably a typo since it only appeared once.
For China and Central African Republic, the uncapitalized versions appear fewer
times, and we will simply capitalize them.  
We will use regular expressions to do these changes.

China, Central African Republic and Cote d'Ivoire are very trivial to fix because
there is only one alternative spelling.


```r
gDat <- 
  gDat %>%
  mutate(country = gsub("^Central african republic$",
                        "Central African Republic",
                        country)) %>%
  mutate(country = gsub("^china$",
                        "China",
                        country)) %>%
  mutate(country = gsub("^Cote d'Ivore$",
                        "Cote d'Ivoire",
                        country))
```

The situation is a little more complex for Congo since there are two different
wrong spellings that are not super similar.  We want to capture both
_Congo, Democratic Republic_ and _Democratic Republic of the Congo_, so
the regex will capture strings that either begin with "congo" and end with
"democratic republic", or the other way around (and ignore the case)


```r
gDat <-
  gDat %>%
  mutate(country = gsub("^((congo)|(democratic republic)).*((democratic republic)|(congo))$",
                        "Congo, Dem. Rep.",
                        country,
                        ignore.case = TRUE))
```

Let's make sure we don't have any more countries with multiple spellings


```r
table(gDat$country)[table(gDat$country) != length(unique(gDat$year))]
```

```
## named integer(0)
```

Sweet!
### Final check
Load the clean Gadpminder data and compare it to our version to see
if we cleaned it properly


```r
gDatClean <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear.txt"),
                        header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                        quote = "")
identical(gDat, gDatClean)  
```

```
## [1] FALSE
```

:(  
I know from past experience that if the order of the columns is not the same
in both dataframes, this will return `FALSE`. Let's just change the order of
the columns in my dataframe to match the order in the clean version 


```r
gDat <- gDat %>%
  dplyr::select(match(names(gDatClean), names(gDat)))
```

And now check again if they're the same


```r
identical(gDat, gDatClean)
```

```
## [1] TRUE
```

Hooray, the dirty data I read from the file is now clean and matches exactly
the good version! This means data cleaning is done :)
