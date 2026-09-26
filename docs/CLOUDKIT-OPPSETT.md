# CloudKit – tilganger og forhåndsoppsett

**Status:** Forberedelse til CloudKit PoC  
**Dato:** 2026-09-14

Dette dokumentet er arbeidsveiledningen for å klargjøre Tekstilig for en CloudKit-PoC fra GitHub Pages/PWA, med mulighet for senere gjenbruk i en SwiftUI-app.

## Slik skal dokumentet brukes

Arbeidsdelen skal følges **strengt sekvensielt fra punkt 1 og videre**. Et punkt skal være ferdig før neste punkt påbegynnes. Ingen handling i et tidligere punkt forutsetter at et senere punkt allerede er utført.

Statusmarkeringene er:

- **✅ AKSJON – DU:** Utført og kontrollert.
- **❗️ AKSJON – DU:** Gjenstår helt eller delvis.
- **INFORMASJON:** Forklaring eller prosjektregel. Ingen handling kreves nå.
- **SENERE – PROSJEKT:** Gjennomføres sammen med PoC-en eller i en senere fase.

Du kan selv endre `❗️` til `✅` etter hvert som punktene blir ferdige.

## Fremdrift akkurat nå

Følgende er allerede bekreftet:

- ✅ Apple Developer-tilgang fungerer.
- ✅ Permanent Bundle ID er valgt: `com.longfjeld.tekstilig`.
- ✅ Permanent iCloud container ID er valgt og opprettet: `iCloud.com.longfjeld.tekstilig`.
- ✅ App ID for Tekstilig er opprettet med iCloud/CloudKit.
- ✅ iCloud-containeren er koblet til Tekstilig.
- ✅ Containeren er synlig i CloudKit Database.
- ✅ CloudKit-miljøet er kontrollert til `Development`.
- ✅ GitHub Pages-adresse er fastsatt og HTTPS er kontrollert.
- ✅ Development API-token er opprettet etter at Pages-origin ble fastsatt.
- ✅ Allowed Origin er satt på Development-tokenet.
- ✅ Forhåndsoppsettet er komplett.
- ❗️ CloudKit-PoC-en må nå publiseres og testes sekvensielt.

---

# Arbeidsveiledning

## 1. Apple-konto og Developer-tilgang

**✅ AKSJON – DU**

Følgende skal være på plass:

- Apple Account med tofaktorautentisering.
- Aktiv tilgang til Apple Developer.
- Tilgang til **Certificates, Identifiers & Profiles**.
- Tilstrekkelig rolle til å opprette og administrere iCloud-containeren.

Dette er i praksis bekreftet fordi Tekstilig sin App ID og iCloud-container allerede er opprettet.

**Resultat:** Punkt 1 er ferdig.

---

## 2. Fastsett permanente identifikatorer

**✅ AKSJON – DU**

Tekstilig bruker:

```text
Appnavn:       Tekstilig
Bundle ID:     com.longfjeld.tekstilig
iCloud ID:     iCloud.com.longfjeld.tekstilig
GitHub repo:   Longfjeld/Tekstilig
Custom domain: Ingen foreløpig
```

Bundle ID og iCloud container ID bør behandles som permanente.

GitHub Pages-adressen kontrolleres senere i punkt 7, etter at GitHub Pages er aktivert.

**Resultat:** Punkt 2 er ferdig.

---

## 3. Opprett App ID og aktiver CloudKit

**✅ AKSJON – DU**

I Apple Developer → **Certificates, Identifiers & Profiles → Identifiers** er følgende opprettet:

```text
Description:        Tekstilig
App ID Prefix:      Team ID
Bundle ID type:     Explicit
Bundle ID:          com.longfjeld.tekstilig
```

Under **Capabilities** er:

- iCloud aktivert.
- CloudKit support aktivert.

**Resultat:** Punkt 3 er ferdig.

---

## 4. Opprett iCloud-container

**✅ AKSJON – DU**

