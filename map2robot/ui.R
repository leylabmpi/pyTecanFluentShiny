# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Map2Robot"),
  fluidRow(
    column(6,
      h5('Convert a QIIME-formatted mapping file into a Tecan worklist file for barcoded PCR setup')
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
               h5('Convert a QIIME-formatted mapping file to a GWL file, which is used by the TECAN robot to conduct the NGS amplicon PCR prep (ie., combining MasterMix, primers, samples, etc)'),
               h5('The mapping file must contain some extra columns that will tell the robot where the samples are.'),
               h3('Input'),
               h4('Extra columns needed in the mapping file:'),
               h6(br('If no barcoding, single barcoding, or dual barcodes already combined:')),
               h5('"TECAN_sample_labware_name"'),
               h6('The sample labware name on the robot worktable'),
               h5('"TECAN_sample_labware_type"'),
               h6('The type of labware containing samples (eg., "96 Well Eppendorf TwinTec PCR")'),
               h5('"TECAN_sample_target_position"'),
               h6('The well or tube location (a number)'),
               h5('"TECAN_sample_rxn_volume"'),
               h6('The volume of sample to use per PCR (ul)'),
               h5('"TECAN_primer_labware_name"'),
               h6('The primer plate labware name on the robot worktable (eg., "515F-806R")'),
               h5('"TECAN_primer_labware_type"'),
               h6('The primer plate labware type on the robot worktable (eg., "96 Well Eppendorf TwinTec PCR"'),
               h5('"TECAN_primer_target_position"'),
               h6('The position (well) of your samples in your labware (numeric values; column-wise ordering)'),
               br(),
               h4('Primers:'),
               tags$ul(
                 tags$li('For single-indexed primers (eg., EMP primers), the non-barcoded primer should be pre-added to either the mastermix (adjust the volume used for this script!) or each of the barcoded primers.')
               ),
               br(),
               h4('Controls:'),
               tags$ul(
                 tags$li('For the positive & negative controls, include them in the mapping file'),
                 tags$li('If the controls (or samples) are provided in a tube, include them in the mapping file and use either "1.5ml Eppendorf" or "2.0ml Eppendorf" for the labware type'),
                 tags$li('See the example input table (under the "Example Input" tab)')
               ),
               h4('Labware:'),
               tags$ul(
                 tags$li('In order to use a plate adapter, use "PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR"')
               ),
               br(),
               h4('Output files:'),
               h5('*_report.txt'),
               h6('A summary of the PCR assay setup'),
               h5('*_BIORAD-*.txt'),
               h6('>=1 file for importing into the BIORAD PrimePCR software for sample labeling'),
               h5('*_map.txt'),
               h6('A mapping file with added PCR assay information'),
               h5('*_labware.txt'),
               h6('A table listing the labware to be placed on the robot worktable'),
               h5('*.gwl'),
               h6('A "worklist" file with instructions for the robot'),
               h3('Notes'),
               tags$ul(
                 tags$li('All volumes are in ul'),
                 tags$li('Plate well locations are 1 to n-wells; numbering by column'),
                 tags$li('PicoGreen should be added to the MasterMix *prior* to loading on robot (adjust the volume accordingly!)')
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
               fileInput("MapFile", "A QIIME-formatted mapping file with extra columns (see Description)"),
               textInput('rows',
                            label = 'Which rows of the mapping file to use (eg., "all"=all rows; "1-48"=rows1-48; "1,3,5-6"=rows1+3+5+6)?',
                            value = 'all')
        ),
        column(4,
               h4('Output'),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_NGS_amplicon")
        )
      )
    ),
    tabPanel("Destination Plate", 
      fluidRow(
        column(12, h4('Destination labware parameters'))
      ),
      fluidRow(
        column(4,
               textInput('destname',
                         label = "Destination labware name",
                         value = "Destination plate"),
               selectInput('desttype',
                           label = "Destination plate labware type (# of wells)",
                           choices = c('96-well' = '96 Well Eppendorf TwinTec PCR',
                                       '384-well' = '384 Well Biorad PCR'),
                           selected = '96-well')
        ),
        column(4,
               numericInput('deststart',
                            label = "Start well number on destination plate",
                            value = 1)
        ),
        column(4,
               numericInput('rxns',
                            label = "Number of replicate PCRs per sample",
                            value = 3)
        )
      )
    ),
    tabPanel("Reagents", 
      fluidRow(
        column(12, h4('PCR reagent parameters'))
      ),
      fluidRow(
        column(4,
               h4("Total volumes"),
               numericInput('pcrvolume',
                            label = "Total volume per PCR",
                            value = 25),
               numericInput('mmvolume',
                            label = "MasterMix volume per PCR",
                            value = 13.1),
               numericInput('prmvolume',
                            label = "Primer volume (assuming primers are combined in 1 tube)",
                            value = 2.0),
               numericInput('errorperc',
                            label = "% total volume to include in calculating total reagent needed",
                            value = 10)
        ),
        column(4,
               h4('Liquid classes'),
               textInput('mm_liq',
                         label = "Mastermix liquid class",
                         value = "MasterMix Free Multi Bottom Disp"),
               textInput('primer_liq',
                         label = "Primer liquid class",
                         value = "Water Free Single Bottom Disp"),
               textInput('sample_liq',
                         label = "Sample liquid class",
                         value = "Water Free Single Bottom Disp"),
               textInput('water_liq',
                         label = "Water liquid class",
                         value = "Water Free Single Bottom Disp")
        )
      )
    ),
    tabPanel("Example Input",
             fluidRow(
               column(12, 
                      h4('Mapping File format example'),
                      h5('Note: the table can contain other columns')
               )
             ),
             fluidRow(
               column(12, DT::dataTableOutput('example_tbl'))
             )
    )
  )
))
