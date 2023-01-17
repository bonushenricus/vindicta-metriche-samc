# VINDICTA progetto 16.1 PSR Emilia-Romagna 2014-2020

## azione 3, analisi agroecosistema

### Calcolo delle metriche di analisi dell’agroecosistema

    library(raster) # per analizzare il raster
    library(httr)
    library(tidyverse)
    library(ggplot2)
    library(terrainr)
    library(patchwork)

### Visualizzazione della resistenza

    setwd('./raster') #cartella in cui si trovano i raster in formato tif
    resistance_norm <- raster('resistance_norm.tif') #carico come raster il file
    risoluzione <- xres(resistance_norm) #calcolo risoluzione, servirà a calcolare la risoluzione della foto aerea scaricata
    colonne <- ncol(resistance_norm) #idem come sopra
    righe <- nrow(resistance_norm) #idem come sopra

    resistance_norm_spdf <- as(resistance_norm, "SpatialPixelsDataFrame") #sono i passaggi per usare ggplot2 per visualizzare la carta
    resistance_norm_df <- as.data.frame(resistance_norm_spdf)
    colnames(resistance_norm_df) <- c("value", "x", "y")
    plot_resistance_norm <- ggplot(resistance_norm_df)+
      geom_tile(aes(x=x,y=y,fill=value))+
        scale_fill_distiller(type="seq",palette = "Reds",direction=-1)+ #direction=-1 è per invertire i gradienti
      coord_fixed() #per avere un quadrato sempre

    bbox <- raster::bbox(resistance_norm) #ricavo il bounding-box del raster
    bbox <- paste0(bbox[1,1],',',bbox[2,1],',',bbox[1,2],',',bbox[2,2]) #su cui estrarre il dato dal wms
    wms <- "http://servizigis.regione.emilia-romagna.it/wms/agea2020_nir?" # url del servizio wms
    url <- parse_url(wms)
    url$query <- list(service = "WMS"
                      ,version = "1.3.0" # optional
                      ,request = "GetMap"
                      ,layers = "Agea2020_NIR" # layer del servizio
                      ,crs = "EPSG:25832" # uguale alla mappa della resistenza
                      ,bbox = bbox # la dimensione in coordinate della mappa della resistenza
                      ,format = "image/jpeg" # formato adatto per una foto
                      ,WIDTH=((colonne[1]+1)*risoluzione)
                      ,HEIGHT=((righe[1]+1)*risoluzione)
    )
    request <- build_url(url)
    file <- "wms_raster.jpeg"
    GET(url = request, 
        write_disk(file,overwrite = T)) #estraggo un'immagine

    ## Response [http://servizigis.regione.emilia-romagna.it/wms/agea2020_nir?service=WMS&version=1.3.0&request=GetMap&layers=Agea2020_NIR&crs=EPSG%3A25832&bbox=642312.140941324%2C4957210.17631022%2C643292.140941324%2C4958190.17631022&format=image%2Fjpeg&WIDTH=1000&HEIGHT=1000]
    ##   Date: 2023-01-17 22:37
    ##   Status: 200
    ##   Content-Type: image/jpeg
    ##   Size: 133 kB
    ## <ON DISK>  /home/bonushenricus/Documenti/lavoro/progetti/vindicta/R/github_vindicta_samc/wms_raster.jpeg

    wms_raster <- stack("wms_raster.jpeg") #carico la foto aerea nelle 3 componenti RGB
    extent(wms_raster) <- extent(resistance_norm) #georeferenzio la foto aerea sul raster tif della resistenza
    crs(wms_raster) <- crs(resistance_norm) #do la proiezione corretta

    plot_wms_raster <- ggplot() +
      geom_spatial_rgb(
        data = wms_raster,
        mapping = aes(
          x=x,
          y=y,
          r=red,
          g=green,
          b=blue
        )
      )+
      coord_sf(crs = 25832)+ #stranamente mi segna comunque le coordinate in 4326
      coord_fixed()

    ## Warning: [rast] unknown extent

    plot_wms_raster|plot_resistance_norm

![](metriche_files/figure-markdown_strict/plot%20foto%20aerea%20+%20resistance_norm-1.png)
