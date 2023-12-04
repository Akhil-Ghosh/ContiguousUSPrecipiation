library(tidyverse)
library(ggplot2)
library(reshape2)
library(sf)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(animation)
library(RCurl)

cpcNumLat   <- 120 # number of lats
cpcNumLon   <- 300 # number of lons
cpcNumBytes <- cpcNumLat * cpcNumLon * 2 # 2 fields, precipitation and num gages
cpcRes      <- 0.25 # data resolution
cpcLatVec   <- 20.125 + (1:cpcNumLat)*cpcRes - cpcRes # latitudes
cpcLonVec   <- -129.875 + (1:cpcNumLon)*cpcRes - cpcRes # longitudes


get_Xth_percentile <- function(percentile, year1=1950,year2=1979) {
  baseline_years <- as.character(year1:year2)
  
  # Initialize matrix to store flattened daily data
  num_days <- sum(sapply(baseline_years, function(y) {
    sum(sapply(names(precipitation_data[[y]]), function(m) {
      length(names(precipitation_data[[y]][[m]]))
    }))
  }))
  
  # Dimensions of a single day's data
  day_dims <- c(120,300)
  num_lat_lon_pairs <- prod(day_dims)
  
  data_matrix <- matrix(NA, nrow=num_lat_lon_pairs, ncol=num_days)
  
  # Flatten and store daily data directly into data_matrix
  col_idx <- 1
  for (year in baseline_years) {
    for (month in names(precipitation_data[[year]])) {
      for (day in names(precipitation_data[[year]][[month]])) {
        day_data <- precipitation_data[[year]][[month]][[day]]
        data_matrix[,col_idx] <- as.vector(day_data)
        col_idx <- col_idx + 1
      }
    }
  }
  
  # Calculate Xth percentile for each latitude-longitude pair
  percentile_calc <- apply(data_matrix, 1, function(x) {
    if (all(is.na(x))) {
      return(NA)
    } else {
      return(quantile(x, percentile, na.rm = TRUE))
    }
  })
  
  return(percentile_calc)
}


plot_extreme_events <- function(year, percentile_matrix) {
  # Reshape the percentile_95 vector back to matrix form
  day_dims <- dim(precipitation_data$`1950`$Jan$`1`)
  
  # Get data for the given year and calculate extreme events
  yearly_data <- precipitation_data[[as.character(year)]]
  extreme_count <- matrix(0, nrow = day_dims[1], ncol = day_dims[2])
  for (month_data in yearly_data) {
    for (day_data in month_data) {
      extreme_count <- extreme_count + (day_data > percentile_matrix)
    }
  }
  
  # Plotting
  r <- raster(extreme_count, 
              xmn=min(cpcLonVec), xmx=max(cpcLonVec), 
              ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  states <- ne_states(country = "United States of America", returnclass = "sf")
  great_lakes_states <- c("Michigan", "Wisconsin", "Illinois", "Indiana", "Ohio", "Minnesota", "Iowa", "Missouri", "New York", "Pennsylvania")
  states <- states[states$name %in% great_lakes_states, ]
  states_raster <- rasterize(states, r, field=1)
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  p <- ggplot() +
    geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
    geom_sf(data = states, color = "black", fill = NA) +
    scale_fill_gradientn(colors = c("red", "yellow", "cyan", "blue"), 
                         name = "Extreme Events Count",
                         limits = c(0,50),
                         oob = scales::squish) +  # Setting fixed limits here
    labs(title = paste("Extreme Precipitation Events in", year),
         x = "Longitude",
         y = "Latitude") +
    theme_minimal() +
    coord_sf(expand = FALSE, xlim = c(-98, -70), ylim = c(35, 50))
  return(p)
}

plot_extreme_events_US <- function(year, percentile_matrix) {
  # Reshape the percentile_95 vector back to matrix form
  day_dims <- c(120, 300)

    # Get data for the given year and calculate extreme events
  yearly_data <- precipitation_data[[as.character(year)]]
  extreme_count <- matrix(0, nrow = day_dims[1], ncol = day_dims[2])
  for (month_data in yearly_data) {
    for (day_data in month_data) {
      extreme_count <- extreme_count + (day_data > percentile_matrix)
    }
  }
  
  # Plotting
  r <- raster(extreme_count, 
              xmn=min(cpcLonVec), xmx=max(cpcLonVec), 
              ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  states <- ne_states(country = "United States of America", returnclass = "sf")
  states_raster <- rasterize(states, r, field=1)
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  p <- ggplot() +
    geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
    geom_sf(data = states, color = "black", fill = NA) +
    scale_fill_gradientn(colors = c("red", "yellow", "cyan", "blue"), 
                         name = "Extreme Events Count",
                         limits = c(0,10),
                         oob = scales::squish) +  # Setting fixed limits here
    labs(title = paste("Extreme Precipitation Events in", year),
         x = "Longitude",
         y = "Latitude") +
    theme_minimal() +
    coord_sf(expand = FALSE, xlim = c(-125, -66), ylim = c(24, 49))  # Adjusted limits for the entire contiguous U.S.
  return(p)
}