gdURL <- "http://tiny.cc/gapminder"
gDat <- read.delim(file = gdURL) 

shinyServer(function(input, output) {
	
	output$gapminder_table <- renderTable({ 
		subset(gDat, country == input$select_country & year >= input$year_range[1] &
					 	year <= input$year_range[2])
	})
	output$output_country <- renderText({
		paste("Country selected", input$select_country)
	})
	output$country_select_ui <- renderUI({
		selectInput("select_country", 
								label = "Country",
								choices = levels(gDat$country)
		)
	})
})