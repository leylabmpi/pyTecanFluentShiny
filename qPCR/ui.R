# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("qPCR"),
  fluidRow(
    column(12,
      h5('Convert a qPCR setup table file into a Tecan worklist file')
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
               h5('First, make sure to reads the NGS pipeline docs on', tags$a(href="https://confluence.eb.local:8443/display/D3PROTOCOL/NGS+pipelines", "Confluence")),
               br(),
               h4('Description'),
               h6('This app creates worklist and labware files for the TECAN Fluent robot.'),
               h6('The input is an exported plate layout from the BioRad qPCR software.'),
               h6('The robot will setup the qPCR assay based on the BioRad qPCR plate layout'),
               br(),
               h5('Generating the input table:'),
               h6('Just create a plate layout for your experiment, then export by doing the following:'),
               tags$ul(
                 tags$li('In the plate layout view, click "spreadsheet view/importer"'),
                 tags$li('Right click on the table, then clik "Export to Excel"')
                 ),
              h5('Input table format:'),
              h6('See the "Example Input" tab for an example'),
              tags$ul(
                tags$li('"Sample labware name"'),
                tags$ul(
                  tags$li('Labware name containing the sample (any name that you want)'),
                  tags$li('Exmaple: "source plate"')
                ),
                tags$li('"Sample labware type"'),
                tags$ul(
                  tags$li('Labware type (must EXACTLY match an existing labware type)'),
                  tags$li('Labware types:'),
                  tags$ul(
                    tags$li('"1.5ml Eppendorf"'),
                    tags$li('"2ml Eppendorf"'),
                    tags$li('"5ml Eppendorf"'),
                    tags$li('"10ml Falcon"'),
                    tags$li('"PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR"'),
                    tags$li('"PCR Adapter 384 Well and 384 Well Biorad PCR"')
                  )
                ),
                tags$li('"Sample location"'),
                tags$ul(
                  tags$li('Location of sample in the source plate'),
                  tags$li('Numeric; column-wise indexing'),
                  tags$li('For eppendorf tubes, use the location on the tube holder')
                ),
                tags$li('"Sample volume"'),
                tags$ul(
                  tags$li('Numeric; sample volume in ul')
                ),
                tags$li('"MM name"'),
                tags$ul(
                  tags$li('Name of master mix for that sample'),
                  tags$li('This allows for multiple master mixes per assay')
                ),
                tags$li('"MM volume"'),
                tags$ul(
                  tags$li('Volume of master mix in PCR rxn')
                ),
                tags$li('"Water volume"'),
                tags$ul(
                  tags$li('Volume of water in PCR rxn')
                )
               ),
               br(),
               h5('Notes:'),
               tags$ul(
                tags$li('Sample locations in plates numbered are column-wise (left-to-right)'),
                tags$li('The setup file (input table) MUST have a header (capitalization doesn\'t matter)'),
                tags$li('Extra columns in the setup file are ignored (besides those listed above'),
                tags$li('For labware: "PCR Adapter" means that the plate MUST be placed on a metal adapter'),
                tags$li('All volumes are in ul')
               )
        ),
        column(5,
               br(),
               h4('Input & Output'),
               fileInput("SetupFile", "An Excel or CSV file with experimental setup (see Description)"),
               selectInput('format',
                           label = "File  excel or tab-delimited. If left blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'csv' = 'csv',
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
    tabPanel("Other Options", 
      fluidRow(
        column(12, br())
      ),
      fluidRow(
        column(4,
               h4('Source labware'),
               selectInput('mm_type',
                           label = "Labware type containing the Mastermix",
                           choices = c('25ml trough (in 100ml trough)' = '25ml_1 waste',
                                       '1.5ml Eppendorf tube' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf tube' = '2ml Eppendorf waste',
                                       '5ml Eppendorf tube' = '5ml Eppendorf waste',
                                       '10ml Falcon tube' = '10ml Falcon'),
                           selected = '2ml Eppendorf waste'),
               selectInput('water_type',
                           label = "Labware type containing the PCR water",
                           choices = c('25ml trough (in 100ml trough)' = '25ml_1 waste',
                                       '1.5ml Eppendorf tube' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf tube' = '2ml Eppendorf waste',
                                       '5ml Eppendorf tube' = '5ml Eppendorf waste',
                                       '10ml Falcon tube' = '10ml Falcon'),
                           selected = '25ml_1 waste')
        ),
        column(4,
               h4("Destination labware"),
               textInput('dest',
                         label = "Destination plate labware ID on TECAN worktable",
                         value = "Destination plate"),
               selectInput('dest_type',
                           label = "Destination plate labware name",
                           choices = c('96 Well Eppendorf TwinTec PCR' = '96 Well Eppendorf TwinTec PCR',
                                       'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR' = 'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR',
                                       '384 Well Biorad PCR' = '384 Well Biorad PCR',
                                       'PCR Adapter 384 Well and 384 Well Biorad PCR' = 'PCR Adapter 384 Well and 384 Well Biorad PCR'),
                           selected = '384 Well Biorad PCR')
        ),
        column(4,
               h4('Liquid classes'),
               textInput('mm_liq',
                         label = "MasterMix liquid class",
                         value = "MasterMix Free Single Bottom Disp"),
               textInput('samp_liq',
                         label = "Sample liquid class",
                         value = "Water Free Single Wall Disp"),
               textInput('water_liq',
                         label = "Water liquid class",
                         value = "Water Free Single Wall Disp"),
               h4('Other'),
               numericInput('n_tip_reuse',
                            label = "Number of tip re-uses for aliquoting the mastermix",
                            value = 4, min = 1, max = 12)
        )
      )
    ),
    tabPanel("Example Input",
             fluidRow(
               column(12, h4('qPCR Setup File format example:'))
             ),
             fluidRow(
               column(12, DT::dataTableOutput('example_tbl'))
             )
    ),
    tabPanel("TECAN webserver",
             fluidRow(
               br(),
               column(12, htmlOutput('tecan_ws'))
             )
    )
  )
))