I Apple Developer → **Certificates, Identifiers & Profiles → Identifiers**:

1. Velg `iCloud Containers`.
2. Opprett containeren:

```text
iCloud.com.longfjeld.tekstilig
```

Containeren er allerede opprettet.

**Resultat:** Punkt 4 er ferdig.

---

## 5. Knytt iCloud-containeren til App ID-en

**✅ AKSJON – DU**

Når både App ID og iCloud-container eksisterer:

1. Åpne App ID-en `com.longfjeld.tekstilig`.
2. Kontroller at iCloud/CloudKit er aktivert.
3. Knytt containeren:

```text
iCloud.com.longfjeld.tekstilig
```

4. Lagre endringen.

Dette er allerede utført for Tekstilig.

**Resultat:** Punkt 5 er ferdig.

---

## 6. Kontroller container og Development-miljø i CloudKit Database

**✅ AKSJON – DU**

1. Åpne:

```text
https://icloud.developer.apple.com/
```

2. Velg **CloudKit Database**.
3. Kontroller at containeren er:

```text
iCloud.com.longfjeld.tekstilig
```

4. Kontroller at miljøet er:

```text
Development
```

Begge deler er kontrollert i CloudKit Database.

Ikke opprett schema, record types, indekser eller Production-oppsett nå.

**Resultat:** Punkt 6 er ferdig.

---

## 7. Klargjør GitHub Pages og fastsett web-origin

**✅ AKSJON – DU**

Dette punktet skal fullføres **før** API-tokenet opprettes, fordi vi trenger den faktiske Pages-origin-en som `Allowed Origin`.

### 7.1 Kontroller repository

Repositoryet skal være:

```text
Longfjeld/Tekstilig
```

Tekstilig-koden kan ligge offentlig på GitHub. CloudKit-brukerdata skal ikke ligge i repositoryet.

### 7.2 Aktiver GitHub Pages

I GitHub-repositoryet:

1. Åpne **Settings**.
2. Åpne **Pages**.
3. Velg publiseringskilde for Pages.
4. Publiser appen.
5. Vent til GitHub viser at siden er tilgjengelig.

Forventet adresse er eksempelvis:

```text
https://longfjeld.github.io/Tekstilig/
```

Bruk den faktiske adressen GitHub viser dersom store/små bokstaver eller repository-navn avviker.

### 7.3 Kontroller HTTPS

Åpne Pages-adressen i nettleseren og kontroller at den bruker:

```text
https://
```

Aktiver **Enforce HTTPS** i GitHub Pages dersom valget er tilgjengelig og ikke allerede er aktivert.

### 7.4 Fastsett origin

For en Pages-adresse som:

```text
https://longfjeld.github.io/Tekstilig/
```

er origin:

```text
https://longfjeld.github.io
```

Path-delen `/Tekstilig/` er ikke en del av origin.

### 7.5 Noter verdiene

Fyll inn:

```text
GitHub repository:  Longfjeld/Tekstilig
Pages URL:           https://longfjeld.github.io/Tekstilig/
Allowed Origin:      https://longfjeld.github.io
HTTPS kontrollert:   Ja
```

**Stopp ved slutten av punkt 7 dersom disse verdiene ikke er klare. Ikke gå videre til punkt 8 før de er bekreftet.**

---

## 8. Opprett Development API-token

**✅ AKSJON – DU**

Punkt 7 skal være ferdig før dette punktet utføres.

1. Åpne CloudKit Database.
2. Kontroller igjen:

```text
Container:    iCloud.com.longfjeld.tekstilig
Environment:  Development
```

3. Gå til **Settings → Tokens & Keys**.
4. Opprett et nytt web/API-token for Development.
5. Gi tokenet et tydelig navn, for eksempel:

```text
Tekstilig PWA Development
```

6. Sett `Allowed Origin` til verdien som ble bekreftet i punkt 7.
7. Lagre tokenet.
8. Noter tokenverdien slik at den kan brukes i PoC-konfigurasjonen.

