#script per generare i raster a partire dalla fotointerpretazione
#lo script è piuttosto pesante e lo si fa andare un raster alla volta
#i raster di partenza hanno questo pattern "azienda.tif" nella cartella "habitat"  e sono dei geotiff creati con qualsiasi mezzo di interpretazione
#i raster devono avere la stessa risoluzione in x e y. consigliata la risoluzione a 1 metro
#nel nostro caso abbiamo optato per questa tabella di fotointerpretazione e classi
#- 1 Alberi
#- 2 Alberi giovani
#- 3 Arbusti
#- 4 Strisce fiorite
#- 5 Prato non sfalciato
#- 6 Prato poco sfalciato
#- 7 Prato molto sfalciato
#- 8 Fossi e carrareccie
#- 9 Frutteto non trattato
#- 10 Frutteto poco trattato
#- 11 Frutteto molto trattato
#- 12 Frutteto giovane
#- 13 Aree non adatte: questa classe può non essere definita nel tif, ed avere valore NULL, nello script verrà definita automaticamente 13<-NULL
#si consiglia di partire da dei geotiff di 1 metro di risoluzione
library(grainchanger)
library(sf)
library(raster)
library(future)
library(samc)
library(dplyr)

#variabili: 10 metri di home-range e 20 metri di response grain scelte in base ai risultati di questo articolo
#Lowenstein D, Andrews H, Hilton R, et al (2019) Establishment in an Introduced Range: Dispersal Capacity and Winter Survival of Trissolcus japonicus, an Adventive Egg Parasitoid. Insects 10
predictor_grain <- 1 # la risoluzione di rasterizzazione
scale_of_effect <- 10 #la home-range (in pixel di risoluzione) di movimento dei parassitoidi, ovvero gli spostamenti di andata e ritorno per la ricerca del cibo e degli ospiti, di breve raggio e di breve periodo
response_grain <- 20 #in pixel di risoluzione la soglia dei movimenti di dispersione del parassitoide, ovvero non di breve periodo e senza ritorno.

#qui sotto importiamo il vettore poligonale degli habitat, dell'azienda in studio, e rasterizziamo
cartella <- '/home/bonushenricus/Documenti/lavoro/progetti/vindicta/cartografia/arvaia/output' #cartella delle elaborazioni finali
setwd(cartella) #setti la stessa cartella come quella in cui salverai le elaborazioni
azienda <- "habitat_giusto" #setti il nome dell'azienda
file <- paste0(azienda,'.gpkg')
habitat <- sf::read_sf(paste0('../fotointerpretazione/vector/',file))
habitat$classe <- as.factor(habitat$classe)
habitat_raster <- raster::rasterize(
  habitat,
  raster(habitat,resolution=predictor_grain),"classe")
remove(habitat)

#classe 13 è habitat non adatto (serve comunque riclassificare a 13 le aree vuote, per poter andare avanti)
habitat_raster <-
  reclassify(
    habitat_raster,
    matrix(c(NA,13),ncol=2,byrow = T)
  )
raster::writeRaster(
  habitat_raster,
  filename = paste0('../fotointerpretazione/raster/',azienda,'.tif'),
  overwrite=T)

#variabili calcolate in base alla risoluzione del raster
scale_pixel <- ceiling(scale_of_effect/raster::xres(habitat_raster)) #lo scale_pixel è la grandezza in pixel dello scale_of_effect
fattore_agg <- #fattore agg è la grandezza in pixel del response_grain
  round(
    response_grain/raster::xres(habitat_raster),
    digits = 0
  )

habitat_moving_w <- raster(habitat_raster) #creo dei raster vuoti della stessa dimensione dei raster habitat su cui inserire poi i valori calcolati
#il raster di habitat_mowing è il calcolo di un gradiente pesato di habitat ideonei su una finestra mobile uguale all'home-range
#calcoli dell'indice di diversità a coppie di habitat arboreo/arbustivo e prativo
plan(multisession) #per migliorare l'efficienza dei calcoli, che sono pesanti e tanti
habitat_moving_w$shdi_1_4 <- #creo un rasterbrick
  winmove( #winmove di grainchanger è una finestra mobile con alcune funzioni già impostate, e con la scelta di alcune classi
    fine_dat = habitat_raster, 
    d = scale_of_effect, #scale_of_effect e non scale_pixel perché è basato su unità del CRS, quindi metri
    win_fun = shdi, #shannon diversity
    type = "circle",
    is_grid = F, 
    lc_class = c(1,4) #selezione solo di due classi
  )
