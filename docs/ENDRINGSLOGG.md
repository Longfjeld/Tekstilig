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

## Kodeleveranse 0006 – 2026-09-26

Den tekniske native CloudKit-PoC-en er fullført. Leveransen starter første faktiske produktarkitektur og reelle brukerflyt i SwiftUI.

### Opprettet

- `Tekstilig/Domain/Textile.swift` – første faktiske Swift-domenemodell
- `Tekstilig/Data/TextileRepository.swift` – lagringsgrensesnitt for Textile
- `Tekstilig/Data/CloudKitTextileRepository.swift` – CloudKit-implementasjon med query, mapping og save/update
- `Tekstilig/Features/Library/TextileLibraryModel.swift` – feature state og lagringskoordinering
- `Tekstilig/Features/Library/TextileLibraryView.swift` – første reelle tekstilbibliotek
- `Tekstilig/Features/Library/TextileDetailView.swift` – detaljvisning
- `Tekstilig/Features/Library/TextileEditorView.swift` – opprett/rediger navn og kategori
- `Tekstilig/Diagnostics/DeveloperDiagnosticsView.swift` – PoC-flaten flyttet ut av produktets hovedflyt
- `docs/SWIFTUI-IMPLEMENTERING.md` – ny sekvensiell veiledning for produktfasen

### Endret

- `Tekstilig/ContentView.swift` – produkt-UI er nå hovedflate; diagnostikk er egen Debug-fane
- `README.md` – PoC markert fullført og produktfase aktiv
- `docs/SWIFTUI-OPPSTART.md` – punkt 8 og 9 dokumentert fullført og teknisk PoC lukket
- `docs/ARKITEKTUR.md` – repository-arkitektur og første produktstykke dokumentert
- `docs/DATAMODELL.md` – native implementeringsstatus og permanent ID-strategi presisert
- `docs/UX-FLYTER.md` – første implementerte brukerflyt markert
- `docs/BESLUTNINGSLOGG.md` – B-034, B-035 og B-036
- `docs/README.md` – aktiv veiledning flyttet til `SWIFTUI-IMPLEMENTERING.md`
- `docs/ENDRINGSLOGG.md` – denne leveransen

### Første produktflyt

```text
Tekstilbibliotek
    -> tekstildetalj
    -> opprett/rediger Textile
    -> TextileRepository
    -> CloudKitTextileRepository
    -> privat Development-database
```

### Bevisst ikke implementert

- `Piece` i produkt-UI
- bilder i produkt-UI
- full Textile-schemautvidelse
- søk og filtre
- lokal cache/offline
- sletting
- Production-deploy
- PWA-endringer



## Devpatch 0001 – 2026-09-27

Rettet identitetsfeil som ble synlig med eldre PoC-data der flere CloudKit `Textile`-records hadde samme `textileId`.

### Endret

- `Textile.id` bruker `cloudRecordName` for lagrede records og `textileId` som fallback for ulagrede drafts.
- `TextileLibraryView` navigerer med den tekniske record-identiteten i stedet for `textileId`.
- `TextileLibraryModel` slår opp detaljrecord på samme identitet som listen bruker.
- `TextileDetailView` viser dermed korrekt CloudKit-record selv når legacy-data har duplisert `textileId`.
- Dokumentasjon beskriver årsaken og trygg opprydding av gamle PoC-records.

### Viktig

Patchen sletter eller skjuler ikke gamle CloudKit-records automatisk. Eventuelle overflødige PoC-records ryddes manuelt etter kontroll av `recordName`.


## Devpatch 0002 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0002.zip`, der Textile-produktflyt test 1–9 er validert.

### Opprettet

- `Tekstilig/Domain/Piece.swift` – native domenetype for fysisk stoffstykke
- `Tekstilig/Data/PieceRepository.swift` – repository-grensesnitt
- `Tekstilig/Data/CloudKitPieceRepository.swift` – CloudKit query, mapping, save/update og delete
- `Tekstilig/Features/Pieces/PieceInventoryModel.swift` – feature state for valgt tekstils beholdning
- `Tekstilig/Features/Pieces/PieceEditorView.swift` – opprett/rediger dimensjoner og reservasjon

### Endret

- `Tekstilig/Features/Library/TextileDetailView.swift` – viser, oppretter, redigerer, oppdaterer og sletter stoffstykker
- `README.md` og dokumentasjon – Textile test 1–9 registrert som validert og Piece satt som aktivt produktsteg

### CloudKit

Ingen nye record-felt opprettes i denne leveransen. Produktkoden bruker eksisterende `Piece`-schema. `Piece.textileId` må markeres `QUERYABLE` i Development før den nye beholdningslisten testes.

### Bevisst utsatt

