# Shiny server
library(shiny)
library(readxl)
source("../utils/io.R")
source("../utils/format.R")



#' calling 'map2robot' subcommand
call_map2robot = function(script_path, subcommand,input){
  # command
  if(is.null(input$MapFile)){
    options = c('-h')
  } else {
    # dealing with --prefix
    prefix = file.path(tempdir(), gsub('^.+/', '', input$prefix))
    
    # compiling options
    options = c(
      # I/O
      rename_tmp_file(input$MapFile),
      c('--rows', add_quotes(input$rows)),
      c('--prefix', add_quotes(prefix)),
      # Destination plate
      c('--dest-name', add_quotes(input$destname)),
      c('--dest-type', add_quotes(input$desttype)),
      c('--dest-start', input$deststart),
      c('--rxns', input$rxns),
      # Reagents
      c('--pcr-volume', add_quotes(input$pcrvolume)),
      c('--mm-volume', input$mmvolume),
      c('--prm-volume', input$prmvolume),
      c('--error-perc', add_quotes(input$errorperc)),
      # Liquid classes
      c('--mm-liq', add_quotes(input$mm_liq)),
      c('--primer-liq', add_quotes(input$primer_liq)),
      c('--sample-liq', add_quotes(input$sample_liq)),
      c('--water-liq', add_quotes(input$water_liq)),
      c('--n-tip-reuse', input$n_tip_reuse),
      c('--n-multi-disp', input$n_multi_disp),
      # labware type
      c('--mm-labware-type', add_quotes(input$mm_labware_type))
    ) 
    ## boolean options
    if(input$mm_one_source == TRUE){   # one source labare for MM
      options = c(options, c('--mm-one-source'))
    }
    if(input$prm_in_mm == TRUE){   # primers in mastermix
      options = c(options, c('--prm-in-mm'))
    }
    if(input$water_in_mm == TRUE){   # water in mastermix
      options = c(options, c('--water-in-mm'))
    }
  }
  # call with options
  options = paste(c(subcommand, options), collapse=' ')
  system2(script_path, options, stdout=TRUE, stderr=TRUE)
}

#' get files created by the command
get_files_created = function(x){
  x = gsub('File written: +', '', x)
  x[sapply(x, file.exists)]
}

#' loading example mapping file for Step2 PCR
load_ex_map_file = function(step=1){
  step = as.numeric(step)
  if(step == 1){
    f = '../data/PCR-Step1_96well.txt'
  } else
  if(step == 2){
    f = '../data/PCR-Step2_96well.txt'
  } else {
    stop('"step" option value not recognized')
  }
  df = read.delim(f, sep='\t')
  colnames(df)[1] = '#SampleID'
  return(df)
}


#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  #script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
  #script_path = '/usr/local/bin/pyTecanFluent'
  script_path = '/home/shiny/miniconda3/envs/py3/bin/pyTecanFluent'
  subcommand = 'map2robot'
  
  # updating UI
  observe({
    x = input$PCR_step
    if (x == 1){
      # PCR step 1
      updateTextInput(session, 'prefix',
                         label = 'Output file name prefix',
                         value = 'TECAN_NGS_amplicon_PCR1')
      updateNumericInput(session, "mmvolume",
                         label = "MasterMix volume per PCR",
                         value = 13.1,
                         min = 0,
                         max = 200)
      updateNumericInput(session, 'prmvolume',
                         label = "Primer volume (assuming primers are combined in 1 tube)",
                         value = 2.0,
                         min = 0,
                         max = 100,
                         step = 0.5)
      updateNumericInput(session, 'rxns',
                         label = "Number of replicate PCRs per sample",
                         value = 3,
                         min = 1,
                         max = 99)
      
    } else {
      # PCR step 2
      updateTextInput(session, 'prefix',
                      label = 'Output file name prefix',
                      value = 'TECAN_NGS_amplicon_PCR2')
      updateNumericInput(session, "mmvolume",
                        label = "MasterMix volume per PCR",
                        value = 12.5,
                        min = 0,
                        max = 200)
      updateNumericInput(session, 'prmvolume',
                         label = "Primer volume (assuming primers are combined in 1 tube)",
                         value = 4.0,
                         min = 0,
                         max = 100,
                         step = 0.5)
      updateNumericInput(session, 'rxns',
                         label = "Number of replicate PCRs per sample",
                         value = 1,
                         min = 1,
                         max = 99)
      }
  })
  observe({
    x = input$mm_single_disp
    if(x == TRUE){
      updateNumericInput(session, 'n_multi_disp',
                         label = "Number of multi-dispenses per tip",
                         value = 1,
                         min = 1,
                         max = 1)
      updateTextInput(session, 'mm_liq',
                         label = "Mastermix liquid class",
                         value = "MasterMix Free Single Wall Disp")
    }
  })
  
  # calling script
  script_out = eventReactive(input$runBtn, {
    # run command 
    call_map2robot(script_path, subcommand, input)
  })
  
  # adding script output to output
  output$script_out = reactive({
    ret = gsub('File written:.+/', 'File created: ', script_out())
    paste(ret, collapse='\n')
  })
  
  # number of output files
  output$download_btn = renderUI({
    n_files = length(grep('^File written: ', script_out())) 
    if(n_files > 0){
      downloadButton('downloadData', 'Download results')
    }
  })
  
  # file download
  output$downloadData = downloadHandler(
    filename = function() { paste0(input$prefix, '.zip') },
    content = function(file_name) {
      files = get_files_created(script_out())
      zip(file_name, files, flags='-r9Xj')
    }
  )
  
  # example data tables
  output$example_tbl = DT::renderDataTable(
    load_ex_map_file(step=input$PCR_step),
    extensions = c('Buttons'),
    rownames = FALSE,
    options = list(
      pageLength = 40,
      dom = 'Brt',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
  
  # TECAN webserver
  output$tecan_ws <- renderUI({
    tags$iframe(src = 'http://10.35.156.190/', height=500, width=1000)
  })
})

