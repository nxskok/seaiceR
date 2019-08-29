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
    d %>% drop_na() -> d1
    label="missings excluded"
  } else {
    label="missings included"
    d1 <- d
  }
  d1 %>% select(-year) %>% t() %>% dist() -> d2
  bu.hc=hclust(d2,method="ward.D")
  # plot(bu.hc,xlab=label)
  # rect.hclust(bu.hc,n_cluster)
  clusters=cutree(bu.hc,k=n_cluster)
  dendr <- ggdendro::dendro_data(bu.hc)
  clust.df <- data.frame(label=names(clusters), cluster=factor(clusters))
  # dendr[["labels"]] has the labels, merge with clust.df based on label column
  dendr[["labels"]] <- merge(dendr[["labels"]],clust.df, by="label")
  ggplot() +
    geom_segment(data=ggdendro::segment(dendr), aes(x=x, y=y, xend=xend, yend=yend)) +
    geom_text(data=ggdendro::label(dendr), aes(x, y-10, label=label, hjust=0, colour=factor(clusters)), size=3) +
    guides(colour=F) +
    theme(axis.line.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.text.x=element_blank(),
          axis.title.x=element_blank(),
          panel.background=element_rect(fill="white"),
          panel.grid=element_blank()) -> g
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
  d %>% drop_na() %>% select(-year) %>% t() -> vv
  max_clusters=min(15, nrow(vv)-1)
  # scree plot
  tibble(clusters=2:max_clusters) %>%
    mutate(km=map(clusters, ~kmeans(vv, ., nstart=40))) %>%
    mutate(ss=map_dbl(km, "tot.withinss")) -> twss
  g=ggplot(twss, aes(x=clusters, y=ss))+geom_point()+geom_line()
  # get chosen number of clusters
  vv %>% kmeans(n_cluster, nstart=40) -> kmm
  clusters=enframe(kmm$cluster,name="location", value="cluster")
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
#' map_cluster(ward(nine_points, T, 3)$clusters, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6)
#' map_cluster(k_means(nine_points, 4)$clusters, nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6)
#'
#' @export
#'
map_cluster=function(clusters, locations, bounding_box, zoom) {
  draw_map(locations, as.factor(clusters), bounding_box=bounding_box, zoom=zoom, text="Cluster")
}
