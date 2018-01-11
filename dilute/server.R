# Shiny server
library(shiny)
library(readxl)
source("../utils/io.R")
source("../utils/format.R")


#' making data.frame of example input table
make_example_data = function(){
  conc = c(10.1, 6.3, 1, 2.2, 3.1, 8.5)
  data.frame(
    TECAN_labware_name = rep('Sample DNA', length(conc)),
    TECAN_target_position = 1:length(conc),
    TECAN_sample_conc = conc
  )
}


#' calling 'dilute' subcommand
call_dilute = function(script_path, subcommand,input){
  # command
  if(is.null(input$ConcFile)){
    options = c('-h')
  } else {
    # dealing with --prefix
    prefix = file.path(tempdir(), gsub('^.+/', '', input$prefix))
    
    # compiling options
    options = c(
      # I/O
      rename_tmp_file(input$ConcFile),
      c('--prefix', add_quotes(prefix)),
      # Concentration file
      # --format <see below>
      # --header <see below>
      c('--rows', add_quotes(input$rows)),
      # Dilution
      c('--dilution', input$dilution),
      c('--min-volume', input$minvolumne),
      c('--max-volume', input$maxvolumne),
      c('--min-total', input$mintotal),
      c('--dil-labware-name', add_quotes(input$dil_labware_name)),
      c('--dil-labware-type', add_quotes(input$dil_labware_type)),
      # Destination labware
      c('--dest-name', add_quotes(input$dest_name)),
      c('--dest-type', add_quotes(input$dest_type))
    ) 
    # format
    if(input$format != 'blank'){
      options = c(options, c('--format', add_quotes(input$format)))
    }
    # header
    if(input$header == FALSE){   # no header
      options = c(options, c('--header'))
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

#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  #script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
  #script_path = '/usr/local/bin/pyTecanFluent'
  script_path = '/home/shiny/miniconda3/envs/py3/bin/pyTecanFluent'
  subcommand = 'dilute'
  
  # calling script
  script_out = eventReactive(input$runBtn, {
    # run command 
    call_dilute(script_path, subcommand, input)
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
  
  # example data table
  output$example_tbl = DT::renderDataTable(
    make_example_data(),
    rownames = FALSE,
    extensions = c('Buttons'),
    options = list(
      pageLength = 40,
      dom = 'Brt',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
})

