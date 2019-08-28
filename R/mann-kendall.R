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
    dplyr::mutate(P_value_adj_2=format(P_value_adj, scientific=F)) -> mann_kendall
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
