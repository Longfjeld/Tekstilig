# Arkitektur

## 1. Overordnet modell

Tekstilig utvikles nå som en native SwiftUI-app med CloudKit som primærlager. Den tidligere PWA/CloudKit JS-klienten beholdes frosset som teknisk PoC og referanse, men er ikke lenger et aktivt implementeringsspor.

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

Gjeldende Development-mapping, etablert i PoC-en og validert native i steg 9:

| Felt | CloudKit-type | Formål |
|:---|:---|:---|
| `pieceId` | String | Permanent Tekstilig-ID for stoffstykket |
| `textileId` | String | Permanent Tekstilig-ID for tilhørende tekstil |
| `lengthCm` | Int64 | Lengde i centimeter |
| `widthCm` | Int64 | Bredde i centimeter |
| `reservedLengthCm` | Int64 | Reservert lengde i centimeter |
| `project` | String | Prosjektnavn for reservasjonen |

Native steg 9 bruker den faste Development-recorden `swiftui-poc-piece-v1`. Den logiske modellen i `DATAMODELL.md` er rikere enn dette PoC-schemaet; blant annet `quantity` og reservasjonsnotat vurderes når produksjonsmodellen konkretiseres. PoC-en skal ikke utvide CloudKit-schemaet før den gjennomgangen.

### TextileImage

Representerer metadata om et bilde og en CloudKit Asset med selve bildefilen.

Gjeldende Development-mapping, etablert i PoC-en og gjenbrukt uendret i native steg 7:

| Felt | CloudKit-type | Formål |
|:---|:---|:---|
| `imageId` | String | Permanent Tekstilig-ID for bildet |
| `textileId` | String | Permanent Tekstilig-ID for tilhørende tekstil |
| `type` | String | Bildetype, f.eks. `fabric` |
| `primary` | Int64 | `1` for hovedbilde, ellers `0` |
| `fileName` | String | Filnavn/formatmetadata som CloudKit Asset ikke bevarer |
| `contentType` | String | MIME-type/innholdstype |
| `imageAsset` | Asset | Selve bildefilen som `CKAsset` i native klient |

Denne mappingen er fortsatt Development-schema og gjennomgås før Production. Punkt 7 bruker en fast testrecord `swiftui-poc-textile-image-v1` slik at gjentatte tester erstatter samme Asset i stedet for å opprette nye testrecords.

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

Den aktive native appen skal senere bruke en native lokal database/cache i tillegg til CloudKit-synk. Eksakt cache-/persistensmekanisme avgjøres etter at den tekniske CloudKit-PoC-en er ferdig.

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

SwiftUI-appen skal følge de etablerte UX-prinsippene og den logiske datamodellen. PWA-en beholdes kun som historisk PoC/referanse.

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

## 14. Overgangen fra PWA til SwiftUI

Overgangen til SwiftUI er besluttet og pågår. CloudKit gjør at backend, schema og Development-data kan gjenbrukes mens klientlaget erstattes.

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

CloudKit-PoC-en brukes derfor som teknisk referanse for backend og schema, men PWA-klientkoden videreutvikles ikke. Nye klientfunksjoner implementeres i SwiftUI.

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

---

## 17. Arkitekturstatus etter CloudKit JS PoC – 2026-09-26

CloudKit JS/PWA-sporet er avsluttet som teknisk PoC. Testen validerte autentisering og vanlige record-operasjoner mot privat CloudKit-database, men Asset-opplasting ble stoppet av CORS/preflight på Apples separate `singleFileUpload`-endepunkt i både Safari og Chrome.

Dette endrer **ikke** beslutningen om CloudKit som primærlager. Neste klientspor er SwiftUI med native CloudKit mot samme Development-container:

```text
iCloud.com.longfjeld.tekstilig
```

Oppdatert klientbilde:

```text
+---------------------------+
| CloudKit                  |
| Private database          |
| Development               |
|                           |
| Textile                   |
| Piece                     |
| TextileImage + CKAsset    |
+-------------+-------------+
              ^
              |
      native CloudKit
              |
+-------------+-------------+
| Tekstilig SwiftUI         |
| iPhone / iPad først       |
| Mac senere etter behov    |
+---------------------------+

PWA / CloudKit JS
  -> beholdes som PoC/referanse
  -> ikke aktivt produksjonsspor
```

Før videre UI-utvikling skal en minimal native PoC validere eksisterende records og deretter `CKAsset`. Production deployes ikke før schema og native flyt er gjennomgått.


