bbox <- lapply(resistance_norm,raster::bbox)
bbox_comma_sep <- function(x) {
  paste0(x[1,1],',',x[2,1],',',x[1,2],',',x[2,2])
}
bbox <- lapply(bbox, bbox_comma_sep)
colonne <- lapply(resistance_norm,raster::ncol)
righe <- lapply(resistance_norm,raster::nrow)
risoluzione <- lapply(resistance_norm,raster::xres)
wms <- "http://servizigis.regione.emilia-romagna.it/wms/agea2020_nir?" # url del servizio wms
url <- parse_url(wms)
fun_query <- function(var1,var2,var3,var4) {
  list(service = "WMS"
       ,version = "1.3.0" # optional
       ,request = "GetMap"
       ,layers = "Agea2020_NIR" # layer del servizio
       ,crs = "EPSG:25832" # uguale alla mappa della resistenza
       ,bbox = var1 # la dimensione in coordinate della mappa della resistenza
       ,format = "image/jpeg" # formato adatto per una foto
       ,WIDTH=((var2+1)*var4)
       ,HEIGHT=((var3+1)*var4)
  )}
query <- sapply(bbox,fun_query,colonne,righe,risoluzione)
request <- lapply(url,build_url)

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