#' Make all the maps for a data set
#'
#' @param d wide-format data set (see make_wide)
#' @param locations lats and longs of the locations (data frame with three columns Location, Longitude, Latitude)
#' @param bounding_box bounding box for map: bottom left long, lat; top right long, lat, longitudes W negative
#' @param zoom zoom for map; higher requires more map tiles, but produces better map. Default 5.
#' @param scaling global scaling factor for points on Theil-Sen map, default 1
#' @param n_cluster number of clusters to use for Ward and K-means maps
#'
#' @return list of maps (including scree plot and dendrograms)
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#'
#' make_spatial(nine_points, nine_points_locations, n_cluster=4)
#' make_spatial(nine_points, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6, scaling=1, n_cluster=4)
#'
#' @export
#'
make_spatial <- function(d, locations, bounding_box=F, zoom=5, scaling=1, n_cluster) {
  # general map
  g1 <- draw_map(locations=locations, bounding_box=bounding_box, zoom=zoom)
  # make long data
  d_long <- make_long(d)
  # Mann-Kendall map
  g2 <- mk_map(d_long, locations, bounding_box, zoom)
  # Theil-Sen map
  g3 <- theil_sen_map(d_long, locations, bounding_box=bounding_box, zoom=zoom, scaling=scaling)
  # Ward missings-included clustering and map
  w <- ward(d, F, n_cluster)
  g4 <- w$dendrogram
  g5 <- map_cluster(w$clusters, locations, bounding_box, zoom, title="Ward missings included")
  # Ward missings-excluded clustering and map
  w2 <- ward(d, T, n_cluster)
  g6 <- w$dendrogram
  g7 <- map_cluster(w$clusters, locations, bounding_box, zoom, title="Ward missings excluded")
  # K-means and map
  k <- k_means(d, n_cluster)
  g8 <- k$scree
  g9 <- map_cluster(k$clusters, locations, bounding_box, zoom, title="K-means")
  return(list(g1, g2, g3, g4, g5, g6, g7, g8, g9))
}

#' Make temporal analysis without maps (in first part of spatial analysis)
#'
#' @param d wide-format data set
#'
#' @return list: Mann-Kendall result table, summary of significance, Theil-Sen slopes table, summary.
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#'
#' make_temporal(nine_points)
#'
#' @export
#'
make_temporal <- function(d) {
  d_long <- make_long(d)
  mk_table <- mann_kendall_table(d_long)
  mk_sig_summary <- mk_sig(d_long)
  ts_slopes <- theil_sen_slopes(d_long)
  ts_summary <- theil_sen_summary(d_long)
  list(mk_table, mk_sig_summary, ts_slopes, ts_summary)
}

#' Make the whole analysis for a data set
#'
#' @param d wide-format data set (see make_wide)
#' @param locations lats and longs of the locations (data frame with three columns Location, Longitude, Latitude)
#' @param bounding_box bounding box for map: bottom left long, lat; top right long, lat, longitudes W negative. Defaults to FALSE; then determined from data.
#' @param zoom zoom for map; higher requires more map tiles, but produces better map. Default 5, max 18.
#' @param scaling global scaling factor for points on Theil-Sen map, default 1 (bigger makes all points bigger)
#' @param n_cluster number of clusters to use for Ward and K-means maps

#' @return list of 2: the temporal results from nake_temporal; the spatial results from make_spatial.
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#'
#' make_everything(nine_points, nine_points_locations, n_cluster=4)
#'
#' @export
#'
make_everything=function(d, locations, bounding_box=F, zoom=5, scaling=1, n_cluster) {
  l1 <- make_temporal(d)
  l2 <- make_spatial(d, locations, bounding_box, zoom, scaling, n_cluster)
  list(temporal=l1, spatial=l2)
}
