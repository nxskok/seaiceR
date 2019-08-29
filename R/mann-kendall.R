#' Significance of Mann-Kendall test for trend, summarized
#'
#' @param d_long data frame in long format (see make_long)
#' @return data frame summarizing Mann-Kendall significance for all locations. Columns of interest:
#  z: Basic Mann-Kendall test statistic;
#' z-star: Mann-Kendall test statistic adjusted for autocorrelation by method of Hamed and Rao;
#' ratio: Effective sample size ratio: greater than 1 = positive autocorrelation, less than 1 = negative autocorrelation (rare), 1 = no adjustment needed;
#' P_value: Basic Mann-Kendall P-value;
#' P_value_adj: Mann-Kendall P-value adjusted for autocorrelation;
#' P_value_2, P_value_adj_2: text versions of P-values formatted to not be in scientific notation (easier to read by human).
#' colour: colour-coded significance level
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' mann_kendall_table(nine_points_long)
#'
#' @export
#'
mann_kendall_table=function(d_long){
  d_long %>%
    tidyr::drop_na() %>%
    tidyr::nest(-location) %>%
    dplyr::mutate(MK=purrr::map(data, ~as_tibble(mkac::kendall_Z_adjusted(.$day)))) %>%
    tidyr::unnest(MK) %>%
    dplyr::mutate(P_value_2=format(P_value, scientific=F)) %>%
    dplyr::mutate(P_value_adj_2=format(P_value_adj, scientific=F)) %>%
    dplyr::mutate(P_level=cut(P_value_adj, c(0, 0.01, 0.05, 0.10, 1))) -> mann_kendall
  mann_kendall
}


#' Count number of significant Mann-Kendall trends
#'
#' @param d_long data frame in long format (see make_long)
#' @param alpha significance level (default 0.05)
#' @return table showing number of significant and non-significant Mann-Kendall trends
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' mk_sig(nine_points_long)
#' mk_sig(nine_points_long, alpha=0.01)
#'
#' @export
#'
mk_sig=function(d_long, alpha=0.05) {
  seaiceR::mann_kendall_table(d_long) %>%
    dplyr::count(P_value_adj<=alpha)
}


#' Map of Mann-Kendall significance levels
#'
#' @param d_long long format data set
#' @param locations lats and longs of locations
#' @param bounding_box bottom left long, lat, top right long, lat (as a vector)
#' @param zoom zoom factor for stamen map (default 5)
#'
#' @return ggplot map of locations coloured by P-level
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' mk_map(nine_points_long, nine_points_locations, c(-87.5, 71, -82.5, 74), zoom=6)
#' @export
#'
mk_map=function(d_long, locations, bounding_box, zoom=5) {
  mk_tab=mann_kendall_table(d_long)
  draw_map(locations, colours=mk_tab$P_level, bounding_box=bounding_box, zoom=zoom)
}