Ikke opprett Production-token nå.

> Web-API-tokenet brukes av klientkoden og er ikke det samme som en hemmelig servernøkkel. Server-to-server private keys eller andre private nøkler skal aldri legges i GitHub Pages-koden.

Når tokenet er opprettet og origin er satt korrekt, endres dette punktet til `✅`.

---

## 9. Kontroller at forhåndsoppsettet er komplett

**✅ AKSJON – DU**

Dette punktet utføres først når punkt 8 er ferdig.

Kontroller følgende:

- [x] Apple Developer-tilgang fungerer.
- [x] Bundle ID er `com.longfjeld.tekstilig`.
- [x] iCloud container ID er `iCloud.com.longfjeld.tekstilig`.
- [x] iCloud/CloudKit er aktivert for App ID-en.
- [x] Containeren er koblet til App ID-en.
- [x] Containeren er synlig i CloudKit Database.
- [x] `Development` er valgt.
- [x] GitHub Pages er publisert.
- [x] GitHub Pages bruker HTTPS.
- [x] Eksakt Pages URL er notert.
- [x] Eksakt Allowed Origin er notert.
- [x] Development API-token er opprettet.
- [x] Allowed Origin er lagt inn på Development-tokenet.

Når alle punktene er avkrysset, er ditt forhåndsoppsett ferdig.

Gi deretter følgende tre verdier til PoC-arbeidet:

```text
Container ID:  iCloud.com.longfjeld.tekstilig
Pages URL:     https://longfjeld.github.io/Tekstilig/
API token:     f2bf857c5160f4dc3c08917c06ab9b678d5a4582f45dcbc7140d0f9d015c2853
```

**Ikke gå videre med manuelt Production-oppsett. Neste steg er å publisere og teste CloudKit-PoC-en etter `CLOUDKIT-POC-TEST.md`.**

---

# Informasjon om det som skjer etter forhåndsoppsettet

Delene nedenfor er ikke aksjonspunkter du skal utføre nå.

## 10. Første CloudKit-schema

**SENERE – PROSJEKT**

PoC-en skal bruke et minimalt schema som kan utvides senere.

### `Textile`

Foreløpige felt:

```text
textileId        String
name             String
category         String
createdAt        Date/Time
updatedAt        Date/Time
schemaVersion    Int(64)
```

### `Piece`

```text
pieceId          String
textileId        String eller Reference
lengthCm         Int(64)
widthCm          Int(64)
reservedLengthCm Int(64), valgfri
project          String, valgfri
```

### `TextileImage`

```text
imageId          String
textileId        String eller Reference
type             String
primary          Int(64)/Boolean-mapping
imageAsset       Asset
```

Eksakt bruk av `Reference`, parent-relasjoner og eventuelle custom record zones bestemmes før PoC-schemaet låses. Dette er viktig dersom fremtidig deling via `CKShare` skal holdes åpen.

---

## 11. Indekser

**SENERE – PROSJEKT**

CloudKit-felter som brukes i server-side queries må planlegges og indekseres.

Aktuelle felt senere er blant annet:

- `textileId`
- `name`
- `category`
- relasjonsfelt
- `updatedAt`

Komplekse kombinerte brukerfiltre kan fortsatt utføres lokalt mot cache.

Vi skal ikke opprette produksjonsindekser nå.

---

## 12. CloudKit JS i PWA-en

**SENERE – PROSJEKT**

PoC-en skal bruke CloudKit JS mot den samme CloudKit-containeren som senere kan brukes av en native app.

Apple leverer CloudKit JS fra sin CDN, blant annet via:

```html
<script src="https://cdn.apple-cloudkit.com/ck/2/CloudKit.js"></script>
```

Konfigurasjonen trenger i hovedsak:

- container identifier
- Development API-token
- environment `development`
- autentisering av iCloud-bruker for privat database

