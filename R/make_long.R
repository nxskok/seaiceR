#' Make wide data long
#'
#' @param d data frame in wide format (years in column 1, called `year`, locations in other columns)
#' @return data frame in long format with one row per observation
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' make_long(nine_points)
#'
#' @export
#'
make_long <- function(d) {
  d %>% tidyr::gather(location, day, -year) %>%
    dplyr::mutate(location=as.numeric(location)) -> d_long
  d_long
}

#' Make long data wide
#'
#' @param d data frame in long format (year, location, day)
#' @return data frame in wide format (column of years, one column per location)
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' make_wide(nine_points_long) # should be same as nine_points
#'
#' @export
#'
make_wide <- function(d) {
  d %>% tidyr::spread(location, day) -> d_wide
  d_wide
}
