shinyUI(fluidPage(
	titlePanel("Gapminder Shiny app"),
	
	sidebarLayout(
		sidebarPanel(
			h2("What country and years do you want to see?"),
								 uiOutput("country_select_ui"),
								 sliderInput("year_range", 
								 						label = "Range of years:",
								 						min = 1952, max = 2007,
								 						value = c(1955, 2005),
								 						format = "####",
								 						step = 5)
		),
		mainPanel(
							h3(textOutput("output_country"), align = "center"),
							tableOutput("gapminder_table"),
							plotOutput("ggplot_gdp_vs_country")
		)
	)
))