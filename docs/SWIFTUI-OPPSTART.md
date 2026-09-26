# SwiftUI + CloudKit – sekvensiell oppstart

**Status:** Punkt 1–7 fullført · punkt 8 utsatt · punkt 9 klar til test  
**Miljø:** Development · Xcode 27 · iOS/iPadOS 27

Denne veiledningen skal følges strengt i nummerrekkefølge. Innenfor hvert punkt kommer handlingen først, deretter kontrollen, og til slutt eventuell stopp-/fortsett-beslutning.

Statusmarkeringer:

- ❗️ gjenstår
- ✅ utført
- ⏭️ senere

## 1. Sett CloudKit web-tokenet tilbake til begrenset origin

**✅ AKSJON – DU**

1. Åpne CloudKit Database.
2. Gå til **Settings → Tokens & Keys**.
3. Åpne Development-tokenet som ble brukt av PWA-en.
4. Velg **Only the following domain(s)**.
5. Sett domenet til:

```text
https://longfjeld.github.io
```

6. Lagre.
7. Kontroller at tokenet ikke lenger står på `Any Domain`.

**Ikke gå videre før punkt 1 er bekreftet.**

## 2. Kontroller Xcode

**✅ AKSJON – DU**

1. Åpne Xcode på Mac-en.
2. Velg **Xcode → Settings → Accounts**.
3. Kontroller at Apple-kontoen som har tilgang til Tekstilig-containeren er lagt til.
4. Kontroller at riktig Developer Team er tilgjengelig.

**Ikke opprett prosjektet før konto og Team er synlige i Xcode.**

## 3. Opprett et minimalt SwiftUI-prosjekt

**✅ AKSJON – DU**

1. Velg **File → New → Project**.
2. Velg en vanlig **App** under iOS.
3. Sett Product Name til:

```text
Tekstilig
```

4. Velg SwiftUI som grensesnitt og Swift som språk dersom Xcode viser disse valgene.
5. Velg riktig Team.
6. Sett Organization Identifier slik at prosjektets Bundle Identifier blir:

```text
com.longfjeld.tekstilig
```

7. Lagre prosjektet i en egen prosjektmappe.
8. Åpne target-innstillingene og kontroller at Bundle Identifier faktisk er `com.longfjeld.tekstilig`.

**Ikke gå videre hvis Xcode har generert en annen Bundle Identifier.**

## 4. Aktiver iCloud og CloudKit i Xcode

**✅ AKSJON – DU**

1. Velg Tekstilig-targetet.
2. Åpne **Signing & Capabilities**.
3. Legg til **iCloud** capability.
4. Aktiver **CloudKit**.
5. Velg den eksisterende containeren:

```text
iCloud.com.longfjeld.tekstilig
```

6. Kontroller at Xcode viser den eksisterende containeren på targetet.

**Ikke opprett en ny iCloud-container.**

## 5. Kjør tom app på én testenhet

**✅ AKSJON – DU**

1. Velg en fysisk iPhone/iPad som er logget inn på iCloud, eller en egnet simulator med iCloud-oppsett.
2. Bygg og kjør appen.
3. Kontroller at appen starter uten signing-/entitlement-feil.

**Ikke legg til CloudKit-kode før den tomme appen kjører korrekt.**

## 6. Kjør minimal CloudKit-diagnostikk

**✅ AKSJON – DU**

Kodeleveransen for dette punktet ligger nå i Xcode-prosjektet. Testen gjør bare det som trengs for å validere native CloudKit før vi går videre til bilder.

### 6.1 Åpne oppdatert prosjekt

1. Pakk ut den nye leveransen.
2. Åpne `Tekstilig.xcodeproj` i Xcode.
3. Kontroller i Project navigator at gruppen **Tekstilig** inneholder:

```text
TekstiligApp.swift
ContentView.swift
CloudKitDiagnosticModel.swift
Tekstilig.entitlements
Assets.xcassets
```

4. Velg Tekstilig-targetet.
5. Åpne **Signing & Capabilities**.
6. Kontroller at **iCloud → CloudKit** fortsatt er aktivert.
7. Kontroller at containeren fortsatt er:

```text
iCloud.com.longfjeld.tekstilig
```

**Ikke kjør testen dersom containeren mangler eller en annen container er valgt.**

### 6.2 Bygg og start appen

1. Velg samme fysiske testenhet som fungerte i punkt 5.
2. Velg **Product → Run** eller trykk Run-knappen.
3. Vent til Tekstilig åpnes på enheten.
4. Kontroller at skjermen viser seksjonen **CloudKit** og knappen **Kjør CloudKit-diagnostikk**.

Hvis appen ikke bygger eller starter, stopp her og noter hele feilmeldingen fra Xcode.

### 6.3 Kjør testen

1. Trykk **Kjør CloudKit-diagnostikk**.
2. Testen skal utføre følgende i denne rekkefølgen:
   1. åpne `CKContainer(identifier: "iCloud.com.longfjeld.tekstilig")`
   2. hente iCloud account status
   3. velge brukerens private database
   4. lete etter testrecorden `swiftui-poc-textile-v1`
   5. opprette en minimal `Textile` dersom den ikke allerede finnes
   6. lese samme `Textile` tilbake fra CloudKit
3. Kontroller at **iCloud** viser `Tilgjengelig`.
4. Kontroller at resultatlisten avsluttes med:

```text
Steg 6 er validert. Klar for CKAsset-testen i steg 7.
```

5. Kontroller at skjermen viser **Steg 6 er fullført**.

Testen bruker én fast record-ID. Gjentatt kjøring skal derfor lese samme testrecord i stedet for å opprette nye records.

### 6.4 Kontroller recorden i CloudKit Database

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne **Private Database**.
5. Åpne record type **Textile**.
6. Finn recorden med Record Name:

```text
swiftui-poc-textile-v1
```

7. Kontroller at den minst inneholder disse feltene:

| Felt | Forventet verdi |
|:---|:---|
| `textileId` | `T-SWIFTUI-POC-001` |
| `name` | `SwiftUI CloudKit-test` |
| `category` | `Test` |
| `schemaVersion` | `1` |
| `createdAt` | dato/tid |
| `updatedAt` | dato/tid |

**Ikke slett testrecorden ennå. Den kan brukes som referanse videre i native PoC-en.**

### 6.5 Stoppunkt

Punkt 6 er ferdig når begge disse kontrollene er bestått:

- appen viser **Steg 6 er fullført**
- `swiftui-poc-textile-v1` er synlig i privat Development-database

**Ikke gå videre til punkt 7 før begge er bekreftet.**

## 7. Valider `TextileImage` + `CKAsset`

**✅ AKSJON – DU**

Punkt 6 er fullført på fysisk Apple-enhet. Punkt 7 tester nå den ene sentrale CloudKit-funksjonen som PWA-PoC-en ikke fikk validert: opplasting og nedlasting av et faktisk bilde som `CKAsset`.

Testen bruker eksisterende Development-schema og endrer ikke PWA-koden.

### 7.1 Legg inn kodeleveranse 0004

1. Lukk Xcode dersom prosjektet er åpent.
2. Ta en vanlig Git-commit eller lokal sikkerhetskopi av den fungerende versjonen etter punkt 6.
3. Pakk ut `Tekstilig-endringer-0004.zip`.
4. Kopier innholdet fra endringspakken inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett eller erstatt andre lokale filer i overordnet mappe som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller i Project Navigator at `Tekstilig` nå inneholder:

```text
TekstiligApp.swift
ContentView.swift
CloudKitDiagnosticModel.swift
CloudKitAssetDiagnosticModel.swift
Tekstilig.entitlements
Assets.xcassets
```

9. Velg Tekstilig-targetet og åpne **Signing & Capabilities**.
10. Kontroller at **iCloud → CloudKit** fortsatt er aktivert.
11. Kontroller at containeren fortsatt er:

```text
iCloud.com.longfjeld.tekstilig
```

**Ikke kjør testen dersom containeren mangler eller en annen container er valgt.**

### 7.2 Bygg og start på fysisk iPhone/iPad

1. Koble til eller velg den samme fysiske iPhone/iPad-en som ble brukt da punkt 6 ble validert.
2. Kontroller at enheten fremdeles er logget inn på samme iCloud-konto.
3. Velg den fysiske enheten som Run Destination øverst i Xcode 27.
4. Velg **Product → Run** eller trykk Run-knappen.
5. Vent til Tekstilig åpnes på enheten.
6. Kontroller at skjermen viser:

```text
Steg 6: native CloudKit er validert
```

7. Kontroller at du ser knappen **Velg bilde fra Bilder**.

Hvis appen ikke bygger eller starter, stopp her og noter hele feilmeldingen fra Xcode før andre endringer gjøres.

### 7.3 Velg ett lite testbilde

1. Sørg for at det finnes et lite, ikke-sensitivt testbilde i Bilder-appen på enheten. Ta eventuelt et bilde med Kamera-appen først.
2. Gå tilbake til Tekstilig.
3. Trykk **Velg bilde fra Bilder**.
4. Velg ett bilde.
5. Vent til bildet vises i Tekstilig.
6. Kontroller at skjermen viser filnavn, innholdstype og størrelse.
7. Kontroller at knappen **Lagre og les CKAsset** nå er aktiv.

