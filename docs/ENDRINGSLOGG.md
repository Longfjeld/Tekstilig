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


## Devpatch 0006 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0007.zip`. Test 40 var vellykket, mens test 41 viste at materiale-/fargeeditoren fortsatt kunne åpnes og deretter forsvinne straks.

### Rettet

- `.sheet(item:)` for materiale/farge er flyttet fra `TextileAttributesSection` til den stabile forelderen `TextileDetailView`.
- `TextileAttributesModel` eies nå av `TextileDetailView`, slik at samme modellinstans brukes av seksjonen og editorens save-callbacks.
- `TextileAttributesSection` sender add/edit-handlinger opp via callbacks og er ikke lenger modal presentasjonshost.

### Uendret

- plassering-funksjonen fra devpatch 0005 beholdes uendret
- CloudKit-schema og indekser endres ikke
- PWA-koden endres ikke

### Testrekkefølge

Devpatch 0006 skal først bekrefte at materiale- og fargeeditorene forblir åpne. Deretter fortsetter de utsatte plasseringstestene.


## Devpatch 0007 – 2026-09-27

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0008.zip`. Devpatch 0006 stabiliserte materiale-/fargeeditoren, mens samme presentasjonsfeil ble observert på **Legg til plassering**.

### Rettet

- `.sheet(isPresented:)` for plassering er flyttet fra `TextileLocationSection` til den stabile forelderen `TextileDetailView`.
- `TextileDetailView` eier nå `showLocationEditor`.
- `TextileLocationSection` sender bare `onEditLocation` opp til forelderen og har ikke egen modal state.

### Uendret

- plasseringsmodellen og `TextileLocationEditorView`
- CloudKit-mappingen `locationArea`, `locationShelf`, `locationContainer`
- PWA-koden

### Testrekkefølge

Plasseringseditorens stabilitet skal bekreftes før de tre CloudKit-feltene opprettes og faktisk lagring testes.

## Devpatch 0008 – 2026-09-29

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0009.zip`, der plassering test 43–53 er validert.

### Opprettet

- `Domain/TextileCare.swift`
- `Features/Care/TextileCareSection.swift`
- `Features/Care/TextileCareEditorView.swift`

### Endret

- `Textile` inneholder nå strukturert `care` med tom standardverdi for bakoverkompatibilitet.
- `CloudKitTextileRepository` leser og lagrer ni valgfrie vedlikeholdsfelt på samme Textile-record.
- `TextileLibraryModel` normaliserer vedlikeholdsdata før lagring.
- `TextileDetailView` viser Vedlikehold før Plassering og presenterer editoren fra den stabile detaljroten.
- dokumentasjon og testplan er oppdatert etter fullført plassering.

### CloudKit

Nye valgfrie felt på eksisterende `Textile` record type i Development:

- `careWashAllowed` (Int64)
- `careWashTemperatureC` (Int64)
- `careWashCycle` (String)
- `careBleach` (String)
- `careTumbleDry` (String)
- `careDrying` (String)
- `careIron` (String)
- `careDryClean` (String)
- `careNotes` (String)

Ingen nye indekser kreves i dette steget.

### Bevisst utsatt

- nøyaktig grafisk standardisering av tekstilpleiesymboler
- bilde av vaskelapp
- søk/filter på vedlikehold
- Production deploy
- PWA-endringer


## Devpatch 0009 – 2026-09-29

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0010.zip`. Devpatch 0008 bygget korrekt, men første biblioteklasting etter opprettelse av vedlikeholdsfeltene endte i `CKError.operationCancelled` (feil 20).

### Rettet/stabilisert

- `CloudKitTextileRepository.fetchTextiles()` bruker nå `desiredKeys = nil` og henter komplette Textile-records i stedet for en eksplisitt klientliste over felt.
- samme innstilling brukes både på første query og cursor-fortsettelser.
- `TextileLibraryModel` viser mer CloudKit-diagnostikk når tilgjengelig: retry-tid, partial errors og underliggende NSError.

### Uendret

- CloudKit-schemaet fra devpatch 0008
- `TextileCare`-modellen og vedlikeholds-UI
- øvrige produktområder
- PWA-koden

### Testrekkefølge

Biblioteklasting og refresh skal valideres før vedlikeholdstestene fortsetter.

## Devpatch 0010 – 2026-09-30

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0011.zip`, der test 1–67 er validert.

