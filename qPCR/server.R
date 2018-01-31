# Shiny server
library(shiny)
source("../utils/io.R")
source("../utils/format.R")



#' calling 'map2robot' subcommand
call_qPCR = function(script_path, subcommand,input){
  # command
  if(is.null(input$SetupFile)){
    options = c('-h')
  } else {
    # dealing with --prefix
    prefix = file.path(tempdir(), gsub('^.+/', '', input$prefix))
    
    # compiling options
    options = c(
      # I/O
      rename_tmp_file(input$SetupFile),
      c('--prefix', add_quotes(prefix)),
      # Source labware
      c('--mm-type', add_quotes(input$mm_type)),
      c('--water-type', add_quotes(input$water_type)),
      # Destination plate
      c('--dest', add_quotes(input$dest)),
      c('--dest-type', add_quotes(input$dest_type)),
      # Liquid classes
      c('--mm-liq', add_quotes(input$mm_liq)),
      c('--samp-liq', add_quotes(input$sample_liq)),
      c('--water-liq', add_quotes(input$water_liq))
    ) 
    if(input$format != 'blank'){
      c('--format', add_quotes(input$format))
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

#' loading example mapping file
load_ex_file = function(){
  df = read.table('../data/qPCR_setup.txt', sep='\t', 
                  comment.char="~", header=TRUE, check.names=FALSE)
  return(df)
}


#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  #script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
  #script_path = '/usr/local/bin/pyTecanFluent'
  script_path = '/home/shiny/miniconda3/envs/py3/bin/pyTecanFluent'
  subcommand = 'qPCR'
  
  # calling script
  script_out = eventReactive(input$runBtn, {
    # run command 
    call_qPCR(script_path, subcommand, input)
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
    load_ex_file(),
    extensions = c('Buttons'),
    options = list(
      pageLength = 200,
      dom = 'Brt',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
})

