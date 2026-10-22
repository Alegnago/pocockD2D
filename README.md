# Pocock · Day to day

Webapp installabile (PWA) della guida "Cosa avvii tu, cosa segue": scegli da dove parti e vedi
una roadmap orizzontale degli step fino alla fine della skill, poi le strade possibili da lì al
finale (rilascio, modifiche, altri percorsi), seguite dalla spiegazione di ogni passaggio. Ogni
strada è marcata "Dalla guida" (segue una regola scritta nella pagina) o "Ipotesi". Tocca uno
step per saltare al suo dettaglio, o un percorso per aprire la sua roadmap. Funziona offline
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

Compila una piccola app nativa (`mac/PocockD2D.swift`) in `~/Applications/Pocock D2D.app`.
Servono gli strumenti da riga di comando di Apple: se mancano, lo script ne avvia l'installazione.

- Non compare né nel Dock né nella barra dei menu e parte da sola al login.
- Si apre e si chiude con una scorciatoia globale sulla P: la prima libera tra ⌃⌥P, ⌃⌥⌘P,
  ⌃⌥⇧P e ⌃⇧⌘P. Lo script stampa quella scelta, che resta salvata in
  `~/Library/Application Support/PocockD2D/shortcut.txt`. Si nasconde anche con Esc o ⌘W.
- Il pannello ti segue su tutte le scrivanie e sopra le app a schermo intero.
- Funziona offline: la pagina è dentro l'app.
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
