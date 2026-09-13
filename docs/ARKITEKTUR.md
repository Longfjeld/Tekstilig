# Arkitektur

## 1. Overordnet modell

Tekstilig bygges som en lokal-first webapp/PWA.

```text
GitHub / GitHub Pages
        |
        | leverer appkode
        v
+----------------------+
|       Tekstilig      |
|       PWA/webapp     |
+----------+-----------+
           |
           | leser/skriver brukerdata
           v
iCloud Drive / lokal katalog
Tekstilig/
|-- tekstiler.json
`-- bilder/
    |-- T0001-main.webp
    |-- T0001-care.webp
    `-- ...
```

GitHub skal bare inneholde programkode og generell dokumentasjon. Brukerens tekstildata og bilder skal ikke inngå i repositoryet.

## 2. Lagringslag

Tilgang til data skal kapsles inn i et separat lagringslag. Resten av applikasjonen skal ikke være direkte avhengig av den konkrete mekanismen som brukes for filtilgang.

Dette gjør det mulig å endre lagringsmekanisme senere uten å skrive om søk, visning og registreringslogikk.

Primær datakilde:

- `tekstiler.json`

Bilder lagres som separate filer i `bilder/`.

## 3. Dataeierskap

Data skal:

- være lesbare uavhengig av appen
- kunne sikkerhetskopieres som vanlige filer
- kunne synkroniseres med iCloud Drive
- ikke kreve en sentral Tekstilig-tjeneste
- ikke publiseres via GitHub Pages

## 4. Bilder

Et tekstil kan ha flere bilder. Ett bilde kan markeres som hovedbilde.

Planlagte bildetyper:

- stoffprøve
- nærbilde
- vaskelapp
- hele stoffet
- annet

Appen skal redusere bildestørrelsen ved registrering. WebP er foretrukket lagringsformat.

## 5. Klienter

### Mobil/iPad

Prioriteres for:

- fotografering
- rask registrering
- oppslag ved stofflageret
- enkel redigering

### Mac

Prioriteres for:

- administrasjon
- omfattende søk og filtrering
- redigering
- sammenligning og oversikt

Begge skal bruke samme datamodell.

## 6. Søk

Det planlegges to hovedformer:

1. Vanlig søk/bla – fritekstsøk, filtre og visuelt stoffbibliotek.
2. Finn stoff til prosjekt – kriteriebasert søk etter blant annet materiale, tilgjengelig sammenhengende lengde, bredde, vekt og elastisitet.

Alle strukturerte egenskaper skal så langt det er meningsfullt kunne brukes som søke- eller filterkriterier.

## 7. Ytelse

Ytelse regnes som en del av brukeropplevelsen.

Det innebærer blant annet:

- optimaliserte bilder
- thumbnails/tilpasset bildelasting ved behov
- effektiv filtrering av JSON-data
- unngå unødvendige visuelle effekter
- ikke laste store originalbilder når mindre visning er tilstrekkelig

## 8. Fremtidig utvidbarhet

Datamodellen skal ha `schemaVersion`. Permanente tekstil-ID-er gjør det mulig å innføre blant annet QR-koder senere.

Mulige senere utvidelser skal ikke være en forutsetning for første versjon.
