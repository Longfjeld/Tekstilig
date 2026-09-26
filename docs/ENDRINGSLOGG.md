# Endringslogg

## Dokumentasjon 0001 – 2026-09-13

Første dokumentasjonspakke for Tekstilig.

### Opprettet

- `README.md`
- `ARKITEKTUR.md`
- `DATAMODELL.md`
- `BESLUTNINGSLOGG.md`
- `ENDRINGSLOGG.md`

### Fastlagt

- lokal-first PWA/webapp
- GitHub/GitHub Pages for programkode
- privat JSON- og bildelagring i lokal/iCloud-katalog
- datamodell v1
- separate fysiske stoffstykker
- strukturerte material-, farge-, vedlikeholds-, elastisitets- og krympdata
- valgfri prisinformasjon
- reservasjon per stoffstykke
- visuell retning og designprinsipper
- arbeidsdeling mellom mobil/iPad og Mac
- sekvensiell ZIP-basert leveransemodell

### Applikasjonskode

Ingen applikasjonskode er levert i denne versjonen.


## Dokumentasjon 0002 – 2026-09-13

UX-grunnlaget og hovedbrukerflytene er konkretisert.

### Ny fil

- `UX-FLYTER.md`

### Endret

- `README.md` – lagt til UX-dokumentasjon og oppdatert status
- `BESLUTNINGSLOGG.md` – lagt til beslutninger B-017 til B-021
- `ENDRINGSLOGG.md` – denne leveransen

### Fastlagt

- fire hovedområder i navigasjonen
- stoffbibliotek som primær startflate
- innhold og interaksjon i tekstilkort
- søk og filterstruktur
- tekstildetalj og håndtering av stoffstykker
- hurtigregistrering med progressiv detaljering
- mobil/iPad-flyt for fotografering
- prosjektsøk med forklarbare treff
- reservasjon og grunnleggende beholdningsredigering
- forskjeller mellom mobil/iPad og Mac
- tomme tilstander, feil og grunnleggende tilgjengelighet
- anbefalt implementeringsrekkefølge

### Applikasjonskode

Ingen applikasjonskode er levert i denne versjonen.

## Kodeleveranse 0001 – 2026-09-13

Første komplette kodeleveranse.

### Opprettet

- teknisk PWA-prototype
- nettleserdeteksjon for katalogtilgang og OPFS
- abstrahert lagringslag
- oppretting/lesing/skriving av `tekstiler.json`
- testdata basert på datamodell v1
- bildevalg/kamerainput og bildelagring
- Safari/iOS eksport/import av JSON
- service worker og manifest
- responsivt grensesnitt med valgt designretning

### Teknisk avklaring

Direkte bruker-valgt iCloud Drive-katalog kan ikke være eneste lagringsmekanisme for Safari/iPhone/iPad. Dette testes videre før endelig produksjonsarkitektur låses.


## Dokumentasjonsendring 0002 – 2026-09-14

CloudKit er valgt som ny primær lagringsarkitektur etter at første PWA-prototype bekreftet begrensningene ved direkte iCloud Drive-katalogtilgang i Safari.

### Ny fil

- `CLOUDKIT-OPPSETT.md` – forutsetninger, Apple Developer/CloudKit-oppsett, API-token, GitHub Pages, development/production og PoC-sjekkliste

### Endret

- `ARKITEKTUR.md` – CloudKit som primærlager, lokal cache, eksport og gjenbruk mot SwiftUI
- `DATAMODELL.md` – presisert at modellen er logisk og at JSON er eksport-/backupformat
- `BESLUTNINGSLOGG.md` – lagt til B-023 til B-028 og oppdatert status for B-021/B-022
- `README.md` – lagt til CloudKit-dokumentasjon og status
- `ENDRINGSLOGG.md` – denne leveransen

### Ingen kodeendring

Eksisterende PWA-kode er ikke endret i denne leveransen. Neste kodeendring blir en CloudKit JS PoC når container, token og origin er klargjort.


## Kodeleveranse 0002 – 2026-09-25

CloudKit-forhåndsoppsettet er validert mot prosjektets dokumentasjon og første CloudKit JS PoC er implementert.

### Opprettet

