#uno script da usare per scaricare le foto aeree da un servizio WMS delle aree elaborate
library(raster)
library(httr)

mappe_cartella <- './cartografia/fotointerpretazione/raster' #come base uso le mappe degli habitat
mappe_files <- list.files(path=mappe_cartella,                #lista di file tif (nelle cartelle ci sono anche i README.md)
                          pattern = "\\.tif$",
                          full.names = TRUE,
                          recursive = T)
mappe_nomi <- strsplit(mappe_files, "(\\\\|/)+") #per dare i nomi ai file
mappe_nomi <- sapply(mappe_nomi, function(prova) prova[5])
cartella_foto_aeree <- './cartografia/fotointerpretazione/foto_aeree/'
mappe_nomi <- sapply(mappe_nomi,function(x) paste0(cartella_foto_aeree,x))
mappe_rast <- lapply(mappe_files, raster) #i raster degli habitat vengono aperti per poter ricavarne i dati per interrogare il servizio wms
bbox <- lapply(mappe_rast,raster::bbox)
bbox_comma_sep <- function(x) {
  paste0(x[1,1],',',x[2,1],',',x[1,2],',',x[2,2]) #funzione per creare la stringa bbox
}
bbox <- lapply(bbox, bbox_comma_sep) #creazione stringa bbox
colonne <- lapply(mappe_rast,raster::ncol) #colonne e righe possono essere in numero diverso
righe <- lapply(mappe_rast,raster::nrow)
risoluzione <- lapply(mappe_rast,raster::xres) #la risoluzione e colonne e righe servono per dare la risoluzione dell'immagine richiesta al servizio wms
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
       ,WIDTH=((as.numeric(var2)+1)*var4) #con questa formula abbiamo una risoluzione massima dell'immagine
       ,HEIGHT=((as.numeric(var3)+1)*var4)
  )}
query <- mapply(fun_query,bbox,colonne,righe,risoluzione,SIMPLIFY = F) #creo la query
url <- list(url,url,url,url,url,url) #lista di tante url quanto è numeroso il numero di zone elaborate. Qui si deve agire manualmente
for (i in seq_along(url)){                          #questo loop serve per aggiornare il campo query per ogni url
  url[[i]]$query <- query[[i]]
}
request <- lapply(url,build_url) #creo una lista di url request
fun_get <- function(x,nomi) {GET(url = x, 
                                 write_disk(nomi,overwrite = T))} #funzione per fare un GET con salvataggio dell'immagine

mapply(fun_get,request,mappe_nomi) #salvataggio delle immagini. Da un errore, ma le salva bene.