- `quantity` og Piece-notat
- mer avansert reservasjonsmodell
- splitting av rester / egen «registrer bruk»-flyt
- bilder i produkt-UI
- Production deploy
- PWA-endringer

## Devpatch 0003 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0003.zip`, der Textile test 1–9 og Piece test 10–18 er validert.

### Opprettet

- `Tekstilig/Domain/TextileImage.swift` – domenetype for bilde og lastet Asset-data
- `Tekstilig/Data/TextileImageRepository.swift` – repository-grensesnitt
- `Tekstilig/Data/CloudKitTextileImageRepository.swift` – query, CKAsset-lesing og save/update av hovedbilde
- `Tekstilig/Features/Images/TextileImageModel.swift` – feature state for valgt tekstils hovedbilde
- `Tekstilig/Features/Images/TextileMainImageSection.swift` – produkt-UI for visning, valg og erstatning av hovedbilde

### Endret

- `Tekstilig/Features/Library/TextileDetailView.swift` – hovedbilde vises som første produktseksjon etter grunnopplysninger
- `Tekstilig/Features/Pieces/PieceEditorView.swift` – Lengde og Bredde har nå persistente synlige etiketter i stedet for bare TextField-placeholder
- `README.md` og dokumentasjon – Piece markert validert og TextileImage satt som aktivt produktsteg

### CloudKit

Ingen nye record-felt opprettes. Produktkoden bruker eksisterende `TextileImage`-schema. Før testing må:

- `TextileImage.textileId` være `QUERYABLE`
- `TextileImage.recordName` være `QUERYABLE`

### Bevisst utsatt

- direkte kamera
- flere bilder per tekstil i produkt-UI
- sletting av hovedbilde
- thumbnails og lokal bildeoptimalisering
- lokal cache/offline
- Production deploy
- PWA-endringer


## Devpatch 0004 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0005.zip`, der bildeproduktsteget test 23–29 er validert.

### Opprettet

- `Domain/TextileMaterial.swift` og `Domain/TextileColor.swift`
- repository-grensesnitt og CloudKit-implementasjoner for begge child-record-typene
- `Features/Attributes/TextileAttributesModel.swift`
- editorer og detaljseksjon for materiale/farge

### Endret

- `TextileDetailView` viser Materialer og Farger i ordinær produktflyt
- `TextileMainImageSection` tar en lokal snapshot av `isSaving` før `PhotosPicker`-labelen, slik at Xcode 27 ikke refererer direkte til en MainActor-isolert property fra en Sendable closure
- dokumentasjonen markerer bildeproduktsteget som validert og beskriver ny CloudKit-mapping
- feil seksjonsnummer i `ARKITEKTUR.md` for TextileImage er korrigert fra 19 til 23

### CloudKit

Nye Development-record-typer:

- `TextileMaterial(materialId, textileId, material, percent)`
- `TextileColor(colorId, textileId, group, name, hex)`

Begge krever `textileId` som `QUERYABLE`; `recordName` anbefales `QUERYABLE` for administrasjon/testing.

### Bevisst utsatt

- søk/filtrering på materiale og farge
- plassering
- kamera / flere bilder / bildeoptimalisering
- Production deploy
- PWA-endringer


## Devpatch 0005 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0006.zip`, der materiale/farge test 30–39 er validert.

### Rettet

- materiale-/farge-editor bruker nå én felles sheet-route i stedet for fire konkurrerende `.sheet(...)`-presentasjoner; dette retter den observerte sporadiske feilen der et nytt materiale- eller fargefelt kunne vises og deretter forsvinne
- `TextileLibraryModel.upsert` matcher nå den samme tekniske `Textile.id`/CloudKit `recordName` som resten av navigasjonen, i stedet for bare `textileId`; dette gjør også redigering tryggere for gamle PoC-records med duplisert `textileId`

### Opprettet

- `Features/Location/TextileLocationSection.swift`
- `Features/Location/TextileLocationEditorView.swift`

### Endret

- `Textile` har valgfrie `locationArea`, `locationShelf` og `locationContainer`
- `CloudKitTextileRepository` leser, lagrer og fjerner plassering på samme Textile-record
- `TextileDetailView` viser Plassering mellom materialer/farger og stoffstykker
- dokumentasjon og testplan er oppdatert

### CloudKit

Nye valgfrie String-felt på eksisterende `Textile` record type:

- `locationArea`
- `locationShelf`
- `locationContainer`

Ingen nye indekser kreves i dette steget.

### Bevisst utsatt

- søk/filtrering på plassering
- kamera / flere bilder / bildeoptimalisering
- øvrige tekstilegenskaper og vedlikehold
- Production deploy
- PWA-endringer