### Opprettet

- `Domain/TextilePhysicalProperties.swift` – strukturerte Swift-typer for elastisitet og krymp
- `Features/PhysicalProperties/TextilePhysicalPropertiesSection.swift` – detaljvisning for vekt, elastisitet og krymp
- `Features/PhysicalProperties/TextilePhysicalPropertiesEditorView.swift` – samlet editor med enkel tallvalidering

### Endret

- `Textile` har nå valgfri `weightGsm`, `stretch` og `shrinkage` med bakoverkompatible standardverdier
- `CloudKitTextileRepository` leser, lagrer og fjerner syv valgfrie felt på samme Textile-record
- `TextileLibraryModel` normaliserer elastisitet og krymp før lagring
- `TextileDetailView` viser **Fysiske egenskaper** mellom Vedlikehold og Plassering og presenterer editoren fra den stabile detaljroten
- dokumentasjonen markerer vedlikehold/query test 54–67 som validert og legger til test 68–77

### CloudKit

Nye valgfrie felt på eksisterende `Textile` record type i Development:

- `weightGsm` (Int64)
- `stretchLevel` (String)
- `stretchDirection` (String)
- `stretchPercent` (Int64)
- `shrinkageLengthPercent` (Int64)
- `shrinkageWidthPercent` (Int64)
- `shrinkageNote` (String)

Ingen nye indekser kreves i dette steget.

### Bevisst utsatt

- søk/filtrering på vekt, elastisitet og krymp
- generelle egenskapstagger (`properties`)
- innkjøp/pris og fritekstnotater
- kamera / flere bilder / bildeoptimalisering
- Production deploy
- PWA-endringer

## Devpatch 0041 – 2026-10-03

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0016.zip`, der test 1–77 er validert.

### Første søk-/filtertrinn

- `TextileLibraryView` har fått native `.searchable`-felt.
- Fritekstsøket kjører lokalt på allerede innlastede Textile-snapshots og søker i navn, kategori og plassering (område, hylle og beholder).
- Søk er case-insensitivt, støtter deltreff og ignorerer ytre mellomrom.
- Biblioteket har fått et enkelt kategorifilter i toolbaren.
- Søk og kategorifilter kan kombineres.
- Tomt søkeresultat har egen `Ingen treff`-tilstand med knapper for å tømme søk og nullstille kategori.
- Eksisterende snapshot-mønster i biblioteket beholdes; hele `Textile` sendes fortsatt ikke direkte inn i NavigationLink-labelen.

### Arkitektur

Dette trinnet bruker ikke CloudKit-query for søk og krever derfor ingen nye indekser. Det er et bevisst første steg for å validere UX og lokal filterlogikk før søk utvides til child-records som materiale/farge og mer avanserte filtre.

### Testplan

- test 68–77 er markert validert
- test 78–86 dekker første fritekstsøk og kategorifilter
- `SWIFTUI-IMPLEMENTERING.md` dokumenterer nå eksplisitt normalmetodikken: nummererte tester er hovedsporet; ad-hoc diagnostikk brukes bare midlertidig når et konkret problem blokkerer planen

### Bevisst utsatt

- søk i materiale og farge
- søk/filter på Piece-data og tilgjengelige mål
- filter på vekt, elastisitet, vedlikehold og plassering
- generelle egenskapstagger (`properties`)
- CloudKit-søkeindekser og server-side query-søk
- prosjektsøk


## Devpatch 0042 – arbeidsmetodikk og utvidede grunnfiltre

- Ny `docs/ARBEIDSMETODIKK.md` samler fast metode for kodegrunnlag, nummerert testing, ❗️/✅-status, devpatcher og midlertidig ad-hoc feilisolering.
- Test 78–86 er registrert som fullført etter validering av første søk/grunnfilter-blokk.
- Kategorifilteret flyttes til et eget filterpanel.
- Filterpanelet utvides med plassering/område, minimum/maksimum vekt og elastisitetsnivå.
- Ingen nye CloudKit-felt eller indekser introduseres.
- Nye testpunkter 87–94 er lagt inn som ❗️ frem til eksplisitt validering.

## Devpatch 0044 – materiale- og fargebasert søk/filter

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0018.zip`, der test 1–94 er validert.

