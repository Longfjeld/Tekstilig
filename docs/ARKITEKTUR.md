# Arkitektur

## 1. Overordnet modell

Tekstilig bygges først som en PWA/webapp, men med en backendmodell som også kan brukes direkte av en senere SwiftUI-app.

```text
                        +---------------------------+
                        |       CloudKit            |
                        |  iCloud container         |
                        |                           |
                        |  Private database         |
                        |  - Textile records        |
                        |  - Piece records          |
                        |  - Image records/assets   |
                        |  - øvrige data            |
                        +-------------+-------------+
                                      ^
                         samme schema | og data
                                      |
              +-----------------------+-----------------------+
              |                                               |
+-------------+-------------+                   +-------------+-------------+
| Tekstilig PWA / webapp    |                   | Tekstilig SwiftUI         |
| GitHub Pages              |                   | iPhone / iPad / Mac       |
| CloudKit JS               |                   | native CloudKit           |
+-------------+-------------+                   +-------------+-------------+
              |                                               |
              +--------------- lokal cache -------------------+
                       IndexedDB / OPFS eller native lager
```

GitHub/GitHub Pages inneholder bare programkode og generell dokumentasjon. Brukerens tekstildata og bilder skal ikke ligge i repositoryet.

## 2. Primær lagring

CloudKit blir primær datakilde i stedet for en bruker-valgt iCloud Drive-katalog.

Første versjon bruker brukerens **private CloudKit database**. Private records er som standard bare tilgjengelige for den aktuelle iCloud-brukeren og teller mot brukerens iCloud-lagringskvote.

Dette løser Safari-begrensningen som hindrer en ren PWA i å ha permanent direkte tilgang til en vilkårlig iCloud Drive-katalog.

## 3. CloudKit-container og schema

Tekstilig skal bruke én egen iCloud/CloudKit-container, foreløpig planlagt som eksempelvis:

```text
iCloud.com.longfjeld.tekstilig
```

Endelig identifier fastsettes ved opprettelse og skal deretter behandles som permanent.

CloudKit-schemaet utformes slik at både CloudKit JS og native CloudKit kan bruke samme container og samme data.

Første planlagte record-typer:

```text
Textile
Piece
TextileImage
```

Ytterligere typer kan innføres når vi konkretiserer schemaet.

### Textile

Representerer selve tekstilet og hovedegenskapene fra `DATAMODELL.md`.

### Piece

Representerer ett fysisk stoffstykke med lengde, bredde og eventuell reservasjon.

### TextileImage

Representerer metadata om et bilde og en CloudKit Asset med selve bildefilen.

CloudKit-recordnavn og permanente Tekstilig-ID-er skal ikke blandes sammen unødvendig. Tekstilig beholder egne permanente ID-er som `T0042` og `P001`, mens CloudKit håndterer sine system-ID-er og endringsmetadata.

## 4. Logisk datamodell og fysisk lagring

`DATAMODELL.md` beskriver fortsatt den **logiske datamodellen**. Den er ikke lenger en spesifikasjon som krever at produksjonsdata fysisk ligger i én `tekstiler.json`.

CloudKit mapper den logiske modellen til records og assets. JSON beholdes som et portabelt eksport-/backupformat.

Dette skillet er viktig fordi samme logiske modell da kan brukes av:

- PWA med CloudKit JS
- SwiftUI med native CloudKit
- eksport/import
- eventuelle senere verktøy

## 5. Bilder

Et tekstil kan ha flere bilder. Ett bilde markeres som hovedbilde.

Planlagte bildetyper:

- stoffprøve
- nærbilde
- vaskelapp
- hele stoffet
- annet

Bilder reduseres/optimaliseres lokalt før opplasting. I CloudKit lagres bildefilen som Asset knyttet til en bilderecord.

## 6. Lokal cache og offline

CloudKit er autoritativ datakilde, men klienten skal ikke være avhengig av et nettverkskall for hver skjermvisning.

### PWA

Planlagt lokal cache:

- IndexedDB og/eller OPFS for data/cache
- lokale bilde-thumbnails der det gir gevinst
- kø for endringer som må synkroniseres når nettverk er tilgjengelig

### SwiftUI

En senere native app kan bruke en native lokal database/cache og CloudKit-synk. Eksakt mekanisme avgjøres hvis SwiftUI-sporet aktiveres.

Synkroniseringslaget skal ta høyde for CloudKit-recordenes systemfelt/change tags, slik at konflikter kan håndteres riktig.

## 7. Autentisering

### PWA / CloudKit JS

Webappen konfigureres med container-ID og et CloudKit API-token. API-tokenet begrenses til de faktiske web-originene som skal bruke containeren.

Brukeren autentiseres mot iCloud gjennom CloudKit JS. Private databaseoperasjoner utføres på vegne av den innloggede iCloud-brukeren.

### SwiftUI

