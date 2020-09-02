# Shiny server
library(shiny)
library(readxl)
source("../utils/io.R")
source("../utils/format.R")



#' calling 'Tn5' subcommand
call_Tn5 = function(script_path, subcommand,input){
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
      # Reagents
      ## Tagmentation
      c('--tag-rxn-volume', input$tag_rxn_volume),
      c('--sample-conc', input$sample_conc),
      c('--sample-volume', input$sample_volume),
      c('--tag-Tn5-labware-type', add_quotes(input$tag_Tn5_labware_type)),
      c('--tag-n-tip-reuse', input$tag_n_tip_reuse),
      ## PCR
      c('--pcr-mm-volume', input$pcr_mm_volume),
      c('--primer-volume', input$primer_volume),
      c('--pcr-mm-labware-type', add_quotes(input$pcr_mm_labware_type)),
      c('--pcr-n-tip-reuse', input$pcr_n_tip_reuse),
      # Liquid classes
      c('--tag-Tn5-liq', add_quotes(input$tag_Tn5_liq)),
      c('--sample-liq', add_quotes(input$sample_liq)),
      c('--pcr-mm-liq', add_quotes(input$pcr_mm_liq)),
      c('--primer-liq', add_quotes(input$primer_liq)),
      # misc
      c('--error-perc', add_quotes(input$errorperc)),
      c('--Tn5-calc-method', input$Tn5_calc_method)
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
  df = read.delim('../data/Tn5_96well.txt', sep='\t')
  colnames(df)[1] = 'SampleID'
  return(df)
}


#-- server --#
shinyServer(function(input, output, session) {
  # script path & subcommand
  #script_path = '/Users/nyoungblut/anaconda2/bin/pyTecanFluent'
  #script_path = '/Users/nick/anaconda3/envs/py3_dev/bin/pyTecanFluent'
  #script_path = '/usr/local/bin/pyTecanFluent'
  script_path = '/home/shiny/miniconda3/envs/py3/bin/pyTecanFluent'
  subcommand = 'Tn5'
  
  # calling script
  script_out = eventReactive(input$runBtn, {
    # run command 
    call_Tn5(script_path, subcommand, input)
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
      buttons = list(
        list(extend = "copy", title = NULL), 
        'csv', 
        list(extend = 'excel', title = NULL, filename = 'Tn5_example.xlsx'),
        'pdf', 
        'print'
      )
    )
  )
  
  # TECAN webserver
  output$tecan_ws <- renderUI({
    tags$iframe(src = 'http://10.35.156.190/', height=500, width=1000)
  })
})

