# CloudKit – tilganger og forhåndsoppsett

**Status:** Forberedelse til CloudKit PoC  
**Dato:** 2026-09-14

Dette dokumentet beskriver hva som bør være på plass før Tekstilig kan bruke CloudKit fra GitHub Pages/PWA, og hvordan oppsettet bør gjøres med tanke på en mulig senere SwiftUI-app.

## Slik skal dokumentet brukes

Dette dokumentet er både **arbeidsveiledning** og **bakgrunnsdokumentasjon**. Du skal ikke utføre alle kapitlene punkt for punkt.

Bruk **kapittel 15 – Sjekkliste før jeg kan lage CloudKit-PoC-koden** som den autoritative arbeidslisten. Kapitlene før denne forklarer hvordan punktene i sjekklisten utføres, hvilke valg vi har tatt, og hva som skal gjøres senere i prosjektet.

Markeringene betyr:

- **AKSJON – DU ❗️:** Dette må du konfigurere eller beslutte før PoC-en.
- **INFORMASJON:** Bakgrunn eller arbeidsregler; ingen egen handling kreves nå.
- **SENERE – PROSJEKT:** Dette gjør vi sammen med PoC-en eller senere.

### Kort arbeidsrekkefølge

1. Sørg for Apple Developer Program og nødvendig rolle.
2. Bestem permanent Bundle ID og iCloud container ID.
3. Opprett App ID og aktiver iCloud/CloudKit.
4. Opprett og koble iCloud-containeren.
5. Kontroller at containeren vises i CloudKit Console.
6. Bestem GitHub repository og Pages-adresse, og aktiver HTTPS.
7. Opprett et **Development** API-token.
8. Legg GitHub Pages-origin inn som `Allowed Origin`.
9. Bekreft at PoC-en bruker **Development**, ikke Production.
10. Stopp der og bruk kapittel 15 som kontrolliste.

Du skal **ikke** deploye production-schema, opprette production-token eller bygge hele CloudKit-schemaet manuelt før PoC-en.

## 1. Kontoer og tilganger

**AKSJON – DU ❗️:** Kontroller konto, medlemskap og rolle.

### Apple Account

Du trenger en Apple Account med tofaktorautentisering. Apple krever tofaktorautentisering ved innmelding i Apple Developer Program.

### Apple Developer Program

For Tekstilig bør en aktiv **Apple Developer Program**-konto behandles som en prosjektforutsetning. CloudKit inngår i programmet, og medlemskap vil uansett være nødvendig dersom vi senere skal distribuere en SwiftUI-app via TestFlight/App Store.

For et organisasjonsteam må riktig rolle være tilgjengelig. Opprettelse av en iCloud container krever ifølge Apple rollen **Account Holder eller Admin**.

For et privat prosjekt er individuell medlemskap enklest dersom appen og containeren skal eies privat. Dersom løsningen skal eies av en organisasjon, bør containeren opprettes under organisasjonens Developer Team fra starten. Flytting senere bør unngås hvis mulig.

### iCloud-konto for testing

Minst én vanlig iCloud-konto må være tilgjengelig for å teste den private databasen. Det er en fordel å ha to testkontoer senere når deling/`CKShare` eventuelt skal testes.

## 2. Verktøy på Mac

**AKSJON – DU ❗️:** Kontroller grunnleggende verktøy og portaltilganger.

Installer/ha tilgjengelig:

- siste stabile Xcode
- Git
- nettlesere som skal testes, særlig Safari
- tilgang til Apple Developer-portalen
- tilgang til CloudKit Console
- GitHub-konto/repository for Tekstilig

Xcode blir spesielt viktig hvis vi går videre med SwiftUI. Apple beskriver også CloudKit JS som en webflate mot de samme CloudKit-containerne som brukes av iOS/macOS-apper.

## 3. Velg eierskap og identifiers før opprettelse

**AKSJON – DU ❗️:** Bestem permanente identifikatorer før opprettelse.

Før containeren opprettes bør følgende fastsettes:

```text
Appnavn:       Tekstilig
Bundle ID:     f.eks. com.longfjeld.tekstilig
iCloud ID:     f.eks. iCloud.com.longfjeld.tekstilig
GitHub repo:   f.eks. Longfjeld/Tekstilig
Pages URL:     f.eks. https://longfjeld.github.io/Tekstilig/
Custom domain: valgfritt (vi setter ikke denne)
```

Identifierne bør velges konservativt og regnes som permanente.

## 4. Opprett App ID / Bundle ID

**AKSJON – DU ❗️:** Utføres i Apple Developer-portalen.

I Apple Developer -> Certificates, Identifiers & Profiles:

1. Opprett en eksplisitt App ID/Bundle ID for Tekstilig hvis den ikke finnes.
2. Aktiver iCloud capability.
3. Velg CloudKit-støtte.
4. Knytt App ID-en til Tekstilig sin iCloud container.

