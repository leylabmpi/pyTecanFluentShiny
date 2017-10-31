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
      c('--destname', add_quotes(input$dest)),
      c('--desttype', add_quotes(input$desttype)),
      c('--deststart', input$deststart),
      c('--rxns', input$rxns),
      # Master mix
      c('--mmtube', input$mmtube),
      c('--mmvolume', input$mmvolume),
      # Primers
      c('--fpvolume', input$fpvolume),
      c('--rpvolume', input$rpvolume),
      c('--fptube', input$fptube),
      c('--rptube', input$rptube),
      # Liquid classes
      c('--mm-liq', add_quotes(input$mm_liq)),
      c('--primer-liq', add_quotes(input$primer_liq)),
      c('--sample-liq', add_quotes(input$sample_liq)),
      c('--water-liq', add_quotes(input$water_liq)),
      # Tip type
      c('--tip1000_type', add_quotes(input$tip1000_type)),
      c('--tip200_type', add_quotes(input$tip200_type)),
      c('--tip50_type', add_quotes(input$tip50_type)),
      c('--tip10_type', add_quotes(input$tip10_type)),
      # Misc
      c('--pcrvolume', add_quotes(input$pcrvolume)),
      c('--errorperc', add_quotes(input$errorperc))
    ) 
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
load_ex_map_file = function(){
  df = read.delim('../data/basic_96well.txt', sep='\t')
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
  
  # example data table
  output$example_tbl = DT::renderDataTable(
    load_ex_map_file(),
    extensions = c('Buttons'),
    rownames = FALSE,
    options = list(
      pageLength = 40,
      dom = 'Brt',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
})

