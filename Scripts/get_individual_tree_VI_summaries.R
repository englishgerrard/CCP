source('./Scripts/.FUNCTIONS.R')
source('./Scripts/.PACKAGES.R')

NDVI <- sample_VI(raster.path = './Data/VI/M3M_Merged_NDVI.tif', 
                  chm.filter = 0.5,
                  vi.name = 'NDVI')

# write.csv(NDVI, './Data/individual_tree_NDVI.csv')


GRVI <- sample_VI(raster.path = './Data/VI/GRVI_R_computed.tif', 
                  chm.filter = 0.5,
                  vi.name = 'GRVI')

write.csv(GRVI, './Data/individual_tree_GRVI.csv')

