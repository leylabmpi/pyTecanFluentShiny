# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Dilution"),
  fluidRow(
    column(6,
      h5('Create Tecan worklist & labware files for diluting samples')
    )
  ),
  fluidRow(
    verbatimTextOutput('script_out')
  ),
  fluidRow(
    column(2,
      br(),
      actionButton("runBtn", "Run command"),
      br(),
      br()
    ),
    column(2,
      br(),
      uiOutput('download_btn'),
      br(),
      br()
    )
  ),
  tabsetPanel(
    tabPanel("Description",
      fluidRow(
        column(12,
               h3('Input'),
               h4('The input is an Excel or tab-delimited file with columns:'),
               h5('"TECAN_labware_name"'),
               h6('Name of the labware containing samples (eg., "Sample plate 1")'),
               h5('"TECAN_labware_type"'),
               h6('Type of the labware containing samples (eg., "96 Well Eppendorf TwinTec PCR")'),
               h5('"TECAN_target_position"'),
               h6('The position (well) of your samples in your labware (numeric values; column-wise ordering'),
               h5('"TECAN_sample_conc"'),
               h6('The concentration of your samples (units = ng/ul)'),
               hr(),
               h3('Output'),
               h4('The output files consist of the following files:'),
               h5('*_conc.txt'),
               h6('A table with the post-dilution concentrations (ng/ul)'),
               h5('*_labware.txt'),
               h6('A table listing the labware to be placed on the robot worktable'),
               h5('*.gwl'),
               h6('A "worklist" file with instructions for the robot'),
               hr(),
               h3('Notes'),
               tags$ul(
                        tags$li('Sample locations in plates numbered are column-wise'),
                        tags$li('All volumes are in ul')
          )
        )    
      )
    ),
    tabPanel("Input/Output", 
      fluidRow(
        column(12,
               h4('Input & Output')
        )
      ),
      fluidRow(
        column(4,
               fileInput("ConcFile", "Concentration File: Excel or tab-delim file of sample concentrations"),
               selectInput('format',
                           label = "File  excel or tab-delimited. If blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'Tab-delimited' = 'tab'),
                           selected = 'blank')
        ),
        column(4,
               checkboxInput("header", 
                             label = "Header in the file?",
                             value = TRUE),
               textInput('rows', 
                         label = 'Which rows (not including header) of the column file to use ("all"=all rows; "1-48"=rows 1-48)', 
                         value = 'all')
        ),
        column(4,
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_dilute")
        )
      )
    ),
    tabPanel("Dilution", 
      fluidRow(
        column(12,
          h4('Dilution parameters')
        )
      ),
       fluidRow(
         column(4,
                br(),
                numericInput('dilution',
                             label = "Target dilution concentration (ng/ul)",
                             value = 5.0)
        ),
        column(4,
               br(),
               numericInput('minvolumne',
                            label = "Minimum sample volume to use",
                            value = 2.0),
               numericInput('maxvolumne',
                            label = "Maximum sample volume to use",
                            value = 30.0)
        ),
        column(4,
               br(),
               numericInput('mintotal',
                            label = "Minimum post-dilution total volume",
                            value = 10.0),
               textInput('dlabware_name',
                            label = "Name of labware containing the dilutant",
                            value = "100ml_1"),
               selectInput('dlabware_type',
                           label = "Name of labware containing the dilutant",
                           choices = c('100ml trough' = '100ml_1',
                                       '1.5ml Eppendorf' = '1.5ml Eppendorf',
                                       '2.0ml Eppendorf' = '2.0ml Eppendorf',
                                       '96 well plate' = '96 Well Eppendorf TwinTec PCR'),
                           selected = "100ml trough")
        )
      )
    ),
    tabPanel("Destination Plate", 
      fluidRow(
        column(12,
               h4('Destination plate parameters')
        )
      ),             
      fluidRow(
        column(4,
               br(),
               textInput('destname',
                         label = "Destination plate labware name",
                         value = "Diluted DNA plate")
        ),
        column(4,
               br(),
               selectInput('desttype',
                            label = "Destination labware type",
                            choices = c('96-well' = '96 Well Eppendorf TwinTec PCR',
                                        '384-well' = '384 Well Biorad PCR'),
                            selected = '96-well')
        ),
        column(4,
               br(),
               numericInput('deststart',
                            label = "Starting position (well) number on destination plate",
                            value = 1)
        )
      )
    ),
    tabPanel("Example Input",
      fluidRow(
        column(12, 
               h4('Concentration File format example'),
               h5('Note: the table can include more columns')
          )
        ),
      fluidRow(
        column(12, DT::dataTableOutput('example_tbl'))
        )
     )
  )
))
