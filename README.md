![Badge License]

![Badge Edoardo]
![Badge Peter]
![Badge Manuele]


## Tabella dei contenuti

- [Tabella dei contenuti](#tabella-dei-contenuti)
- [Organizzazione contenuti](#organizzazione-contenuti)
- [Utilizzo](#utilizzo)
- [Progetto](#progetto)
  - [Identificazione](#identificazione)
  - [Validazione](#validazione)
  - [Taratura](#taratura)

## Organizzazione contenuti
Il progetto è diviso principalmente in due cartelle:
- **DEBUG:** cartella all'interno della quale sono stati sviluppati tutti i codici per l'impementazione delle classi di controllo del sistema SCARA in particolare del controllore in cascate composto dai controllori **P ,PI** e dai filtri **filtro notch** (attenuazione della risonanza) e **filtro passa basso** (attenuazione dei disturbi)
- **Progetto:** dove è contenuto tutto il codice per l'dentificazione, taratura e calcolo dello score del controllore. AL suo interno è organizzato in:
  - **controllori**: cartella dove risiedono i controllori per l'attuazione del robot SCARA
  - **file_mat_init**: cartella di interscambio dei file.mat generati dagli script contenuti nella cartella identificazione e utilizzati per il calcolo dello score 
  - **identificazione**: cartella che contiene gli script necessari per l'identificazione e per la taratura dei controllori
    - **identificazione_cl**: script per eseguire l'identificazione del sistema in closed-loop
    - **confronto modelli**: script utilizzato per valutare l'ordine del modello da utilizzare nella fase di taratura
    - **taratura_giunto1_PI_interno**: script per eseguire la taratura del giunto numero 1 (sia dei controllori che dei filtri). Il sistema di controllo è costituita da un PI nel loop interno e da un P nel loop esterno
    - **taratura_giunto2_PI_interno**: script per eseguire la taratura del giunto numero 2 (sia dei controllori che dei filtri). Il sistema di controllo è costituita da un PI nel loop interno e da un P nel loop esterno  
  - **modelli**: contiene i file necessari alla creazione del sistema SCARA e per la valutazione del controllo
  - **caclolo_score.mlx**: livescript per la valutazione delle prestazioni del controllo realizzato  
## Utilizzo
**PER L'IDENTIFICAZIONE**
1. posizionare il modello da identificare nella cartella modelli
2. aprire il file identificazione_cl.mlx nella cartella identificazione 
3. impostare i seguenti elementi:
   - il modello nella riga numero 7
   - il segnale di eccitazione
   - controllore di default (preimpostato un controllo con Kp = 0.01 e Ki =0.1).
4. Eseguire la sezione di codice
5. Scorrere il codice nella sezione Identificazione e settare i pesi delle frequenze di interesse ( di default è [100-1000]rad/s) e l'ordine del modello desiderato
6. la fase di validazione viene eseguita di seguito con la definizione di un seganle eccitante differente rispetto all'identificazione e poi si procede alla verifica

 `N.B.` Il modello viene salvato automaticamente nella cartella **file_mat_init** con il nome **ide_modelli_scara**

**PER LA TARATURA**
1. aprire il file taratura_giunto[n] nella cartella identificazione in base al giunto [n] che si vuole controllare
2a. settare nell'apposita sezione del loop interno:
    - filtro notch
    - filtro passa basso 
2b. scegliere i valori di Ki e Kp del controllore interno in base alla frequenza di taglio Wc_des  
   - l'azione integrale viene posta circa una decade prima wi = wc_des/30 -> Ki = Kp*wi
   - l'azione proporzionale viene impostata in modo da ottenere la frequenza di taglio desiderata Kp=(1/abs(freqresp(sistema,wc_des)))
   - l'anti wind-up viene implementato con algoritmo di back-calculation e parametro caratteristico Kaw = Ki/Kp
3.  passare alloop esterno per impostare:
   - filtro passa basso
   - valore di Kp in base alla w desiderata

`N.B.` I valori dei controllori vengono salvati nella nella cartella **file_mat_init** con il nome **ctrlX.mat**

## Progetto
il progetto consiste nell'identificazione e sucessiva taratura di un controllore attraverso il modello identificato di un robot SCARA a 2 assi, che esegue una movimentazione di pick and place di un determinato oggetto. per la valutazionre della bonta del progetto si usa uno script che fa variare la traettoria e il payload del robot.
![27945-productpicture-hires-en-ls10-b702s_07](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/cbf687ad-7725-4ec1-b7af-789939c58dc9)


## Identificazione
l'dentificazione è stata eseguita eccitando il giunto interessato con un sweep in frequenza "chirp" a cui si somma un segnle portante.
poi tramitre algoritmi si è ricavata la risposta in frequenza del sistema e il si è ricavato il modello dell'ordine d'interesse 3° per il primo giunto e 5° per il secondo giunto.
per verificare la correttezza dei modelli otteuti è stata eseguita una fase di validazione dove si eccita il sistema con un segnale differente si ricava il modello e lo si confronta con il modell ottenuto.
l'identificazione è stata eseguita in closeloop recendo il controllore del giunto da indentificare poco aggressivo e per quello non sotto indagite è stato fatto un tuning in maniera tale da compensare la posizione ed avere un movimento molto piccolo per non influenzare l'identificazione dell'altro giunto si è deciso di fare una correzzione di x[Nm] in base a dove il giunto si trova.
`N.B.` il codice necessario è stato realizzato all'interno della cartella identificazione negli script di identificazione dei giunti

![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/99c6af10-4a14-4407-a690-c2e91acf384c)
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/45c44465-760a-4628-bbe6-c6c5e1c59b33)


## Validazione
sono stati utilizzati dei test che permetto la verifica sia delle condizioni di starting che della condione di saturazione. Successivamente si è verifica che le classi utilizzate sia in openloop che in closeloop coincidessero con gli analoghi andamenti dei controllori fatti direttamente al'interno di script matlab.
`N.B.` vedere cartella debug per risulatati


## Taratura
si è deciso di utilizzare un controllore in cascata nel quale nel loop interno è presente un controllore PI mentre nel loop esterno è presente un controllore P.
Per la taratura ci siamo affidati al modello del sistema ricavato nella fase di identificazione.
### GIUNTO 1
`N.B.` vedere cartella identificazione taratua giunto 1 PI interno per il codice utilizzato
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/a8412669-4857-4ff6-9513-057d87c992ec)
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/786f4fc2-03d3-4fc7-b57b-d3a427ea8ce6)
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/c01a3ed0-3ebd-459e-9490-f871e64f92e2)

### GIUNTO 2
`N.B.` vedere cartella identificazione taratua giunto 2 PI interno per il codice utilizzato
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/ac3d6805-69f2-4479-982a-3950a2fcf844)
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/2d925c13-6448-474a-a1ac-f1bdc1f5ee18)
![image](https://github.com/EdoGitMira/Progetto_LAB_Automatica/assets/49036361/e3bbf8e2-2e2c-44a4-9d21-b221533f112a)


[Badge License]: https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge
[Badge Edoardo]: https://img.shields.io/badge/Edoardo_Mirandola-FF6600?style=for-the-badge
[Badge Manuele]: https://img.shields.io/badge/Manuele_Pennacchio-FF6600?style=for-the-badge
[Badge Peter]: https://img.shields.io/badge/Peter_William_Fares-FF6600?style=for-the-badge
