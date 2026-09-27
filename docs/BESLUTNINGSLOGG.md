# Beslutningslogg

Beslutningsloggen dokumenterer **hvorfor** Tekstilig bygges slik den gjør. Endringsloggen dokumenterer hva som endres mellom leveranser.

---

## B-001 – Programkode og brukerdata skilles

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Programkoden kan publiseres via GitHub/GitHub Pages. Tekstildata og brukerbilder skal ikke publiseres i GitHub.

### Begrunnelse

Dataene er private og skal eies og kunne håndteres direkte av brukeren.

### Konsekvens

Appen må ha et separat lagringslag.

---

## B-002 – JSON og separate bilder i lokal/iCloud-katalog

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Primær lagringsmodell er en lokal katalog, primært plassert i iCloud Drive, med `tekstiler.json` og en egen bildekatalog.

### Begrunnelse

Løsningen er transparent, enkel å sikkerhetskopiere og gir direkte tilgang til data uten å være avhengig av en sentral tjeneste.

---

## B-003 – Lagringslaget abstraheres

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Filtilgang skal kapsles inn slik at resten av appen ikke avhenger direkte av den konkrete nettleser-API-en.

### Begrunnelse

Dette reduserer konsekvensen av forskjeller mellom nettlesere og gjør senere endring av lagringsmekanisme enklere.

---

## B-004 – Stoffstykker modelleres separat

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Et tekstil kan bestå av flere fysiske stoffstykker. Lengde og bredde registreres per stykke.

### Begrunnelse

Total meterlengde sier ikke om det finnes et stort nok sammenhengende stykke til et syprosjekt. Rester kan også ha ulik bredde.

---

## B-005 – Materialinnhold lagres strukturert

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Fibertype og prosentandel lagres som separate strukturerte verdier, ikke bare som fritekst.

### Begrunnelse

Dette muliggjør presist søk og filtrering på materiale og andel.

---

## B-006 – Vedlikehold lagres strukturert

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Vask, bleking, tørking, stryking og rens registreres som strukturerte verdier. Bilde av vaskelapp kan lagres i tillegg.

### Begrunnelse

Strukturerte data kan søkes og filtreres. Bildet fungerer som dokumentasjon og supplement.

---

## B-007 – Visuell retning: varm minimalisme

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Tekstilig skal ha et varmt, rolig og stilrent uttrykk med dempet, hovedsakelig nøytral palett. Stoffbildene skal stå for mesteparten av fargen og det visuelle uttrykket.

Appen følger systemets lys/mørk-modus.

### Designprinsipper

1. Stoffet er hovedpersonen.
2. Enkel før komplett.
3. Visuelt, men informativt.
4. Mobil ved lageret, Mac ved skrivebordet.
5. Rolig og varmt, ikke dekorativt.
6. Ytelse er en del av designet.

### Begrunnelse

Grensesnittet skal være enkelt, vakkert og oversiktlig uten å konkurrere med tekstilbildene eller bli sterilt.

---

## B-008 – Responsiv arbeidsdeling mellom enheter

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Mobil/iPad prioriteres for fotografering, registrering og oppslag ved lageret. Mac prioriteres for administrasjon, redigering og omfattende søk.

### Konsekvens

Mobilgrensesnittet skal ikke bare være en nedskalert desktop-visning.

---

## B-009 – Søk og visuelt bibliotek er hovedinngangen

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Forsiden kombinerer fritekstsøk med et visuelt stoffbibliotek. Vanlig søk, filtrering, prosjektsøk og fri blaing skal støttes.

Kortvisning skal prioritere relativt store stoffbilder og vise navn, materiale og tilgjengelig størrelse.

---

## B-010 – Rask registrering med progressiv detaljering

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Et nytt tekstil skal kunne registreres raskt med få grunnopplysninger. Flere detaljer kan fylles ut umiddelbart eller senere.

Fotografering direkte fra telefon/iPad skal være en sentral arbeidsflyt.

---

## B-011 – Symboler kombineres med tekst

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Vedlikehold og andre egnede egenskaper skal presenteres med både grafiske symboler og forklarende tekst.

### Begrunnelse

Symboler gir rask visuell lesing, mens tekst reduserer tvetydighet.

---

## B-012 – Farge lagres på flere nivåer

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Farge kan bestå av søkbar fargegruppe, beskrivende navn og en konkret fargeverdi.

### Begrunnelse

Fargegruppe gir robust filtrering, mens navn og fargeverdi gir mer presis beskrivelse.

---

## B-013 – Pris er valgfritt

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Innkjøpspris kan registreres, men er ikke obligatorisk. Meterpris og/eller totalpris kan lagres sammen med valuta, leverandør og innkjøpsdato.

---

## B-014 – Reservasjon knyttes til stoffstykke

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Hele eller deler av et stoffstykke kan reserveres til et prosjekt.

### Begrunnelse

Andre stykker av samme tekstil kan fortsatt være tilgjengelige, og et stykke kan være delvis reservert.

---

## B-015 – Permanente ID-er og versjonert schema

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Tekstiler får permanente automatiske ID-er. Datafilen inneholder `schemaVersion`.

### Begrunnelse

Dette gjør migrering av datamodellen mulig og legger grunnlag for senere funksjoner som QR-koder.

---

## B-016 – Leveransemodell for kode

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Første kodeleveranse skal være en komplett ZIP.

Ved senere endringer laster brukeren opp ZIP med gjeldende kode. Denne regnes som autoritativ kilde. Ny leveranse skal da være en ZIP som bare inneholder endrede eller nye filer, med korrekt katalogstruktur.

Leveranser nummereres sekvensielt, eksempelvis `0001`, `0002`, `0003`.

### Begrunnelse

Dette reduserer risikoen for å gjeninnføre gammel eller eksperimentell kode fra tidligere samtaler.


---

## B-017 – Fire hovedområder i navigasjonen

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Første versjon organiseres rundt Tekstiler, Finn til prosjekt, Nytt tekstil og Innstillinger. Stoffbiblioteket er primær startflate.

### Begrunnelse

Dette dekker de viktigste arbeidsmåtene uten å gjøre navigasjonen omfattende.

---

## B-018 – Stoffbiblioteket bruker store visuelle kort

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Standardvisningen bruker relativt store kort med hovedbilde, navn, materialinformasjon og tilgjengelig størrelse.

### Begrunnelse

Brukeren skal kunne kjenne igjen og bla i tekstiler visuelt. Stoffbildene prioriteres over maksimal informasjonstetthet.

---

## B-019 – Hurtigregistrering før fullstendig registrering

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Registrering starter med bilde, navn, første stoffstykke og sentrale klassifiseringsfelt. Øvrige detaljer ligger under «Flere detaljer» og kan kompletteres senere.

### Begrunnelse

Registrering ved stofflageret skal være rask nok til at datakvalitet ikke oppnås på bekostning av faktisk bruk.

---

## B-020 – Prosjektsøk bruker absolutte krav og forklarbare treff

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

«Finn stoff til prosjekt» filtrerer på konkrete kriterier som nødvendig lengde, bredde, materiale, vekt og elastisitet. Resultater skal vise hvorfor stoffet passer.

### Begrunnelse

Første versjon skal være forutsigbar og forståelig fremfor å bruke en uklar anbefalingsalgoritme.

---

## B-021 – Første implementering angriper lagringsrisiko tidlig

**Dato:** 2026-09-13  
**Status:** Gjennomført – førte til B-022 og B-023

### Beslutning

Valg/oppretting av lokal/iCloud-datakatalog og sikker lesing/skriving av `tekstiler.json` implementeres før omfattende UI-funksjonalitet.

### Begrunnelse

Filtilgang fra PWA/nettleser på de aktuelle Apple-enhetene er den viktigste tekniske usikkerheten og bør valideres tidlig.

---

## B-022 – Direkte iCloud-katalog kan ikke være eneste lagringsmekanisme i Safari

**Dato:** 2026-09-13  
**Status:** Bekreftet teknisk begrensning – produksjonsstrategi erstattet av B-023

### Funn

Safari 26.6 på macOS og iOS/iPadOS støtter ikke `showDirectoryPicker()` fra File System Access API. En ren webapp kan derfor ikke få permanent direkte tilgang til en vilkårlig bruker-valgt iCloud Drive-katalog på samme måte som støttede desktop Chromium-nettlesere.

Safari støtter Origin Private File System (OPFS), men dette lageret er privat for nettstedet og er ikke en vanlig synlig mappe i iCloud Drive.

### Konsekvens

Kodeleveranse 0001 implementerer et abstrahert lagringslag med:

- direkte katalogmodus når nettleseren støtter dette
- OPFS som Safari/iOS-prototype
- eksplisitt eksport/import av `tekstiler.json` fra OPFS-modus

Endelig beslutning om produksjonslagring tas etter testing på de faktiske Apple-enhetene.


---

## B-023 – CloudKit blir primær produksjonslagring

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

Tekstilig bruker CloudKit som primær produksjonslagring. Første implementering bruker brukerens private CloudKit database. iCloud Drive/`tekstiler.json` er ikke lenger primær produksjonsdatabase.

### Begrunnelse

Safari/iOS gir ikke PWA-en den permanente katalogtilgangen som den opprinnelige iCloud Drive-modellen krevde. CloudKit gir i stedet en Apple-native dataplattform som fungerer på tvers av web og native Apple-klienter, med private brukerdata, strukturert database og støtte for assets.

### Konsekvens

`tekstiler.json` går fra produksjonsdatabase til eksport-/backupformat. CloudKit-schemaet blir en sentral del av løsningen.

---

## B-024 – CloudKit-schemaet skal være klientuavhengig

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

CloudKit-container, record-typer, felter og relasjoner skal utformes slik at samme backend kan brukes av både CloudKit JS/PWA og native CloudKit/SwiftUI.

### Begrunnelse

Dette gjør PWA-PoC-en verdifull selv om sluttproduktet senere flyttes til SwiftUI. Backend, schema, data og assets kan gjenbrukes.

---

## B-025 – CloudKit-records fremfor én stor JSON-record

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

Produksjonsdata modelleres som separate CloudKit records, foreløpig med `Textile`, `Piece` og `TextileImage` som kjerne. Bilder lagres som Assets.

### Begrunnelse

Dette gir bedre oppdatering, søk, synkronisering og senere native gjenbruk enn å lagre hele samlingen som én JSON-fil eller én record.

---

## B-026 – Lokal cache beholdes

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

CloudKit er autoritativ datakilde, men klientene skal bruke lokal cache der dette gir raskere oppstart, offline-egenskaper og bedre brukeropplevelse.

### Konsekvens

PWA-en kan bruke IndexedDB/OPFS. En eventuell SwiftUI-app velger en native cache-/persistensmekanisme. Cacheformatet er ikke autoritativt.

---

## B-027 – Eksport/import beholdes som portabilitetskrav

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

Selv om CloudKit er primærlager, skal Tekstilig kunne eksportere data og bilder til et lesbart backupformat basert på JSON + bildefiler, og senere kunne importere dette igjen.

### Begrunnelse

Brukerens data skal ikke være låst til CloudKit eller én klientimplementasjon.

---

## B-028 – Neste PoC validerer CloudKit, ikke UI

**Dato:** 2026-09-14  
**Status:** Besluttet

### Beslutning

Neste tekniske PoC skal bruke CloudKit JS og validere:

1. iCloud-autentisering
2. oppretting av `Textile`
3. lesing/endring av `Textile`
4. `Piece`-relasjon
5. opplasting og lesing av bilde/Asset
6. tilgang til samme data fra flere Apple-enheter

UI-et holdes bevisst enkelt i denne fasen.

### Begrunnelse

Dette validerer den delen av løsningen som også gjenbrukes dersom Tekstilig senere blir en SwiftUI-app.

---

## B-029 – Native SwiftUI blir neste klientspor

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

CloudKit JS/PWA-PoC-en avsluttes som teknisk validering. Videre klientutvikling flyttes til SwiftUI med native CloudKit.

### Validerte resultater fra PoC-en

Følgende fungerte mot brukerens private CloudKit-database i Development:

- CloudKit JS-konfigurasjon og iCloud-autentisering
- oppretting, lesing og endring av `Textile`
- oppretting av `Piece`
- valg av bildefil i webklienten

Følgende ble ikke validert som fungerende:

- opplasting av `TextileImage.imageAsset` fra PWA-en
- lesing av samme Asset tilbake
- kryssenhetstest av lagret bilde

Ved Asset-opplasting gikk forespørselen til Apples `cws.icloud-content.com/.../singleFileUpload`, men både Safari og Chrome stoppet flyten med CORS/preflight-feil (`PreflightMissingAllowOriginHeader`). Feilen besto også ved en kontrolltest der Development-tokenet midlertidig ble satt til `Any Domain`. Tokenet skal stå tilbake på `Only the following domain(s): https://longfjeld.github.io`.

### Begrunnelse

Bilder er en kjernefunksjon i Tekstilig. PoC-en har validert at CloudKit-containeren, privat database og den strukturerte record-modellen fungerer, men websporet har ikke gitt en robust Asset-flyt i testmiljøet. Det er derfor mer hensiktsmessig å validere samme backend med native `CKAsset` enn å bruke mer tid på PWA-spesifikk Asset-feilsøking.

