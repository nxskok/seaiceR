#' Dendrogram with clusters shown by rectangles (like rect.hclust)
#'
#' @param object cluster object from hclust
#' @param n_cluster number of clusters to show
#'
#' @return ggplot like output from rect.hclust
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' rect_hclust(ward(nine_points, T, 3)$object, 4)
#'
#' @export
#'
rect_hclust=function(object, n_cluster) {
  # height first
  tibble::enframe(object$height, value="height") %>%
    dplyr::mutate(clusters=max(name)+2-name) -> h
  h %>% dplyr::filter(dplyr::between(clusters, n_cluster, n_cluster+1)) %>%
    dplyr::summarize(mh=mean(height)) %>%  dplyr::pull(mh) -> rect_height
  # cluster info, use to make box x-boundaries
  cutree(object, k=n_cluster) %>% tibble::enframe(name="label", value="cluster") -> d1
  object$labels %>% tibble::enframe(name="obs", value="label") -> d2
  object$order %>% tibble::enframe(name="ordered", value="obs") -> d3
  d3 %>% dplyr::left_join(d2) %>% dplyr::left_join(d1) -> cluster_info
  cluster_info %>%
    dplyr::mutate(prev_cluster=dplyr::lag(cluster)) %>%
    dplyr::mutate(diff_from_prev=(cluster!=prev_cluster)) -> thing
  thing %>% dplyr::filter(diff_from_prev) %>%
    dplyr::pull(ordered) -> brks
  brks <- c(1, brks, nrow(cluster_info)+1)-0.5
  tibble::tibble(w=brks) %>%
    dplyr::mutate(w_next=lead(w), h_min=0, h_max=rect_height) -> rectangles
  ggdendro::ggdendrogram(object) +
    ggplot2::geom_rect(data=rectangles, ggplot2::aes(xmin=w, xmax=w_next, ymin=h_min, ymax=h_max), colour="red", alpha=0.1)
}
#' Hierarchical (Ward) cluster analysis
#'
#' @param d data frame in wide format (see make_wide)
#' @param remove_missing whether or not to remove missing data
#' @param n_cluster number of clusters to obtain
#' @return list: dendrogram, cluster memberships
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' ward(nine_points, T, 3)
#'
#' @export
#'
ward=function(d, remove_missing=T, n_cluster) {
  if (remove_missing) {
    # take out missing
    d %>% tidyr::drop_na() -> d1
    label="missings excluded"
  } else {
    label="missings included"
    d1 <- d
  }
  d1 %>% dplyr::select(-year) %>% t() %>% dist() -> d2
  bu.hc=hclust(d2,method="ward.D")
  g <- rect_hclust(bu.hc, n_cluster)
  clusters <- cutree(bu.hc, n_cluster)
  list(dendrogram=g, clusters=clusters, object=bu.hc)
}

#' Non-hierarchical (K-means) cluster analysis
#'
#' @param data frame in wide format (see make_wide)
#' @param n_cluster number of clusters to obtain
#' @return list: scree plot, cluster memberships
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#'
#' k_means(nine_points, 4)
#'
#' @export
#'
k_means=function(d, n_cluster){
  # get rid of missings (and transpose)
  d %>% tidyr::drop_na() %>% dplyr::select(-year) %>% t() -> vv
  max_clusters=min(15, nrow(vv)-1)
  # scree plot
  tibble::tibble(clusters=2:max_clusters) %>%
    dplyr::mutate(km=purrr::map(clusters, ~kmeans(vv, ., nstart=40))) %>%
    dplyr::mutate(ss=purrr::map_dbl(km, "tot.withinss")) -> twss
  g=ggplot2::ggplot(twss, ggplot2::aes(x=clusters, y=ss))+ggplot2::geom_point()+ggplot2::geom_line()
  # get chosen number of clusters
  vv %>% kmeans(n_cluster, nstart=40) -> kmm
  clusters=tibble::enframe(kmm$cluster,name="location", value="cluster")
  clusters=kmm$cluster
  names(clusters)=1:length(clusters)
  list(scree=g, clusters=clusters)
}


#' Map clusters from cluster analysis
#'
#' @param clusters cluster output from cluster analysis
#' @param locations data frame of lats and longs for locations (columns Location, Latitude, Longitude)
#' @param bounding_box (long and lat of bottom left, long and lat of top right)
#' @param zoom for stamen map (defaults to 5)
#' @return map of locations coloured by cluster
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#'
#' map_cluster(ward(nine_points, T, 3)$clusters, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6, title="Cluster map (Ward's method)")
#' map_cluster(k_means(nine_points, 4)$clusters, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6, title="Cluster map (K-means method)")
#'
#' @export
#'
map_cluster=function(clusters, locations, bounding_box, zoom, title) {
  draw_map(locations, as.factor(clusters), bounding_box=bounding_box, zoom=zoom, text="Cluster", title=title)
}