### Søkeindeks

- nytt `TextileLibraryAttributeIndex` henter og grupperer alle material- og farge-child-records lokalt på `textileId`
- material- og fargerepositories har fått bulk-lesing for bibliotekssøk
- pull-to-refresh oppdaterer både Textile-listen og child-record-indekset

### Søk og filter

- fritekstsøk omfatter nå materialnavn, fargegruppe og beskrivende fargenavn i tillegg til eksisterende Textile-felt
- filterpanelet har fått **Materiale** og **Farge**
- materialfilter matcher dersom minst ett registrert materiale passer
- fargefilter matcher dersom minst én registrert fargegruppe passer
- eksisterende kategori-, plassering-, vekt- og elastisitetsfiltre kan kombineres med de nye filtrene

### CloudKit

- ingen nye record-felt
- ingen nye feltbaserte `QUERYABLE`/`SEARCHABLE`-indekser i dette steget
- child-records hentes samlet og filtreres lokalt

### Dokumentasjon/test

- test 87–94 er beholdt som validert
- kortvarig treghet observert under kategorifilter i test 88 er dokumentert som ikke-blokkerende ytelsesobservasjon
- test 95–103 er lagt inn som **❗️** frem til eksplisitt validering


## Validering – devpatch 0044

Test 95–103 er gjennomført og eksplisitt bekreftet OK. Materiale- og fargebasert fritekstsøk/filter regnes dermed som validert del av hovedsporet.

## Devpatch 0045 – første «Finn til prosjekt»

Bygger på `Tekstilig-SwiftUIActualApp0019.zip`.

### Endret

- `ContentView.swift` – legger til egen fane **Finn til prosjekt**.
- `PieceRepository.swift` – legger til bulk-lesing av Piece-records.
- `CloudKitPieceRepository.swift` – paginert `fetchAllPieces()` uten nye schemaendringer.
- `PieceLibraryIndex.swift` – nytt lokalt Piece-indeks gruppert på `textileId`.
- `ProjectSearchView.swift` – første kriteriebaserte prosjektsøk.

### Første støttede krav

- minimum tilgjengelig sammenhengende lengde
- minimumsbredde
- kategori
- materiale
- minimum/maksimum vekt
- elastisitetsnivå

Treff krever at ett konkret stoffstykke oppfyller aktive dimensjonskrav, og resultatet viser tilgjengelige mål samt forklarende materiale-/vektinformasjon. Delvis reservasjon reduserer tilgjengelig lengde i søket.

### CloudKit

Ingen nye felter eller indekser opprettes i denne leveransen.

### Teststatus

Test 104–113 er lagt inn som **❗️** frem til eksplisitt validering.

## Devpatch 0050 – reservasjon direkte fra «Finn til prosjekt»

Bygger på `Tekstilig-SwiftUIActualApp0020.zip`, der test 1–113 er validert.

- søkeresultater får **Reserver stykke** / **Endre reservasjon**
- ny fokusert reservasjonsskjerm lagrer reservasjon i eksisterende Piece-record
- søkets lengdekrav foreslås som reservert lengde for ureserverte stykker
- Piece-indeksen lastes på nytt etter lagring og gjeldende prosjektsøk beregnes på nytt automatisk
- ingen nye CloudKit-felt eller indekser
- test 114–122 er lagt inn som **❗️**
- UX-/ytelsesobservasjoner fra test 104–113 er dokumentert for senere opprydding

## Devpatch 0051 – UX- og ytelsesopprydding etter prosjektsøk