habitat_moving_w$shdi_1_5 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,5)
  )
habitat_moving_w$shdi_1_6 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,6)
  )
habitat_moving_w$shdi_1_7 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,7)
  )
habitat_moving_w$shdi_1_8 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,8)
  )
habitat_moving_w$shdi_1_9 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,type = "circle",
    is_grid = F, 
    lc_class = c(1,9)
  )
habitat_moving_w$shdi_1_10 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,type = "circle",
    is_grid = F, 
    lc_class = c(1,10)
  )
habitat_moving_w$shdi_1_11 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,11)
  )
habitat_moving_w$shdi_1_12 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(1,12)
  )
#la classe due è "Alberi giovani"
habitat_moving_w$shdi_2_4 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,4)
  )
habitat_moving_w$shdi_2_5 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,5)
  )
habitat_moving_w$shdi_2_6 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,6)
  )
habitat_moving_w$shdi_2_7 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,7)
  )
habitat_moving_w$shdi_2_8 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,8)
  )
habitat_moving_w$shdi_2_9 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,9)
  )
habitat_moving_w$shdi_2_10 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,10)
  )
habitat_moving_w$shdi_2_11 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,11)
  )
habitat_moving_w$shdi_2_12 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(2,12)
  )
#la classe tre è "Arbusti"
habitat_moving_w$shdi_3_4 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,4)
  )
habitat_moving_w$shdi_3_5 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,5)
  )
habitat_moving_w$shdi_3_6 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,6)
  )
habitat_moving_w$shdi_3_7 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,7)
  )
habitat_moving_w$shdi_3_8 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,8)
  )
habitat_moving_w$shdi_3_9 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,9)
  )
habitat_moving_w$shdi_3_10 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,10)
  )
habitat_moving_w$shdi_3_11 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,11)
  )
habitat_moving_w$shdi_3_12 <- 
  winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = shdi,
    type = "circle",
    is_grid = F, 
    lc_class = c(3,12)
  )


#calcoli della proporzione in numero di celle nella window per ogni classe
habitat_moving_w$n_1 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(1))
  )*(scale_pixel/2)^2*pi #numero totale di celle
habitat_moving_w$n_2 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(2))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_3 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(3))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_4 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(4))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_5 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(5))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_6 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(6))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_7 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(7))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_8 <- 
  (winmove(
    fine_dat = habitat_raster, 
    d = scale_of_effect,
    win_fun = prop,
    type = "circle" ,
    is_grid = F, 
    lc_class = c(8))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_9 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(9))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_10 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(10))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_11 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(11))
  )*(scale_pixel/2)^2*pi
habitat_moving_w$n_12 <- 
  (winmove
   (
     fine_dat = habitat_raster, 
     d = scale_of_effect,
     win_fun = prop,
     type = "circle" ,
     is_grid = F, 
     lc_class = c(12))
  )*(scale_pixel/2)^2*pi
#purtroppo il calcolo della proporzione tiene conto dell'esterno all'estensione della mappa,
#creando un bordo di NA.
#Far diventare gli NA degli 0 non sarebbe corretto per il calcolo,
#quindi operiamo ora un crop interno al bordo,
#che è in scale of effect in termini di pixel+1,
#prima di fare il calcolo finale.
#Il crop avviene in maniera uguale su tutti gli stack raster
#non funziona pad=True e na.rm=T per risolvere il problema

extent <- 
  raster::extent(
    habitat_moving_w,scale_pixel+1,
    raster::nrow(habitat_moving_w)-scale_pixel-1,
    scale_pixel+1,
    raster::ncol(habitat_moving_w)-scale_pixel-1)
habitat_moving_w <- 
  raster::crop(habitat_moving_w,extent,snap="in")

