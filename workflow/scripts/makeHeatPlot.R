library(magrittr)
library(ComplexHeatmap)
library(stringr)
library(circlize)

matrix_filename <- snakemake@input[[1]]
colorsForHeatPlot <- stringr::str_split(snakemake@params[[1]],pattern=",") %>% .[[1]]
heatplotBreaks <- stringr::str_split(snakemake@params[[2]],pattern=",") %>% .[[1]]
rds_output <- snakemake@output[[1]]

map_colors<-circlize::colorRamp2(heatplotBreaks,colorsForHeatPlot)

matrix <- read.table(matrix_filename,
                     skip=3,
                     header=F) %>% as.matrix

matrix <- matrix[rev(order(apply(matrix,1,quantile,0.8))),]

names <- read.table(matrix_filename,skip=2,nrow=1)[1,-1] %>% 
  as.character %>%
  gsub("_bkgrndNorm","",.)

htmp <- ComplexHeatmap::Heatmap(matrix,
                        cluster_columns = FALSE,
                        cluster_rows=FALSE,
                        show_column_names = FALSE,
                        show_row_names=FALSE,
                        column_split = names,
                        col=map_colors)

saveRDS(htmp,rds_output)