####################################################
#   Haplotype-Based Artificial Intelligence for    #
#          SARS-COV-2 Variant Prediction(HAI)      #
#             Lue Ping Zhao & Michael Zhao         #
#                    June 15, 2022                 #
####################################################
source("hai.R")
m_parameters=c(prob_threshold=0.99, min_prob=0.1, min_AA=2)
#results=HAI(preddata, variant_prop, variant_corehap)

####################################
# User interface                   #
####################################
addResourcePath("assets", file.path(getwd(), "www"))
ui <- fluidPage(theme = shinytheme("superhero"),shinyjs::useShinyjs(),
tags$head(tags$script(src="assets/js/gisaid/gisaid.js")),
# HTML("Example: <span epi_isl_id='EPI_ISL_430811'>EPI_ISL_430811</span>"),
								# Page header
								tags$style(
									type = 'text/css',
									'table.dataTable td {white-space: nowrap;}'
								),
								titlePanel(div(h1('AI for SARS-COV-2 Variant Predictions'),div(style="display: flex; align-items: center;",h5("Enabled by data from "),
															 tags$a(target="_blank", img(src="assets/GISAIDlogo.png", style="margin-left: 8px;", height="25%", width="35%", align="left"),href="https://gisaid.org")),
															 ),
													 windowTitle='AI for SARS-COV-2 Variant Predictions'),
								#a("Terms of Use",target="_blank",href="./HAI_TOU.pdf"),
								
								# Input values
								sidebarPanel(
									div(style="display: flex; align-items: center;",
										HTML("<h3>Input Data</h3>"),
										actionButton("info1", "", style="border-radius: 50%; margin-left: 10px; height:30px; width: 30px;display:flex;", icon = icon("info", lib='font-awesome')),
									),
									wellPanel(
										tags$label("Step 1 - Enter your data",style="float: none; width: 100%;"),
										actionLink("addlink", "Insert example data"),
										tags$textarea(id="predata", rows=10, cols=100, style="float: none; width:100%;", "EPI_ISL_2535080,EPI_ISL_9164243,EPI_ISL_6945682,EPI_ISL_10910169,EPI_ISL_759612,EPI_ISL_12500362,EPI_ISL_other1, EPI_ISL_other2"),
										uiOutput('file1_ui'),
										tags$label("Step 2 - Submit your job",style="float: none; width: 100%;"),
										actionButton("submitbutton", "Predict", class = "btn btn-primary"),
										actionButton("clear", "Clear", class = "btn btn-primary"),
									),
								),
								# Output panel
								mainPanel(
									verbatimTextOutput('contents'),
									navbarPage(title=("RESULTS"),
														 tabPanel("Summary",value="",
														 				 wellPanel(
														 				 	div(id='table-container', style='width: 100% !important; overflow-x: auto; overflow-y: auto; height: 70vh;',
														 				 			DT::dataTableOutput('summary'),  # Prediction results table
														 				 	),
														 				 	downloadButton("downloadData", "Download")
														 				 )
														 ),
														 tabPanel("Probability", value="",
														 				 wellPanel(
														 				 	div(id='table-container', style='width: 100% !important; overflow-x: auto; overflow-y: auto; height: 70vh;',
														 				 			DT::dataTableOutput('probability'),  # Prediction results table
														 				 	),
														 				 	downloadButton("downloadprob", "Download")
														 				 )
														 				 ),
														 tabPanel("Kappa", value="",
														 				 wellPanel(
														 				 	div(id='table-container', style='width: 100% !important; overflow-x: auto; overflow-y: auto; height: 70vh;',
														 				 			DT::dataTableOutput('kappa'),  # Kappa analysis with hai prediction
														 				 	),
														 				 	downloadButton("downloadkappa", "Download")
														 				 )
														 ),
														 tabPanel("Kappapp", value="",
														 				 wellPanel(
														 				 	div(id='table-container', style='width: 100% !important; overflow-x: auto; overflow-y: auto; height: 70vh;',
														 				 			DT::dataTableOutput('kappapp'),  # Kappa analysis with post-prediction modification
														 				 	),
														 				 	downloadButton("downloadkappapp", "Download")
														 				 )
														 ),
														 
														 tabPanel("Your Data", value="",
														 				 wellPanel(
														 				 	div(id='table-container', style='width: 100% !important; overflow-x: auto; overflow-y: auto; height: 70vh;',
														 				 			DT::dataTableOutput('inputdata'),  # Prediction results table
														 				 	),
														 				 	downloadButton("downloadinput", "Download")
														 				 )
														 ),
									)	
								),
		HTML("<script>gisaid.addPopups();</script>"),
																	HTML("<div>We would like to thank the GISAID Initiative and are grateful to all of the data contributors, i.e. the Authors, 
			the Originating laboratories responsible for obtaining the specimens, and the Submitting laboratories for 
			generating the genetic sequence and metadata and sharing via the GISAID Initiative, on which this research is based. 
			GISAID data provided on this website are subject to GISAID’s <a target='_blank' href='https://www.gisaid.org/registration/terms-of-use/'>Terms and Conditions</a>. <br/>
			Elbe, S., and Buckland-Merrett, G. (2017) Data, disease and diplomacy: GISAID’s innovative contribution to global health. Global Challenges, 1:33-46. DOI: <a target='blank' href='https://onlinelibrary.wiley.com/doi/10.1002/gch2.1018'>10.1002/gch2.1018</a> PMCID: <a target='_blank' href='https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6607375/'>31565258</a>.</div><br/>"),

								div(
								actionLink("contactLink1", "Academic contact"), br(),
									actionLink("contactLink2", "Non-academic contact"),
									div(style='display: flex; justify-content: space-between;', p("Copyright © 2022 Fred Hutchinson Cancer Research Center.  All rights reserved."), a("Terms of Use",target="_blank",href="assets/HAI_TOU.pdf"),
)
								),
)

####################################
# Server                           #
####################################
server <- function(input, output, session) {
	# Default example data
	observe({
		FASTADATA <- ''
		fastaexample <- 'EPI_ISL_2535080,EPI_ISL_9164243,EPI_ISL_6945682,EPI_ISL_10910169,EPI_ISL_759612,EPI_ISL_12500362,EPI_ISL_8932290,EPI_ISL_6167645, 
		EPI_ISL_3130164,EPI_ISL_1287358,EPI_ISL_9490703,EPI_ISL_12361600,EPI_ISL_2565162,EPI_ISL_2865667,EPI_ISL_1660382,EPI_ISL_6859660, EPI_ISL_8336438,EPI_ISL_1092367,EPI_ISL_11748114,EPI_ISL_4245269,EPI_ISL_8079238,EPI_ISL_10795053,EPI_ISL_3554123,EPI_ISL_2343683, EPI_ISL_8488617'
		xdata=""
		m_parameters=c(prob_threshold=0.99, min_prob=0.1, min_AA=2)
		
		if(input$addlink>0) {
			isolate({
				FASTADATA <- fastaexample
				updateTextInput(session, inputId = "predata", value = FASTADATA)
			})
		}
	})
	
	# Input Data
	datasetInput <- reactive({  
		inFile <- input$file1 
		inTextbox <- input$predata
		shinyjs::logjs("hello12");
		
		if (inTextbox=="" & is.null(inFile)) {
			xdata=""
			return(data.frame(WARNING="Please insert/upload prediction data in GISAID format"))
		} else {
			if (is.null(inFile)) {
				xdata <- inTextbox
				xdata=gsub(" ","", xdata)
				xdata=strsplit2(xdata,",")
				#xdata=xdata[substr(xdata,1,8)=="EPI_ISL_"]
				xdata=unique(xdata)
				#xdata=intersect(xdata, rownames(metadata))
				xN=length(xdata)
				# Status/Output Text Box
				output$contents <- renderPrint({
					if (input$submitbutton>0 & xN>xN_limit) return(paste("Exceed the limit of", xN_limit, "viruses", sep=" "))
				})
				if (is.null(xdata)) return("invalid GISAID ID or no selected data") else {
					if (xN<=xN_limit) {
						others=setdiff(xdata, rownames(metadata))
						xdata=intersect(xdata, rownames(metadata))
						results<-HAI(metadata[xdata,], variant_prop, variant_corehap,m_parameters)
						if (length(others)>0){
							results$summary<-rbind(results$summary, matrix(NA, length(others), NCOL(results$summary), 
																														 dimnames = list(others, colnames(results$summary))))							
						}
						return(results)						
					}
				}
			} else {
				xdata <- read.csv(inFile$datapath, row.names = 1)
				xN=NROW(xdata)
				# Status/Output Text Box
				output$contents <- renderPrint({
					if (input$submitbutton>0 & xN>xN_limit) return(paste("Exceed the limit of", xN_limit, "viruses", sep=" "))
					if (input$submitbutton>0 & sum(colnames(xdata)=="AA.Substitutions")==0) return("Where is AA.Substitution column?")
				})
				if (xN<=xN_limit) {
					results<-HAI(xdata, variant_prop, variant_corehap,m_parameters)
					return(results)						
				}
			}
		}
	})
	
	observeEvent(input$clear, {
		updateTextInput(session, inputId='predata', value = "")
	})
	
	observeEvent(input$info1, {
		showModal(modalDialog(
			title = h2("INPUT DATA"),
			"For GISAID viruses (www.gisaid.org), use a string of virus ID, separated by comma.  
			You can directly input several virus ID in the text box, or can place them in a ASCII file.", br(),br(),
			"For your own viral data, it is best to submit your data to GISAID, and download metadata for uploading.
			If you want to prepare your data file with rows of viruses and columns of variables.
			The critical column is AA.substitutions as specified in GISAID",
			easyClose = TRUE,
			footer = NULL
		))
	})
	
	observeEvent(input$contactLink1, {
		showModal(modalDialog(
			title = h2("Academic Contact"),
			HTML("Contact Lue Ping Zhao &lt;lzhao@fredhutch.org&gt; for academic collaborations. <br>
"),
			easyClose = TRUE,
			footer = NULL
		)
		)
	})
	
	observeEvent(input$contactLink2, {
		showModal(modalDialog(
			title = h2("For for-profit uses, Contact"),
			"Contact Mr. Patrick Shelby <jpshelby@fredhutch.org> for collaborations",
			easyClose = TRUE,
			footer = NULL
		)
		)
	})
	
	output$file1_ui <- renderUI({
		input$clear ## Create a dependency with the reset button
		fileInput('file1', 'or upload file',accept=c('text','.csv','.txt'))
	})
	
	# Prediction results
	output$summary <- DT::renderDataTable({
		if (input$submitbutton>0) { 
			isolate(datasetInput()[["summary"]])
		} 
	})
	
	# Prediction probabilities
	output$probability <- DT::renderDataTable({
		if (input$submitbutton>0) { 
			isolate(datasetInput()[["probability"]]) 
		} 
	})
	
	# Kappa
	output$kappa <- DT::renderDataTable({
		if (input$submitbutton>0) { 
			isolate(datasetInput()[["kappa"]]) 
		} 
	})
	
	# Kappa
	output$kappapp <- DT::renderDataTable({
		if (input$submitbutton>0) { 
			isolate(datasetInput()[["kappa_pp"]]) 
		} 
	})
	
	# Input data
	output$inputdata <- DT::renderDataTable({
		if (input$submitbutton>0) { 
			isolate(datasetInput()[["inputdata"]]) 
		} 
	})
	
	# Downloadable csv of key result
	output$downloadData <- downloadHandler(
		filename = function() {
			paste(input$dataset, "****.csv", sep = "")
		},
		content = function(file) {
			write.csv(datasetInput()[["summary"]], file, row.names = T)
		}
	)
	
	# Downloadable csv of posterior probabilities
	output$downloadprob <- downloadHandler(
		filename = function() {
			paste(input$dataset, "****.csv", sep = "")
		},
		content = function(file) {
			write.csv(datasetInput()[["probability"]], file, row.names = T)
		}
	)

		# Downloadable csv of kappa frequencies
	output$downloadkappa <- downloadHandler(
		filename = function() {
			paste(input$dataset, "****.csv", sep = "")
		},
		content = function(file) {
			write.csv(datasetInput()[["kappa"]], file, row.names = T)
		}
	)
	
	# Downloadable csv of kappa frequencies for post-prediction modifications
	output$downloadkappapp <- downloadHandler(
		filename = function() {
			paste(input$dataset, "****.csv", sep = "")
		},
		content = function(file) {
			write.csv(datasetInput()[["kappa_pp"]], file, row.names = T)
		}
	)
	# Downloadable csv of inputdata
	output$downloadinput <- downloadHandler(
		filename = function() {
			paste(input$dataset, "****.csv", sep = "")
		},
		content = function(file) {
			write.csv(datasetInput()[["inputdata"]], file, row.names = T)
		}
	)

}

####################################
# Create the shiny app             #
####################################
# Do not remove - this is needed for deployment:
if (!interactive()) {
	options(shiny.port=3838L, shiny.host="0.0.0.0", launch.browser=FALSE)
}

shinyApp(ui = ui, server = server)
