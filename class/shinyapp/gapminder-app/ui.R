shinyUI(fluidPage(
	titlePanel("Gapminder Shiny app"),
	
	sidebarLayout(
		sidebarPanel(
								 uiOutput("country_select_ui"),
								 sliderInput("year_range", 
								 						label = "Range of years:",
								 						min = 1952, max = 2007, value = c(1955, 2005),
								 						step = 5)
		),
		mainPanel(
							textOutput("output_country"),
							tableOutput("gapminder_table")
		)
	)
))