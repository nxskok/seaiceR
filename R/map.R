#' Map of locations with colours and/or sizes
#'
#' @param locations data frame with columns Location, Longitude, Latitude
#' @param colours vector of things to colour, in same order as locations
#' @param bounding_box If FALSE (default), determined from locations; else bottom left long, bottom left lat, top right long, top right lat (vector of length 4); W longs negative
#' @param zoom stamen maps zoom (higher=better resolution but more tiles to get), default 5
#' @param text text to go above the legend
#' @param title title for the plot
#'
#' @return map showing points labelled by location
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' draw_map(nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=6)
#'
#' @export
#'
draw_map=function(locations, colours=NULL, size=NULL, bounding_box=F, zoom=5, text=NULL, title=NULL) {
  if (!bounding_box) {
    lon_extremes=range(-locations$Longitude) # assuming longitude west
    lat_extremes=range(locations$Latitude)
    lon_range=lon_extremes[2]-lon_extremes[1]
    lat_range=lat_extremes[2]-lat_extremes[1]
    extra=5 # arbitrary: go 1/5 of the range beyond the extremes
    bounding_box=c(
      lon_extremes[1]-lon_range/extra,
      lat_extremes[1]-lat_range/extra,
      lon_extremes[2]+lon_range/extra,
      lat_extremes[2]+lat_range/extra
    )
  }
  the_map=ggmap::get_stamenmap(bbox=bounding_box, zoom=zoom, maptype="toner-lite")
  ggmap::ggmap(the_map) +
    ggplot2::geom_point(data=locations, ggplot2::aes(x=-Longitude, y=Latitude, colour=colours, size=size)) +
    ggrepel::geom_text_repel(data=locations, ggplot2::aes(x=-Longitude, y=Latitude, label=Location)) +
    ggplot2::xlab("Longitude") + ggplot2::ylab("Latitude") + ggplot2::labs(colour=text) +
    ggplot2::ggtitle(title)
}