Selv om første klient er en webapp, anbefales dette oppsettet fordi samme container da er klar for en senere native app.

## 5. Opprett iCloud container

**AKSJON – DU ❗️:** Utføres i Apple Developer-portalen.

I Apple Developer -> Certificates, Identifiers & Profiles -> Identifiers:

1. Velg `iCloud Containers`.
2. Opprett containeren.
3. Bruk valgt permanent identifier, eksempelvis:

```text
iCloud.com.longfjeld.tekstilig
```

Apple oppgir at opprettelse krever Account Holder eller Admin.

## 6. Åpne CloudKit Console

**AKSJON – DU ❗️:** Kontroller at Tekstilig-containeren er synlig. Schemaarbeidet gjøres senere.

CloudKit Console brukes til blant annet:

- schema
- development-data
- production-schema
- API tokens
- telemetry/logs
- deploy av schema til production

Adresse:

```text
https://icloud.developer.apple.com/
```

Velg Tekstilig-containeren før videre oppsett.

## 7. Development og production

**INFORMASJON:** Bruk Development for PoC. Ikke deploy til Production nå.

CloudKit har separate miljøer.

### Development

Brukes under PoC og schemautvikling. Her kan schema endres og miljøet resettes.

### Production

Brukes når schemaet er testet og deployet. Produksjonsschema skal behandles som langsiktig. Apple dokumenterer at produksjonsendringer i praksis må være fremoverkompatible/additive; man bør derfor ikke deploye tidlige eksperimentfelt ukritisk.

### Arbeidsregel

Vi skal ikke deploye Tekstilig-schema til production før:

- record-typene er gjennomgått
- navn og datatyper er gjennomgått
- nødvendige query-indexer er bestemt
- PoC fungerer i development

## 8. Første CloudKit-schema

**SENERE – PROSJEKT:** Foreløpig schema-design. Ikke bygg hele schemaet manuelt nå.

Første PoC bør ha et minimalt schema som senere kan utvides.

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

Eksakt bruk av `Reference`/parent-relasjoner og eventuelle custom record zones bestemmes før PoC-koden låses. Dette er spesielt viktig hvis fremtidig deling via CKShare skal holdes åpen.

## 9. Indekser

**SENERE – PROSJEKT:** Planlegges sammen med schema/PoC.

CloudKit-felter som skal brukes i server-side queries må planlegges og indekseres. Ikke indekser alt automatisk i production.

For første PoC trenger vi bare det som er nødvendig for å hente testrecords. Før produksjon vurderes blant annet indekser for:

- `textileId`
- `name` hvis server-side søk skal brukes
- `category`
- relasjonsfelt
- `updatedAt` dersom dette inngår i synk

Komplekse kombinerte brukerfiltre kan fortsatt utføres lokalt mot cache.

## 10. Opprett API-token for CloudKit JS

**AKSJON – DU ❗️:** Opprett kun Development-tokenet som PoC-en trenger.

CloudKit JS krever container-ID og API-token.

I CloudKit Console:

1. Åpne riktig container.
2. Gå til API Access / API Tokens.
3. Opprett token for **development**.
4. Begrens `Allowed Origins` til den faktiske origin som brukes av GitHub Pages.
5. Angi sign-in callback/redirect etter behov i CloudKit-oppsettet.
6. Opprett separat token for production når vi er klare for production.

Apple dokumenterer at tokens er knyttet til container og deployment environment; development og production skal derfor ha separate tokens.

### Viktig om tokenet

Web-API-tokenet brukes i klientkoden og er ikke det samme som en hemmelig servernøkkel. Sikkerheten skal likevel strammes inn med `Allowed Origins`.

**Ikke** legg server-to-server private keys eller andre private nøkler i GitHub Pages-kode.

## 11. GitHub Pages-oppsett

**AKSJON – DU ❗️:** Pages-URL, HTTPS og faktisk origin må være klare.

### Repository

Tekstilig-koden kan fortsatt ligge på GitHub og publiseres med GitHub Pages. Ingen CloudKit-brukerdata skal ligge i repositoryet.

### HTTPS

HTTPS skal være aktivert og `Enforce HTTPS` skal brukes. GitHub oppgir at Pages støtter HTTPS både på `github.io` og korrekt konfigurerte custom domains.

### Origin

Hvis appen publiseres som:

```text
https://longfjeld.github.io/tekstilig/
```

er web-origin:

```text
https://longfjeld.github.io
```

Det er origin, ikke prosjektets URL-path, som normalt er relevant for origin-begrensning. Den konkrete CloudKit-konfigurasjonen verifiseres når tokenet opprettes.

### Custom domain

Et custom domain er valgfritt. Hvis dere senere bruker eksempelvis:

```text
https://tekstilig.longfjeld.com
```

må dette:

- konfigureres i GitHub Pages/DNS
- ha gyldig HTTPS
- legges til i CloudKit-tokenets tillatte origins
- testes før gammel origin eventuelt fjernes

