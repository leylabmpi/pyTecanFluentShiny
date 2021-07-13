# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Tn5-on-Bead: PCR"),
  fluidRow(
    column(6,
      h5('Create TECAN Fluent worklist instructions for Tn5-on-Bead "amplification and adapter extension"')
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
               h5('Convert a table of samples to a GWL file, which is used by the TECAN robot to conduct custom-Tn5 NGS library prep'),
               h5('The robot will perform the following steps:'),
               tags$ul(
                 tags$li('PCR prep (PCR with barcoded primers)'),
                 tags$ul(
                   tags$li('Sample-bead storage buffer removed from each well (plate on magnet)'),
                   tags$li('PCR mastermix aliquoted to each well'),
                   tags$li('Barcoded primers aliquoted to sample wells')
                 )
               ),
               h5('NOTE: the MasterMix will be added directly to the samples after the storage buffer is removed!'),
               hr(),
               h3('Input'),
               h4('Columns needed in the samples file (see "Example Input" tab for an example)'),
               h5('[optional] "SampleID"'),
               h6('The name of each sample (if not provided, samples will named by sample order)'),
               h5('"TECAN_sample_labware_name"'),
               h6('The sample labware name on the robot worktable'),
               h5('"TECAN_sample_labware_type"'),
               h6('The type of labware containing samples (eg., "PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR")'),
               h5('"TECAN_sample_target_position"'),
               h6('The well or tube location (a number, column-wise ordering)'),
               h5('"TECAN_primer_labware_name"'),
               h6('The primer plate labware name on the robot worktable (eg., "515F-806R")'),
               h5('"TECAN_primer_labware_type"'),
               h6('The primer plate labware type on the robot worktable (eg., "96 Well Eppendorf TwinTec PCR"'),
               h5('"TECAN_primer_target_position"'),
               h6('The position (well) of your samples in your labware (numeric values; column-wise ordering)'),
               br(),
               h4('Primers:'),
               tags$ul(
                 tags$li('If primer volume set to 0, then primers are skipped.'),
                 tags$li('Primers should be in primer plates of all pairwise combinations.')
               ),
               br(),
               h4('Output files:'),
               h5('Worklist files and associated files will be created for the PCR assay setup'),
               h5('PCR assay files = "*_pcr_*"'),
               h5('*_report.txt'),
               h6('A summary of the reagents required'),
               h5('*_map.txt'),
               h6('A samples file with added PCR assay information'),
               h5('*_labware.txt'),
               h6('A table listing the labware to be placed on the robot worktable'),
               h5('*.gwl'),
               h6('A "worklist" file with instructions for the robot'),
               h5('*BIORAD-Destination_plate.txt'),
               h6('Load this into the BioRad PCR software to add sample IDs to the plate layout'),
               h3('Notes'),
               tags$ul(
                 tags$li('All volumes are in ul'),
                 tags$li('Plate well locations are 1 to n-wells; numbering by column')
               )
        )
      )
    ),
    tabPanel('Input & Output',
      fluidRow(
        column(12,
              h3('Input & output')
        )
      ),
      fluidRow(
        column(4,
               h4('Input file'),
               fileInput("MapFile", "A samples file with specific columns (see Description)"),
               textInput('rows',
                         label = 'Which rows of the samples file to use (eg., "all"=all rows; "1-48"=rows1-48; "1,3,5-6"=rows1+3+5+6)?',
                         value = 'all')
        ),
        column(4,
               h4('Output'),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_Tn5-on-bead")
        )
      )
    ),
    tabPanel("Reagents", 
      fluidRow(
        column(3,
               h4('PCR reagents'),
               numericInput('sup_volume',
                            label = "Storage buffer volume (removed prior to MM addition)",
                            value = 120.0, min = 0, max = 150),
               numericInput('mm_volume',
                            label = "PCR MasterMix volume per reaction",
                            value = 23.0, min = 0, max = 100),
               numericInput('primer_volume',
                            label = "Primer volume (assuming primers are combined in 1 tube/well)",
                            value = 6.0, min = 0, max = 100),
               selectInput('mm_labware_type',
                           label = "Labware type containing the PCR mastermix",
                           choices = c('25ml trough (in 100ml trough)' = '25ml_1 waste',
                                       '1.5ml Eppendorf tube' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf tube' = '2ml Eppendorf waste',
                                       '5ml Eppendorf tube' = '5ml Eppendorf waste',
                                       '10ml Falcon tube' = '10ml Falcon'),
                           selected = '5ml Eppendorf waste')
        ),
        column(3,
               h4('Liquid classes'),
               textInput('sup_liq',
                         label = "Sample storage buffer liquid class",
                         value = "Tn5-on-bead Supernatant Free Single"),
               textInput('mm_liq',
                         label = "Mastermix liquid class",
                         value = "MasterMix Free Single"),
               textInput('primer_liq',
                         label = "Primer liquid class",
                         value = "Water Contact Wet Single")
        ),
        column(3,
               h4('Misc'),
               numericInput('errorperc',
                            label = "% extra volume to include in calculating total reagents needed",
                            value = 15, min = 0, max = 100)
        )
      )
    ),
    tabPanel("Example Input",
             fluidRow(
               column(12, 
                      h4('Samples file format example'),
                      h5('Note: the table can contain other columns')
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
