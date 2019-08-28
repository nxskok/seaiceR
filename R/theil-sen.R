#' Theil-Sen slopes of time trends for each location
#'
#' @param d_long data frame in long format (see make_long)
#' @return data frame containing location, nested data frame containing year and days, Theil-Sen slope for that location
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' theil_sen_slopes(nine_points_long)
#'
#' @export
#'
theil_sen_slopes=function(d_long) {
  d_long %>% tidyr::drop_na() %>%
    tidyr::nest(-location) %>%
    dplyr::mutate(theil_sen=purrr::map_dbl(data, ~mkac::theil_sen_slope(.$day)))
}

#' Theil-Sen slopes of time trends for each location, summarized
#'
#' @param d_long data frame in long format (see make_long)
#' @return numerical summaries of Theil-Sen slopes
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' theil_sen_summary(nine_points_long)
#'
#' @export
#'
theil_sen_summary=function(d_long) {
  slopes <- seaiceR::theil_sen_slopes(d_long)
  slopes %>% summarize(
    mean=mean(theil_sen),
    SD=sd(theil_sen),
    min=min(theil_sen),
    Q1=quantile(theil_sen, 0.25),
    median=quantile(theil_sen, 0.50),
    Q3=quantile(theil_sen, 0.75),
    max=max(theil_sen)
  )
}
