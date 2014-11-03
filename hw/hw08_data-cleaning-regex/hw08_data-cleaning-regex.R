#+ define-dirs, include = F
DATA_DIR <- file.path("data")
HW_NAME <- "hw08_data-cleaning-regex"
HW_DIR <- file.path("hw", HW_NAME)

#+ spin-code, eval = F, include = F
# Note for clarity:
# Instead of manually creating both a .R and a .Rmd files that have almost
# identical R code, this .R script is the only file I am writing manually.
# I am using the `knitr::spin` function to turn this R script into Rmarkdown
# and then converting it into markdown and HTML formats in the code. This code
# is wrapped around an if(FALSE) so that it is not executed when the script is ran,
# and it will only do this R -> markdown/HTML conversion when these lines are
# ran explicitly. 
if (FALSE) {
  library(knitr)
  library(markdown)
  
  spinMyR <- function() {
    opts_knit$set(root.dir = getwd())
    opts_knit$set(base.dir = HW_DIR)
    opts_chunk$set(fig.path = "markdown-figs-")
    opts_chunk$set(tidy = FALSE)
    
    spin(file.path(HW_DIR, paste0(HW_NAME, ".R")), knit = F)
    knit(file.path(HW_DIR, paste0(HW_NAME, ".Rmd")),
         file.path(HW_DIR, paste0(HW_NAME, ".md")))
    markdownToHTML(file.path(HW_DIR, paste0(HW_NAME, ".md")),
                   file.path(HW_DIR, paste0(HW_NAME, ".html")))
  }
  spinMyR()
}

#' # Homework 8 - Data cleaning
#' Dean Attali  
#' Nov 1 2014 
#' 
#' Last updated: `r Sys.time()`
#' 
#' ## Overview
#' In this assignment I will clean up a dirty dataset to get it ready for analysis
#' using various string operations and regexes.  

#+ load-libs, include = F
library(plyr)
library(dplyr)
library(tidyr)

#' ### Loading dirty Gapminder
#' I will load the data with `strip.white` = TRUE and FALSE and compare the difference

#' #### strip.white = FALSE
gDatRaw <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                      header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                      strip.white = FALSE)
#' #### strip.white = TRUE
gDatRawStrip <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                      header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                      strip.white = TRUE)

#' #### Comparing strip.white versions
#' Let's do a very high-level inspection of the two
str(gDatRaw)
str(gDatRawStrip)
#' Based on this, we can't really see any difference.  Let's dig deeper.

all.equal(gDatRaw, gDatRawStrip)
#' Ah, it looks like some regions are not identical.  

#' To try to find the mismatching regions, I will find the difference between
#' the union of the regions in both datasets and the intersection of the regions 
setdiff(union(gDatRaw$region, gDatRawStrip$region),
        intersect(gDatRaw$region, gDatRawStrip$region))
#' Now we see the difference. There are some regions that have extra whitespace
#' in the beginning/end of the region string.

#' Conclusion: according to the `read.table` documentation, `strip.white` strips
#' leading and trailing whitespace from unquoted character fields. That's pretty
#' self-explanatory, but it's nice to see it in action: when `strip.white = FALSE`,
#' some regions had extra unwanted whitespace. In our case, we don't care about
#' leading/trailing whitespace, so we want to work with the dataset that was
#' read using `whitespace = TRUE` - the version that removed whitespace. 
gDat <- gDatRawStrip


#' ### Splitting or merging the columns
#' Let's look at a bit of the data to see if any columns need to be split/merged
head(gDat)
#' The _region_ column seems to be holding two pieces of information that could
#' be split (continent and country). Let's try using `tidyr::separate` to do that  
#' > `tidyr` is awesome! Two weeks ago I wouldn't have known to do this :)
gDat <-
  gDat %>%
  separate("region", c("continent", "country"), sep = "_")
#' Hmm... there's some problem with a few of the rows.  Let's have a look at one
#' of these rows to see if it can give us any insight into why the `separate`
#' didnt work.
gDat[361, ]

#' Well, there's clearly a problem with the _region_ value of this observation...
#' It looks like the import was messed up on Cote d'Ivoire.  We can see that the
#' apostrophe is missing from the country's name, so an educated guess here would
#' be that the import step choked on the apostrophe/single quote.  
#' Upon looking at the `read.table` documentation, I learned that by default
#' it uses both souble and single quotes as quoting characters.  In our dataset
#' we don't have any quotes so I should disable them. Let's try doing data import 
#' again (with strip.white = TRUE) and also setting the quote character to nothing.
gDat <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear_dirty.txt"),
                   header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                   strip.white = TRUE, quote = "")
#' Now let's try splitting up the _region_ column again
gDat <-
  gDat %>%
  separate("region", c("continent", "country"), sep = "_")
