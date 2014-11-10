#!usr/bin/make -f

# Note: to keep this makefile OS-independent (run on Windows+Liunx+Mac), 
# I moved all low-level shell commands into R

all: hw09_pipelines-make-report.md hw09_pipelines-make-report.html

clean:
	Rscript -e 'suppressWarnings(file.remove("globalterrorismdb.csv", "globalterrorismdb_clean.csv", "injuryByAttack.csv", "injuryByAttack-attackTypeOrder.txt", "injuryByAttack.png", "attackByRegion5YearBin.csv", "attackByRegion5YearBin-regionOrder.txt", "attackByRegion5YearBin.png", "hw09_pipelines-make-report.md", "hw09_pipelines-make-report.html"))'
	Rscript -e 'unlink("hw09_pipelines-make-report_files", recursive = TRUE)'

.PHONY: all clean
.DELETE_ON_ERROR:
.SECONDARY:


# Step 0: Download raw data (70MB, could take a few minutes)
globalterrorismdb.csv: 
	Rscript -e 'cat(file="globalterrorismdb.csv", RCurl::getURL("https://raw.githubusercontent.com/daattali/statsTerrorismProject/master/globalterrorismdb.csv", ssl.verifypeer = FALSE))'


# Step 1: Clean the raw data

globalterrorismdb_clean.csv: script01_clean-data.R globalterrorismdb.csv
	Rscript $<

# If you don't want to download the raw data because it's too large,
# uncomment this target and comment the previous one instead
#globalterrorismdb_clean.csv:
#	Rscript -e 'cat(file="globalterrorismdb_clean.csv", RCurl::getURL("https://raw.githubusercontent.com/daattali/statsTerrorismProject/master/globalterrorismdb_clean.csv", ssl.verifypeer = FALSE))'	


# Step 2: Calculate injuries per attack type
injuryByAttack.csv injuryByAttack-attackTypeOrder.txt : script02_calc-injuries-by-attack.R  globalterrorismdb_clean.csv
	Rscript $<


# Step 3: Plot injuries per attack type
injuryByAttack.png: script03_fig-injuries-by-attack.R injuryByAttack.csv injuryByAttack-attackTypeOrder.txt
	Rscript $<
	Rscript -e 'file.remove("Rplots.pdf")'


# Step 4: Calculate terrorist attacks per region per 5 year interval
attackByRegion5YearBin.csv attackByRegion5YearBin-regionOrder.txt : script04_calc-attack-per-region-year-bin.R globalterrorismdb_clean.csv
	Rscript $<


# Step 5: Plot attacks per regions per 5 year interval
attackByRegion5YearBin.png: script05_fig-attack-per-region-year-bin.R attackByRegion5YearBin.csv attackByRegion5YearBin-regionOrder.txt
	Rscript $<
	Rscript -e 'file.remove("Rplots.pdf")'


# Step 6: Render the report
hw09_pipelines-make-report.md hw09_pipelines-make-report.html : hw09_pipelines-make-report.Rmd injuryByAttack.png attackByRegion5YearBin.png
	Rscript -e 'rmarkdown::render("$<")'
