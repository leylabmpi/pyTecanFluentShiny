# Shiny server
library(shiny)


as.Num = function(x){
  x %>% as.character %>% as.numeric
}

call_help = function(script_path, subcommand, input){
  # command
  options = c(
    input$ConcFile,
    c('--prefix', input$prefix)
  )
  # call with options
  options = paste(c(subcommand, options), collapse=' ')
  ret = system2(script_path, options, stdout=TRUE, stderr=TRUE)
  # return output
  paste(ret, collapse='\n') 
} 

add_quotes = function(x){
  paste0('"', x, '"')
}

# remaming temp file produced by fileInput (adding back file extension)
rename_tmp_file = function(select_input_obj){
  file_ext = gsub('.+(\\.[^.])$', '\\1', select_input_obj$name) 
  new_file = paste0(select_input_obj$datapath, file_ext)
  file.copy(select_input_obj$datapath, new_file, overwrite=TRUE)
  return(new_file)
}

# calling 'dilute' subcommand
call_dilute = function(script_path, subcommand,input){
  #print(input$prefix)
  #print(input$ConcFile)
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
      #c('--format', input$format)
      # Concentration file
      c('--labware', input$labware),
      c('--location', input$location),
      c('--conc', input$conc),
      c('--rows', add_quotes(input$rows)),
      # Dilution
      c('--dilution', input$dilution),
      c('--minvolume', input$minvolumne),
      c('--maxvolume', input$maxvolumne),
      c('--mintotal', input$mintotal),
      c('--dlabware', add_quotes(input$dlabware)),
      # Destination plate
      c('--dest', add_quotes(input$dest)),
      c('--desttype', add_quotes(input$desttype)),
      c('--deststart', input$deststart)
    ) 
    if(input$format != 'blank'){
      c('--format', add_quotes(input$format))
    }
    if(input$header == FALSE){   # no header
      options = c(options, c('--header'))
    }
  }
  # call with options
  options = paste(c(subcommand, options), collapse=' ')
  system2(script_path, options, stdout=TRUE, stderr=TRUE)
}

# get files created by the command
get_files_created = function(x){
  x = gsub('File written: +', '', x)
  x[sapply(x, file.exists)]
}

#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
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
      print(files)
      zip(file_name, files, flags='-r9Xj')
    }
  )
})

