# Pocock · Day to day

Webapp installabile (PWA) della guida "Cosa avvii tu, cosa segue": scegli da dove parti e vedi
una roadmap orizzontale degli step (dalla partenza all'arrivo), seguita dalla spiegazione di
ogni passaggio. Tocca uno step della roadmap per saltare al suo dettaglio. Funziona offline
dopo la prima apertura e segue il tema chiaro/scuro del dispositivo.

## File

- `index.html` — la pagina (contenuti e logica in un unico file)
- `manifest.webmanifest`, `icons/` — nome, colori e icone per l'installazione
- `sw.js` — service worker: cache per l'uso offline
- `install-mac.sh`, `icons/AppIcon.icns` — installazione come app locale su macOS

## Installare sul Mac (locale, senza internet)

Apri il Terminale e lancia:

```sh
git clone -b claude/friendly-archimedes-1btdg2 https://github.com/Alegnago/pocockD2D.git
cd pocockD2D && ./install-mac.sh
```

Crea `~/Applications/Pocock D2D.app`. Aprila da Spotlight o Launchpad ("Pocock D2D") e
trascinala nel Dock se la vuoi sempre a portata.

- Con Chrome, Edge, Brave, Chromium o Vivaldi installato si apre in una finestra dedicata,
  senza barre del browser, su un profilo separato. Altrimenti si apre nel browser predefinito.
- Funziona offline: la pagina è dentro l'app.
- L'icona nel Dock, mentre è aperta, è quella del browser, non quella dell'app.
- Per aggiornarla dopo una modifica: `git pull && ./install-mac.sh`.
- Per rimuoverla: `./install-mac.sh --uninstall`.

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
