gDat <- read.delim("gapminderDataFiveYear.txt")
library(plyr)

yearMin <- min(gDat$year)
jFun <- function(x) {
  estCoefs <- coef(lm(lifeExp ~ I(year - yearMin), x))
  names(estCoefs) <- c("intercept", "slope")
  return(estCoefs)
}
jCoefs <- ddply(gDat, ~country + continent, jFun)
str(jCoefs)
write.table(jCoefs, "jCoefs.txt", quote = FALSE, sep = "\t", row.names = FALSE)

# factor levels reordering
head(levels(jCoefs$country))
jCoefs <- within(jCoefs, country <- reorder(country, intercept))
head(levels(jCoefs$country))

# factor level reordering won't save in an output file, but this will
countryLevels <- data.frame(original = head(levels(jCoefs$country)))
write.table(jCoefs, "jCoefs.txt", quote = FALSE, sep = "\t", row.names = FALSE)
saveRDS(jCoefs, "jCoefs.rds")
rm(jCoefs)
jCoefsTable <- read.delim("jCoefs.txt")
jCoefsRDS <- readRDS("jCoefs.rds")
countryLevels$postRDS <- head(levels(jCoefsRDS$country))
countryLevels$postTable <- head(levels(jCoefsTable$country))
print(countryLevels)

# dput and dget
jCoefs <- readRDS("jCoefs.rds")
dput(jCoefs, "jCoefs-dput.txt")
jCoefsPut <- dget("jCoefs-dput.txt")
countryLevels$postPut <- head(levels(jCoefsPut$country))
countryLevels

# delete the files we created
file.remove(list.files(pattern = "^jCoef"))

# plot to PDF
pdf("testFigure_method1.pdf")
plot(1:10)
dev.off()
list.files(pattern = "^testFigure*")

# plot to PDF more freestyle
plot(5:20)
dev.print(pdf, "testFigure_method2.pdf")
list.files(pattern = "^testFigure*")
file.remove(list.files(pattern = "^testFigure*"))