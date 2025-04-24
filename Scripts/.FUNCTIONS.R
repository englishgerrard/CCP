
# using 0.75 m spatial buffers (with master tree attributes assigned to them (see method in CCP report)
# and the M3M generated canopy height model
# this function extracts raster values that are higher than 0.5m (can be customised in function)
# and are with 0.75 m of M3E generated tree tops
)
sample_VI <- function(raster.path = './Data/VI/M3M_Merged_NDVI.tif', 
                      chm.filter = 0.5,
                      vi.name = 'NDVI'){
  # combine 0.75m buffer at M3E tree top loctions with groud truth tree attributes  
  # and updated 2024 tree data 
  # and black treatment variables
  buf <- left_join(left_join(st_read('./Data/spatial_data/M3E_treetopBuffer_wAttributes.shp')[c(1:12, 16,18,20:24,28:32,80)],
                             read.csv('./Data/master_tree_locations/BTM 24 master data cleaned (not merged).csv')[,-c(6,7,8)],
                             by = 'Barcode') %>%
                     mutate(Plot =Id), read.csv('./Data/Vars.csv'), by = 'Plot')
  
  # the M3M canopy hieght model
  chm <- rast('./Data/CHM/M3M_Merged_CHM.tif')
  # site NDVI
  VI <- rast(raster.path)
  # sample 
  VI_aligned <- resample(VI, chm, method = "bilinear")
  # Create a mask where CHM values are greater than 0.5
  chm_mask <- chm > chm.filter
  # Mask the NDVI raster using the CHM mask
  masked_VI <- mask(VI_aligned, chm_mask)
  
  sampled_values <- extract(masked_VI, vect(buf), df = TRUE)
  colnames(sampled_values)[2] <- 'value'
  summary_stats <- sampled_values %>%
    group_by(ID) %>%
    summarise(
      average_vi = mean(value, na.rm = TRUE),  # Average NDVI
      count = n(),                               # Count of pixels
      min_vi = min(value, na.rm = TRUE),      # Minimum NDVI
      max_vi = max(value, na.rm = TRUE),      # Maximum NDVI
      sd_vi = sd(value, na.rm = TRUE)         # Standard deviation of NDVI
    )
  
  result_df <- merge(summary_stats, st_drop_geometry(buf), by.x = "ID", by.y = "row.names", all.x = TRUE)
  colnames(result_df) <- gsub("vi", vi.name, colnames(result_df))
  
return(result_df)  
                      }


