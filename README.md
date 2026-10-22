# Pocock · Day to day

Webapp installabile (PWA) della guida "Cosa avvii tu, cosa segue": scegli da dove parti e vedi
una roadmap orizzontale degli step (dalla partenza all'arrivo), seguita dalla spiegazione di
ogni passaggio. Tocca uno step della roadmap per saltare al suo dettaglio. Funziona offline
dopo la prima apertura e segue il tema chiaro/scuro del dispositivo.

## File

- `index.html` — la pagina (contenuti e logica in un unico file)
- `manifest.webmanifest`, `icons/` — nome, colori e icone per l'installazione
- `sw.js` — service worker: cache per l'uso offline

## Pubblicare (GitHub Pages)

1. Su GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**.
2. Scegli il branch con questi file (es. `main`) e la cartella `/ (root)`, poi **Save**.
3. Dopo un minuto il sito è su `https://alegnago.github.io/pocockD2D/`.

## Installare

- **iPhone/iPad (Safari):** apri l'indirizzo → Condividi → *Aggiungi alla schermata Home*.
- **Android (Chrome):** apri l'indirizzo → menu ⋮ → *Installa app*.
- **Mac/PC (Chrome o Edge):** icona di installazione nella barra degli indirizzi.

## Aggiornare i contenuti

I percorsi sono nell'oggetto `routes` dentro `index.html`. Dopo ogni modifica incrementa
`VERSION` in `sw.js`: le app installate scaricano la nuova versione in background e la
mostrano alla riapertura successiva.
