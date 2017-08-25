# formatting utility functions

#' convert factor to numeric
as.Num = function(x){
  x %>% as.character %>% as.numeric
}

#' adding quotes to string 
add_quotes = function(x){
  paste0('"', x, '"')
}