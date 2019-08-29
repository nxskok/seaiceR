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
  slopes %>% dplyr::summarize(
    mean=mean(theil_sen),
    SD=sd(theil_sen),
    min=min(theil_sen),
    Q1=quantile(theil_sen, 0.25),
    median=quantile(theil_sen, 0.50),
    Q3=quantile(theil_sen, 0.75),
    max=max(theil_sen)
  )
}

#' Map of Theil-Sen slopes of time trends with size of slope reflected in size of point
#'
#' @param d_long data frame in long format (see make_long)
#' @param locations latitude and longitude of locations
#' @param bounding_box bottom left long, lat, top right long, lat (as a vector)
#' @param zoom zoom factor for stamen map (default 5)
#' @param scaling factor to control overall size of points
#' @return graph
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' theil_sen_map(nine_points_long, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6, scaling=0.8)
#'
#' @export
#'
theil_sen_map=function(d_long, locations, bounding_box, zoom=5, scaling=1) {
  slopes <- seaiceR::theil_sen_slopes(d_long)
  draw_map(locations=locations, colour="red",
           size=slopes$theil_sen*scaling, bounding_box=bounding_box, zoom=zoom, title="Theil-Sen slopes map") +
    ggplot2::guides(colour=F)
}
