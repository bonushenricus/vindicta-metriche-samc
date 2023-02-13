library(raster)
library(ggplot2)
library(terrainr)

#questa prima parte è da ripetere solo se non è già stata caricata da foto_aeree.R, e serve per l'estensione
mappe_cartella <- './cartografia/fotointerpretazione/raster' #come base uso le mappe degli habitat
mappe_files <- list.files(path=mappe_cartella,                #lista di file tif (nelle cartelle ci sono anche i README.md)
                          pattern = "\\.tif$",
                          full.names = TRUE,
                          recursive = T)
mappe_nomi <- strsplit(mappe_files, "(\\\\|/)+") #per dare i nomi ai file
mappe_nomi <- sapply(mappe_nomi, function(prova) prova[5])
cartella_foto_aeree <- './cartografia/output/0_foto_aeree/'
mappe_nomi <- sapply(mappe_nomi,function(x) paste0(cartella_foto_aeree,x))
mappe_rast <- lapply(mappe_files, raster) #i raster degli habitat vengono aperti per poter ricavarne i dati per interrogare il servizio wms


cartella_foto_aeree <- './cartografia/output/0_foto_aeree'
foto_aeree_files <- list.files(path=cartella_foto_aeree,                #lista di file tif
                           pattern = "\\.tif$",
                           full.names = TRUE,
                           recursive = T)
wms_raster <- mapply(function(x) stack(x),foto_aeree_files) #carico la foto aerea nelle 3 componenti RGB
fun_extent <- function(x,y) {
  extent(x) <- extent(y)
}
mapply(fun_extent,wms_raster,mappe_rast,SIMPLIFY = F)

fun_plot_rgb <- function(x) ggplot() +
  geom_spatial_rgb(
    data = x,
    mapping = aes(
      x=x,
      y=y,
      r=red,
      g=green,
      b=blue
    )
  )
#+
#  coord_sf(crs = 25832)+ #stranamente mi segna comunque le coordinate in 4326
#  coord_fixed()
plot_foto_aeree <- lapply(wms_raster,fun_plot_rgb)
