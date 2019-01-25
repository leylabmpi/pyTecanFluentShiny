# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Pool PCR replicates"),
  fluidRow(
    column(6,
      h5('Create robot commands for pooling PCR replicates')
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
               h5('Create a worklist and labware file for the TECAN Fluent robot for pooling samples (eg., pooling PCR reaction replicates).'),
               h3('Input'),
               h4('Sample file(s)'),
               h5('The input is >=1 Excel or tab-delimited file containing the following columns:'),
               tags$ul(
                 tags$li("A column of sample names (samples with the same name will be pooled)"),
                 tags$li("A column designating whether to include or skip the samplles (include = 'Success/Pass/Include'; skip = 'Fail/Skip')"),
                 tags$li("A column designating the sample labware name"),
                 tags$li("A column designating the sample labware type (eg., '96 Well Eppendorf TwinTec PCR')"),
                 tags$li("A column designating the sample position (well). This can be column-wise numbering or well indexing (eg., 'A01' or 'C03')"),
                 tags$li("[optional] A column designating the sample volume (overrides the 'volume' parameter)"),
                 tags$li("NOTE: you can select column names in the 'Input/Output' tab")
               ),
               h4('Mapping file'),
               h5("If a mapping file is provided (same names as in the pooling file), then the mapping file will be trimmed to just those pooled, and the final pooled locations will be added to the mapping table."),
               h5('The added columns have the prefix: "TECAN_postPool_*"'),
               h3('Output'),
               h4('The output files consist of the following files:'),
               h5('*_labware.txt'),
               tags$ul(tags$li('A table listing the labware to be placed on the robot worktable')),
               h5('*.gwl'),
               tags$ul(tags$li('A "worklist" file with instructions for the robot')),
               h5('IF mapping file provided: *_map.txt'),
               tags$ul(tags$li('A mapping file trimmed to just pooled samples')),
               h5('ELSE: *_samples.txt'),
               tags$ul(tags$li('A simpler table than the mapping file that designates the designation locations of all samples')),
               hr(),
               h3('Notes'),
               tags$ul(
                        tags$li('Samples are pooled based on sample name (eg., all samples named "control" will be pooled, regardless of source plate'),
                        tags$li('The final order of the pooled samples will match the order of samples in the input table'),
                        tags$li('Sample locations in plates are numbered column-wise'),
                        tags$li('All volumes are in ul'),
                        tags$li('Labware types with "PCR Adapter 96 Well and ..." or "PCR Adapter 384 Well and ..." will include a plate adapter'),
                        tags$li('If needed, there\'s an app to convert the well index:', tags$a(href='http://shiny-wetlab.eb.local:3838/RTecanFluentShiny/well_index/', 'well index'))
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
               h4('Sample file'),
               fileInput("sample_file", 
                         label = "Sample File: excel or tab-delim file of samples to pool",
                         multiple = TRUE),
               selectInput('sample_format',
                           label = "File  excel or tab-delimited. If blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'Tab-delimited' = 'tab'),
                           selected = 'blank'),
               checkboxInput("sample_header", 
                             label = "Header in the file?",
                             value = TRUE),
               textInput('sample_rows', 
                         label = 'Which rows (not including header) of the column file to use ("all"=all rows; "1-48"=rows 1-48)', 
                         value = 'all')
        ),
        column(4,
               h4('Sample file columns'),
               textInput('sample_col', 
                         label = 'Column containing the samples',
                         value = 'Sample'),
               textInput('include_col', 
                         label = 'Name of column designating sample include/skip the sample',
                         value = 'Call'),
               textInput('sample_labware_name', 
                         label = 'Name of column designating the sample labware name',
                         value = 'labware_name'),
               textInput('sample_labware_type', 
                         label = 'Name of column designating the sample labware type',
                         value = 'labware_type'),
               textInput('position_col', 
                         label = 'Column designating sample location in the plate',
                         value = 'Well'),
               textInput('volume_col', 
                         label = 'Column designating sample volume (use "None" to skip)',
                         value = 'None')
        ),
        column(4,
               h4('Mapping file (optional)'),
               fileInput("map_file", 
                         label = "Map File: a QIIME-formatted mapping file"),
               selectInput('map_format',
                           label = "File  excel or tab-delimited. If blank, the format will be guessed",
                           choices = c(' ' = 'blank',
                                       'Excel' = 'excel',
                                       'Tab-delimited' = 'tab'),
                           selected = 'blank'),
               checkboxInput("map_header", 
                             label = "Header in the file?",
                             value = TRUE),
               hr(),
               h4('Output files'),
               textInput("prefix", 
                         label = "Output file name prefix", 
                         value = "TECAN_pool")
        )
      )
    ),
    tabPanel("Pooling", 
      fluidRow(
        column(12,
          h3('Pooling parameters')
        )
      ),
       fluidRow(
         column(4,
                h4('Aspiration/Dispense'),
                numericInput('volume',
                             label = 'Per-sample volume to pool (ng/ul)',
                             value = 30.0),
                textInput('liqcls',
                          label = 'Liquid class for pooling',
                          value = 'Water Free Single')#,
                #checkboxInput("new_tips", 
                #              label = "New tips for each sample replicate?",
                #              value = FALSE)
        ),
        column(4,
               h4('Destination labware'),
               textInput('destname',
                         label = "Destination labware name",
                         value = "Pooled DNA plate"),
               selectInput('desttype',
                           label = "Destination labware type",
                           choices = c('96 well plate' = '96 Well Eppendorf TwinTec PCR',
                                       '384 well plate' = '384 Well Biorad PCR',
                                       '1.5ml Eppendorf' = '1.5ml Eppendorf',
                                       '2ml Eppendorf' = '2ml Eppendorf'),
                           selected = '96 Well Eppendorf TwinTec PCR'),
               numericInput('deststart',
                            label = "Starting position (eg., well) on the destination labware",
                            value = 1)
        )
      )
    ),
    tabPanel("Example Input: PCR samples",
      fluidRow(
        column(12, 
               h4('Sample File format example (pooling replicate PCRs)'),
               h5('Note: the table can include more columns')
        )
      ),
      fluidRow(
        column(12, DT::dataTableOutput('example_pcr_sample_tbl'))
      )
    ),
    tabPanel("Example Input: mapping",
     fluidRow(
       column(12,
              h4('Mapping File format example'),
              h5('Note: the table can include more columns')
              )
     ),
     fluidRow(
       column(12, DT::dataTableOutput('example_map_tbl'))
     )
    ),
    tabPanel("Example Input: combine all samples",
             fluidRow(
               column(12, 
                      h4('Sample File format example (pooling all samples)'),
                      h5('Note: the table can include more columns')
               )
             ),
             fluidRow(
               column(12, DT::dataTableOutput('example_gen_sample_tbl'))
     )
    )
   )
))
