## R Markdown

Calcolo delle metriche di analisi dell’agroecosistema per il progetto
VINDICTA

    setwd('./raster')
    resistance_norm <- raster('resistance_norm.tif')
    levelplot(resistance_norm,zscaleLog=TRUE,margin=F)

![](metriche_files/figure-markdown_strict/resistance-1.png)
