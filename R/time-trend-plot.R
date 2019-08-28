#' Time trend plot, with linear or lowess trend, for all locations
#'
#' @param d_long data frame in long format (see make_long)
#' @param lowess if TRUE, add lowess curve; if FALSE, add linear trend
#' @return ggplot time trend plot with locations in facets
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' time_trend_plot(nine_points_long) # with lowess
#' time_trend_plot(nine_points_long, FALSE) # with line
#'
#' @export
#'
time_trend_plot=function(d_long, lowess=TRUE) {
    g <- ggplot2::ggplot(d_long, ggplot2::aes(x=year, y=day))+ggplot2::geom_point()+
      ggplot2::facet_wrap(~location)
    if (lowess) g + ggplot2::geom_smooth(se=F) else g + ggplot2::geom_smooth(se=F, method="lm")
}

#' Time trend plot, with linear or lowess trend, for single location
#'
#' @param d_long data frame in long format (see make_long)
#' @param lowess if TRUE, add lowess curve; if FALSE, add linear trend (defaults to TRUE)
#' @param loc character string that identifies location
#' @return ggplot time trend plot for specified location
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' time_trend_single(nine_points_long, loc=6) # with lowess
#' time_trend_single(nine_points_long, lowess=FALSE, loc=6) # with line
#'
#' @export
#'
time_trend_single=function(d_long, lowess=TRUE, loc) {
  d_long %>% dplyr::filter(location==loc) %>%
    ggplot2::ggplot(ggplot2::aes(x=year, y=day))+ggplot2::geom_point() -> g
  if (lowess) g + ggplot2::geom_smooth(se=F) else g + ggplot2::geom_smooth(se=F, method="lm")
}