#somma ponderata degli indici di diversità di Shannon calcolati x proporzione coppie x un'indice esponenziale
#gli indici esponenziali sono empirici e servono a pesare diversamente le varie coppie di classi
moving_window <-
  (
    (
      (habitat_moving_w$n_1+habitat_moving_w$n_4)
      *habitat_moving_w$shdi_1_4*exp(5) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_5)
      *habitat_moving_w$shdi_1_5*exp(4) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_6)
      *habitat_moving_w$shdi_1_6*exp(3) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_7)
      *habitat_moving_w$shdi_1_7*exp(2) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_8)
      *habitat_moving_w$shdi_1_8*exp(1.5) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_9)
      *habitat_moving_w$shdi_1_9*exp(4.5) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_10)
      *habitat_moving_w$shdi_1_10*exp(2) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_11)
      *habitat_moving_w$shdi_1_11*exp(1.5) + 
        (habitat_moving_w$n_1+habitat_moving_w$n_12)
      *habitat_moving_w$shdi_1_12*exp(2) + 
        (habitat_moving_w$n_2+habitat_moving_w$n_4)
      *habitat_moving_w$shdi_2_4*exp(2.5) + 
        (habitat_moving_w$n_2+habitat_moving_w$n_5)
      *habitat_moving_w$shdi_2_5*exp(2)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_6)
      *habitat_moving_w$shdi_2_6*exp(1.5)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_7)
      *habitat_moving_w$shdi_2_7*exp(1)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_8)
      *habitat_moving_w$shdi_2_8*exp(0.5)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_9)
      *habitat_moving_w$shdi_2_9*exp(2)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_10)
      *habitat_moving_w$shdi_2_10*exp(1)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_11)
      *habitat_moving_w$shdi_2_11*exp(0.5)  + 
        (habitat_moving_w$n_2+habitat_moving_w$n_12)
      *habitat_moving_w$shdi_2_12*exp(1)+ 
        (habitat_moving_w$n_3+habitat_moving_w$n_4)
      *habitat_moving_w$shdi_3_4*exp(2)+ 
        (habitat_moving_w$n_3+habitat_moving_w$n_5)
      *habitat_moving_w$shdi_3_5*exp(1.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_6)
      *habitat_moving_w$shdi_3_6*exp(1)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_7)
      *habitat_moving_w$shdi_3_7*exp(0.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_8)
      *habitat_moving_w$shdi_3_8*exp(0.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_9)
      *habitat_moving_w$shdi_3_9*exp(1.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_10)
      *habitat_moving_w$shdi_3_10*exp(0.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_11)
      *habitat_moving_w$shdi_3_11*exp(0.5)  + 
        (habitat_moving_w$n_3+habitat_moving_w$n_12)
      *habitat_moving_w$shdi_3_12*exp(1))
    /(0.6931*exp(5)*(scale_pixel/2)^2*pi) #il risultato finale è rapportato alla somma massima esprimibile dal calcolo
  )
remove(habitat_moving_w)
#trasformo il moving_window in un file tiff
#raster::writeRaster(
#  moving_window,
#  filename = paste0('./moving_window/',azienda,".tif"),
#  overwrite=T
#) #il raster di habitat_mowing è il calcolo di un gradiente pesato di habitat ideonei su una finestra mobile uguale all'home-range


##lavoro sul response_grain: ricalcolo delle finestre mobili del grandiente di landscape prima calcolato
#aggrego per valore uguale a media+deviazione standard, per pesare di più celle con un gradiente migliore
mean <- 
  raster::aggregate(
    moving_window,
    fact=fattore_agg,
    fun="mean",
    expand=T
  )
sd <- 
  raster::aggregate(
    moving_window,
    fact=fattore_agg,
    fun="sd",
    expand=T
  )
#importante fare un round per avere un'idea del minimo, e quindi del massimo del logaritmo per il minimo
habitat_conductance_norm <- 
  round(
    (mean+sd),
    digits=4
  )
#raster::writeRaster(
#  habitat_conductance_norm,
#  filename = paste0('/conduttanza/',azienda,".tif"), #questa è la mappa alla risoluzione di response_grain del gradiente di landscape
#  overwrite=T
#)

resistance <- 
  raster::calc(
    habitat_conductance_norm,
    fun=function(x) -log(x,1.25) #uso un logaritmo debole per calcolare la resistenza dalla conduttanza.
  ) #di solito negli esempi di samc viene usata la funzione 1/x per calcolare la resistenza dalla conduttanza, ma nel nostro caso i valori sarebbero troppo alti, e inoltre è utile che a conduttanze alte corrispondano resistenze vicine allo 0

#il valore a infinito (per conduttanza a 0, viene rapportato al massimo ottenibile in base ai digits a cui abbiamo arrotondato la conduttanza
resistance <- 
  raster::reclassify(
    resistance,
    matrix(
      c(0,0.00000000001,
        Inf,-log(10^(-4),1.25)), #digits 4
      ncol=2,
      byrow = T)
  )
massimo <- 
  cellStats(
    resistance,
    "max"
  )
resistance_norm <- 
  raster::calc(
    resistance,
    fun=function(x,na.rm) x/massimo #normalizzo
  )
