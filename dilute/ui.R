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
        column(4,
               br(),
               h4('Description'),
               h5('The input is an Excel or tab-delimited file with columns:'),
               tags$ul(
                 tags$li('Sample labware  (eg., "96 Well[001]")'),
                 tags$li('Sample location (numeric value; minimum of 1)'),
                 tags$li('Sample concentration (numeric value; units=ng/ul)')
               ),
               br(),
               h5('Notes:'),
               tags$ul(
                 tags$li('You can designate the input table columns for each value (see options)'),
                 tags$li('Sample locations in plates numbered are column-wise'),
                 tags$li('All volumes are in ul')
               )
        ),
        column(4,
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
        ),
        column(4,
               br(),
               h4('Concentration File settings'),
               numericInput('labware',
                            label = "Column containing the sample labware IDs",
                            value = 1),
               numericInput('location',
                            label = "Column containing the sample location numbers",
                            value = 2),
               numericInput('conc',
                            label = "Column containing the sample concentrations",
                            value = 3),
               textInput('rows',
                         label = 'Which rows (not including header) of the column file to use ("all"=all rows; "1-48"=rows 1-48)',
                         value = 'all')
        )
      )
    ),
    tabPanel("Example Input",
      fluidRow(
        column(12, br(), hr(), h4('Concentration File format example:'))
       ),
      fluidRow(
        column(12, DT::dataTableOutput('example_tbl'))
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
               textInput('dlabware',
                            label = "Labware containing the dilutant",
                            value = "100ml_1")
        )
      )
    ),
    tabPanel("Destination Plate", 
      fluidRow(
        column(4,
               br(),
               textInput('dest',
                         label = "Destination plate labware ID on TECAN worktable",
                         value = "96 Well[001]")
        ),
        column(4,
               br(),
               selectInput('desttype',
                            label = "Destination plate labware type (# of wells)",
                            choices = c('96-well' = 96,
                                        '384-well' = 384),
                            selected = 96)
        ),
        column(4,
               br(),
               numericInput('deststart',
                            label = "Start well number on destination plate",
                            value = 1)
        )
      )
    )
  )
))
