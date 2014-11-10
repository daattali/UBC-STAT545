#!usr/bin/make -f

# Note: to keep this makefile OS-independent (run on Windows+Liunx+Mac), 
# I moved all low-level shell commands into R

all: hw09_pipelines-make-report.md

clean:
	Rscript -e 'file.remove("globalterrorismdb.csv", "globalterrorismdb_clean.csv", "injuryByAttack.csv", "attackTypeOrder.txt", "injuryByAttack.png")'

.PHONY: all clean
.DELETE_ON_ERROR:
.SECONDARY:


# Download raw data (70MB, could take a few minutes)
globalterrorismdb.csv: 
	Rscript -e 'cat(file="globalterrorismdb.csv", RCurl::getURL("https://raw.githubusercontent.com/daattali/statsTerrorismProject/master/globalterrorismdb.csv", ssl.verifypeer = FALSE))'


# Step 1: Clean the raw data

# If you don't want to download the raw data because it's too large,
# uncomment this target and comment the next one instead
globalterrorismdb_clean.csv:
	Rscript -e 'cat(file="globalterrorismdb_clean.csv", RCurl::getURL("https://raw.githubusercontent.com/daattali/statsTerrorismProject/master/globalterrorismdb_clean.csv", ssl.verifypeer = FALSE))'	

#globalterrorismdb_clean.csv: script01_clean-data.R globalterrorismdb.csv
#	Rscript $<


# Step 2: Calculate injuries per attack type
injuryByAttack.csv attackTypeOrder.txt : script02_calc-injuries-by-attack.R globalterrorismdb_clean.csv
	Rscript $<


# Step 3: Plot injuries per attack type
injuryByAttack.png: script03_fig-injuries-by-attack.R injuryByAttack.csv attackTypeOrder.txt
	Rscript $<
	Rscript -e 'file.remove("Rplots.pdf")'


hw09_pipelines-make-report.md: injuryByAttack.png