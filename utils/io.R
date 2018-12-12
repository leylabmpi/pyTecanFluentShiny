# i/o utility functions 

#' Remaming temp file produced by fileInput (adding back file extension)
#' Converting spaces to underscores (if present)
#' select_input_obj = object generated from shiny::selectInput()
rename_tmp_file = function(select_input_obj){
  file_ext = gsub('.+(\\.[^.])$', '\\1', select_input_obj$name) 
  new_file = paste0(select_input_obj$datapath, file_ext)
  new_file = gsub(' +', '_', new_file)
  file.copy(select_input_obj$datapath, new_file, overwrite=TRUE)
  return(new_file)
}

