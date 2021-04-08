# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Tn5"),
  fluidRow(
    column(6,
      h5('Create TECAN Fluent worklist instructions for Tn5 library prep')
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
               h5('This app assumes that there are only 2 reagents for the Tn5 incubation:'),
               tags$ul(
                 tags$li('Tn5 MasterMix (Tn5 + Tn5 buffer + water)'),
                 tags$li('Your DNA samples')
               ),
               h5('This app assumes that the DNA samples are all at appox. the same DNA concentration'),
               h5('The robot will perform the following steps:'),
               tags$ul(
                 tags$li('Tagmentation prep (Tn5 incubation)'),
                 tags$ul(
                  tags$li('Tn5 MasterMix (Tn5 + Tn5 buffer + water) aliquoted to destination plate wells'),
                  tags$li('DNA samples aliquoted to destination plate wells')
                 ),
                 tags$li('PCR prep (PCR with barcoded primers)'),
                 tags$ul(
                   tags$li('PCR mastermix aliquoted to post-tagmentation sample wells'),
                   tags$li('Barcoded primters aliquoted to post-tagmentation sample wells')
                 )
               ),
               h5('This app assumes that the DNA samples are all at appox. the same DNA concentration'),
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
                 tags$li('If primer volume set to 0, then primers are skipped.')
               ),
               br(),
               h4('Controls:'),
               tags$ul(
                 tags$li('For the positive & negative controls, include them in the samples file'),
                 tags$li('If the controls (or samples) are provided in a tube, include them in the samples file and use either "1.5ml Eppendorf" or "2ml Eppendorf" for the labware type'),
                 tags$li('See the example input table (under the "Example Input" tab)')
               ),
               h4('Labware:'),
               tags$ul(
                 tags$li('In order to use a plate adapter, use "PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR"')
               ),
               br(),
               h4('Output files:'),
               h5('Worklist files and associated files will be created for the tagmentation assay setup and the PCR assay setup'),
               h5('Tagmentation assay files = "*_tag_*"'),
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
                         value = "TECAN_Tn5")
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
                           choices = c('96 Well Eppendorf TwinTec PCR' = '96 Well Eppendorf TwinTec PCR',
                                       'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR' = 'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR',
                                       '384 Well Biorad PCR' = '384 Well Biorad PCR',
                                       'PCR Adapter 384 Well and 384 Well Biorad PCR' = 'PCR Adapter 384 Well and 384 Well Biorad PCR'),
                           selected = 'PCR Adapter 96 Well and 96 Well Eppendorf TwinTec PCR')
        ),
        column(4,
               numericInput('deststart',
                            label = "Start well number on destination plate",
                            value = 1, min = 1, max = 384)
        )
      )
    ),
    tabPanel("Reagents", 
      fluidRow(
        column(3,
               h4("Tagmentation"),
               numericInput('tag_rxn_volume',
                            label = "Total tagmentation rxn volume per well",
                            value = 20.0, min = 0, max = 100),
               numericInput('sample_conc',
                            label = "Concentration of DNA samples (ng/ul)",
                            value = 1.0, min = 0, max = 100),    
               numericInput('sample_volume',
                            label = "Volume of DNA samples to user per tagmentation rxn (ul)",
                            value = 5.0, min = 0, max = 100), 
               selectInput('tag_Tn5_labware_type',
                           label = "Labware type for Tn5 MasterMix (Tn5 + buffer + water)",
                           choices = c('25ml trough (in 100ml trough)' = '25ml_1 waste',
                                       '1.5ml Eppendorf tube' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf tube' = '2ml Eppendorf waste',
                                       '5ml Eppendorf tube' = '5ml Eppendorf waste',
                                       '10ml Falcon tube' = '10ml Falcon'),
                           selected = '2ml Eppendorf waste')
        ),
        column(3,
               h4('PCR'),
               numericInput('pcr_mm_volume',
                     label = "PCR MasterMix volume per reaction",
                     value = 25.0, min = 0, max = 100),
               numericInput('primer_volume',
                     label = "Primer volume (assuming primers are combined in 1 tube/well)",
                     value = 6.0, min = 0, max = 100),
               selectInput('pcr_mm_labware_type',
                           label = "Labware type containing the PCR mastermix",
                           choices = c('25ml trough (in 100ml trough)' = '25ml_1 waste',
                                       '1.5ml Eppendorf tube' = '1.5ml Eppendorf waste',
                                       '2ml Eppendorf tube' = '2ml Eppendorf waste',
                                       '5ml Eppendorf tube' = '5ml Eppendorf waste',
                                       '10ml Falcon tube' = '10ml Falcon'),
                           selected = '5ml Eppendorf waste'),
               h4('Creating the MasterMix'),
               h5('See ', tags$a(href="https://confluence.eb.local:8443/pages/viewpage.action?pageId=47656819", "the Confluence protocol"))
        ),
        column(3,
               h4('Multi-dispense'),
               numericInput('tag_n_tip_reuse',
                            label = "Tagmentation mastermix: number of tip re-uses",
                            value = 12, min = 1, max = 96),
               numericInput('pcr_n_tip_reuse',
                            label = "PCR mastermix: number of tip re-uses",
                            value = 1, min = 1, max = 12)
        ),
        column(3,
               h4('Liquid classes'),
               textInput('tag_Tn5_liq',
                         label = "Tagmentation: Tn5 liquid class",
                         value = "Tn5 Free Single Wall Disp"),
               textInput('sample_liq',
                         label = "Sample liquid class",
                         value = "Water Contact Wet Single Ignore"),
               textInput('pcr_mm_liq',
                         label = "PCR: Mastermix liquid class",
                         value = "MasterMix Free Single"),
               textInput('primer_liq',
                         label = "Primer liquid class",
                         value = "Water Contact Wet Single Ignore"),
               hr(),
               h4('Misc'),
               numericInput('errorperc',
                            label = "% extra volume to include in calculating total reagents needed",
                            value = 15, min = 0, max = 100),
               selectInput('Tn5_calc_method',
                           label = "Method for calculating the amount of Tn5 based on DNA input. ('Silke_*' = based on Silke's tests on Marek's batches, 'Marek' = from his protocol)",
                           choices = c('Silke_Spring2021' = 'Silke_Spring2021',
			               'Silke_Fall2019' = 'Silke_Fall2019',
                                       'Silke_Spring2019' = 'Silke_Spring2019', 
                                       'Marek' = 'Marek'),
                           selected = 'Silke_Spring2021')
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
