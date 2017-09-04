# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Dilution"),
  fluidRow(
    column(6,
      h5('Create a Tecan worklist file for diluting samples')
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
    tabPanel("Input/Output", 
      fluidRow(
        column(7,
               br(),
               h4('Description'),
               h5('The input is an Excel or tab-delimited file with columns:'),
               tags$ul(
                 tags$li('"TECAN_labware_name"  (eg., "96 Well Eppendorf TwinTec PCR")'),
                 tags$li('"TECAN_labware_type" (numeric value; minimum of 1)'),
                 tags$li('"TECAN_target_position" = The location of your samples in your labware (plate)'),
                 tags$li('"TECAN_sample_conc" (numeric value; units=ng/ul)')
               ),
               br(),
               h5('Notes:'),
               tags$ul(
                 tags$li('Sample locations in plates numbered are column-wise'),
                 tags$li('All volumes are in ul')
               )
        ),
        column(5,
               br(),
               h4('Input & Output'),
               fileInput("ConcFile", "Concentration File: Excel or tab-delim file of sample concentrations"),
               selectInput('format',
                           label = "File  excel or tab-delimited. If blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'Tab-delimited' = 'tab'),
                           selected = 'blank'),
               checkboxInput("header", 
                             label = "Header in the file?",
                             value = TRUE),
               br(),
               br(),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_dilute")
        )
      )
    ),
    tabPanel("Dilution", 
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
        column(12, br(), h4('Concentration File format example:'))
        ),
      fluidRow(
        column(12, DT::dataTableOutput('example_tbl'))
        )
     )
  )
))
