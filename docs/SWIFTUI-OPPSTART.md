# SwiftUI + CloudKit – sekvensiell oppstart

**Status:** Neste arbeidsfase  
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

## 6. Lag minimal CloudKit-diagnostikk

**⏭️ NESTE KODELEVERANSE**

Når punkt 1–5 er bekreftet, lager vi den første native kodeleveransen. Den skal bevisst være liten og teste i denne rekkefølgen:

1. åpne `CKContainer(identifier: "iCloud.com.longfjeld.tekstilig")`
2. hente iCloud account status
3. åpne private database
4. lese/opprette en minimal `Textile`
5. lese den tilbake
6. først deretter teste bilde som `CKAsset`

Vi bygger ikke full Tekstilig-UI før disse operasjonene fungerer.

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
