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
               h5('First, make sure to reads the NGS pipeline docs on', tags$a(href="https://confluence.eb.local:8443/display/D3PROTOCOL/NGS+pipelines", "Confluence")),
               h3('Input'),
               h4('The input is an Excel or tab-delimited file with columns:'),
               h5('"TECAN_labware_name"'),
               h6('Name of the labware containing samples (eg., "Sample plate 1")'),
               h5('"TECAN_labware_type"'),
               h6('The labware type (eg., "96 Well Eppendorf TwinTec PCR")'),
               h5('"TECAN_target_position"'),
               h6('The position (well) of your samples in your labware (numeric values; column-wise ordering)'),
               h5('"TECAN_sample_conc"'),
               h6('The concentration of your samples (units = ng/ul)'),
               hr(),
               h3('Output'),
               h4('The output files consist of the following files:'),
               h5('*_conc.txt'),
               h6('A table with the post-dilution concentrations (ng/ul)'),
               h5('*_worklist.txt'),
               h6('>=1 "worklist" table file with instructions for the robot (1 worklist per plate of sample DNA)'),
               hr(),
               h3('Notes'),
               tags$ul(
                        tags$li('Sample locations in plates numbered are column-wise'),
                        tags$li('All volumes are in ul'),
                        tags$li('Labware types with "PCR Adapter 96 Well and ..." or "PCR Adapter 384 Well and ..." will include a plate adapter')
          )
        )    
      )
    ),
    tabPanel("Input/Output", 
      fluidRow(
        column(12,
               h4('Input & output')
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
                             value = 5.0),
                br(),
                textInput('dil_liq',
                          label = "Dilutant liquid class",
                          value = "Water Free Single Wall Disp"),
                textInput('samp_liq',
                          label = "Sample liquid class",
                          value = "Water Free Single Wall Disp Aspirate Anyway")
        ),
        column(4,
               br(),
               numericInput('minvolumne',
                            label = "Minimum sample volume to use",
                            value = 2.0),
               numericInput('maxvolumne',
                            label = "Maximum sample volume to use",
                            value = 30.0),
               numericInput('mintotal',
                            label = "Minimum post-dilution total volume",
                            value = 20.0),
               checkboxInput('only_dil',
                             label = "If sample conc. is <=0, only add dilutant?",
                             value = FALSE)
        ),
        column(4,
               br(),
               textInput("dil_labware_name", 
                         label = "Name of labware containing the dilutant", 
                         value = "Dilutant"),
               selectInput("dil_labware_type", 
                           label = "Labware type containing the dilutant",
                           choices = c('25ml_1 waste' = '25ml_1 waste',
                                       '100ml_1 waste' = '100ml_1 waste',
                                       '1.5ml Eppendorf waste' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf waste' = '2ml Eppendorf waste'),
                           selected = '25ml_1 waste'),
               br(),
               checkboxInput('reuse_tips',
                             label = "Re-use tips for each dispense of the dilutant? (WARNING: dilutant volumes must all use the same tip size!)",
                             value = FALSE)
        )
      )
    ),
    tabPanel("Destination labware", 
             fluidRow(
               column(12,
                      h4('Destination labware')
               )
             ),
             fluidRow(
               column(4,
                      br(),
                      textInput('dest_name',
                                   label = 'Destination labware name',
                                   value = 'Diluted sample plate'),
                      selectInput('dest_type',
                                label = 'Destination labware type',
                                choices = c('96 Well Eppendorf TwinTec PCR' = '96 Well Eppendorf TwinTec PCR',
                                            'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR' = 'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR',
                                            '384 Well Biorad PCR' = '384 Well Biorad PCR',
                                            'PCR Adapter 384 Well and 384 Well Biorad PCR' = 'PCR Adapter 384 Well and 384 Well Biorad PCR'),
                                selected = '96 Well Eppendorf TwinTec PCR')
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
     ),
    tabPanel("TECAN webserver",
      fluidRow(
        br(),
        column(12, htmlOutput('tecan_ws'))
      )
    )
  )
))