GitHub anbefaler å verifisere custom domain og støtter HTTPS på korrekt konfigurerte domener.

## 12. CloudKit JS i PWA-en

**SENERE – PROSJEKT:** Implementeres i PoC-koden.

Apple leverer CloudKit JS fra sin CDN. Dokumentasjonen viser CloudKit JS 2 via:

```html
<script src="https://cdn.apple-cloudkit.com/ck/2/CloudKit.js"></script>
```

Konfigurasjonen trenger i hovedsak:

- container identifier
- API token
- environment: development/production
- autentisering av iCloud-bruker for privat database

`setUpAuth()` kan brukes til å oppdage aktiv CloudKit-session og presentere inn-/utlogging.

## 13. Første PoC-test

**SENERE – PROSJEKT:** Dette er akseptansekriteriene når PoC-en testes.

Når punktene over er klare bør PWA-PoC-en gjøre bare dette:

1. laste CloudKit JS
2. konfigurere Tekstilig-container i development
3. la bruker logge inn med iCloud
4. vise hvilken CloudKit-bruker/session som er aktiv
5. opprette én `Textile`
6. lese den tilbake
7. endre den
8. opprette ett `Piece`
9. fotografere/velge et bilde og lagre det som Asset
10. lese record og bilde på en annen Apple-enhet
11. logge relevante feil forståelig

Dette er godkjenningskriteriet før resten av UI-et kobles på CloudKit.

## 14. Hvis vi går til SwiftUI etter PoC

**INFORMASJON:** Beskriver gjenbruk ved eventuell overgang til SwiftUI.

Vi oppretter et SwiftUI-prosjekt med samme Bundle ID-familie og kobler det til den samme CloudKit-containeren. I Xcode aktiveres iCloud/CloudKit capability og riktig container velges.

Da gjenbrukes:

- alle eksisterende CloudKit-data
- schema
- record-typer
- assets
- indekser
- Tekstilig-ID-er
- logisk datamodell

Native appen bruker `CKContainer`, `CKDatabase`, `CKRecord`, `CKAsset` osv. i stedet for CloudKit JS.

Det gjør PWA-PoC-en til en backend-/schema-PoC, ikke en blindvei.

## 15. Sjekkliste før jeg kan lage CloudKit-PoC-koden

**AKSJON – DU / FASIT:** Dette er den autoritative sjekklisten.

- [x] Apple Account med tofaktorautentisering
- [ ] Apple Developer Program/team valgt
- [ ] Tilgang som Account Holder/Admin der container skal opprettes
- [ ] Endelig Bundle ID bestemt
- [ ] Endelig iCloud container ID bestemt/opprettet
- [ ] CloudKit aktivert for App ID
- [ ] Tekstilig-container synlig i CloudKit Console
- [ ] GitHub repository/Pages URL bestemt
- [ ] HTTPS aktiv på Pages
- [ ] Development API-token opprettet
- [ ] GitHub Pages-origin lagt inn som Allowed Origin
- [ ] Development brukes – ikke production – for første PoC

Når disse er på plass er ditt forhåndsoppsett ferdig. PoC-koden trenger i praksis container-ID, Development API-token og den avtalte Pages-origin.

### Dette skal ikke gjøres før vi går videre

- Ikke deploy schema til Production.
- Ikke opprett Production API-token.
- Ikke opprett alle `Textile`, `Piece` og `TextileImage`-feltene manuelt med mindre vi uttrykkelig avtaler det under PoC-arbeidet.
- Ikke bygg CloudKit JS-kode selv.
- Ikke opprett SwiftUI-prosjektet ennå dersom vi først skal gjennomføre CloudKit/PWA-PoC-en.

## 16. Offisielle kilder

- Apple Developer Program enrollment: https://developer.apple.com/help/account/membership/program-enrollment
- Apple Developer Program membership/CloudKit: https://developer.apple.com/programs/whats-included/
- Apple: Create an iCloud container: https://developer.apple.com/help/account/identifiers/create-an-icloud-container
- Apple: Enable app capabilities/iCloud: https://developer.apple.com/help/account/identifiers/enable-app-capabilities
- Apple: CloudKit JS: https://developer.apple.com/documentation/cloudkitjs
- Apple: CloudKit JS configuration: https://developer.apple.com/documentation/cloudkitjs/cloudkit
- Apple: CloudKit JS authentication: https://developer.apple.com/documentation/cloudkitjs/cloudkit.container/setupauth
- Apple: CloudKit Console: https://developer.apple.com/icloud/cloudkit/
- Apple: Deploy CloudKit schema: https://developer.apple.com/documentation/cloudkit/deploying-an-icloud-container-s-schema
- GitHub: GitHub Pages HTTPS: https://docs.github.com/en/pages/getting-started-with-github-pages/securing-your-github-pages-site-with-https
- GitHub: Custom domains: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages
