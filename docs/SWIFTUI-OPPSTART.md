# SwiftUI + CloudKit – sekvensiell oppstart

**Status:** Punkt 1–5 fullført · punkt 6 klar til test  
**Miljø:** Development

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

## 7. Valider CKAsset

**⏭️ SENERE I NATIVE PoC**

Etter at native record-tilgang fungerer:

1. velg eller ta et lite testbilde
2. skriv bildet til en midlertidig lokal fil
3. opprett `CKAsset(fileURL:)`
4. lagre en `TextileImage` i privat database
5. hent recorden tilbake
6. les Asset-filen og vis bildet

Dette er den viktigste testen som PWA-PoC-en ikke fullførte.

## 8. Test på en annen Apple-enhet

**⏭️ SENERE I NATIVE PoC**

Etter at punkt 7 fungerer:

1. installer/kjør samme Development-app på en annen Apple-enhet
2. bruk samme iCloud-konto
3. hent samme `Textile` og `TextileImage`
4. kontroller at både metadata og bilde er tilgjengelige

## 9. Stoppunkt før videre apputvikling

**⏭️ SENERE**

Full UI-/funksjonsutvikling starter først når følgende er validert i native klient:

- privat CloudKit-database
- `Textile`
- `Piece`
- `TextileImage`
- `CKAsset`
- lesing på en annen Apple-enhet

Production skal fortsatt ikke deployes på dette tidspunktet.
