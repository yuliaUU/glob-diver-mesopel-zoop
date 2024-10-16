plot_per_phylum <- function(phylum_name, dim_value) {
  sums = function(dd){
    # remove rows that had empty values  in all species columns
    dd1= dd[rowSums(is.na(dd[,-c(1:3)])) != ncol(dd[,-c(1:3)]), ]
    coord=dd1[,1:3]
    total=rowSums(dd1[,-c(1:3)], na.rm =TRUE)
    return(cbind(coord,total))
  }
  # Select species names based on the phylum
  sp1 <- META_zoop |> 
    select(name, phylum) |>  
    filter(phylum == phylum_name) |> 
    mutate(col_names = paste0(name, "_wmean")) |> 
    pull(col_names)
  
  sp2 <- META_zoop |> 
    select(name, phylum) |>  
    filter(phylum == phylum_name) |> 
    mutate(col_names = paste0(name, "_HSIwmean")) |> 
    pull(col_names)
  
  # Filter and transform data
  ENSEMBLE_occ.wmean1 <- ENSEMBLE_occ.wmean |> select(longitude, latitude, ProvId, all_of(sp1))
  ENSEMBLE_occ.wmean.tot1 <- sums(ENSEMBLE_occ.wmean1) |> drop_na(ProvId)
  
  # Maximum species per latitude
  max.sp_lat <- ENSEMBLE_occ.wmean1 |> 
    pivot_longer(-c("longitude", "latitude", "ProvId")) |> 
    filter(value >= 1) |> 
    group_by(latitude) |> 
    summarise(count = n_distinct(name), .groups = "keep")
  
  # Plot for Species Richness and Latitudinal Gradient
  ldg_UR <- ENSEMBLE_occ.wmean.tot1[, c(1, 2, 4)] |> 
    filter(total > 0) |>
    ltg() +
    geom_line(data = max.sp_lat, aes(x = latitude, y = count), color = "grey70") +
    labs(x = "Latitude (cell midpoint)", color = "Species Richness", y = "Species Richness")
  
  SR_UR <- plot.map(ENSEMBLE_occ.wmean.tot1[, c("longitude", "latitude", "total")]) +
    labs(color = "Species Richness")
  
  sr_patch <- SR_UR + 
    ldg_UR + 
    theme(legend.position = "none") +
    plot_layout(widths = c(3.0, 1)) +
    plot_layout(guides = 'collect')
  
  # Compute Species Importance
  sp.importance <- ENSEMBLE_occ.wmean1 |> 
    group_by(longitude, latitude, ProvId) |> 
    pivot_longer(-c("longitude", "latitude", "ProvId")) |> 
    drop_na(value) |> 
    filter(value > 0) |>
    group_by(name) |> 
    mutate(N = n()) |> 
    ungroup() |> 
    mutate(R = value / N)
  
  dt <- sp.importance |> 
    group_by(latitude, longitude, ProvId) |> 
    summarize(sum = sum(R, na.rm = TRUE), .groups = "keep") |> 
    ungroup() |> 
    right_join(grid, by = c("latitude", "longitude", "ProvId")) |> 
    drop_na(ProvId) |> 
    select(longitude, latitude, sum) |> 
    mutate(sum = scales::rescale(sum)) |> 
    drop_na()
  
  dt1 <- sp.importance |> 
    group_by(latitude, longitude, ProvId) |> 
    summarize(n = n(), sum = sum(R, na.rm = TRUE) / n, .groups = "keep") |>  
    ungroup() |> 
    right_join(grid, by = c("latitude", "longitude", "ProvId")) |> 
    drop_na(ProvId) |> 
    select(longitude, latitude, sum) |> 
    mutate(sum = scales::rescale(sum)) |> 
    drop_na()
  
  # Rarity Plots
  tot_rarity <- plot.map(dt) + labs(color = "Total range-size rarity")
  
  ldg_tot_rarity <- dt |> 
    rename(total = sum) |> 
    ltg() + labs(x = "Latitude (cell midpoint)", y = "Total range-size rarity", color = "Total range-size rarity")
  
  tot_rarity_patch <- tot_rarity + 
    theme(legend.position = "none") + 
    ldg_tot_rarity + 
    plot_layout(widths = c(3.0, 1)) +
    plot_layout(guides = 'collect')
  
  avrg_rarity <- plot.map(dt1) + labs(color = "Average range-size rarity")
  
  ldg_avrg_rarity <- dt1 |> 
    rename(total = sum) |> 
    ltg() + labs(x = "Latitude (cell midpoint)", y = "Average range-size rarity", color = "Average range-size rarity")
  
  avrg_rarity_patch <- avrg_rarity + 
    theme(legend.position = "none") + 
    ldg_avrg_rarity + 
    plot_layout(widths = c(3.0, 1)) +
    plot_layout(guides = 'collect')
  
  # 2D Bivariate Mapping
  dt2D <- full_join(ENSEMBLE_occ.wmean.tot1[, c(1, 2, 4)], dt, by = c("longitude", "latitude")) |> drop_na(sum, total)
  
  NE_places.df <- bi_class(dt2D, x = total, y = sum, style = "quantile", dim = dim_value)
  names(NE_places.df) <- c("lon", "lat", "PROB", "PROB1", "bi_class")
  
  sf_object <- st_as_sf(NE_places.df, coords = c("lon", "lat"), crs = 4326)
  transformed_sf <- st_transform(sf_object, crs = PROJ)
  NE_places.df.prj <- as.data.frame(st_coordinates(transformed_sf))
  names(NE_places.df.prj)[1:2] <- c("X.prj", "Y.prj")
  
  NE_places.dt.prj <- data.table(NE_places.df.prj, NE_places.df)
  
  # Map and Legend
  map <- ggplot() +
    geom_point(data = NE_places.dt.prj, aes(x = X.prj, y = Y.prj, color = bi_class), size = 1, show.legend = FALSE) +
    bi_scale_color(pal = "BlueYl", dim = dim_value) +
    geom_polygon(data = NE_countries.prj, aes(long, lat, group = group), colour = "gray70", fill = "gray90", size = .25) +
    geom_polygon(data = NE_box.prj, aes(x = long, y = lat), colour = "black", fill = "transparent", size = .25) +
    geom_path(data = NE_graticules.prj, aes(long, lat, group = group), linetype = "dotted", colour = "grey50", size = .25) +
    theme_void()
  
  legend <- bi_legend(pal = "BlueYl", dim = dim_value, xlab = "species richness", ylab = "total rarity", size = 8)
  
  # Combine Map and Legend
  SR_TotRar_2D <- ggdraw() + draw_plot(map, 0, 0, 1, 1) + draw_plot(legend, 0.76, .74, 0.3, 0.3)
  
  # Final Layout
  (sr_patch / tot_rarity_patch / avrg_rarity_patch / SR_TotRar_2D) +
    plot_layout(heights = c(1, 1, 1, 1.5)) + 
    plot_annotation(tag_levels = 'A') &
    theme(plot.tag = element_text("Times New Roman", face = "bold", size = 12, hjust = -3, vjust = 0))
}

# Usage Example:
#plot_per_phylum("Annelida", 2)