- `cloudkit-config.js` – Development-konfigurasjon for container, API-token og Allowed Origin
- `docs/CLOUDKIT-POC-TEST.md` – strengt sekvensiell testprosedyre

### Endret

- `index.html` – CloudKit PoC-grensesnitt
- `app.js` – iCloud-autentisering og tester for `Textile`, `Piece` og `TextileImage`/Asset
- `styles.css` – støtte for CloudKit-autentiseringsområdet
- `sw.js` – nytt cache-navn og ny asset-liste; eksterne CloudKit-kall caches ikke
- `README.md` – kodeleveranse 0002 og testmål
- `docs/README.md` – oppdatert prosjektstatus
- `docs/CLOUDKIT-OPPSETT.md` – status korrigert etter fullført forhåndsoppsett
- `docs/ENDRINGSLOGG.md` – denne leveransen

### Validering av oppsett

Dokumenterte verdier er internt konsistente:

```text
Container:      iCloud.com.longfjeld.tekstilig
Environment:    development
Pages URL:      https://longfjeld.github.io/Tekstilig/
Allowed Origin: https://longfjeld.github.io
```

Development API-tokenet har forventet 64-tegns heksadesimalt format. Selve Allowed-Origin-innstillingen i Apple-portalen kan ikke verifiseres fra repositoryfilene alene og regnes som brukerbekreftet.

## Dokumentasjonsendring 0004 – 2026-09-26

CloudKit JS/PWA-PoC-en er avsluttet etter at record-operasjoner fungerte, mens Asset-opplasting stoppet i nettleseren på CORS/preflight mot Apples separate `singleFileUpload`-endepunkt. Neste klientspor er SwiftUI med native CloudKit.

### Ny fil

- `SWIFTUI-OPPSTART.md` – strengt sekvensiell oppstartsplan for native SwiftUI/CloudKit-PoC

### Endret

- `BESLUTNINGSLOGG.md` – B-029 dokumenterer overgang til native SwiftUI som neste klientspor
- `CLOUDKIT-POC-TEST.md` – gjort om fra testprosedyre til faktisk resultatlogg
- `ARKITEKTUR.md` – PWA markert som avsluttet PoC-spor; SwiftUI/native CloudKit som neste valideringsspor
- `README.md` – prosjektstatus og neste milepæl oppdatert
- `docs/README.md` – dokumentoversikt og status oppdatert
- `ENDRINGSLOGG.md` – denne leveransen

### Ingen applikasjonskode

Denne leveransen endrer ikke PWA-koden. Første SwiftUI-kode lages etter at punktene 1–5 i `SWIFTUI-OPPSTART.md` er utført.

## Kodeleveranse 0003 – 2026-09-26

Første native SwiftUI/CloudKit-kodeleveranse etter at punkt 1–5 i `SWIFTUI-OPPSTART.md` ble fullført.

### Opprettet

- `Tekstilig/CloudKitDiagnosticModel.swift` – minimal native CloudKit-diagnostikk
- `docs/DESIGN.md` – samlet autoritativ design- og typografiretning

### Endret

- `Tekstilig/ContentView.swift` – enkel diagnostikkflate for steg 6
- `Tekstilig/MyApp.swift` erstattet av `Tekstilig/TekstiligApp.swift`
- `Tekstilig.xcodeproj/project.pbxproj` – produktnavn ryddet til `Tekstilig`
- `.gitignore` – lokal Xcode-brukerstate og build-output ignoreres
- `README.md` – tidlig prosjektstatus og aktivt native utviklingsspor presisert
- `docs/README.md` – dokumenthierarki og gjeldende neste steg oppdatert
- `docs/SWIFTUI-OPPSTART.md` – punkt 6 gjort om til konkret, sekvensiell testprosedyre
- `docs/BESLUTNINGSLOGG.md` – lagt til B-030 og B-031
- `docs/ENDRINGSLOGG.md` – denne leveransen

### Ryddet fra leveransen

- `xcuserdata`
- `*.xcuserstate`
- generert Playground-eksempelkode

### Teknisk omfang

Kodeleveransen tester bare:

1. eksplisitt CloudKit-container
2. iCloud account status
3. privat database
4. hent eller opprett én fast `Textile`
5. les samme record tilbake

`Piece`, `TextileImage`, `CKAsset`, full datamodell, cache og produkt-UI er bevisst ikke implementert i denne leveransen.

