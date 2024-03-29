% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mann-kendall.R
\name{mann_kendall_table}
\alias{mann_kendall_table}
\title{Significance of Mann-Kendall test for trend, summarized}
\usage{
mann_kendall_table(d_long)
}
\arguments{
\item{d_long}{data frame in long format (see make_long)}
}
\value{
data frame summarizing Mann-Kendall significance for all locations. Columns of interest:
z-star: Mann-Kendall test statistic adjusted for autocorrelation by method of Hamed and Rao;
ratio: Effective sample size ratio: greater than 1 = positive autocorrelation, less than 1 = negative autocorrelation (rare), 1 = no adjustment needed;
P_value: Basic Mann-Kendall P-value;
P_value_adj: Mann-Kendall P-value adjusted for autocorrelation;
P_value_2, P_value_adj_2: text versions of P-values formatted to not be in scientific notation (easier to read by human).
colour: colour-coded significance level
}
\description{
Significance of Mann-Kendall test for trend, summarized
}
\examples{
mann_kendall_table(nine_points_long)

}
\author{
Ken Butler, \email{butler@utsc.utoronto.ca}
}
