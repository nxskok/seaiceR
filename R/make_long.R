#' Make wide data long
#'
#' @param d data frame in wide format (years in column 1, called `year`, locations in other columns)
#' @return data frame in long format with one row per observation
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
make_long(example_data)
#' @export
#'
make_long=function(d) {
  d %>% tidyr::gather(location, day, -year) %>%
    dplyr::mutate(location=as.numeric(location)) -> d_long
  d_long
}