Denne testen bruker systemets Photos Picker. Kamera direkte i Tekstilig implementeres ikke i punkt 7.

### 7.4 Kjør CKAsset-testen

1. Trykk **Lagre og les CKAsset**.
2. La testen fullføre uten å bytte app eller koble fra enheten.
3. Kontroller at resultatlisten viser vellykkede steg 1–7 i denne rekkefølgen:
   1. iCloud-konto og privat database tilgjengelig
   2. eksisterende `swiftui-poc-textile-v1` funnet
   3. midlertidig lokal bildefil skrevet
   4. `TextileImage` og `CKAsset` lagret
   5. samme `TextileImage` lest tilbake
   6. Asset-filen lest lokalt igjen
   7. nedlastede bytes er identiske med de valgte bytesene
4. Kontroller at resultatlisten avsluttes med:

```text
Steg 7 er validert. Klar for kryssenhetstest i steg 8.
```

5. Kontroller at seksjonen **Bilde lest tilbake fra CloudKit** vises.
6. Kontroller visuelt at bildet i denne seksjonen er det samme bildet du valgte.
7. Kontroller at skjermen viser:

```text
Steg 7 er fullført
```

Testen gjenbruker én fast record:

```text
swiftui-poc-textile-image-v1
```

Gjentatte testkjøringer erstatter derfor Asset-feltet på samme Development-record i stedet for å opprette nye `TextileImage`-records.

### 7.5 Kontroller `TextileImage` i CloudKit Database

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne **Private Database**.
5. Åpne record type **TextileImage**.
6. Finn recorden med Record Name:

```text
swiftui-poc-textile-image-v1
```

7. Kontroller feltene mot tabellen:

| Felt | Forventet verdi |
|:---|:---|
| `imageId` | `IMG-SWIFTUI-POC-001` |
| `textileId` | `T-SWIFTUI-POC-001` |
| `type` | `fabric` |
| `primary` | `1` |
| `fileName` | `swiftui-asset-test.<format>` |
| `contentType` | bildets MIME-type/innholdstype |
| `imageAsset` | Asset med lagret bildefil |

8. La både `swiftui-poc-textile-v1` og `swiftui-poc-textile-image-v1` stå i Development-databasen. De brukes i neste validering.

### 7.6 Stoppunkt

Punkt 7 er ferdig først når alle disse er bekreftet:

- appen viser **Steg 7 er fullført**
- bildet som er lest tilbake vises korrekt i appen
- `swiftui-poc-textile-image-v1` finnes i privat Development-database
- `imageAsset` er lagret på recorden

**Ikke gå videre til punkt 8 før alle fire er bekreftet.**

## 8. Test på en annen Apple-enhet

**✅ UTSATT – IKKE BLOKKERENDE FOR PUNKT 9**

Punkt 8 skal fortsatt gjennomføres før den tekniske CloudKit-PoC-en avsluttes helt, men testen krever en annen fysisk Apple-enhet med samme iCloud-konto. Siden en slik enhet ikke er tilgjengelig nå, går vi videre til `Piece` først.

Når en annen fysisk enhet er tilgjengelig:

1. installer/kjør samme Development-app på den andre enheten
2. bruk samme iCloud-konto
3. hent `swiftui-poc-textile-v1`
4. hent `swiftui-poc-textile-image-v1`
5. kontroller at både metadata og bildet er tilgjengelige

**Punkt 8 skal ikke markeres fullført før testen faktisk er gjennomført på en annen fysisk enhet.**

## 9. Valider `Piece` i native klient

**✅ AKSJON – DU**

Punkt 9 validerer eksisterende `Piece`-schema med native CloudKit. Testen endrer ikke PWA-koden og utvider ikke Development-schemaet med nye felt. Den bruker feltene som allerede ble etablert i CloudKit JS-PoC-en:

| Felt | Type i testen | Testverdi |
|:---|:---|:---|
| `pieceId` | String | `P-SWIFTUI-POC-001` |
| `textileId` | String | hentes fra `swiftui-poc-textile-v1` |
| `lengthCm` | Int64 | `280` |
| `widthCm` | Int64 | `145` |
| `reservedLengthCm` | Int64 | først `0`, deretter `150` |
| `project` | String | først tom, deretter `SwiftUI testprosjekt` |

Testen bruker fast Record Name:

```text
swiftui-poc-piece-v1
```

Gjentatte testkjøringer oppdaterer derfor samme Development-record.

### 9.1 Legg inn kodeleveranse 0005

