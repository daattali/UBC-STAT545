library(plyr)
library(dplyr)
library(magrittr)
library(rvest)
library(rsalad)     # devtools::install_github("daattali/rsalad")
library(gapminder)  # devtools::install_github("jennybc/gapminder")
library(jsonlite)
library(ggplot2)

wikiPage <- html("http://en.wikipedia.org/wiki/List_of_countries_by_research_and_development_spending")
table <- wikiPage %>% html_node("table")
table2 <- html_table(table)
tableClean <- table2 %>%
	dplyr::select(-grep("(Rank)|(Source)|(Expenditure.*per capita)|(Year)", colnames(table2), ignore.case = TRUE))
countryIdx <- grep("country", colnames(tableClean), ignore.case = TRUE)
totalExpenseIdx <- grep("Expenditure", colnames(tableClean), ignore.case = TRUE)
gdpPercentIdx <- grep("%", colnames(tableClean), ignore.case = TRUE)
colnames(tableClean)[countryIdx] <- "country"
colnames(tableClean)[totalExpenseIdx] <- "expense_RnD_billion_USD"
colnames(tableClean)[gdpPercentIdx] <- "expense_RnD_Percent_of_GDP"

tableClean %<>%
	mutate(expense_RnD_Percent_of_GDP = as.numeric(sub("%", "", expense_RnD_Percent_of_GDP))) %>%
	mutate(expense_RnD_billion_USD = as.numeric(sub("([0-9\\.]*).*", "\\1", expense_RnD_billion_USD)))



nobelApiBase <- "http://api.nobelprize.org/"
getCoutries <- "v1/country.csv"
api <- paste0(nobelApiBase,getCoutries)
cs<-read.table(header = TRUE,
					 text = RCurl::getURL(api),
					 row.names = NULL, sep=",", quote="\"")

a<-sapply(tableClean$country, function(x) { cs[grep(x, cs$name)[1],]$code }) %>%
	data.frame() %>%
	set_colnames("countryCode") %>% mutate(country = rownames(.)) %>% set_rownames(NULL)
a[is.na(a$countryCode), "country"]
cs %>% filter(code == "US")
a[a$country == "United States", "countryCode"] <- "US"
a[a$country == "United Kingdom", "countryCode"] <- "GB"


tableMerged <- left_join(tableClean, a, by = "country")
tableMerged <- tableMerged[complete.cases(tableMerged), ]
tableMerged <- tableMerged %>% mutate(countryCode = as.character(countryCode)) %>% droplevels



myFromJSON <- function(x) {
	fromJSON(gsub("\r\n"," ", x))
}

b<-sapply(tableMerged$countryCode, function(x) {
	laureatesBornInCountry <- paste0("/v1/laureate.json?bornCountryCode=",x)
	api <- paste0(nobelApiBase, laureatesBornInCountry)
	response <- RCurl::getURL(api)
	if (response == "" || length(myFromJSON(response) %>% extract2(1)) == 0) {
		born <- c()
	} else {
		born <- myFromJSON(response) %>% extract2(1) %>% select(id) %>% first
	}
	laureatesDiedInCountry <- paste0("/v1/laureate.json?diedCountryCode=",x)
	api <- paste0(nobelApiBase, laureatesDiedInCountry)
	response <- RCurl::getURL(api)
	if (response == "" || length(myFromJSON(response) %>% extract2(1)) == 0) {
		died <- c()
	} else {
		died <- myFromJSON(response) %>% extract2(1) %>% select(id) %>% first
	}
	laureatesFromCountry <- unique(c(born, died))
	numLaureates <- length(laureatesFromCountry)
	numLaureates
})


b <- b %>%
	data.frame() %>%
	set_colnames("numLaureates") %>% mutate(countryCode = rownames(.)) %>% set_rownames(NULL)

tableMergedFinal <- left_join(tableMerged, b, by = "countryCode")



countryPopulationPage <- html("http://www.geonames.org/countries/")
table <- countryPopulationPage %>% html_nodes("table") %>% extract2(2) %>%
	html_table

tableC <- 
	table %>%
	set_colnames(sub("ISO-3166alpha2", "countryCode", colnames(.)) %>% tolowerfirst) %>%
	mutate(population = as.numeric((gsub(",", "", population))))

popTable <-
	tableC %>%
	dplyr::select(countryCode, population)
	


all<-left_join(tableMergedFinal, popTable, by="countryCode")
	
sum(!complete.cases(all))

all %<>%
	mutate(laureatesPerM = numLaureates / population * 1000000) %>%
	arrange(desc(numLaureates))

# correlation of numlaurents vs total spending and of numlaureates per capita vs $ of spending on R%D/capita

ggplot(all,aes(numLaureates,expense_RnD_billion_USD))+geom_point()
ggplot(all,aes(laureatesPerM,expense_RnD_Percent_of_GDP))+geom_point()

good <- all %>% filter(numLaureates >= 5)
ggplot(good,aes(numLaureates,expense_RnD_billion_USD))+geom_point()
ggplot(good,aes(laureatesPerM,expense_RnD_Percent_of_GDP))+geom_point()



# first tried using csv, but certain countries were giving me problems and it was
# difficult to understand where the problem was
# next i tried json, which also gave problems. sometimes an empty list was returned
# as "" and sometimes as {"laureates":[]}
# another problem was that two countries had "\r\n" in the text, which was
# causing errors in the JSON parsing, so I had to remove those
# mapping countries across sources was a b***h. Especially the fact that the nobel
# laureates api specifically returned a mapping from United Kingdom -> UK, yet
# a search for "UK" returned 0 while a search for GB returned many.