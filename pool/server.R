# Shiny server
library(shiny)
library(readxl)
source("../utils/io.R")
source("../utils/format.R")



#' calling 'dilute' subcommand
call_pool = function(script_path, subcommand, input){
  print(input$map_file)
  
  # command
  if(is.null(input$sample_file)){
    options = c('-h')
  } else {
    # dealing with --prefix
    prefix = file.path(tempdir(), gsub('^.+/', '', input$prefix))
    # sample file paths
    file_paths = c()
    for(i in 1:nrow(input$sample_file)){
      x = input$sample_file
      file_paths = c(file_paths, rename_tmp_file(x[i,]))
    }
    file_paths = paste(file_paths, collapse=' ')
    
    # compiling options
    options = c(
      # I/O
      #rename_tmp_file(input$sample_file),
      c('--prefix', add_quotes(prefix)),
      # Sample file
      # --sample_format <see below>
      # --sample_header <see below>
      c('--sample_rows', add_quotes(input$sample_rows)),
      c('--sample_col', add_quotes(input$sample_col)),
      c('--include_col', add_quotes(input$include_col)),
      c('--sample_labware_name', add_quotes(input$sample_labware_name)),
      c('--sample_labware_type', add_quotes(input$sample_labware_type)),
      c('--position_col', add_quotes(input$position_col)),
      # Mapping file
      # --mapfile <see below>
      # --map_format <see below>
      # --map_header <see below>
      # Pooling
      c('--volume', input$volume),
      c('--liqcls', add_quotes(input$liqcls)),
      # --new_tips <see below>
      # Destination plate
      c('--destname', add_quotes(input$destname)),
      c('--desttype', add_quotes(input$desttype)),
      c('--deststart', input$deststart),
      # sample files
      file_paths
    ) 
    # mapfile
    if(!is.null(input$map_file)){
      options = c(options, c('--mapfile', rename_tmp_file(input$map_file)))
    }
    # format
    ## sample
    if(input$sample_format != 'blank'){
      options = c(options, c('--sample_format', add_quotes(input$sample_format)))
    }
    ## mapping 
    if(input$map_format != 'blank'){
      options = c(options, c('--map_format', add_quotes(input$map_format)))
    }
    # header
    ## sample
    if(input$sample_header == FALSE){   # no header
      options = c(options, c('--sample_header'))
    }
    ## mapping
    if(input$map_header == FALSE){   # no header
      options = c(options, c('--map_header'))
    }
    # tips
    if(input$new_tips == TRUE){  
      options = c(options, c('--new_tips'))
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


#' Loading example sample file
load_ex_sample_file = function(){
  df = read_excel('../data/pool_PCR-run1.xlsx', sheet='SYBR')
  #colnames(df)[1] = '#SampleID'
  return(df)
}

#' loading example mapping file
load_ex_map_file = function(){
  df = read_excel('../data/pool_map.xlsx', sheet='Sheet1')
  colnames(df)[1] = '#SampleID'
  return(df)
}


#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  #script_path = '/Users/nyoungblut/anaconda2/envs/py35/bin/pyTecanFluent'
  #script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
  #script_path = '/usr/local/bin/pyTecanFluent'
  script_path = '/home/shiny/miniconda3/envs/py3/bin/pyTecanFluent'
  subcommand = 'pool'
  
  # calling script
  script_out = eventReactive(input$runBtn, {
    # run command 
    call_pool(script_path, subcommand, input)
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
  
  # example sample data table
  output$example_sample_tbl = DT::renderDataTable(
    load_ex_sample_file(),
    rownames = FALSE,
    extensions = c('Buttons'),
    options = list(
      pageLength = 40,
      dom = 'Brt',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
    )
  )
  # sample mapping table
  output$example_map_tbl = DT::renderDataTable(
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

