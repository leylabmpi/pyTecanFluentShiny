# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Map2Robot"),
  fluidRow(
    column(12,
      h5('Convert a qPCR setup table file into a Tecan worklist file for barcoded PCR setup')
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
               h6('Create a worklist file for the TECAN Fluent robot for qPCR setup.'),
               h6('The input is an exported plate layout from the BioRad qPCR software.'),
               h6('The file format should be Excel or CSV.'),
               br(),
               h5('Generating the input table:'),
               h6('Just create a plate layout for your experimet, then export and add some extra columns:'),
              tags$ul(
                tags$li('"Sample labware"  (labware containing sample DNA/RNA; eg., "96-Well[001]")'),
                tags$li('"Sample location"  (numeric; minimum of 1)'),
                tags$li('"Sample volume"  (numeric)'),
                tags$li('"MM name"  (Name of master mix; this allows for multiple mastermixes)'),
                tags$li('"MM volume"  (Volume of master mix in PCR rxn)'),
                tags$li('"Water volume"  (Volume of water in PCR rxn)')
               ),
               br(),
               h5('Notes:'),
               tags$ul(
                tags$li('Sample locations in plates numbered are column-wise'),
                tags$li('The setup file (input table) MUST have a header (capitalization doesn\'t matter)'),
                tags$li('All volumes are in ul')
               )
        ),
        column(5,
               br(),
               h4('Input & Output'),
               fileInput("SetupFile", "An Excel or CSV file with experimental setup (see Description)"),
               selectInput('format',
                           label = "File  excel or tab-delimited. If blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'Tab-delimited' = 'tab'),
                           selected = 'blank'),
               br(),
               br(),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_qPCR")
        )
      )
    ),
    tabPanel("Example input",
      fluidRow(
        column(12, h4('qPCR Setup File format example:'))
      ),
      fluidRow(
        column(12, DT::dataTableOutput('example_tbl'))
      )
    ),
    tabPanel("Other Options", 
      fluidRow(
        column(12, br())
      ),
      fluidRow(
        column(4,
               h4("Destination labware"),
               textInput('dest',
                         label = "Destination plate labware ID on TECAN worktable",
                         value = "96 Well[001]"),
               selectInput('desttype',
                           label = "Destination plate labware type (# of wells)",
                           choices = c('96-well' = 96,
                                       '384-well' = 384),
                           selected = 384)
        ),
        column(4,
               h4('Source labware'),
               textInput('mm',
                         label = "Mastermix source labware ID on TECAN worktable",
                         value = "Tubes[001]"),
               numericInput('mmloc',
                            label = "Mastermix start position on source labware",
                            value = 1),
               textInput('water',
                         label = "Water source labware ID on TECAN worktable",
                         value = "100ml[001]"),
               numericInput('waterloc',
                            label = "Water start position on source labware",
                            value = 1)
        ),
        column(4,
               h4('Liquid classes'),
               textInput('mmliq',
                         label = "Mastermix liquid class",
                         value = "MasterMix Free Multi"),
               textInput('sampliq',
                         label = "Sample liquid class",
                         value = "Water Contact Wet Single"),
               textInput('waterliq',
                         label = "Water liquid class",
                         value = "Water Contact Wet Single")
        )
      )
    )
  )
))