Autentiseringsflyten implementeres i PoC-koden.

---

## 13. Akseptansekriterier for CloudKit-PoC

**SENERE – PROSJEKT**

Når punkt 1–9 er ferdige, skal PoC-en bygges for å validere:

1. lasting av CloudKit JS
2. konfigurasjon av `iCloud.com.longfjeld.tekstilig` i Development
3. innlogging med iCloud
4. aktiv CloudKit-bruker/session
5. opprettelse av én `Textile`
6. lesing av samme record
7. endring av record
8. opprettelse av ett `Piece`
9. fotografering/valg av bilde og lagring som Asset
10. lesing av record og bilde på en annen Apple-enhet
11. forståelig visning/logging av relevante feil

Dette er godkjenningskriteriet før resten av Tekstilig-grensesnittet kobles på CloudKit.

---

## 14. Development og Production

**INFORMASJON**

CloudKit har separate miljøer.

### Development

Brukes under PoC og schemautvikling. Her kan schemaet utvikles og testdata håndteres uten å låse tidlige valg til produksjon.

### Production

Brukes først når schemaet er gjennomgått og PoC-en fungerer.

Vi skal ikke deploye Tekstilig-schema til Production før:

- record-typene er gjennomgått
- navn og datatyper er gjennomgått
- nødvendige query-indekser er bestemt
- PoC-en fungerer i Development

---

## 15. Mulig overgang til SwiftUI

**INFORMASJON**

CloudKit-PoC-en er ikke en blindvei dersom Tekstilig senere bygges som SwiftUI-app.

En native app kan kobles til den samme CloudKit-containeren:

```text
iCloud.com.longfjeld.tekstilig
```

Følgende kan gjenbrukes:

- CloudKit-data
- schema
- record-typer
- assets
- indekser
- Tekstilig-ID-er
- logisk datamodell

SwiftUI/native CloudKit vil bruke blant annet `CKContainer`, `CKDatabase`, `CKRecord` og `CKAsset` i stedet for CloudKit JS.

Web-spesifikke deler som HTML/CSS, service worker og CloudKit-JS-autentiseringskode gjenbrukes ikke direkte.

---

## 16. Dette skal ikke gjøres før PoC-en

**INFORMASJON**

Før punkt 1–9 er ferdige og PoC-arbeidet starter:

- Ikke deploy schema til Production.
- Ikke opprett Production API-token.
- Ikke opprett hele `Textile`, `Piece` og `TextileImage`-schemaet manuelt.
- Ikke bygg CloudKit JS-kode manuelt.
- Ikke opprett SwiftUI-prosjektet dersom vi først skal gjennomføre CloudKit/PWA-PoC-en.

---

## 17. Verktøy for senere SwiftUI-arbeid

**INFORMASJON**

På Mac bør følgende være tilgjengelig når vi eventuelt går videre til SwiftUI:

- siste stabile Xcode
- Git
- Safari
- Apple Developer-tilgang
- CloudKit Database-tilgang
- GitHub-tilgang

Xcode er ikke nødvendig for å fullføre punkt 1–9 i denne CloudKit/PWA-forberedelsen.

---

## 18. Offisielle kilder

- Apple Developer Program enrollment: https://developer.apple.com/help/account/membership/program-enrollment
- Apple Developer Program membership/CloudKit: https://developer.apple.com/programs/whats-included/
- Apple: Create an iCloud container: https://developer.apple.com/help/account/identifiers/create-an-icloud-container
- Apple: Enable app capabilities/iCloud: https://developer.apple.com/help/account/identifiers/enable-app-capabilities
- Apple: CloudKit JS: https://developer.apple.com/documentation/cloudkitjs
- Apple: CloudKit JS configuration: https://developer.apple.com/documentation/cloudkitjs/cloudkit
- Apple: CloudKit JS authentication: https://developer.apple.com/documentation/cloudkitjs/cloudkit.container/setupauth
- GitHub Pages HTTPS: https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https
