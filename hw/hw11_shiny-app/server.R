# Dean Attali
# November 21 2014

# This is the server portion of a shiny app shows cancer data in the United
# States

source("helpers.R")

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)

cDatRaw <- getData()
plotCols <- getPlotCols()

shinyServer(function(input, output, session) {
	
	# we need to have a quasi-variable flag to indicate when the plot
	# area was adjusted
	dataValues <- reactiveValues(
		appLoaded = FALSE
	)
	
	observe({
		if (dataValues$appLoaded) {
			return(NULL)
		}
		if(!is.null(input$years)) {
			dataValues$appLoaded <- TRUE
			
			session$sendCustomMessage(type = "equalizeHeight",
																message = list(target = "dataPlot",
																							 by = "resultsTab")) 			
		}
	})

	cDat <- reactive({
		# add dependency on the update button (only update when button is clicked)
		input$updateBtn	
		
		isolate(
			if (is.null(input$years)) {
				return(cDatRaw)
			}
		)
		
		data <- cDatRaw
		
		isolate({
			data <- data %>%
				filter(year >= input$years[1] & year <= input$years[2])
			
			if (!is.null(input$variablesSelect)) {
				data <- data %>%
					filter(stat %in% input$variablesSelect)
			}
			
			if (input$subsetType == "specific" & !is.null(input$cancerType)) {
				data <- data %>%
					filter(cancerType %in% input$cancerType)
			}
			
			if (!input$showIndividual) {
				data <- data %>%
					group_by(year, stat) %>%
					summarise(value =
											ifelse(stat[1] != "mortalityRate",
														 sum(value),
														 mean(value))) %>%
					ungroup %>%
					data.frame
			}
		})

		data
	})
	
	cDatTable <- reactive({
		data <- cDat()
		
		data <- data %>%
			mutate(value = formatC(data$value, format = "fg", digits = 2))		
		
		if (input$tableFormWide) {
			data <- data %>%
				spread(stat, value)
		}
		
		data
	})
	
	# create select box input for choosing cancer types
	output$cancerTypeUi <- renderUI({
		selectizeInput("cancerType", "",
									 levels(cDatRaw$cancerType),
									 selected = NULL, multiple = TRUE,
									 options = list(placeholder = "Select cancer types"))
	})	

	output$variablesUi <- renderUI({
		selectizeInput("variablesSelect", "Variables to show:",
									 unique(as.character(cDatRaw$stat)),
									 selected = unique(cDatRaw$stat), multiple = TRUE,
									 options = list(placeholder = "Select variables to show"))
	})	
	
	
	# create slider for selecting year range
	# NOTE: there are some minor bugs with sliderInput rendered in renderUI
	# https://github.com/rstudio/shiny/issues/587
	output$yearUi <- renderUI({
		sliderInput("years", 
							label = "Years:",
							min = min(cDatRaw$year), max = max(cDatRaw$year),
							value = c(min(cDatRaw$year), max(cDatRaw$year)),
							step = 1,
							format = "####")
	})
	
	output$dataTable <- renderTable({
		data <- cDatTable()
		if (is.null(data) | nrow(data) == 0) {
			return(NULL)
		}
		data
	},
	include.rownames=FALSE)
	
	output$downloadData <- downloadHandler(
		filename = function() { 
			"cancerData.csv"
		},
		
		content = function(file) {
			write.table(x = cDatTable(),
									file = file,
									quote = FALSE, sep = ",", row.names = FALSE)
		}
	)	
	
	output$downloadPlot <- downloadHandler(
		filename = function() {
			"cancerDataPlot.pdf"
		},
		
		content = function(file) {
			pdf(file = file, width = 12, height = 10)
			print(buildPlot())
			dev.off()
		}
	)	
	
	buildPlot <- reactive({
		p <-
			ggplot(cDat()) +
			aes(x = as.factor(year), y = value)
		
		isolate(
			if (input$showIndividual) {
				p <- p + aes(group = cancerType, col = cancerType)
			} else {
				p <- p + aes(group = 1)
			}
		)
		p <- p +
			facet_wrap(~stat, scales = "free_y", ncol = 2) +
			geom_point() +
			geom_line(show_guide = FALSE) +
			theme_bw() +
			theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
			scale_color_manual(values = plotCols) +
			theme(legend.position = "bottom")+
			guides(color = guide_legend(title = "",
																	ncol = 4,
																	override.aes = list(size = 4))) +
			xlab("Year") + ylab("") +
			theme(panel.grid.minor = element_blank(),
						panel.grid.major.x = element_blank())
		
		p
	})	
	
	output$dataPlot <-
		renderPlot(
			{
				buildPlot()
			},
			height = function(){ input$plotDim },
			width = function(){ input$plotDim },
			units = "px",
			res = 100
		)

	# ------------ show form content and hide loading message
	session$sendCustomMessage(type = "hide",
														message = list(id = "loadingContent"))
	session$sendCustomMessage(type = "show",
														message = list(id = "allContent")) 	
})
