
NDVI <- sample_VI(raster.path = './Data/VI/M3M_Merged_NDVI.tif', 
                  chm.filter = 0.5,
                  vi.name = 'NDVI')

write.csv(NDVI, './Data/individual_tree_NDVI.csv')
