plot.map2D<- function(dt2D, dim=4,  xlab = "species richness",ylab = "total rarity", pal= "BlueYl"){
  dim=dim
  # before projecting, transform NE_places to data frame to use it inside ggplot()
  NE_places.df <- bi_class(dt2D, x = total, y = sum, style = "quantile", dim = dim)
  names(NE_places.df) <- c("lon", "lat","PROB","PROB1","bi_class")
  NE_places.dt.prj <- data.table(NE_places.df,NE_places.df)
  
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
  
  map<- ggplot() +
    geom_point(data = NE_places.dt.prj, 
               aes(x = X.prj, y = Y.prj, color=bi_class),size = 1, 
               show.legend = FALSE) +
    bi_scale_color(pal = pal, dim = dim) +
    geom_polygon(data = NE_countries.prj, 
                 aes(long,lat, group = group), 
                 colour = "gray70", fill = "gray90", size = .25) +
    geom_polygon(data = NE_box.prj, 
                 aes(x = long, y = lat), 
                 colour = "black", fill = "transparent", size = .25) +
    geom_path(data = NE_graticules.prj, 
              aes(long, lat, group = group), 
              linetype = "dotted", colour = "grey50", size = .25) +
    geom_text(data = lbl.Y.prj, # latitude
              aes(x = X.prj, y = Y.prj, label = lbl), 
              colour = "grey50", size = 2) +
    geom_text(data = lbl.X.prj, # latitude
              aes(x = X.prj, y = Y.prj*1.04, label = lbl), 
              colour = "grey50", size = 2) +
    coord_fixed(ratio = 1) +
    theme_void() + # remove the default background, gridlines & default gray color around legend's symbols
    # final theme tweaks
    theme(legend.title = element_text(colour="black", size=10, face="bold",angle = 90), # adjust legend title
          legend.title.align = 0.5,
          legend.direction = "vertical",
          legend.margin=margin(0,0,0,0),
          legend.box.margin=margin(-10,-10,-10,-10),
          #legend.position = c(1.01, 0.25), # relative position of legend
          plot.margin = unit(c(t=0, r=1, b=0, l=0), unit="cm")
    ) 
  
  legend <- bi_legend(pal = pal,
                      dim = dim,
                      xlab = xlab,
                      ylab = ylab,
                      size = 8)+
    theme(
      plot.background = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank()
    )
  
  # combine map with legend
  ggdraw() +
    draw_plot(map, 0, 0, 1, 1) +
    draw_plot(legend, 0.76, .74, 0.3, 0.3)
  
}