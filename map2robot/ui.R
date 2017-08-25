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
    tabPanel("Input/Output", 
      fluidRow(
        column(7,
               br(),
               h4('Description'),
               h6('Convert a QIIME-formatted mapping file to a GWL file, which is used by the TECAN robot to conduct the NGS amplicon PCR prep (ie., combining MasterMix, primers, samples, etc)'),
               h6('The extra columns in the mapping file designate the SOURCE of samples and primers; the DESTINATION (plate & well) is set by this script.'),
               br(),
               h5('EXTRA COLUMNS in MAPPING FILE:'),
               h6('* "TECAN_sample_labware" = The sample labware name on the robot worktable'),
               h6('* "TECAN_sample_location" = The well or tube location (a number)'),
               h6('* "TECAN_primer_labware" = The primer plate labware name on the robot worktable'),
               h6('* "TECAN_primer_location" = The well location (1-96 or 1-384)'),
               h6('* "TECAN_sample_rxn_volume" = The volume of sample to use per PCR (ul)'),
               br(),
               h5('CONTROLS:'),
               h6('* For the positive & negative controls, include them in the mapping file'),
               h6('* If the controls (or samples) are provided in a tube, use "micro15[XXX]" for the "TECAN_sample_labware" column, but change "XXX" to the tube number that you want to use (eg., micro15[003] for tube position 3)'),
               br(),
               h5('OUTPUT FILES:'),
               h6('* The output files ending in "_win" have Windows line breads (needed for the robot)'),
               br(),
               h5('MISC NOTES:'),
               h6('* All volumes are in ul'),
               h6('* Plate well locations are 1 to n-wells; numbering by column'),
               h6('* PicoGreen should be added to the MasterMix *prior* to loading on robot')
        ),
        column(5,
               br(),
               h4('Input & Output'),
               fileInput("MapFile", "A QIIME-formatted mapping file with extra columns (see Description)"),
               textInput('rows',
                            label = 'Which rows of the mapping file to use (eg., "all"=all rows; "1-48"=rows1-48; "1,3,5-6"=rows1+3+5+6)?',
                            value = 'all'),
               br(),
               br(),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_NGS_amplicon")
        )
      )
    ),
    tabPanel("Example input",
      fluidRow(
        column(12, h4('Mapping File format example:'))
      ),
      fluidRow(
        column(12, DT::dataTableOutput('example_tbl'))
      )
    ),
    tabPanel("Destination Plate", 
      fluidRow(
        column(12, br())
      ),
      fluidRow(
        column(4,
               textInput('dest',
                         label = "Destination plate labware ID on TECAN worktable",
                         value = "96 Well[001]"),
               selectInput('desttype',
                           label = "Destination plate labware type (# of wells)",
                           choices = c('96-well' = 96,
                                       '384-well' = 384),
                           selected = 96)
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
        column(12, br()),
        column(12, h5('Note: "tube number" is the location in the tube runner, starting from the "top" of the runner'))
      ),
      fluidRow(
        column(4,
               h4("Total volumes"),
               numericInput('pcrvolume',
                            label = "Total volume per PCR",
                            value = 25),
               numericInput('errorperc',
                            label = "Percent of extra total reagent volume to include",
                            value = 10),
               hr(),
               br(),
               h4('Master mix'),
               numericInput('mmtube',
                            label = "Master Mix tube number (which tube in the tube runner?)",
                            value = 1),
               numericInput('mmvolume',
                            label = "MasterMix volume per PCR",
                            value = 13.1)
        ),
        column(4,
               h4('Primers'),
               numericInput('fpvolume',
                            label = "Forward primer volume per PCR",
                            value = 1.0),
               numericInput('rpvolume',
                            label = "Reverse primer volume per PCR",
                            value = 1.0),
               numericInput('fptube',
                            label = "Forward non-bacode primer tube number (If 0, then primers assummed to be barcoded primer on a plate)",
                            value = 0),
               numericInput('rptube',
                            label = "Reverse non-bacode primer tube number (If 0, then primers assummed to be barcoded primer on a plate)",
                            value = 0)
        ),
        column(4,
               h4('Liquid classes'),
               textInput('mm_liq',
                         label = "Mastermix liquid class",
                         value = "MasterMix Free Multi"),
               textInput('primer_liq',
                         label = "Primer liquid class",
                         value = "Water Contact Wet Single"),
               textInput('sample_liq',
                         label = "Sample liquid class",
                         value = "Water Contact Wet Single"),
               textInput('water_liq',
                         label = "Water liquid class",
                         value = "Water Contact Wet Single")
        )
      )
    )
  )
))
