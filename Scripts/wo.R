
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
ndvi <-rast('./Data/VI/M3M_Merged_NDVI.tif')
# sample 
ndvi_aligned <- resample(ndvi, chm, method = "bilinear")
# Create a mask where CHM values are greater than 0.5
chm_mask <- chm > 0.5
# Mask the NDVI raster using the CHM mask
masked_ndvi <- mask(ndvi_aligned, chm_mask)

sampled_values <- extract(masked_ndvi, vect(buf), df = TRUE)
colnames(sampled_values)[2] <- 'value'
summary_stats <- sampled_values %>%
  group_by(ID) %>%
  summarise(
    average_ndvi = mean(value, na.rm = TRUE),  # Average NDVI
    count = n(),                               # Count of pixels
    min_ndvi = min(value, na.rm = TRUE),      # Minimum NDVI
    max_ndvi = max(value, na.rm = TRUE),      # Maximum NDVI
    sd_ndvi = sd(value, na.rm = TRUE)         # Standard deviation of NDVI
  )

result_df <- merge(summary_stats, st_drop_geometry(buf), by.x = "ID", by.y = "row.names", all.x = TRUE)

ggplot(result_df, aes(x= Plot, y = average_ndvi, colour = Group, group = Plot)) +
  geom_boxplot() +
  ylim(0.45,1)

anova(lmer(average_ndvi~Tree.classification*Health + (1|Group/Plot), data = result_df))


