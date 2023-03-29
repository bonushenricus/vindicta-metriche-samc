# VINDICTA progetto 16.1 PSR Emilia-Romagna 2014-2020

## azione 3, analisi agroecosistema

### Calcolo delle metriche di analisi dell'agroecosistema

I grafici delle metriche sono dei plot a "ridge," ossia curve:

-   la y, ovvero l'altezza delle curve, indica il numero di celle del raster

-   x è il valore della metrica, per la resistenza in scala normale, per le altre metriche in scala logaritmica in base 10.

La scala dei colori utilizzata corrisponde a quella delle mappe.

#### Foto aeree 2020 AGREA NIR

Queste sono le foto aeree usate per la fotointerpretazione, tratte da [geoportale Emilia-Romagna \> wms \> ortofoto \> AGREA 2020 NIR](https://geoportale.regione.emilia-romagna.it/servizi/servizi-ogc/elenco-capabilities-dei-servizi-wms/cartografia-di-base/service-35). La fotointepretazione è stata supportata da:

-   elaborazioni LIDAR risoluzione 1 metro del 2008-2013 quando presenti per l'area di studio, per ricavare la posizione delle arboree e le loro altezze.

-   dati AGREA 2021 e 2022, disponibili qui [agreagestione file > AppezzAziendaGrafici](https://agreagestione.regione.emilia-romagna.it/agrea-file/AppezzAziendaGrafici/) ![](metriche_files/figure-markdown_github/plot%20foto%20aeree-1.png)

#### Metriche di gradiente di paesaggio

Si tratta di metriche dell'intero paesaggio, senza riferimento alla zona di lancio o presenza del parassitoide.

##### Resistenza

Metrica di quanto è resistente al movimento il paesaggio.

-   1= resistenza totale

-   0= resistenza nulla

![](metriche_files/figure-markdown_github/plot%20heatmap%20resistenza-1.png)

##### Assorbanza

Assorbimento significa impossibilità di movimento, o incapacità di tornare indietro. I valori sono vicini a 1 o vicini a 0.

-   1= assorbanza totale. Nella carta le aree con assorbanza totale sono visualizzate come trasparenti.

-   0= assorbanza nulla, ovvero nessun ulteriore fattore di impossibilità rispetto alla resistenza

![](metriche_files/figure-markdown_github/plot%20heatmap%20assorbimento-1.png)

#### Metriche SAMC (Spatial Absorbing Markov Chain) Marx et al. (2020)

Sono le metriche calcolate dal punto di lancio della vespa samurai, che è il centro del raster.

##### Dispersione

Con dispersione si intende la probabilità che la cella sarà visitata almeno una volta dalle 90 femmine lanciate. Non si prendono in considerazione le generazioni successive e il fattore vento. Il grafico indica quindi la capacità di dispersione delle 90 femmine in quel paesaggio per quel punto di lancio. Nelle mappe sono visualizzati con un gradiente i dati da 1 a 100 per cento. Le zone grigie hanno una probabilità di dispersione inferiore a 1 per cento.

![](metriche_files/figure-markdown_github/plot%20heatmap%20dispersione-1.png)

##### Mortalità

Con Mortalità si intende la probabilità di mortalità, che è data dall'insieme dei fattori di resistenza e assorbimento nella cella visitata per quel punto di lancio, secondo la dispersione calcolata. La mortalità è maggiore in vicinanza delle aree di assorbimento, che però per il modello non vengono raggiunte e superate, quindi al loro interno non c'è mortalità. Maggiore è la probabilità di dispersione in una cella maggiore è la probabilità di mortalità. Nella mappa con scala logaritmica si visualizza la mappa anche nelle zone di dispersione trascurabile (\<1%) per agevolare la comprensione del concetto di mortalità

![](metriche_files/figure-markdown_github/plot%20heatmap%20mortalita-1.png)

::: {#refs .references .csl-bib-body .hanging-indent}
::: {#ref-samc .csl-entry}
Marx, Andrew J., Chao Wang, Jorge A. Sefair, Miguel A. Acevedo, and Robert J. Fletcher Jr. 2020. "Samc: An r Package for Connectivity Modeling with Spatial Absorbing Markov Chains." *Ecography*. <https://onlinelibrary.wiley.com/doi/abs/10.1111/ecog.04891>.
:::
:::
