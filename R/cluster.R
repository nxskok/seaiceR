#' Hierarchical (Ward) cluster analysis
#'
#' @param data frame in wide format (see make_wide)
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
  # plot(bu.hc,xlab=label)
  # rect.hclust(bu.hc,n_cluster)
  clusters=cutree(bu.hc,k=n_cluster)
  dendr <- ggdendro::dendro_data(bu.hc)
  clust.df <- data.frame(label=names(clusters), cluster=factor(clusters))
  # dendr[["labels"]] has the labels, merge with clust.df based on label column
  dendr[["labels"]] <- merge(dendr[["labels"]],clust.df, by="label")
  ggplot2::ggplot() +
    ggplot2::geom_segment(data=ggdendro::segment(dendr), ggplot2::aes(x=x, y=y, xend=xend, yend=yend)) +
    ggplot2::geom_text(data=ggdendro::label(dendr), ggplot2::aes(x, y-10, label=label, hjust=0, colour=factor(clusters)), size=3) +
    ggplot2::guides(colour=F) +
    ggplot2::theme(axis.line.x=ggplot2::element_blank(),
          axis.ticks.x=ggplot2::element_blank(),
          axis.text.x=ggplot2::element_blank(),
          axis.title.x=ggplot2::element_blank(),
          panel.background=ggplot2::element_rect(fill="white"),
          panel.grid=ggplot2::element_blank()) -> g
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
