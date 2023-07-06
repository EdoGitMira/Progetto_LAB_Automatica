Non serve includere path essende già caricati in automatico in base allo script che viene eseguito

cartelle:
- Debug: contengono il codice di implementazione del progetto e i vari test relativi al debug ceh poi una volta finiti sono stati copiati nella cartella progetto
-Progetto: contiene tutto il codice relativo al progetto e si divide:
-- controllori -> contiene tutte le classi necessarie allo sviluppo dei controllori come P,PI,CASCADE
-- file_mat_init -> cartella di interscambio dei dati contiene i file dei modelli e del tuning dei controllori
	- ctrl1 -> parametri dei controllori del giunto 1
	- ctrl2 -> parametri dei controllori del giunto 2
	- ide_giunto1 -> modello utilizzato per il giunto 1
	- ide_giunto2 -> modello utilizzato per il giunto 2
-- modelli -> contiene i modelli base del progetto
-- identificazione -> contiene tutto il codice necessario per l'identificazione dei due giunti in closeloop e per la taratura del'architettura di controllo
--calcolo score -> per valutare l'identificazione e di conseguenza la taratura 