## 18. Aktiv klientretning etter native steg 6 – 2026-09-26

Native SwiftUI har på fysisk Apple-enhet validert container, iCloud-konto, privat Development-database og `Textile`. Videre implementering skjer kun i SwiftUI inntil annet eventuelt besluttes.

Neste tekniske validering er `TextileImage.imageAsset` med native `CKAsset`. PWA-filene skal ikke endres som del av denne eller påfølgende SwiftUI-leveranser.


## 19. Native Piece-validering – 2026-09-26

Etter fullført native `Textile`- og `TextileImage`/`CKAsset`-validering gikk teknisk PoC videre med `Piece`. På dette tidspunktet var kryssenhetstesten midlertidig utsatt. `Piece` ble deretter validert på fysisk klient, og separat klienttilgang ble senere validert fra iOS-simulator som dokumentert i seksjon 20 og B-034.

PWA-koden forblir frosset og endres ikke.

## 20. Native CloudKit-PoC fullført – 2026-09-26

Den tekniske native PoC-en er avsluttet etter vellykket validering av `Textile`, `TextileImage`/`CKAsset`, `Piece` og tilgang fra en separat iOS-simulator med samme iCloud-konto.

PoC-diagnostikken beholdes foreløpig, men er ikke lenger appens hovedarkitektur.

## 21. Produktarkitektur fra kodeleveranse 0006

Første reelle appstruktur skiller UI, applikasjonstilstand, domenemodell og CloudKit-tilgang:

```text
SwiftUI Views
    |
    v
TextileLibraryModel
    |
    v
TextileRepository
    |
    v
CloudKitTextileRepository
    |
    v
Private CloudKit / Development
```

Ansvarsdeling:

| Lag | Ansvar |
|:---|:---|
| `Domain` | Swift-typer som beskriver Tekstilig-domenet |
| `Data` | Repository-grensesnitt og CloudKit-mapping |
| `Features` | Brukerflyter, visninger og feature-spesifikk tilstand |
| `Diagnostics` | Utviklingsverktøy fra teknisk PoC |

`ContentView` er nå kun appens rot. I Debug-build viser den produktflyten og en separat utviklingsfane. I Release-build skal diagnostikkfanen ikke kompileres inn i hovedgrensesnittet.

### Første produktstykke

Kodeleveranse 0006 implementerer bare den allerede validerte `Textile`-kjernen:

- `textileId`
- `name`
- `category`
- `createdAt`
- `updatedAt`
- `schemaVersion`

Dette er en bevisst vertikal implementering, ikke en reduksjon av den logiske datamodellen. Flere felt og record-typer kobles på etter at liste → detalj → opprett/rediger er validert.

### CloudKit-oppdatering

Ved redigering henter repository-laget eksisterende `CKRecord` før lagring. Dermed beholdes CloudKit-systemfelter og gjeldende record change tag. Nye records får en permanent Tekstilig-ID med prefikset `T-` og UUID. Record Name behandles fortsatt som lagringsmetadata og ikke som domenets permanente ID.



## 22. Produktarkitektur for Piece – devpatch 0002

Etter at Textile-flyten er validert utvides samme lagdeling til fysisk beholdning:

```text
TextileDetailView
    |
    v
PieceInventoryModel
    |
    v
PieceRepository
    |
    v
CloudKitPieceRepository
    |
    v
Private CloudKit / Piece
```

`Piece` kobles til `Textile` via den permanente logiske `textileId`. CloudKit `recordName` brukes som teknisk identitet for lagrede Piece-records, på samme måte som for `Textile`.

Første produktimplementering bruker bare allerede eksisterende Piece-felt i Development-schemaet. Ingen nye CloudKit-felt introduseres i devpatch 0002.

Produktkoden henter bare Piece-records for valgt tekstil med query på `textileId`. Feltet `Piece.textileId` må derfor ha en `QUERYABLE`-indeks i Development. Sortering skjer lokalt i klienten og krever ingen `SORTABLE`-indeks.

Diagnostikkrecorden `swiftui-poc-piece-v1` beholdes for utvikling, men filtreres ut av produktflyten.

## 23. Produktarkitektur for TextileImage – devpatch 0003

Etter validert Piece-flyt er hovedbilde neste vertikale produktsteg. Det følger samme lagdeling som Textile og Piece:

```text
TextileDetailView
    ↓
TextileMainImageSection
    ↓
TextileImageModel
    ↓
TextileImageRepository
    ↓
CloudKitTextileImageRepository
    ↓
Private CloudKit / Development
```

