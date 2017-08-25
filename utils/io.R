# i/o utility functions 

#' remaming temp file produced by fileInput (adding back file extension)
#' select_input_obj = object generated from shiny::selectInput()
rename_tmp_file = function(select_input_obj){
  file_ext = gsub('.+(\\.[^.])$', '\\1', select_input_obj$name) 
  new_file = paste0(select_input_obj$datapath, file_ext)
  file.copy(select_input_obj$datapath, new_file, overwrite=TRUE)
  return(new_file)
}
