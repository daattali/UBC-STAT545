library(ggplot2)

gdURL <- "http://tiny.cc/gapminder"
gDat <- read.delim(file = gdURL) 

shinyServer(function(input, output) {

	one_country_data  <- reactive({
		cat("country:\n")
		cat(input$select_country)
		if(is.null(input$select_country)) {
			return(NULL)
		}				
	  subset(gDat, country == input$select_country &
	  			 	     year >= input$year_range[1] & year <= input$year_range[2] )
	})
	
	output$gapminder_table <- renderTable({ 
		cat("render table\n")
		one_country_data()
	})
	output$output_country <- renderText({
		paste("Country: ", input$select_country)
	})
	output$country_select_ui <- renderUI({
		selectInput("select_country", 
								label = "Country",
								choices = levels(gDat$country)
		)
	})
	output$ggplot_gdp_vs_country <- renderPlot({
		cat("render plot\n")
		if(is.null(one_country_data())) {
			return(NULL)
		}		
		p <- ggplot(one_country_data(), aes(x = year, y = gdpPercap))
		p + geom_point()
	})
})