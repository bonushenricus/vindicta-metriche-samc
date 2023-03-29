# vindicta-metriche-samc

<img src="loghi/psr.png" width="25%" style="display: block; margin: auto;" /><img src="loghi/vindicta.png" width="25%" style="display: block; margin: auto;" />

Pagina dei codici di programmazione informatica di:

-   VINDICTA progetto 16.1 PSR 2014-2020
    [psrvindicta.it](https://www.psrvindicta.it/)

    -   Azione 3 “Analisi e potenziamento della biodiversità funzionale”

        -   Cartografia coltivazioni e habitat

            -   Elaborazione software di “landscape ecology” con calcolo
                di metriche

L’elaborazione finale è in [metriche.md](metriche.md) , la quale è un
layout di confronto tra le cartografie e grafici delle varie metriche
del paesaggio delle aziende oggetto del progetto.

Il codice rmarkdown per l’elaborazione finale è in
[metriche.Rmd](metriche.Rmd)

L’elaborazione del paesaggio per ogni azienda viene sviluppata nella
cartella “raster,” nello script [raster.R](cartografia/raster.R), che
prende una fotointerpretazione e sviluppa l’elaborazione creando vari
raster geotiff divisi in cartelle secondo la metrica.
