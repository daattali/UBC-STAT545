# Homework 11

Building a Shiny app

### Demo
The app was deployed both to
[shinyapps.io](http://daattali.shinyapps.io/cancer-data) and to
[the UBC stats shinyapps server](http://shinyapps.stat.ubc.ca/daattali/cancer-data/). 

### Details
I built an app that allows users to explore data about cancer incidences/deaths
in the US.  The data was taken from
[the US CDC](http://wonder.cdc.gov/cancer.html).  

The app lets the user filter the data by year, cancer type, and which variables
to show.  The user can also choose to group all cancer information together
for every given year to see overall combined cancer stats instead of individual
cancer types.  
The data is visualized in both a tabular form and a plot. In both cases the user
can download the data.  In table form, the user can choose to view the data as
wide format (default for table since it's easier on the eyes) or as long format
(generally better to choose this if you want to perform further analysis).  

Note: The app doesn't look too complicated, but a look at the source code
shows that there are many advanced features (e.g. waiting for form to load,
sending messages to javascript to perform tasks, getting inputs from
javascript).  Most of these are the result of very persistent Googling and
experimenting since almost all these techniques are not documented anywhere.

### Code
The source code for the app is [all here](./cancer-data).  To run the app locally,
ensure `shiny` package is installed and loaded, set your working directory to this directory, and run `runApp("cancer-data")`.
