# Manuale Utente – EMMA Client Web

*Guida all'utilizzo della piattaforma documentale EMMA per l'utente aziendale.*

---

## Indice

1. [Introduzione](#1-introduzione)
2. [Accesso al sistema](#2-accesso-al-sistema)
3. [Elementi comuni a tutte le schermate](#3-elementi-comuni-a-tutte-le-schermate)
4. [Dashboard](#4-dashboard)
5. [Carica Documenti](#5-carica-documenti)
6. [Visualizza Documenti](#6-visualizza-documenti)
7. [Fornitori](#7-fornitori)
8. [Articoli Fornitore](#8-articoli-fornitore)
9. [Log](#9-log)
10. [Cambio Password](#10-cambio-password)
11. [Uscita dal sistema](#11-uscita-dal-sistema)

---

## 1. Introduzione

EMMA è la piattaforma documentale che acquisisce automaticamente ordini, bolle di consegna e fatture, ne estrae i dati tramite intelligenza artificiale e supporta l'azienda nella verifica e riconciliazione dei documenti (3-Way Matching).

Questo manuale descrive, schermata per schermata, tutte le funzionalità disponibili all'utente finale del Client Web.

---

## 2. Accesso al sistema

> **[IMMAGINE: Schermata di Login]**

All'apertura del Client Web viene mostrata la finestra di accesso.

**Campi presenti:**

| Campo | Descrizione |
|---|---|
| Utente | Nome utente fornito in fase di attivazione del servizio |
| Password | Password associata all'utente |

**Pulsanti:**

- **OK** – conferma le credenziali inserite e avvia l'accesso. È possibile anche premere il tasto **Invio** dalla tastiera per ottenere lo stesso effetto. Durante la verifica delle credenziali il pulsante mostra una piccola animazione di caricamento e i campi risultano temporaneamente non modificabili.
- **Annulla** – svuota i campi Utente e Password inseriti.

**Messaggi che possono comparire:**

- *"Inserire Utente!"* – se si preme OK senza aver digitato il nome utente.
- *"Inserire Password!"* – se si preme OK senza aver digitato la password.
- *"Credenziali errate !"* – se utente o password non sono corretti; il campo password viene svuotato automaticamente per permettere un nuovo tentativo.

Se si è già autenticati (ad esempio perché si torna sulla pagina di login con una sessione ancora attiva), il sistema reindirizza automaticamente alla Dashboard senza richiedere nuovamente le credenziali.

Una volta effettuato correttamente l'accesso, si viene indirizzati alla **Dashboard**.

---

## 3. Elementi comuni a tutte le schermate

Alcuni elementi dell'interfaccia sono condivisi da più schermate e vengono descritti qui una sola volta.

### 3.1 Barra superiore

> **[IMMAGINE: Barra superiore con titolo pagina, utente e pulsante Esci]**

In ogni schermata successiva al login è presente una barra superiore che contiene:

- **Pulsante "← Indietro"** – presente in tutte le pagine tranne la Dashboard; riporta alla Dashboard.
- **Titolo della pagina corrente** (es. "Caricamento Documenti", "Visualizzatore Documenti", "Fornitori", "Articoli Fornitore", "Log", "Cambio Password").
- **Nome dell'utente collegato**, visualizzato sulla destra.
- **Pulsante "Esci"** – termina la sessione corrente e riporta alla schermata di Login (vedi [§11](#11-uscita-dal-sistema)).

### 3.2 Finestre di conferma e di messaggio

> **[IMMAGINE: Finestra di conferma azione]**

Molte operazioni (eliminazioni, salvataggi, cambi di stato) richiedono una conferma prima di essere eseguite. Compare una finestra con il messaggio dell'operazione e due pulsanti:

- **Sì** – conferma ed esegue l'operazione.
- **No** – annulla l'operazione.

> ⚠️ Nota: nella finestra di conferma il pulsante **Sì** è colorato di rosso e il pulsante **No** di verde. Si consiglia di leggere sempre il testo del pulsante prima di cliccare, senza affidarsi al colore.

> **[IMMAGINE: Finestra di informazione/errore]**

Per messaggi informativi ("Informazione") o di errore ("Errore") compare invece una finestra con il solo pulsante **OK** per chiuderla.

### 3.3 Visualizzatore PDF

> **[IMMAGINE: Finestra di anteprima PDF]**

Quando si apre l'allegato PDF di un documento, viene mostrata una finestra con:

- L'anteprima del documento PDF.
- **💾 Scarica** – salva il file PDF sul proprio dispositivo.
- **↗ Nuova scheda** – apre il PDF in una nuova scheda del browser.
- **❌ Chiudi** – chiude l'anteprima.

---

## 4. Dashboard

> **[IMMAGINE: Dashboard con i sei moduli]**

La Dashboard è la schermata principale che compare subito dopo l'accesso. Mostra una griglia di riquadri, ciascuno dei quali apre una delle funzionalità della piattaforma:

| Riquadro | Funzione |
|---|---|
| **Carica Documenti** | Apre la schermata di caricamento e riconoscimento automatico di un nuovo documento |
| **Visualizza Documenti** | Apre l'elenco dei documenti già acquisiti, con possibilità di verifica e riconciliazione |
| **Fornitori** | Apre l'anagrafica dei fornitori |
| **Articoli** | Apre l'anagrafica degli articoli associati a ciascun fornitore |
| **Log** | Apre lo storico delle elaborazioni effettuate dal sistema |
| **Cambio Password** | Apre la schermata per modificare la propria password |

È sufficiente fare clic su un riquadro per accedere alla relativa schermata.

---

## 5. Carica Documenti

> **[IMMAGINE: Schermata Carica Documenti con toolbar e griglia articoli]**

Questa schermata permette di caricare un nuovo documento (PDF o XML) e di farne estrarre automaticamente i dati dal sistema.

### 5.1 Barra degli strumenti

- **📁 Sfoglia ...** – apre la finestra di selezione file del dispositivo. Sono accettati file **.pdf** e **.xml**, con dimensione massima di **50 MB**. Accanto al pulsante viene mostrato il nome del file selezionato e il suo stato:
  - *"Nessun file selezionato"* – nessun documento caricato.
  - *"Elaborazione in corso: [nome file]..."* – il documento è in fase di analisi da parte del sistema.
  - *[nome file]* – elaborazione completata.
- **➕ Aggiungi Riga** – disponibile dopo il caricamento di un documento; aggiunge una nuova riga vuota alla griglia articoli, da compilare manualmente.
- **🗑️ Elimina Riga** – disponibile dopo il caricamento di un documento e con una riga selezionata nella griglia; rimuove la riga selezionata.
- **✖ Pulisci** – disponibile dopo il caricamento di un documento; svuota tutti i campi e la griglia, riportando la schermata allo stato iniziale.
- **📄 Vedi PDF** – disponibile se al documento è associato un allegato PDF; apre l'anteprima del PDF (vedi [§3.3](#33-visualizzatore-pdf)). Il PDF viene inoltre mostrato automaticamente al termine del caricamento, se presente.

### 5.2 Campi della testata documento

| Campo | Descrizione |
|---|---|
| Fornitore | Nome del fornitore, riconosciuto automaticamente dal documento caricato |
| Tipo Doc. | Tipologia del documento, selezionabile da un elenco a tendina |
| N° Documento | Numero del documento |
| Data Doc. | Data del documento |
| Imponibile (€) | Importo imponibile del documento |
| Totale (€) | Importo totale del documento |

Tutti i campi vengono compilati automaticamente dal riconoscimento AI dopo il caricamento del file, ma restano modificabili manualmente in caso di correzioni.

### 5.3 Griglia articoli

Sotto la testata è presente una tabella con le righe di dettaglio riconosciute nel documento:

| Colonna | Descrizione |
|---|---|
| Codice | Codice articolo |
| Descrizione | Descrizione dell'articolo |
| Quantità | Quantità indicata nel documento |
| U.M. | Unità di misura |
| Totale (€) | Importo totale della riga |

Ogni cella della griglia è modificabile direttamente facendo clic su di essa. Prima di caricare un file, la griglia mostra l'indicazione *"Seleziona un file PDF o XML con 'Sfoglia ...' per estrarre i dati del documento."*

---

## 6. Visualizza Documenti

> **[IMMAGINE: Schermata Visualizza Documenti con filtri e griglia]**

Questa è la schermata principale per la consultazione, la verifica e la riconciliazione (3-Way Matching) dei documenti già acquisiti dal sistema.

### 6.1 Filtri di ricerca

| Filtro | Descrizione |
|---|---|
| Tipo Documento | Elenco a tendina per filtrare per tipologia di documento |
| Fornitore | Elenco a tendina, popolato con i fornitori presenti in anagrafica |
| Stato Documento | Elenco a tendina per filtrare per stato (es. aperto/chiuso) |

### 6.2 Barra degli strumenti

- **📁 Mostra Documenti ...** – applica i filtri impostati e carica l'elenco dei documenti corrispondenti.
- **💾 Esporta su file ...** – disponibile quando sono presenti documenti in elenco; genera ed esporta un file CSV con i dati dei documenti e delle relative righe di dettaglio mostrati a video.
- **❌ Chiudi Stato** – disponibile quando sono presenti documenti in elenco; dopo conferma, cambia lo stato di **tutti** i documenti attualmente mostrati a video.

### 6.3 Elenco documenti (griglia principale)

| Colonna | Descrizione |
|---|---|
| (espansione) | Freccia per espandere/comprimere le righe di dettaglio del documento |
| Fornitore | Nome del fornitore |
| Tipo Doc. | Tipologia del documento |
| N° Documento | Numero del documento |
| Data Documento | Data del documento |

Facendo clic su una riga (o sulla freccia) si espande/comprime il dettaglio del documento. Sulla destra di ogni riga sono presenti tre pulsanti:

- **Pulsante di cambio stato** (etichetta variabile) – dopo conferma, cambia lo stato del singolo documento.
- **Elimina** – dopo conferma, elimina definitivamente il documento.
- **PDF** – disponibile solo se al documento è associato un allegato; apre l'anteprima del PDF (vedi [§3.3](#33-visualizzatore-pdf)).

### 6.4 Dettaglio del documento (righe)

Espandendo un documento viene mostrata la tabella delle righe che lo compongono:

| Colonna | Descrizione |
|---|---|
| Codice | Codice articolo, modificabile |
| Descrizione | Descrizione articolo, modificabile |
| U.M. | Unità di misura, modificabile |
| Q.tà | Quantità, modificabile |
| Imponibile | Importo imponibile della riga, modificabile |
| IVA | Aliquota IVA (sola visualizzazione) |
| Totale | Importo totale della riga, modificabile |
| (azione) | Pulsante **Aggiungi** (verde) per le righe appena create non ancora salvate, oppure **Elimina** (rosso) per le righe già registrate |

Ogni modifica a una cella di una riga già registrata viene inviata automaticamente al sistema non appena si esce dal campo. Per le righe nuove, aggiunte con il pulsante **+ Nuova Riga** in fondo alla tabella di dettaglio, è necessario premere il pulsante **Aggiungi** sulla riga stessa per registrarla; il pulsante **Elimina**, dopo conferma, rimuove invece una riga già registrata.

Se il documento non ha righe di dettaglio, viene mostrato il messaggio *"Nessuna riga di dettaglio."*.

---

## 7. Fornitori

> **[IMMAGINE: Schermata Fornitori]**

Questa schermata gestisce l'anagrafica dei fornitori.

### 7.1 Barra degli strumenti

- **Aggiungi Fornitore** – aggiunge una nuova riga vuota in fondo alla tabella, da compilare.
- **Elimina Selezionato** – disponibile con un fornitore selezionato in tabella; dopo conferma, elimina il fornitore (se già registrato) o rimuove semplicemente la riga (se non ancora salvata).
- **Salva Modifiche** – dopo conferma, salva tutte le righe nuove o modificate; al termine viene mostrato un messaggio con il numero di fornitori inseriti e aggiornati.
- **🔄 Ricarica** – ricarica l'elenco dei fornitori dal sistema. Se sono presenti modifiche non ancora salvate, viene richiesta conferma prima di procedere, per evitare di perderle.

Quando sono presenti modifiche non salvate, accanto ai pulsanti compare l'indicazione *"[N] modifica/e non salvate"*.

### 7.2 Tabella fornitori

| Colonna | Descrizione |
|---|---|
| ID | Identificativo del fornitore (vuoto per le righe non ancora salvate) |
| Descrizione | Nome/ragione sociale del fornitore, modificabile |
| Riferimento | Codice di riferimento del fornitore nel sistema gestionale aziendale, modificabile |
| Score | Punteggio di corrispondenza assegnato dal sistema (sola visualizzazione) |
| Data Creazione | Data e ora di creazione del fornitore in anagrafica |

Facendo clic su una riga la si seleziona (necessario per il pulsante **Elimina Selezionato**). Le righe non ancora salvate e quelle modificate ma non salvate vengono evidenziate graficamente rispetto alle righe invariate.

---

## 8. Articoli Fornitore

> **[IMMAGINE: Schermata Articoli Fornitore]**

Questa schermata gestisce l'anagrafica degli articoli, organizzata per fornitore.

### 8.1 Barra degli strumenti

- **Fornitore** – elenco a tendina per selezionare il fornitore di cui visualizzare gli articoli. È necessario selezionare un fornitore prima di poter usare le altre funzioni della pagina.
- **Aggiungi Articolo** – disponibile con un fornitore selezionato; aggiunge una nuova riga vuota in fondo alla tabella.
- **Elimina Selezionato** – disponibile con un articolo selezionato in tabella; dopo conferma, elimina l'articolo (se già registrato) o rimuove semplicemente la riga (se non ancora salvata).
- **Salva Modifiche** – disponibile con un fornitore selezionato; dopo conferma, salva tutte le righe nuove o modificate; al termine viene mostrato un messaggio con il numero di articoli inseriti e aggiornati.

Quando sono presenti modifiche non salvate, accanto ai pulsanti compare l'indicazione *"[N] modifica/e non salvate"*.

### 8.2 Tabella articoli

| Colonna | Descrizione |
|---|---|
| ID | Identificativo dell'articolo (vuoto per le righe non ancora salvate) |
| Codice | Codice dell'articolo, modificabile |
| Descrizione | Descrizione dell'articolo, modificabile |
| Riferimento Cod. | Codice di riferimento nel sistema gestionale aziendale, modificabile |
| Riferimento Des. | Descrizione di riferimento nel sistema gestionale aziendale, modificabile |
| Scor Cod. | Punteggio di corrispondenza sul codice (sola visualizzazione) |
| Score Des. | Punteggio di corrispondenza sulla descrizione (sola visualizzazione) |
| Data Creazione | Data e ora di creazione dell'articolo in anagrafica |

Come nella schermata Fornitori, le righe nuove o modificate vengono evidenziate graficamente. Se non è stato selezionato alcun fornitore, la tabella mostra il messaggio *"Seleziona un fornitore per vedere gli articoli."*; se il fornitore non ha articoli associati, viene mostrato *"Nessun articolo per questo fornitore."*.

---

## 9. Log

> **[IMMAGINE: Schermata Log]**

Questa schermata mostra lo storico delle elaborazioni AI effettuate dal sistema, utile per monitorare l'attività e i consumi.

### 9.1 Barra degli strumenti

- **🔄 Ricarica** – aggiorna l'elenco dei log.
- Accanto al pulsante viene mostrato il numero totale di righe di log presenti.

### 9.2 Tabella log

| Colonna | Descrizione |
|---|---|
| ID | Identificativo della riga di log |
| Data Creazione | Data e ora dell'elaborazione |
| Token Input | Quantità di "token" AI utilizzati in ingresso per l'elaborazione |
| Token Output | Quantità di "token" AI generati in uscita |
| Token Totali | Somma dei token in ingresso e in uscita |
| Costo €. | Costo stimato dell'elaborazione |
| Stato | Esito dell'elaborazione |
| Note | Eventuali note o dettagli sull'elaborazione |
| Durata (sec.) | Tempo impiegato dall'elaborazione, in secondi |

Questa tabella è di sola consultazione: non è possibile modificarne i dati. Se non sono presenti log, viene mostrato il messaggio *"Nessun log disponibile."*.

---

## 10. Cambio Password

> **[IMMAGINE: Schermata Cambio Password]**

Questa schermata permette di modificare la propria password di accesso.

**Campi:**

| Campo | Descrizione |
|---|---|
| Nuova Password | La nuova password da impostare |
| Conferma Password | Ripetizione della nuova password, per verifica |

**Pulsanti:**

- **Esegui** – convalida e applica il cambio password.
- **Annulla** – riporta alla Dashboard senza applicare alcuna modifica.

**Regole della password:** la nuova password deve essere lunga **almeno 8 caratteri** e contenere **almeno una lettera maiuscola, una lettera minuscola, un numero e un carattere speciale** (uno tra `@ $ ! % * ? &`).

**Messaggi che possono comparire:**

- *"Inserire Password !"* – se il campo Nuova Password è vuoto.
- *"Password non coincidenti !"* – se i due campi non corrispondono.
- *"La password deve essere lunga almeno 8 caratteri, contenere almeno una lettera maiuscola, un numero e un carattere speciale."* – se la password non rispetta i requisiti minimi.
- *"Password cambiata con successo !"* – al termine dell'operazione, prima di essere riportati alla Dashboard.
- *"Cambio password non riuscito."* – in caso di errore imprevisto durante il salvataggio.

Dal successivo accesso sarà necessario utilizzare la nuova password.

---

## 11. Uscita dal sistema

Per terminare la sessione di lavoro è sufficiente premere il pulsante **Esci** presente nella barra superiore (vedi [§3.1](#31-barra-superiore)). L'utente viene disconnesso e riportato alla schermata di Login.

---

*Manuale generato per EMMA Client Web. Le immagini indicate come segnaposto devono essere sostituite con gli screenshot reali dell'applicazione prima della distribuzione al cliente finale.*