1. Lukk Xcode dersom prosjektet er åpent.
2. Ta en Git-commit eller lokal sikkerhetskopi av den fungerende versjonen etter punkt 7.
3. Pakk ut `Tekstilig-endringer-0005.zip`.
4. Kopier innholdet fra endringspakken inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett eller erstatt lokale filer i overordnet mappe som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller i Project Navigator at gruppen **Tekstilig** nå også inneholder:

```text
CloudKitPieceDiagnosticModel.swift
```

9. Velg Tekstilig-targetet og åpne **Signing & Capabilities**.
10. Kontroller at **iCloud → CloudKit** fortsatt er aktivert.
11. Kontroller at containeren fortsatt er:

```text
iCloud.com.longfjeld.tekstilig
```

**Ikke kjør testen dersom containeren mangler eller en annen container er valgt.**

### 9.2 Bygg og start på fysisk iPhone/iPad

1. Velg den samme fysiske iPhone/iPad-en som ble brukt i punkt 6 og 7.
2. Kontroller at enheten er logget inn på samme iCloud-konto som tidligere.
3. Velg den fysiske enheten som Run Destination øverst i Xcode 27.
4. Velg **Product → Build**.
5. Hvis build feiler, stopp her og noter hele feilmeldingen før andre endringer gjøres.
6. Når build er vellykket, velg **Product → Run** eller trykk Run-knappen.
7. Vent til Tekstilig åpnes på enheten.
8. Bla til seksjonen **Steg 9: valider Piece**.
9. Kontroller at knappen **Kjør Piece-test** er synlig.

### 9.3 Kjør Piece-testen

1. Trykk **Kjør Piece-test**.
2. La testen fullføre uten å bytte app eller koble fra enheten.
3. Kontroller at resultatlisten viser vellykkede steg 1–8 i denne rekkefølgen:
   1. iCloud-konto og privat database tilgjengelig
   2. eksisterende `swiftui-poc-textile-v1` funnet, og `textileId` lest
   3. eksisterende `swiftui-poc-piece-v1` funnet eller ny testrecord opprettet
   4. `Piece` lagret med dimensjoner og kobling til `Textile`
   5. `Piece` lest tilbake og basisfeltene kontrollert
   6. reservasjon lagt til på samme `Piece`
   7. oppdatert `Piece` lest tilbake med korrekt reservasjon
   8. relasjon og alle testede felt validert
4. Kontroller at resultatlisten avsluttes med:

```text
Steg 9 er validert. Native CloudKit-PoC-en har nå validert Textile, TextileImage/CKAsset og Piece.
```

5. Kontroller at seksjonen **Piece lest tilbake fra CloudKit** vises.
6. Kontroller at skjermen viser:

```text
Steg 9 er fullført
```

### 9.4 Kontroller `Piece` i CloudKit Database

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne **Private Database**.
5. Åpne record type **Piece**.
6. Finn recorden med Record Name:

```text
swiftui-poc-piece-v1
```

7. Kontroller feltene mot tabellen:

| Felt | Forventet verdi etter testen |
|:---|:---|
| `pieceId` | `P-SWIFTUI-POC-001` |
| `textileId` | `T-SWIFTUI-POC-001` |
| `lengthCm` | `280` |
| `widthCm` | `145` |
| `reservedLengthCm` | `150` |
| `project` | `SwiftUI testprosjekt` |

8. La testrecorden stå i Development-databasen inntil native PoC-en er avsluttet.

### 9.5 Stoppunkt

Punkt 9 er ferdig når alle disse er bekreftet:

- appen viser **Steg 9 er fullført**
- `swiftui-poc-piece-v1` finnes i privat Development-database
- `textileId` peker på test-Textile sin permanente ID
- dimensjonene er lest tilbake korrekt
- reservasjonen er lagret og lest tilbake korrekt

Når dette er bekreftet, er de tre sentrale record-typene validert native. Punkt 8 står fortsatt igjen som separat kryssenhetstest.

## 10. Stoppunkt før videre apputvikling

**⏭️ SENERE**

Full teknisk PoC er ferdig først når følgende er validert i native klient:

- ✅ privat CloudKit-database
- ✅ `Textile`
- ✅ `TextileImage`
- ✅ `CKAsset`
- ✅ lesing på en annen fysisk Apple-enhet (punkt 8)
- ✅ `Piece` (punkt 9, klar til test)

Når punkt 9 er fullført kan vi begynne å planlegge neste appfase, men punkt 8 skal fortsatt lukkes før CloudKit-PoC-en formelt regnes som komplett.

Production skal fortsatt ikke deployes på dette tidspunktet.
