# Dean Attali
# November 21 2014

# This is the ui portion of a shiny app shows cancer data in the United States

library(shiny)

shinyUI(fluidPage(
	
	# add custom JS and CSS
	singleton(
		tags$head(includeScript(file.path('www', 'message-handler.js')),
							includeScript(file.path('www', 'helper-script.js')),
							includeCSS(file.path('www', 'style.css'))
		)
	),
	
	div(id = "headerSection",
		titlePanel("Cancer data in the United States"),
	
		# author info
		em(
			span("Created by "),
			a("Dean Attali", href = "mailto:daattali@gmail.com"), br(),
			span("November 21 2014")
		)
	),
	
	# show a loading message initially
	div(
		id = "loadingContent",
		h3("Loading...")
	),	
	
	# all content goes here, and is hidden initially until the page fully loads
	div(id = "allContent", class = " hideme",
		sidebarLayout(
			sidebarPanel(
				h3("Filter data"),
				
				selectInput(
					"subsetType", "",
					c("Show all cancer types" = "all",
						"Select specific types" = "specific"),
					selected = "all"),
				
				conditionalPanel(
					"input.subsetType == 'specific'",
					uiOutput("cancerTypeUi")
				), br(),
				
				checkboxInput("showIndividual",
											"Show data per each cancer type",
											TRUE), br(),
				
				span("Years:"),
				textOutput("yearText", inline = TRUE), br(),
				uiOutput("yearUi"), br(),

				uiOutput("variablesUi"),shiny::hr(),
				
				actionButton("updateBtn", "Update Data"),
				
				br(), br(), br(), br(),
				p("Data was obtained from ",
					a("the United States CDC",
						href = "http://wonder.cdc.gov/cancer.html",
						target = "_blank"))
			),
			mainPanel(wellPanel(
				tabsetPanel(
					id = "resultsTab", type = "tabs",
					
					# tab showing the data in table format
					tabPanel(
						title = "Show data", id = "tableTab",
						
						downloadButton("downloadData", "Download table"),
						br(), br(),
						span("Table format:"),
						radioButtons(inputId = "tableViewForm",
												 label = "",
												 choices = c("Wide" = "wide", "Long" = "long"),
												 inline = TRUE),
						br(),
						tableOutput("dataTable")
					),
					
					# tab showing the data as plots
					tabPanel(
						title = "Plot data", id = "plotTab",
						
						downloadButton("downloadPlot", "Save figure"),
						br(), br(),
						plotOutput("dataPlot")
					)
				)
			))
		)
	)
))