`TextileImage` bruker CloudKit `recordName` som teknisk identitet for lagrede records og `imageId` som permanent logisk Tekstilig-ID.

Produktkoden spør etter `TextileImage` via `textileId`, leser `CKAsset.fileURL` umiddelbart inn i `Data`, og beholder ikke CloudKits staging-URL som langsiktig filreferanse.

Første produktversjon velger siste endrede record som er markert `primary = 1` dersom eldre Development-data mot formodning inneholder flere hovedbilder for samme tekstil. Koden sletter eller skjuler ikke slike records automatisk. Normal lagring oppdaterer eksisterende primærrecord og oppretter bare ny record når tekstilet ikke har hovedbilde fra før.


## 24. Produktarkitektur for materiale og farge – devpatch 0004

Etter validert bildevertikalsnitt introduseres materialer og farger som egne child-records. Dette følger samme repository-mønster som øvrig produktkode:

```text
TextileDetailView
    ↓
TextileAttributesSection
    ↓
TextileAttributesModel
    ↓
TextileMaterialRepository / TextileColorRepository
    ↓
CloudKitTextileMaterialRepository / CloudKitTextileColorRepository
    ↓
Private CloudKit / Development
```

### TextileMaterial

| Felt | CloudKit-type | Formål |
|:---|:---|:---|
| `materialId` | String | Permanent ID for materialregistreringen |
| `textileId` | String | Relasjon til Textile |
| `material` | String | Fibertype/materialnavn |
| `percent` | Int64, valgfri | Prosentandel 0–100 |

### TextileColor

| Felt | CloudKit-type | Formål |
|:---|:---|:---|
| `colorId` | String | Permanent ID for fargeregistreringen |
| `textileId` | String | Relasjon til Textile |
| `group` | String | Standardisert fargegruppe |
| `name` | String | Valgfritt beskrivende navn |
| `hex` | String | Valgfri `#RRGGBB`-verdi |

Child-records velges fremfor fritekst/parallelle arrays fordi ett tekstil kan ha flere materialer og farger, og fordi hver registrering har flere sammenhørende strukturerte egenskaper. `textileId` må være `QUERYABLE` på begge record-typer for produktets detalj-query. `recordName` gjøres også `QUERYABLE` for forutsigbar inspeksjon i CloudKit Database.

Søk/filtrering på selve `material` og `group` indekseres ikke i dette steget. Søkeindekser fastsettes når faktisk søkeflyt implementeres, slik at Production-schemaet ikke får unødvendige indekser tidlig.


## 25. Produktarkitektur for plassering – devpatch 0005

Plassering er en enkelt, valgfri egenskap ved `Textile` og bruker derfor det eksisterende `TextileRepository` i stedet for en egen child-record/repository-kjede.

```text
TextileDetailView
    ↓
TextileLocationSection
    ↓
TextileLocationEditorView
    ↓
TextileLibraryModel
    ↓
CloudKitTextileRepository
    ↓
Private CloudKit / Textile
```

CloudKit-feltene er:

| Felt | Type | Formål |
|:---|:---|:---|
| `locationArea` | String, valgfri | Område/rom |
| `locationShelf` | String, valgfri | Hylle |
| `locationContainer` | String, valgfri | Beholder/kasse |

Dette følger det logiske `location`-objektet i `DATAMODELL.md`, men unngår en ekstra 1:1-record og ekstra query for hver detaljvisning. Feltene indekseres ikke ennå; søkeindekser fastsettes sammen med faktisk søk/filter-flyt.

### Stabil presentasjon av materiale/farge-editor

Devpatch 0005 samlet de tidligere fire separate `.sheet(...)`-presentasjonene for nytt/rediger materiale/farge til én eksplisitt editor-route, men test 41 viste at editoren fortsatt kunne lukkes straks etter presentasjon. Årsaken var at selve `.sheet`-modifikatoren fortsatt lå på `TextileAttributesSection`, som bygger innholdet sitt gjennom en transparent `Group` med flere `Section`-noder inne i en `List`. Denne view-strukturen kan rekonstrueres når asynkron CloudKit-state endres.

Devpatch 0006 flytter derfor både `TextileAttributesModel`-eierskap og `AttributeEditorRoute` til den stabile forelderen `TextileDetailView`. `TextileAttributesSection` er nå bare innhold/handlinger og ber forelderen om å åpne editoren. Selve `.sheet(item:)` er forankret på `List`-nivået i `TextileDetailView`, slik at presentasjonshosten består når attributtseksjonene oppdateres.
