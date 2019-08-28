## code to prepare `DATASET` dataset goes here
nine_points <- readRDS(url("http://www.utsc.utoronto.ca/~butler/sea_ice_data.rds"))
usethis::use_data(nine_points)

nine_points_long <- make_long(nine_points)
usethis::use_data(nine_points_long)

nine_points_locations <- read_csv("data-raw/nine_points_locations.csv", skip=1)
usethis::use_data(nine_points_locations)
