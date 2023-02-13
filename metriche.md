# VINDICTA progetto 16.1 PSR Emilia-Romagna 2014-2020

## azione 3, analisi agroecosistema

### Calcolo delle metriche di analisi dell'agroecosistema

I grafici delle metriche sono dei plot a violino, un ibrido tra i boxplot e i density plot:

-   sulla y si trova il continuum di valori di ogni cella per ogni metrica calcolata

-   la larghezza del grafico all'area (ossia al numero di celle) corrispondendi al valore.

#### Foto aeree 2020 AGREA NIR

Queste sono le foto aeree usate per la fotointerpretazione, tratte da [geoportale Emilia-Romagna \> wms \> ortofoto \> AGREA 2020 NIR](https://geoportale.regione.emilia-romagna.it/servizi/servizi-ogc/elenco-capabilities-dei-servizi-wms/cartografia-di-base/service-35). La fotointepretazione è stata supportata da:

-   elaborazioni LIDAR risoluzione 1 metro del 2008-2013 quando presenti per l'area di studio, per ricavare la posizione delle arboree e le loro altezze.

-   dati AGREA 2021 e 2022, disponibili qui [agreagestione file > AppezzAziendaGrafici](https://agreagestione.regione.emilia-romagna.it/agrea-file/AppezzAziendaGrafici/) ![](metriche_files/figure-markdown_github/plot%20foto%20aeree-1.svg)

#### Metriche di gradiente di paesaggio

Si tratta di metriche dell'intero paesaggio, senza riferimento alla zona di lancio o presenza del parassitoide.

##### Resistenza

Metrica di quanto è resistente al movimento il paesaggio.

-   1= resistenza totale

-   0= resistenza nulla

![](metriche_files/figure-markdown_github/plot%20heatmap%20resistenza-1.svg)

![](metriche_files/figure-markdown_github/plot%20resistenza-1.svg)

##### Assorbanza

Assorbimento significa impossibilità di movimento, o incapacità di tornare indietro. I valori sono vicini a 1 o vicini a 0.

-   1= assorbanza totale, ovvero mortalità. Nella carta le aree sono quelle trasparenti.

-   0= assorbanza nulla, ovvero nessun fattore di mortalità

![](metriche_files/figure-markdown_github/plot%20heatmap%20assorbimento-1.svg)

![](metriche_files/figure-markdown_github/plot%20assorbanza-1.svg)

#### Metriche SAMC (Spatial Absorbing Markov Chain) Marx et al. (2020)

Sono le metriche calcolate dal punto di lancio della vespa samurai, che è il centro del raster.

##### Dispersione

Con dispersione si intende la probabilità che la cella sarà visitata almeno una volta dal parassitoide. Il grafico indica quindi la capacità di dispersione in quel paesaggio per quel punto di lancio.

![](metriche_files/figure-markdown_github/plot%20heatmap%20dispersione-1.svg)

![](metriche_files/figure-markdown_github/plot%20dispersion-1.svg)

##### Mortalità

Con Mortalità si intende la probabilità di assorbimento nella cella visitata. Il grafico indica quindi la probabilità di "assorbimento" in quel paesaggio per quel punto di lancio

![](metriche_files/figure-markdown_github/plot%20heatmap%20mortalita-1.svg)

![](metriche_files/figure-markdown_github/plot%20mortality-1.svg)

::: {#refs .references .csl-bib-body .hanging-indent}
::: {#ref-samc .csl-entry}
Marx, Andrew J., Chao Wang, Jorge A. Sefair, Miguel A. Acevedo, and Robert J. Fletcher Jr. 2020. "Samc: An r Package for Connectivity Modeling with Spatial Absorbing Markov Chains." *Ecography*. <https://onlinelibrary.wiley.com/doi/abs/10.1111/ecog.04891>.
:::
:::