En native app bruker brukerens iCloud-konto på enheten gjennom native CloudKit. Webinnloggingen og CloudKit-JS-koden gjenbrukes ikke, men samme container og data gjenbrukes.

## 8. GitHub Pages

GitHub Pages fortsetter å være distribusjonsmekanisme for PWA-en.

Krav:

- HTTPS skal være aktivert og håndhevet.
- Den faktiske GitHub Pages-origin må legges til som tillatt origin på CloudKit API-tokenet.
- Dersom Tekstilig senere bruker et custom domain, må også den nye origin legges til og testes før gammel origin fjernes.
- Ingen brukerdata eller hemmelige servernøkler skal lagres i repositoryet.

Et CloudKit web API-token er laget for klientbruk, men skal fortsatt begrenses med Allowed Origins. Server-to-server private keys skal aldri legges i PWA-koden.

## 9. Utviklings- og produksjonsmiljø

CloudKit har separate development- og production-miljøer.

Arbeidsmodell:

```text
Development
  -> bygg og test schema
  -> test PWA/SwiftUI mot utviklingsmiljø
  -> kontroller record-typer, felt og indekser
  -> deploy schema changes
Production
  -> produksjonsdata
```

Vi skal være konservative før schema deployes til production. Etter produksjonsdeploy er schemaendringer i hovedsak additive; eksisterende record-typer og felt kan ikke behandles som fritt omdøpbare/slettbare utviklingsobjekter.

Det opprettes separate API-tokens for development og production.

## 10. Dataeierskap og portabilitet

CloudKit er primærlager, men Tekstilig skal ha eksplisitt eksport/import.

Planlagt eksport:

```text
Tekstilig-backup-YYYY-MM-DD.zip
|-- tekstiler.json
`-- bilder/
    |-- T0001-main.webp
    `-- ...
```

Målet er at brukerens data fortsatt skal kunne leses og sikkerhetskopieres uten CloudKit eller Tekstilig-klienten.

## 11. Klienter

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

PWA og eventuell SwiftUI-app skal følge samme UX-prinsipper og logiske datamodell.

## 12. Søk

Det planlegges to hovedformer:

1. Vanlig søk/bla – fritekstsøk, filtre og visuelt stoffbibliotek.
2. Finn stoff til prosjekt – kriteriebasert søk etter blant annet materiale, tilgjengelig sammenhengende lengde, bredde, vekt og elastisitet.

Felter som brukes i CloudKit-spørringer må planlegges og indekseres bevisst. Lokal cache kan brukes til raske kombinerte filtre der dette er mer hensiktsmessig.

## 13. Ytelse

Ytelse regnes som en del av brukeropplevelsen.

Det innebærer blant annet:

- optimaliserte bilder
- thumbnails/tilpasset bildelasting
- lokal cache
- begrenset nettverkstrafikk
- effektiv filtrering
- unngå unødvendige visuelle effekter

## 14. Veien fra PWA til SwiftUI

CloudKit gjør en eventuell senere overgang til SwiftUI forholdsvis ryddig.

### Kan gjenbrukes

- CloudKit-container
- development/production-miljø
- record-typer og felt
- indekser
- eksisterende brukerdata
- CloudKit Assets/bilder
- permanente Tekstilig-ID-er
- datamodell og valideringsregler
- UX-prinsipper
- eksport/importformat
- store deler av forretningsreglene som spesifikasjon/testgrunnlag

### Må implementeres på nytt eller tilpasses

- HTML/CSS
- PWA-navigasjon og DOM-kode
- service worker
- CloudKit JS-konfigurasjon og webautentisering
- IndexedDB/OPFS-cache
- JavaScript-spesifikk UI-kode

Dette betyr at CloudKit-PoC-en ikke er bortkastet dersom prosjektet senere går over til SwiftUI. PoC-en validerer nettopp backend, schema, dataflyt, bilder og synk som den native appen også trenger.

## 15. Fremtidig deling

Første versjon bruker private database. CloudKit støtter også shared database/CKShare, og arkitekturen skal ikke hindre at en tekstilsamling senere kan deles mellom flere iCloud-brukere.

Deling er ikke en del av første PoC.

## 16. Offisielle referanser

- Apple: CloudKit JS – https://developer.apple.com/documentation/cloudkitjs
- Apple: CloudKit private database – https://developer.apple.com/documentation/cloudkit/ckcontainer/privateclouddatabase
- Apple: Designing and Creating a CloudKit Database – https://developer.apple.com/documentation/cloudkit/designing-and-creating-a-cloudkit-database
- Apple: Deploying an iCloud Container's Schema – https://developer.apple.com/documentation/cloudkit/deploying-an-icloud-container-s-schema
- Apple: CloudKit Console – https://developer.apple.com/icloud/cloudkit/
- GitHub: Securing GitHub Pages with HTTPS – https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https
