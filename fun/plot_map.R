# load datat for plotting
load("rds/map.RData")
my.colors=c("#313695","#4575b4","#74add1","#abd9e9","#e0f3f8","#ffffbf","#fee090","#fdae61","#f46d43","#d73027","#a50026")
#my.colors = colorRampPalette(c("#2c7bb6","#ffffbf","#d7191c"))(11)
plot.map<- function(NE_places.df, continious=TRUE,alpha = 0.5, size = 1){
  names(NE_places.df) <- c("lon", "lat","PROB")
  # Create an sf object from the data frame
  sf_object <- st_as_sf(NE_places.df, coords = c("lon", "lat"), crs = 4326)
  
  # Transform the coordinates to the desired CRS
  transformed_sf <- st_transform(sf_object, crs = PROJ)
  
  # Extract the transformed coordinates and convert them to a data frame
  NE_places.df.prj <- as.data.frame(st_coordinates(transformed_sf))
  
  # Rename the columns
  names(NE_places.df.prj)[1:2] <- c("X.prj", "Y.prj")
  # transform to data.table (easier to work with)
  NE_places.dt.prj <- data.table(NE_places.df.prj,NE_places.df)
  
  plt<- ggplot() +
    # add locations (points); add opacity with "alpha" argument
    geom_point(data = NE_places.dt.prj, 
               aes(x = X.prj, y = Y.prj, colour = PROB),size = size, 
               alpha = alpha) +
    geom_polygon(data = NE_countries.prj, 
                 aes(long,lat, group = group), 
                 colour = "gray70", fill = "gray90", size = .25) +
    # add projected bounding box
    geom_polygon(data = NE_box.prj, 
                 aes(x = long, y = lat), 
                 colour = "black", fill = "transparent", size = .25) +
    # add graticules
    geom_path(data = NE_graticules.prj, 
              aes(long, lat, group = group), 
              linetype = "dotted", colour = "grey50", linewidth = .25) +
    # add graticule labels - latitude and longitude
    geom_text(data = lbl.Y.prj, # latitude
              aes(x = X.prj, y = Y.prj, label = lbl), 
              colour = "grey50", size = 2) +
    geom_text(data = lbl.X.prj, # latitude
              aes(x = X.prj, y = Y.prj*1.04, label = lbl), 
              colour = "grey50", size = 2) +
    # __ Set aspect ratio
    coord_fixed(ratio = 1) +
    # __ Set empty theme
    theme_void(base_size=12, base_family="Times New Roman") + # remove the default background, gridlines & default gray color around legend's symbols
    # final theme tweaks
    theme(legend.title = element_text(colour="black", size=10, face="bold",angle = 90), # adjust legend title
          legend.title.align = 0.5,
          legend.direction = "vertical",
          legend.margin=margin(0,0,0,0),
          legend.box.margin=margin(0,0,0,0),
          #legend.position = c(1.01, 0.25), # relative position of legend
          plot.margin = unit(c(t=0, r=1, b=0, l=0), unit="cm")
    ) 
  if (continious==FALSE) {
    plt
  }else{
    plt+scale_color_gradientn(colours = my.colors,#RColorBrewer::brewer.pal(11, 'Spectral')[11:1],
                              guide = guide_colourbar(
                                title.position = "left",  barwidth=0.5,barheight=10,ticks=TRUE,
                                nbin = 10))
  }
  
}

scale_fill_Publication <- function(...){
  library(scales)
  discrete_scale("fill","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33","darkgreen")), ...)
  
}

scale_colour_Publication <- function(...){
  library(scales)
  discrete_scale("colour","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33","darkgreen")), ...)
  
}