### Konsekvens

- CloudKit beholdes som planlagt primærlager.
- Eksisterende Development-container og schema beholdes.
- `Textile`, `Piece` og `TextileImage` beholdes som utgangspunkt og gjennomgås før Production.
- PWA-koden beholdes som PoC/referanse, men er ikke lenger aktivt implementeringsspor.
- Neste tekniske milepæl er en minimal SwiftUI/CloudKit-PoC som først validerer eksisterende records og deretter `CKAsset`.
- Production deployes fortsatt ikke.

---

## B-030 – Native PoC valideres i små, sekvensielle trinn

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

Første native SwiftUI-kode skal ikke implementere produkt-UI eller full datamodell. CloudKit valideres i små trinn med en synlig diagnostikkflate:

1. container og iCloud account status
2. privat database
3. minimal `Textile`
4. lesing av samme record tilbake
5. deretter `TextileImage` + `CKAsset`
6. deretter kryssenhetstest

En fast Development-record med Record Name `swiftui-poc-textile-v1` brukes i første test for å unngå at gjentatte testkjøringer oppretter unødvendige records.

### Begrunnelse

Dette isolerer feil, gjør testen lett å kontrollere for en ny Xcode/SwiftUI-bruker og holder teknisk backendvalidering adskilt fra senere produktdesign og funksjonsutvikling.

---

## B-031 – DESIGN.md er autoritativ kilde for visuell design

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

`docs/DESIGN.md` er samlet autoritativ kilde for overordnede visuelle design- og typografiprinsipper. `UX-FLYTER.md` beholdes som kilde for brukerflyter, navigasjon og informasjonsstruktur.

### Begrunnelse

Dette reduserer risikoen for at visuelle beslutninger blir spredt og motstridende på tvers av dokumentasjonen når SwiftUI-klienten utvikles videre.

---

## B-032 – PWA-sporet fryses; videre klientutvikling skjer i SwiftUI

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

Videre klientutvikling i Tekstilig skjer i SwiftUI med native CloudKit. Den eksisterende PWA-koden fryses på dagens PoC-nivå og endres ikke som del av videre funksjonsutvikling.

PWA-filene beholdes foreløpig i repositoryet som historisk teknisk referanse for CloudKit JS, tidligere testresultater og sammenligning av schema/dataflyt.

### Begrunnelse

Native steg 6 har validert reell CloudKit-tilgang fra SwiftUI på fysisk Apple-enhet. Den viktigste gjenværende tekniske usikkerheten er native `CKAsset`, som kan testes direkte uten websporets CORS-begrensninger. Å opprettholde to aktive klientimplementasjoner samtidig vil gi unødvendig dobbeltarbeid i denne fasen.

### Konsekvens

- Nye funksjoner implementeres i SwiftUI.
- PWA-kode endres ikke uten en ny eksplisitt beslutning.
- CloudKit-container, Development-schema, datamodell og relevante PoC-data gjenbrukes.
- Dokumentasjon skal omtale SwiftUI som aktiv klient og PWA som frosset PoC/referanse.


---

## B-033 – Kryssenhetstest utsettes; Piece-validering fortsetter

**Dato:** 2026-09-26  
**Status:** Erstattet av B-034

### Beslutning

Punkt 8, lesing på en annen fysisk Apple-enhet med samme iCloud-konto, beholdes som et krav før den tekniske CloudKit-PoC-en formelt avsluttes. Testen utsettes fordi en annen fysisk Apple-enhet ikke er tilgjengelig nå.

Dette skal ikke blokkere punkt 9. `Piece` valideres videre native på den allerede fungerende fysiske testenheten.

### Begrunnelse

Kryssenhetstesten validerer en annen egenskap enn `Piece`: at samme private CloudKit-data kan leses fra en separat klientinstans/enhet. `Piece`-testen validerer record-type, feltmapping, relasjon til `Textile` og oppdatering av reservasjon. Testene er derfor teknisk uavhengige og kan utføres i motsatt rekkefølge.

### Konsekvens

- Denne beslutningen beskrev mellomstatusen før simulator-testen ble gjennomført.
- B-034 erstatter kravet om en ny fysisk enhet etter vellykket separat simulatorvalidering.
- Production deployes fortsatt ikke.
- PWA-koden forblir frosset.

---

## B-034 – Separat iOS-simulator godtas som kryssklientvalidering

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

