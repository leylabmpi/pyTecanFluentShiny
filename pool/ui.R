# Shiny UI
library(shiny)

#-- UI --#
shinyUI(fluidPage(
  
  titlePanel("Pool"),
  fluidRow(
    column(6,
      h5('Create robot commands for pooling samples')
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
               h5('Create a worklist and labware file for the TECAN Fluent robot for pooling samples (eg., pooling PCR reaction replicates).'),
               h3('Input'),
               h4('Sample file(s)'),
               h5('The input is >=1 Excel or tab-delimited file containing the following columns:'),
               tags$ul(
                 tags$li("A column of sample names (samples with the same name will be pooled)"),
                 tags$li("A column designating whether to include or skip the samplles (include = 'Success/Pass/Include'; skip = 'Fail/Skip')"),
                 tags$li("A column designating the sample labware name"),
                 tags$li("A column designating the sample labware type (eg., '96 Well Eppendorf TwinTec PCR')"),
                 tags$li("A column designating the sample position (well)")
               ),
               h4('Mapping file'),
               h5("If a mapping file is provided (same names as in the pooling file), then the mapping file will be trimmed to just those pooled, and the final pooled locations will be added to the mapping table."),
               h5('The added columns have the prefix: "TECAN_postPool_*"'),
               h3('Output'),
               h4('The output files consist of the following files:'),
               h5('*_map.txt'),
               h6('(if a mapping file is provided) a mapping file trimmed to just pooled samples'),
               h5('*_labware.txt'),
               h6('A table listing the labware to be placed on the robot worktable'),
               h5('*.gwl'),
               h6('A "worklist" file with instructions for the robot'),
               hr(),
               h3('Notes'),
               tags$ul(
                        tags$li('Sample locations in plates numbered are column-wise'),
                        tags$li('All volumes are in ul'),
                        tags$li('The output files ending in "_win" have Windows line breaks (for viewing on a PC)')
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
               br(),
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
               textInput('sample_labware_name', 
                         label = 'Name of column designating the sample labware name',
                         value = 'labware_name'),
               textInput('sample_labware_type', 
                         label = 'Name of column designating the sample labware type',
                         value = 'labware_type'),
               textInput('position_col', 
                         label = 'Column designating sample location in the plate',
                         value = 'Well')
        ),
        column(4,
               h4('Mapping file'),
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
                          value = 'Water Free Multi No-cLLD'),
                checkboxInput("new_tips", 
                              label = "New tips for each sample replicate?",
                              value = FALSE)
        ),
        column(4,
               h4('Destination labware'),
               textInput('destname',
                         label = "Destination labware name",
                         value = "Pooled DNA plate"),
               selectInput('desttype',
                           label = "Destination labware type",
                           choices = c('96 well plate' = '96 Well Eppendorf TwinTec PCR',
                                       '384 well plate' = '384 Well Biorad PCR'),
                           selected = '96 Well Eppendorf TwinTec PCR'),
               numericInput('deststart',
                            label = "Starting position (well) on the destination labware",
                            value = 1)
        )
      )
    ),
    tabPanel("Tips", 
      fluidRow(
        column(12,
          h4('Destination plate parameters')
        )
      ),             
      fluidRow(
        column(4,
               br(),
               selectInput('tip1000_type',
                           label = '1000 ul tip type to use',
                           choices = c('FCA, 1000ul SBS' = 
                                                'FCA, 1000ul SBS',
                                              'FCA, 1000ul Filtered SBS' = 
                                                'FCA, 1000ul Filtered SBS',
                                              'None' = 'None'),
                           selected = 'FCA, 1000ul SBS'),
               selectInput('tip200_type',
                           label = '200 ul tip type to use',
                           choices = c('FCA, 200ul SBS' = 
                                                'FCA, 200ul SBS',
                                              'FCA, 200ul Filtered SBS' = 
                                                'FCA, 200ul Filtered SBS',
                                              'None' = 'None'),
                           selected = 'FCA, 200ul SBS')
               ),
        column(4,
               br(),
               selectInput('tip50_type',
                           label = '50 ul tip type to use',
                           choices = c('FCA, 50ul SBS' = 
                                                'FCA, 50ul SBS',
                                              'FCA, 50ul Filtered SBS' = 
                                                'FCA, 50ul Filtered SBS',
                                              'None' = 'None'),
                           selected = 'FCA, 50ul SBS'),
               selectInput('tip10_type',
                           label = '10 ul tip type to use',
                           choices = c('FCA, 10ul SBS' = 
                                                'FCA, 10ul SBS',
                                              'FCA, 10ul Filtered SBS' = 
                                                'FCA, 10ul Filtered SBS',
                                              'None' = 'None'),
                           selected = 'FCA, 10ul SBS')
        )
      )
    ),
    tabPanel("Example Input: samples",
      fluidRow(
        column(12, 
               h4('Sample File format example'),
               h5('Note: the table can include more columns')
        )
      ),
      fluidRow(
        column(12, DT::dataTableOutput('example_sample_tbl'))
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
    )
   )
))