remove(resistance)
raster::writeRaster(
  resistance_norm,
  filename = paste0('./1_resistenza/',azienda,".tif"),
  overwrite=T
)

absorbance <- 
  raster::calc(
    habitat_conductance_norm,
    fun = function(x,na.rm) -log10(x) #per l'assorbanza invece uso un logaritmo forte: vogliamo che a conduttanze zero corrisponda un'assorbanza elevatissima
  )
#appiattiamo molto la normalizzazione dell'assorbanza
absorbance[is.infinite(absorbance)]<-5000
massimo <- cellStats(absorbance,"max")

absorbance_norm <- 
  raster::calc(
    absorbance,
    fun=function(x,na.rm) x/massimo
  )
remove(absorbance)

raster::writeRaster(
  absorbance_norm,
  filename = paste0('./2_assorbimento/',azienda,".tif"),
  overwrite=T
)

Pmatrix <- #calcolo dell'oggetto di Spatial Absorbing Markov Chain basato su resistenza e assorbanza
  samc(
    data=resistance_norm, 
    absorption=absorbance_norm,
    tr_args = list(fun = function(x) 1/mean(x), 
                   dir = 8, 
                   sym = FALSE
    )
  )

#il punto di lancio è al centro del raster, e sono state lanciate 90 femmine.
#calcolo sia "origin" sia "occ" (la prima è un indice e la seconda un raster)
#perché sono da usare alternativamente a seconda delle metriche
estensione <- as.vector(extent(Pmatrix@map))
#lancio reale senza considerare il centro

library(raster)
lancio_x <- 679322.75
lancio_y <- 4930474.22
#lancio <- st_point(c(lancio_x,lancio_y))
#st_write(lancio,driver = "ESRI Shapefile",)

#lancio in azienda
lancio_x2 <-678985.09
lancio_y2 <- 4930774.66

#lancio_x3 <- 722390
#lancio_y3 <- 4908574

#creazione di un dato spaziale con l'insieme dei punti di lancio
occupancy_points <- 
  SpatialPointsDataFrame(coords = 
                           matrix(
                             c(
                               lancio_x,lancio_y
                               ,lancio_x2,lancio_y2
                             ),
                             nrow = 2,byrow = T),
                         data=data.frame(c(90,90)),
                         proj4string = CRS("EPSG:25832")
  )


occupancy_points_rast <- 
  raster::rasterize(
    occupancy_points,
    resistance_norm)
raster::values(occupancy_points_rast) <- 
  ifelse(
    is.na(raster::values(occupancy_points_rast)),
    0,1)
raster::writeRaster(
  occupancy_points_rast,
  filename = "/home/bonushenricus/Documenti/lavoro/progetti/vindicta/cartografia/arvaia/output/occupancy_points_raster.tif",
  overwrite=T
)
occupancy_points_rast <- raster("/home/bonushenricus/Documenti/lavoro/progetti/vindicta/cartografia/arvaia/output/occupancy_points_raster.tif")
library(samc)

#metrica "dispersione"=probabilità per cella che sia visitata almeno una volta dal parassitoide
dispersione <-  #calcolo
  dispersal(
    Pmatrix, 
    occ = occupancy_points_rast
  )
dispersione_map <- 
  samc::map(
    Pmatrix,
    dispersione
  )
raster::writeRaster(
  dispersione_map,
  filename = paste0('/home/bonushenricus/Documenti/lavoro/progetti/vindicta/cartografia/arvaia/output/3_dispersione/',azienda,".tif"),
  overwrite=T
)

#metrica "visitation"=numero di volte che un parassitoide è passato per la cella
visita <-  #calcolo
  visitation(
    Pmatrix, 
    origin = origine
  )
visita_map <- 
  samc::map(
    Pmatrix,
    visita
  )
raster::writeRaster(
  visita_map,
  filename = paste0('./4_visite/',azienda,".tif"),
  overwrite=T
)

#metrica "survival"= il tempo previsto per l'absorption totale
sopravvivenza <-  #calcolo. il risultato è un numero.
  survival(
    Pmatrix, 
    occ = occupancy
  )


#metrica "mortality"= probabilità di absorption
mortalita <-  #calcolo
  mortality(
    Pmatrix, 
    occ = occupancy
  )
mortalita_map <- 
  samc::map(
    Pmatrix,
    mortalita
  )
raster::writeRaster(
  mortalita_map,
  filename = paste0('./5_mortalita/',azienda,".tif"),
  overwrite=T
)