Punkt 8 regnes som fullført etter at en separat iOS-simulator i Xcode 27 ble logget inn på samme iCloud-konto og kunne gjennomføre native CloudKit-testene mot data i den private Development-databasen.

En ny fysisk Apple-enhet er ikke et krav for å lukke den tekniske PoC-en.

### Begrunnelse

Testformålet var å validere at data ikke var bundet til den opprinnelige appinstallasjonen, men kunne nås fra en separat Apple-klientinstans gjennom samme private iCloud-database. Simulatoren ga en separat installasjon og klientkontekst og validerte denne egenskapen.

---

## B-035 – Produktkoden skilles fra CloudKit-diagnostikken med repository-lag

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

Videre produktkode skal ikke bruke diagnostikkmodellene som applikasjonsarkitektur. Domenemodeller, repository-grensesnitt, CloudKit-implementasjon og feature-UI skilles i egne lag.

Diagnostikken beholdes midlertidig i en egen Debug-flate.

### Begrunnelse

PoC-koden er laget for isolert teknisk validering. Et repository-lag gjør CloudKit-mapping eksplisitt, reduserer koblingen mellom SwiftUI og lagringsmekanismen og gir et bedre grunnlag for senere cache, testing og eventuell synkroniseringslogikk.

---

## B-036 – Første produktimplementering er et smalt Textile-vertikalsnitt

**Dato:** 2026-09-26  
**Status:** Besluttet

### Beslutning

Første reelle appflyt implementerer bibliotek → detalj → opprett/rediger for `Textile`, men lagrer foreløpig bare den allerede validerte kjernen: navn, kategori, permanente ID-er og metadata.

Den logiske datamodellen i `DATAMODELL.md` beholdes uendret og utvides i produktkoden trinnvis. `Piece` er neste planlagte vertikalsnitt etter at denne grunnflyten er validert.

### Begrunnelse

Dette gir tidlig validering av faktisk apparkitektur, navigasjon og CloudKit CRUD uten samtidig å introdusere mange nye schemafelt. Feil blir enklere å isolere, og den eksisterende PoC-valideringen utnyttes direkte.


---

## B-037 – CloudKit recordName brukes som UI-/storage-identitet for lagrede Textile-records

**Dato:** 2026-09-27  
**Status:** Besluttet

### Beslutning

`textileId` forblir permanent logisk Tekstilig-ID. For lagrede `Textile`-objekter bruker SwiftUI-klienten CloudKit `recordName` som teknisk identitet ved listevisning og navigasjon. Ulagrede drafts faller tilbake til `textileId`.

### Begrunnelse

PWA-PoC-en kunne opprette flere separate CloudKit-records med standardverdien `textileId = T0001`. Første native produktversjon brukte `textileId` som `Identifiable.id` og detaljoppslagsnøkkel. Legacy-records med samme `textileId` ga dermed dupliserte SwiftUI-identiteter og kunne føre flere rader til samme detaljrecord.

CloudKit `recordName` er unikt innen record-zonen og er derfor riktig teknisk nøkkel for en allerede lagret record. Dette endrer ikke kravet om at nye `textileId` skal være stabile og unike.


## B-038 – Piece implementeres som eget vertikalsnitt uten schemautvidelse

**Dato:** 2026-09-27  
**Status:** Besluttet

### Beslutning

Etter validert Textile-produktflyt implementeres `Piece` som neste ordinære SwiftUI-funksjon gjennom eget domenelag, repository og feature-tilstand. Første produktversjon bruker bare de Piece-feltene som allerede finnes og er validert i CloudKit Development: `pieceId`, `textileId`, `lengthCm`, `widthCm`, `reservedLengthCm` og `project`.

`quantity`, notat og rikere reservasjonsdata fra den langsiktige logiske datamodellen innføres ikke i samme leveranse.

### Begrunnelse

Dette holder schemaendringer adskilt fra overgangen fra diagnostikk til faktisk produktkode. Relasjon, CRUD og reservasjon kan dermed valideres med kjent backend før datamodellen utvides videre.

### Konsekvens

- `Piece.textileId` indekseres som `QUERYABLE` i Development fordi produktkoden henter stoffstykker per tekstil.
- Nye Piece-records får permanent `pieceId` i formatet `P-<UUID>`.
- Lagrede Piece-records bruker CloudKit `recordName` som teknisk SwiftUI-/storage-identitet.
- Sletting krever eksplisitt bekreftelse i UI.
