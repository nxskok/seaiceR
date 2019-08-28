#' Map of locations with colours and/or sizes
#'
#' @param locations data frame with columns Location, Longitude, Latitude
#' @param colours vector of things to colour, in same order as locations
#' @param bounding_box bottom left long, bottom left lat, top right long, top right lat (vector of length 4); W longs negative
#' @param zoom stamen maps zoom (higher=better resolution but more tiles to get), default 5
#' @return map showing points labelled by location
#'
#' @author Ken Butler, \email{butler@utsc.utoronto.ca}
#'
#' @examples
#' draw_map(nine_points_locations, bounding_box=c(-87.5, 71, -82.5, 74), zoom=5)
#'
#' @export
#'
draw_map=function(locations, colours=NULL, size=NULL, bounding_box, zoom=5) {
  the_map=get_stamenmap(bbox=bounding_box, zoom=zoom, maptype="toner-lite")
  ggmap(the_map) +
    geom_point(data=locations, aes(x=-Longitude, y=Latitude, colour=colours, size=size)) +
    geom_text_repel(data=locations, aes(x=-Longitude, y=Latitude, label=Location)) +
    xlab("Longitude") + ylab("Latitude")
}