## Kodeleveranse 0004 – 2026-09-26

Native CloudKit steg 6 er bekreftet fullført på fysisk Apple-enhet. Leveransen implementerer steg 7: `TextileImage` + `CKAsset`.

### Opprettet

- `Tekstilig/CloudKitAssetDiagnosticModel.swift` – native CKAsset tur/retur-test med fast Development-record

### Endret

- `Tekstilig/ContentView.swift` – Photos Picker, lokal forhåndsvisning, CKAsset-test, resultatlogg og visning av bildet lest tilbake fra CloudKit
- `.gitignore` – ignorerer Xcode lokal brukerstate og build-output
- `README.md` – SwiftUI er eneste aktive klientspor; PWA er frosset PoC/referanse
- `docs/README.md` – status oppdatert til punkt 7
- `docs/SWIFTUI-OPPSTART.md` – punkt 6 markert fullført og punkt 7 gjort til komplett sekvensiell testprosedyre for Xcode 27 / OS 27
- `docs/ARKITEKTUR.md` – SwiftUI satt som aktiv klientretning og konkret `TextileImage`/Asset-mapping dokumentert
- `docs/BESLUTNINGSLOGG.md` – B-032 dokumenterer at PWA-sporet fryses
- `docs/ENDRINGSLOGG.md` – denne leveransen

### CKAsset-testens omfang

Testen:

1. bruker eksisterende `swiftui-poc-textile-v1`
2. lar brukeren velge ett bilde via systemets Photos Picker
3. skriver bildefil til midlertidig lokal URL
4. oppretter/oppdaterer `swiftui-poc-textile-image-v1`
5. lagrer bildet i `imageAsset` som `CKAsset`
6. henter samme record tilbake
7. leser CloudKits staging-fil umiddelbart
8. kontrollerer at nedlastede bytes er identiske med valgte bytes
9. viser bildet som faktisk ble lest tilbake fra CloudKit

### Bevisst ikke implementert

- kamera direkte i appen
- bildeoptimalisering eller thumbnails
- full produkt-UI
- lokal cache
- generell bildehåndtering/datamodell i Swift
- Production-deploy

### PWA

Ingen PWA-kode er endret i denne leveransen. PWA-sporet er nå eksplisitt frosset etter B-032.


## Kodeleveranse 0005 – 2026-09-26

Native steg 7 er fullført. Kryssenhetstesten i steg 8 er utsatt fordi en annen fysisk Apple-enhet ikke er tilgjengelig. Leveransen implementerer steg 9: native validering av `Piece`.

### Opprettet

- `Tekstilig/CloudKitPieceDiagnosticModel.swift` – native `Piece`-test mot privat Development-database

### Endret

- `Tekstilig/ContentView.swift` – ny Piece-test, resultatlogg og visning av feltene lest tilbake fra CloudKit
- `README.md` – status oppdatert til fullført steg 7 og aktivt steg 9
- `docs/README.md` – steg 8 markert utsatt og steg 9 som neste handling
- `docs/SWIFTUI-OPPSTART.md` – komplett sekvensiell prosedyre for steg 9 i Xcode 27
- `docs/ARKITEKTUR.md` – konkret Development-mapping for `Piece` dokumentert
- `docs/BESLUTNINGSLOGG.md` – B-033 dokumenterer hvorfor kryssenhetstest kan utsettes uten å blokkere Piece
- `docs/ENDRINGSLOGG.md` – denne leveransen

### Piece-testens omfang

Testen:

1. bruker eksisterende `swiftui-poc-textile-v1`
2. leser permanent `textileId` fra denne
3. oppretter eller gjenbruker `swiftui-poc-piece-v1`
4. lagrer `pieceId`, `textileId`, `lengthCm`, `widthCm`, `reservedLengthCm` og `project`
5. leser basisfeltene tilbake og validerer dem
6. oppdaterer samme record med reservasjon
7. leser oppdatert record tilbake og validerer alle testede felt

### Bevisst ikke implementert

- utvidelse av Piece-schema med `quantity` eller reservasjonsnotat
- full produkt-UI for stoffstykker
- lokal cache/synkroniseringslag
- Production-deploy
- PWA-endringer