head(gDat)
#' Success!

#' ### Missing values
#' Now we will see if there are any missing (NA or empty) values in the data
#' and attempt to fill them properly.  
#'
#' To find out which rows (if any) have missing values, I use the `apply` function
#' to iterate row-by-row and see if there are any NA or empty strings.
#' Then based on the result we can see which rows contain missing values.
rowsMissing <-
  apply(gDat, 1, function(row) {
    sum(is.na(row)) > 0 | sum(row == "") > 0
  })
gDat[which(rowsMissing), ]

#' Alright, so it looks like a few of Canada's rows are missing the continent variable.  
#' For the sake of programming, let's play dumb and pretend we don't know where
#' Canada is. We'll first find out what continent the other Canada rows use,
#' and then use that value to fill in the blanks
gDat %>%
  filter(country == "Canada") %>%
  dplyr::select(continent) %>%
  first()
gDat[which(rowsMissing), "continent"] <- "Americas"

#' Now just a final check to make sure there are no more missing values
rowsMissing <-
  apply(gDat, 1, function(row) {
    sum(is.na(row)) > 0 | sum(row == "") > 0
  })
gDat[which(rowsMissing), ]
#' Great!


#' ### Inconsistent spelling/capitalization
#' Ah, the worst part of dealing with human-entered data...   
#' There are two character variables, _continent_ and _country_, so that's
#' where we will look for potential problems.  First let's examine the continents
unique(gDat$continent)

#' Well, the continents looks pretty good, there are only a few of them and it's
#' easy enough to visually see that they are all legitimately unique continents.  
#' 
#' With countries we will need to follow a more complicated approach since there
#' are many countries and it's hard to visually look at all the names and find duplicates.
#' We know that every country should have one row per year. So if we know how many
#' years we have, we know how many observations per country we expect.  So how many
#' years are there in the data?
length(unique(gDat$year))

#' Ok, this means we expect `r length(unique(gDat$year))` rows for every country.  
#' So now to know which countries have more than one spelling, we simply count how
#' many observations each country has, and note the ones that don't match the expected.
which(table(gDat$country) != length(unique(gDat$year)))
#' This looks pretty good, we can see that _Central African Republic_ and "_China_
#' have multiple names that are simply different cases, the _Democratic Republic of
#' Congo_ has 3 conflicting names, and _Cote d'Ivoire_ has two names.  The integers
#' that we see here are the index of the country in the data, which isn't very useful.
#' If we want to know which spelling is the correct one for each country, we can
#' see how many rows correspond to each of the spellings, and combined with common sense
#' we can determine how to correct the other values.
table(gDat$country)[table(gDat$country) != length(unique(gDat$year))]

#' Now we can see that _Congo, Dem. Rep._ seems to be the consensus name for that
#' country, and that _Cote d'Ivore_ is probably a typo since it only appeared once.
#' For China and Central African Republic, the uncapitalized versions appear fewer
#' times, and we will simply capitalize them.  
#' We will use regular expressions to do these changes.
#' 
#' China, Central African Republic and Cote d'Ivoire are very trivial to fix because
#' there is only one alternative spelling.
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
#' The situation is a little more complex for Congo since there are two different
#' wrong spellings that are not super similar.  We want to capture both
#' _Congo, Democratic Republic_ and _Democratic Republic of the Congo_, so
#' the regex will capture strings that either begin with "congo" and end with
#' "democratic republic", or the other way around (and ignore the case)
gDat <-
  gDat %>%
  mutate(country = gsub("^((congo)|(democratic republic)).*((democratic republic)|(congo))$",
                        "Congo, Dem. Rep.",
                        country,
                        ignore.case = TRUE))

#' Let's make sure we don't have any more countries with multiple spellings
table(gDat$country)[table(gDat$country) != length(unique(gDat$year))]
#' Sweet!

#' ### Final check
#' Load the clean Gadpminder data and compare it to our version to see
#' if we cleaned it properly
gDatClean <- read.table(file.path(DATA_DIR, "gapminderDataFiveYear.txt"),
                        header = TRUE, sep = "\t", row.names = NULL, as.is = TRUE,
                        quote = "")
identical(gDat, gDatClean)  
#' :(  
#' I know from past experience that if the order of the columns is not the same
#' in both dataframes, this will return `FALSE`. Let's just change the order of
#' the columns in my dataframe to match the order in the clean version 
gDat <- gDat %>%
  dplyr::select(match(names(gDatClean), names(gDat)))

#' And now check again if they're the same
identical(gDat, gDatClean)
#' Hooray, the dirty data I read from the file is now clean and matches exactly
#' the good version! This means data cleaning is done :)