#http://wonder.cdc.gov/cancer.html

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)

DATA_DIR <- file.path("data")
HW_NAME <- "hw5-tidyr_dplyr_join_xtable_ggplot_ddply"
HW_DIR <- file.path("hw", HW_NAME)

tolowerfirst <- function(x) {
  return(paste0(tolower(substring(x, 1, 1)), substring(x, 2)))
}
print(getwd())

d <- tbl_df(read.table(file.path(DATA_DIR, "cancerDeathsUS.txt"), header = T))
print(d)
colnames(d) <- tolowerfirst(colnames(d))
d <- d %>% dplyr::select(leading.Cancer.Sites, year, deaths) %>%
  rename(cancerLocation = leading.Cancer.Sites)
levels(d$cancerLocation)
d <- d %>% filter(cancerLocation != "All Sites Combined") %>% droplevels

i <- tbl_df(read.table(file.path(DATA_DIR, "cancerIncidenceUS.txt"), header = T))
print(i)
colnames(i) <- tolowerfirst(colnames(i))
i <- i %>% dplyr::select(leading.Cancer.Sites, year, count) %>%
  rename(cancerLocation = leading.Cancer.Sites,
         cases = count)
levels(i$cancerLocation)
i <- i %>% filter(cancerLocation != "All Sites Combined") %>% droplevels

setdiff(
  union(levels(d$cancerLocation),levels(i$cancerLocation)),
  intersect(levels(d$cancerLocation),levels(i$cancerLocation)))

i$cancerLocation <- revalue(i$cancerLocation, c("Urinary Bladder, invasive and in situ" = "Urinary Bladder"))

cancerData <- left_join(d, i, by = c("cancerLocation", "year"))
cancerData <- cancerData %>% gather(stat, freq, deaths, cases) %>%arrange(year,cancerLocation)

# order cancer types by most cases at most recent timepoint
cancerLocationsOrder <- cancerData %>%
  filter(stat == "cases",
         year == max(year)) %>%
  arrange(desc(freq)) %>%
  first %>%
  as.character

cancerData$cancerLocation <-
  factor(cancerData$cancerLocation, levels = cancerLocationsOrder)

c22 <- c("dodgerblue2","#E31A1C", # red
         "green4",
         "#6A3D9A", # purple
         "#FF7F00", # orange
         "black","gold1",
         "skyblue2","#FB9A99", # lt pink
         "palegreen2",
         "#CAB2D6", # lt purple
         "#FDBF6F", # lt orange
         "gray70", "khaki2",
         "maroon","orchid1","deeppink1","blue1",
         "darkturquoise","green1","yellow4",
         "brown")

p <-
  ggplot(cancerData, aes(x = year, y = freq)) +
  geom_point(aes(col = cancerLocation, group = cancerLocation), size = 2) +
  geom_line(aes(col = cancerLocation, group = cancerLocation), size = 0.7) +
  facet_wrap(~stat) +
  theme_bw(15) +
  scale_colour_manual(values = c22)
#+ plot-results, echo=F, warning=F, fig.width = 8
print(p)
ggsave(file.path(HW_DIR, "cancerStats.pdf"), p)


cc<- ddply(cancerData, .(year, stat), summarize, freq = sum(freq))
ccc<- cancerData %>% group_by(year, stat) %>% summarize(freq = sum(freq))
identical(data.frame(cc), data.frame(ccc))





ccc <- tbl_df(ccc) %>% spread(stat, freq) %>%
  mutate(mortalityRate = deaths/cases,
         mortalityRateDrop = lag(mortalityRate) - mortalityRate)


a <- tbl_df(read.csv(file.path(DATA_DIR, "worldPopByYear.csv")))
print(a)
yearMin <- min(cancerData$year)
yearMax <- max(cancerData$year)
a <- a %>% filter(Country.Code == "USA") %>%
  gather(year, population, starts_with("X")) %>%
  dplyr::select(year, population) %>%
  mutate(year = extract_numeric(year)) %>%
  filter(year %in% yearMin:yearMax)


ccc <- ccc %>% left_join(a, by = "year") %>% mutate(deathsPerM = deaths / (population/1000000))
ccc <- ccc %>% dplyr::select(-population) %>%
  gather(stat, value, -year) %>%
  arrange(year)

p <-
  ggplot(ccc %>% filter(stat != "mortalityRateDrop")) +
  geom_point(aes(x = as.factor(year), y = value), size = 3) + 
  geom_line(aes(x = as.factor(year), y = value, group = 1)) + 
  facet_wrap(~ stat, scales = "free_y") +
  theme_bw(20) +
  theme(axis.text.x = element_text(angle = 270, vjust = 0.5)) +
  xlab("year")
print(p)

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
cancerFiles <- list.files(HW_DIR, pattern = "^cDatTest-.*csv$", full.names = T)
cancerFilesData <- lapply(cancerFiles, function(x) {
  tmpData <- read.table(file.path(x), header = T, sep = ",", row.names = NULL)
  cancerLoc <- gsub("cDatTest-(.*).csv", "\\1", x)
  cancerLoc <- gsub("_", " ", cancerLoc)
  tmpData <- tmpData %>% mutate(cancerLocation = cancerLoc)
})
cancerData2 <- rbind_all(cancerFilesData)
cancerData2$cancerLocation <- as.factor(cancerData2$cancerLocation)
identical(cancerData, cancerData2)
all.equal(cancerData, cancerData2)
file.remove(cancerFiles)

if (FALSE) {
  library(knitr)
  library(markdown)
  
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