- bygger på `Tekstilig-SwiftUIActualApp0021.zip`
- utsetter lasting av **Finn til prosjekt** til fanen faktisk aktiveres
- refresher prosjektsøkets datagrunnlag ved ny aktivering av fanen
- oppdaterer lokal Piece-indeks direkte ved lagring, sletting og reservasjon
- reduserer avhengigheten av umiddelbar CloudKit-read-after-write for søkeresultater
- forenkler bindingen for numeriske prosjektkriterier og validerer dem før søk
- gjør Piece-rader helrad-klikkbare
- gjør lengde/bredde-radene i Piece-editoren klikkbare over hele raden og legger til **Ferdig** for tastaturet
- dokumenterer UX-/ytelsesblokken og test 123–131
- ingen CloudKit-schemaendring

## Devpatch 0052 – utvidede prosjektkriterier

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0022.zip`, der test 1–131 er validert.

### Prosjektsøk

- legger til **Fargegruppe** som kriterium ved å gjenbruke eksisterende lokale fargeindeks
- legger til **Elastisitetsretning** i tillegg til elastisitetsnivå
- legger til **Maks krymp (%)**; aktivt krav krever registrert krymp både i lengde og bredde
- legger til **Vaskbarhet** og **Min vasketemperatur** som første avgrensede vedlikeholdskrav
- ukjente krymp-/vaskedata godkjennes ikke når et absolutt krav er aktivt
- nye kriterier kombineres med eksisterende lengde, bredde, kategori, materiale, vekt og elastisitet som AND-krav
- søkeresultatet forklarer relevante treff for farge, elastisitet, krymp og vask
- eksisterende sortering og Piece-valg beholdes uendret; ingen egnethetsrangering innføres ennå

### Piece-editor

- ved fokus på eksisterende **Lengde** eller **Bredde** flyttes innsettingspunktet eksplisitt til slutten av tallet
- eksisterende helrad-fokus og **Ferdig**-handling beholdes

### CloudKit og datamodell

- ingen nye record-typer
- ingen nye felt
- ingen nye CloudKit-indekser
- eksisterende `TextileColor`, `TextileStretch`, `TextileShrinkage` og `TextileCare` gjenbrukes

### Teststatus

- test 123–131 er beholdt som validert
- test 132–140 er eksplisitt validert **✅**


## Devpatch 0053 – søkefeedback og første egnethetsrangering

Bygger på autoritativ kilde `Tekstilig-SwiftUIActualApp0023.zip`, der test 1–140 er validert.

- **Finn tekstiler** får søkeikon med tydelig visuell bounce-feedback ved hvert trykk
- ved aktivt lengdekrav velges Piece med minst overskytende passende lengde
- ved lik lengdetilpasning brukes minst overskytende bredde som sekundært kriterium når breddekrav finnes
- med bare breddekrav prioriteres minst overskytende passende bredde
- samme best-fit-prinsipp brukes på rekkefølgen mellom søkeresultater
- resultatraden forklarer ekstra lengde/bredde under **Tilpasning**
- uten dimensjonskrav beholdes tidligere deterministiske rekkefølge
- eksisterende AND-filtrering, reservasjon og automatiske Piece-oppdateringer beholdes
- ingen CloudKit-schemaendring
- test 141–149 er lagt inn som **❗️** frem til eksplisitt validering
## Devpatch 0054 – korrigering av test 142

- Fjernet søkeikonet og `symbolEffect` fra **Finn tekstiler**, fordi løsningen i 0053 ikke ga pålitelig synlig feedback og påvirket knappens layout.
- Gjenopprettet knappens opprinnelige tekst og `.borderedProminent`-layout.
- Lagt til kort visuell puls på hele knappen uten å endre ikon, bredde eller Form-struktur.
- Punkt 142 skal retestes før 143–149 fortsetter.



## Devpatch 0055 – 1.0 punkt 3: første hurtigregistreringsblokk

- Basert på `Tekstilig-SwiftUIActualApp0025`.
- `Nytt tekstil` er forenklet til hurtigregistrering: bilde, navn og valgfri plassering.
- Kategori og øvrige metadata er fjernet fra førstegangsregistreringen og kompletteres senere.
- Direkte kamera er lagt til på iOS når fysisk kamera er tilgjengelig.
- Eksisterende bilde kan fortsatt velges via PhotosPicker.
- Kamera-/PhotosPicker-bilder i hurtigregistreringen normaliseres til JPEG, maksimal lengste side 2048 piksler, kvalitet 0,82 før CloudKit-lagring.
- Bildet lagres etter at Textile-recorden er opprettet; ved bildefeil beholdes registreringen åpen slik at lagring kan prøves igjen uten å opprette nytt Textile.
- `NSCameraUsageDescription` er lagt inn i generert Info.plist-konfigurasjon.
- Generelt valgfritt `Textile.notes` er lagt til i domenemodell og CloudKit-mapping.
- Notat vises på tekstildetaljen, redigeres via eksisterende **Rediger tekstil** og inngår i klientens fritekstsøk.
- Ingen Piece-, reservasjons- eller prosjektmatchingslogikk er endret.
- Ny testblokk 150–158 er lagt inn som **❗️** frem til eksplisitt validering.

## Devpatch 0056 – korrigering av hurtigregistreringens bildeknapper

- Basert på autoritativ kilde `Tekstilig-SwiftUIActualApp0026.zip`.
- Retter UX-feilen der teksten i **Ta bilde** fremstod forskjøvet på grunn av ikon + tekst i samme prominent-knapp.
- **Ta bilde** bruker nå en sentrert tekstetikett over hele knappens bredde.
- Retter funksjonsfeilen etter forhåndsvisning der **Ta nytt bilde** og **Velg annet** kunne utløse samme radhandling i `Form`.
- **Ta nytt bilde** og **Velg annet** har nå eksplisitte, separate `.bordered`-kontroller i samme rad.
- **Ta nytt bilde** åpner kamera; **Velg annet** åpner bildebiblioteket.
- Ingen endring i bildeoptimalisering, CloudKit, Textile-datamodell, notat, Piece, reservasjon eller prosjektsøk.
- Ny korrigeringstest 159–160 legges til før neste del av roadmap-punkt 3.

## Devpatch 0057 – 1.0 punkt 3: ny iPhone-hovedside

- Basert på autoritativ kilde `Tekstilig-SwiftUIActualApp0027.zip`, der test 150–160 er validert.
- Biblioteket åpner nå i en rolig oversiktstilstand i stedet for å vise hele tekstillisten umiddelbart.
- Oversikten har en tydelig **Registrer nytt stoff**-handling, **Nylig registrert**, **Vis alle tekstiler** og **Finn til prosjekt**.
- **Nylig registrert** viser inntil fem tekstiler sortert på `createdAt`, ikke siste redigeringstidspunkt.
- Nylige tekstiler viser hovedbilde som kompakt thumbnail når bilde finnes, og en rolig bilde-placeholder ellers.
- Trykk på et nylig tekstil åpner eksisterende detaljvisning direkte.
- **Vis alle tekstiler** aktiverer den eksisterende komplette biblioteklisten. En egen **Oversikt**-handling lar brukeren gå tilbake til startsiden når listen ble åpnet eksplisitt.
- Søk aktiverer den komplette resultatlisten umiddelbart mens brukeren skriver.
- Aktive filtre aktiverer den komplette resultatlisten uten at brukeren først må trykke **Vis alle tekstiler**.
- Når søk/filtre som alene aktiverte listen fjernes, går visningen tilbake til oversikten.
- Filterknappen beholdes øverst til venstre og markerer fortsatt aktive filtre.
- **Finn til prosjekt** på oversikten skifter til den eksisterende prosjektfanen; prosjektlogikken er ikke duplisert.
- Ingen CloudKit-schema-, Textile-, Piece-, reservasjons- eller prosjektmatchingsendringer.
- Ny testblokk 161–169 er lagt inn som **❗️** frem til eksplisitt validering.
