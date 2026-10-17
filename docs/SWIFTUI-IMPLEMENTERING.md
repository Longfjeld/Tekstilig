# SwiftUI – videre implementering

**Status:** Textile 1–9 ✅ · Piece 10–18 ✅ · hovedbilde 20–29 ✅ · materiale/farge 30–39 ✅ · plassering 43–53 ✅ · vedlikehold/query 54–67 ✅ · fysiske egenskaper 68–77 ✅ · første søk/grunnfilter 78–86 ✅ · utvidede grunnfiltre fra 87 ❗️  

> **Fast arbeidsmetodikk:** Les `ARBEIDSMETODIKK.md` før nye kodeendringer. `SWIFTUI-IMPLEMENTERING.md` er hovedsporet. Nye/ikke-validerte punkter markeres ❗️ og endres først til ✅ etter brukerens validering. Ved konkrete feil kan hovedsporet midlertidig erstattes av målrettet ad-hoc feilisolering; når feilen er løst fortsetter arbeidet fra neste ufullførte nummererte punkt.
**Miljø:** Development · Xcode 27 · iOS/iPadOS 27

> **Aktuell status 2026-10-11:** Roadmap-punkt 3 **Rask registrering** er lukket ✅. Devpatch 0064 og test 179–183 er validert ✅, og punkt 184 er validert på iPad ✅. Første native macOS-build er fortsatt blokkert i **punkt 185**. Devpatch 0066 fjernet første UIKit-blokkering i `PieceEditorView`; neste build avdekket flere iOS-spesifikke SwiftUI-modifikatorer. Devpatch 0067 retter denne plattformkompatibiliteten uten å endre forretningslogikk. Arbeidet fortsetter strengt sekvensielt fra **punkt 185**. Se også `LEVERANSE-OG-TESTMETODIKK.md` for fast leveranse-, rsync-, test-, Git- og snapshot-arbeidsflyt.

Denne veiledningen fortsetter etter fullført `SWIFTUI-OPPSTART.md`. Følg punktene strengt i nummerrekkefølge. Handling kommer før kontroll og stoppunkt.

Statusmarkeringer:

- ❗️ gjenstår
- ✅ utført
- ⏭️ senere

## 1. Legg inn kodeleveranse 0006

**✅ AKSJON – DU**

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Ta en Git-commit eller lokal sikkerhetskopi av den fungerende versjonen etter fullført PoC.
3. Pakk ut `Tekstilig-endringer-0006.zip`.
4. Kopier innholdet fra endringspakken inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett lokale filer i overordnet mappe som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at Project Navigator nå viser undermappene/gruppene:

```text
Tekstilig
├── Data
├── Diagnostics
├── Domain
└── Features
    └── Library
```

9. Kontroller at disse nye filene finnes:

```text
Domain/Textile.swift
Data/TextileRepository.swift
Data/CloudKitTextileRepository.swift
Features/Library/TextileLibraryModel.swift
Features/Library/TextileLibraryView.swift
Features/Library/TextileDetailView.swift
Features/Library/TextileEditorView.swift
Diagnostics/DeveloperDiagnosticsView.swift
```

10. Kontroller at de tre eksisterende diagnostikkmodellene fortsatt finnes.

**Ikke flytt eller slett diagnostikkmodellene manuelt.**

## 2. Bygg før appen kjøres

**✅ AKSJON – DU**

1. Velg den fysiske iPhone-en som tidligere fungerte som Run Destination.
2. Velg **Product → Build**.
3. Vent til build er ferdig.
4. Kontroller at Xcode viser at build er vellykket.

Hvis build feiler, stopp her. Ikke bruk automatiske kodeendringer via **Apply Fix** før feilen er gjennomgått.

## 3. Start den nye hovedflyten

**✅ AKSJON – DU**

1. Velg **Product → Run**.
2. Vent til Tekstilig åpnes på telefonen.
3. Kontroller at appen nå åpner på fanen **Tekstiler** i stedet for CloudKit-diagnostikken.
4. Kontroller at en egen fane **Utvikling** finnes i Debug-builden.
5. Åpne **Utvikling** kort og kontroller at tidligere CloudKit-/CKAsset-/Piece-diagnostikk fortsatt er tilgjengelig.
6. Gå tilbake til **Tekstiler**.

Diagnostikkfanen er kompilert bare i Debug. Den skal ikke være del av en senere Release-bygg.

## 4. Valider lesing av tekstilbiblioteket

**✅ AKSJON – DU**

1. Vent til **Tekstiler** har lastet ferdig.
2. Kontroller at `swiftui-poc-textile-v1` ikke vises som et vanlig tekstil i biblioteket.
3. Hvis du ikke har andre reelle `Textile`-records, kontroller at appen viser **Ingen tekstiler ennå**.
4. Hvis det finnes andre reelle records, kontroller at de vises med navn og kategori.

Den faste diagnostikkrecorden skjules bevisst fra produkt-UI, men beholdes i CloudKit for utviklingstester.

## 5. Opprett første reelle tekstil

**✅ AKSJON – DU**

1. Trykk **Nytt tekstil** eller `+`.
2. Skriv et tydelig testnavn som du kjenner igjen, for eksempel:

```text
Produktflyt test 1
```

3. Velg en kategori, for eksempel **Vevd**.
4. Trykk **Lagre**.
5. Vent til editoren lukkes.
6. Kontroller at det nye tekstilet vises i biblioteket.
7. Kontroller at kategorien vises under navnet.

Ikke legg inn flere testtekstiler før dette ene vises korrekt.

## 6. Kontroller detaljvisning

**✅ AKSJON – DU**

1. Trykk tekstilet du nettopp opprettet.
2. Kontroller at detaljsiden viser:
   - navn
   - kategori
   - permanent Tekstilig-ID
   - CloudKit Record Name
   - opprettet-dato
   - sist endret
3. Kontroller at knappen **Rediger** er tilgjengelig.

## 7. Rediger samme tekstil

**✅ AKSJON – DU**

1. Trykk **Rediger**.
2. Endre navnet, for eksempel til:

```text
Produktflyt test 1 – redigert
```

3. Endre eventuelt kategori.
4. Trykk **Lagre**.
5. Kontroller at detaljsiden oppdateres.
6. Gå tilbake til biblioteket.
7. Kontroller at det oppdaterte navnet også vises der.

Dette tester at appen først henter eksisterende `CKRecord` før oppdatering, slik at CloudKit-systemfelter og gjeldende change tag beholdes.

## 8. Kontroller recorden i CloudKit Database

**✅ AKSJON – DU**

1. Åpne CloudKit Database.
2. Velg `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne **Private Database → Textile**.
5. Finn recorden med navnet du nettopp lagret.
6. Kontroller at den inneholder:

| Felt | Kontroll |
|:---|:---|
| `textileId` | starter med `T-` og er stabil etter redigering |
| `name` | siste lagrede navn |
| `category` | valgt kategori |
| `createdAt` | opprinnelig opprettelsestid |
| `updatedAt` | oppdatert etter redigering |
| `schemaVersion` | `1` |

7. Kontroller at redigeringen oppdaterte samme record og ikke opprettet en ny record.

## 9. Stoppunkt for kodeleveranse 0006

Kodeleveranse 0006 er godkjent når alle disse er bekreftet:

- appen bygger i Xcode 27
- produkt-UI åpner på tekstilbiblioteket
- diagnostikken er flyttet til egen Debug-fane
- biblioteket kan lese fra privat Development-database
- et nytt tekstil kan opprettes
- samme tekstil kan åpnes i detaljvisning
- samme tekstil kan redigeres uten at en ekstra CloudKit-record opprettes

**Ikke utvid CloudKit-schemaet eller implementer bilder/Piece i produkt-UI før dette stoppunktet er bekreftet.**

## 10. Legg inn devpatch 0002 – Piece i produkt-UI

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0002.zip`, der test 1–9 er fullført.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Kontroller at siste Git-commit/snapshot er `SwiftUIActualApp0002`.
3. Pakk ut `Tekstilig-devpatch-0002.zip`.
4. Kopier innholdet fra patchen inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett lokale filer som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at disse nye filene vises i Project Navigator:

```text
Domain/Piece.swift
Data/PieceRepository.swift
Data/CloudKitPieceRepository.swift
Features/Pieces/PieceInventoryModel.swift
Features/Pieces/PieceEditorView.swift
```

9. Kontroller at `Features/Library/TextileDetailView.swift` fortsatt finnes.

**Ikke opprett filer eller grupper manuelt dersom filene allerede vises via Xcode-prosjektets synkroniserte mappegruppe.**

## 11. Opprett nødvendig CloudKit-indeks for Piece

**✅ AKSJON – DU**

Produktkoden henter bare stoffstykker som tilhører det valgte tekstilet. Det krever query på `Piece.textileId`.

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Gå til **Schema → Indexes**.
5. Opprett en ny indeks for record type **Piece**.
6. Velg feltet `textileId`.
7. Sett indekstypen til **QUERYABLE**.
8. Gi indeksen et forståelig navn, for eksempel:

```text
Piece-textileId-queryable
```

9. Lagre.
10. Kontroller at indeksen vises for `Piece.textileId`.

Ingen `SORTABLE`-indeks er nødvendig i dette steget; klienten sorterer stoffstykkene lokalt.

**Ikke kjør Piece-produktflyten før `Piece.textileId` er QUERYABLE.**

## 12. Bygg devpatch 0002

**✅ AKSJON – DU**

1. Velg iOS-simulatoren som Run Destination. Simulator er nå primær testenhet for denne produktfasen.
2. Velg **Product → Build**.
3. Vent til build er ferdig.
4. Kontroller at build er vellykket.

Hvis build feiler, stopp her. Ikke bruk **Apply Fix** før feilen er gjennomgått.

## 13. Kontroller tom Piece-tilstand

**✅ AKSJON – DU**

1. Kjør appen.
2. Åpne fanen **Tekstiler**.
3. Åpne tekstilet du opprettet i test 5–9, eller et annet **native-opprettet** tekstil der Tekstilig-ID starter med `T-`. Ikke bruk de gamle PoC-recordene med `textileId = T0001` i denne testen, fordi flere legacy-records deler den ID-en.
4. Finn seksjonen **Stoffstykker**.
5. Kontroller at den viser:

```text
Ingen stoffstykker registrert
```

6. Kontroller at **Legg til stoffstykke** er tilgjengelig.

Hvis du får CloudKit-feil om at `Piece` eller `textileId` ikke er indexable/queryable, stopp her og kontroller punkt 11.

## 14. Opprett første stoffstykke

**✅ AKSJON – DU**

1. Trykk **Legg til stoffstykke**.
2. Sett lengde til:

```text
280
```

3. Sett bredde til:

```text
145
```

4. La **Reserver del av stykket** være av.
5. Trykk **Lagre**.
6. Kontroller at editoren lukkes.
7. Kontroller at detaljvisningen nå viser et stoffstykke med:

```text
280 × 145 cm
Tilgjengelig: 280 cm
```

## 15. Kontroller første Piece-record i CloudKit

**✅ AKSJON – DU**

1. Åpne **CloudKit Database → Development → Private Database → Piece**.
2. Finn den nye recorden.
3. Kontroller at `pieceId` starter med `P-`.
4. Kontroller at `textileId` er lik Tekstilig-ID-en til tekstilet du åpnet i appen.
5. Kontroller feltene:

| Felt | Forventet verdi |
|:---|:---|
| `lengthCm` | `280` |
| `widthCm` | `145` |
| `reservedLengthCm` | `0` |
| `project` | tom streng |

6. Noter gjerne Record Name, men ikke endre recorden manuelt.
(26D3EB62-2A9C-425E-A4D6-78E7F9E6079B)

## 16. Rediger og reserver samme stoffstykke

**✅ AKSJON – DU**

1. Gå tilbake til samme tekstildetalj.
2. Trykk på stoffstykket `280 × 145 cm`.
3. Aktiver **Reserver del av stykket**.
4. Sett reservert lengde til:

```text
150
```

5. Sett prosjekt til:

```text
Testprosjekt
```

6. Trykk **Lagre**.
7. Kontroller at samme rad nå viser:

```text
Reservert 150 cm til Testprosjekt
Tilgjengelig: 130 cm
```

8. Åpne samme Piece-record i CloudKit Database.
9. Kontroller at samme Record Name er beholdt og at `reservedLengthCm`/`project` er oppdatert.

## 17. Test flere separate stoffstykker

**✅ AKSJON – DU**

1. Trykk **Legg til stoffstykke** igjen.
2. Opprett et nytt stykke med:

```text
Lengde: 90 cm
Bredde: 145 cm
```

3. Lagre uten reservasjon.
4. Kontroller at tekstildetaljen viser **to separate stoffstykker**.
5. Åpne begge etter tur og kontroller at riktig stykke åpnes.
6. Kontroller i CloudKit at det finnes to forskjellige Piece-records med samme `textileId`, men forskjellige `pieceId` og Record Name.

Dette validerer den sentrale modellbeslutningen om at beholdning består av separate fysiske stykker, ikke bare én total lengde.

## 18. Test sletting av ett stoffstykke

**✅ AKSJON – DU**

1. I tekstildetaljen, sveip det nye `90 × 145 cm`-stykket mot venstre.
2. Trykk **Slett**.
3. Kontroller at appen viser en eksplisitt bekreftelse.
4. Bekreft sletting.
5. Kontroller at `90 × 145 cm` forsvinner fra appen.
6. Kontroller i CloudKit Database at akkurat denne Piece-recorden er slettet.
7. Kontroller at tekstilet og det første `280 × 145 cm`-stykket fortsatt finnes.

## 19. Stoppunkt for Piece-produktsteget

**✅ FULLFØRT 2026-09-27**

Test 10–18 er gjennomført og validert i simulator mot privat CloudKit Development-database.

Bekreftet:

- appen bygger i Xcode 27
- `Piece.textileId` er QUERYABLE i Development
- `Piece.recordName` er QUERYABLE for CloudKit Database-inspeksjon
- tom Piece-tilstand fungerer
- et stoffstykke kan opprettes og vises på riktig tekstil
- samme Piece kan redigeres uten å opprette en ekstra record
- delvis reservasjon viser korrekt gjenværende tilgjengelig lengde
- flere separate Piece-records kan tilhøre samme tekstil
- ett Piece kan slettes med bekreftelse uten å påvirke Textile eller andre Piece-records

Devpatch 0003 retter i tillegg den observerte UI-uklarheten i Piece-editoren: **Lengde** og **Bredde** får permanente synlige etiketter og er ikke lenger bare placeholders i tekstfeltene.

## 20. Legg inn devpatch 0003 – hovedbilde i produkt-UI

**✅ AKSJON – DU**

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Ta en Git-commit eller lokal sikkerhetskopi av den fungerende `SwiftUIActualApp0003`-versjonen.
3. Pakk ut `Tekstilig-devpatch-0003.zip`.
4. Kopier innholdet fra patchen inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett eller erstatt andre lokale filer i overordnet mappe som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller i Project Navigator at disse nye filene er synlige:

```text
Tekstilig/Domain/TextileImage.swift
Tekstilig/Data/TextileImageRepository.swift
Tekstilig/Data/CloudKitTextileImageRepository.swift
Tekstilig/Features/Images/TextileImageModel.swift
Tekstilig/Features/Images/TextileMainImageSection.swift
```

## 21. Opprett nødvendige CloudKit-indekser for TextileImage

**✅ AKSJON – DU**

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Gå til **Schema → Indexes**.
5. Opprett eller kontroller denne indeksen:

```text
Record Type: TextileImage
Field:       textileId
Type:        QUERYABLE
```

6. Bruk gjerne navnet:

```text
TextileImage-textileId-queryable
```

7. Opprett eller kontroller også:

```text
Record Type: TextileImage
Field:       recordName
Type:        QUERYABLE
```

8. Bruk gjerne navnet:

```text
TextileImage-recordName-queryable
```

`textileId` brukes av appen for å hente bildene til valgt tekstil. `recordName` er ikke nødvendig for denne app-queryen, men gjør inspeksjon via **Query Records** i CloudKit Database forutsigbar og unngår samme administrasjonsfeil som ble observert for `Piece`.

**Ikke kjør bildeproduktsteget før `textileId` er QUERYABLE.**

## 22. Bygg devpatch 0003

**✅ AKSJON – DU**

1. Velg **Product → Build**.
2. Kontroller at build fullføres uten feil.
3. Åpne `PieceEditorView.swift` i simulatoren via et eksisterende stoffstykke dersom du vil kontrollere UI-rettingen.
4. Kontroller at **Lengde** og **Bredde** nå står synlig ved hvert sitt felt også etter at verdier er skrevet inn.

Hvis build feiler, stopp her og noter hele første reelle feilmelding før andre endringer gjøres.

## 23. Kontroller tom hovedbildetilstand

**✅ AKSJON – DU**

1. Kjør appen i simulatoren som er logget inn på iCloud.
2. Åpne fanen **Tekstiler**.
3. Åpne et native-opprettet tekstil med Tekstilig-ID som starter med `T-`.
4. Finn seksjonen **Hovedbilde**.
5. Dersom tekstilet ikke har bilde fra før, kontroller at seksjonen viser:

```text
Ingen bilder registrert
Velg hovedbilde
```

6. Kontroller at resten av tekstildetaljen og Piece-listen fortsatt vises og fungerer.

## 24. Sørg for at simulatoren har et testbilde

**✅ AKSJON – DU**

1. Åpne **Bilder** i simulatoren.
2. Kontroller at det finnes minst ett ikke-sensitivt testbilde.
3. Hvis Bilder er tom, legg et vanlig testbilde inn i simulatorens Bilder-bibliotek med den metoden du normalt bruker for simulatoren.
4. Gå tilbake til Tekstilig.

Dette steget tester valg fra Bilder. Direkte kamera er ikke implementert i devpatch 0003.

## 25. Lagre første hovedbilde

**✅ AKSJON – DU**

1. Trykk **Velg hovedbilde**.
2. Velg ett testbilde fra Bilder.
3. Vent til eventuell tekst **Lagrer i CloudKit …** er borte.
4. Kontroller at det valgte bildet vises i seksjonen **Hovedbilde**.
5. Kontroller at knappen nå heter:

```text
Bytt hovedbilde
```

6. Naviger tilbake til tekstilbiblioteket.
7. Åpne samme tekstil på nytt.
8. Kontroller at bildet lastes på nytt fra CloudKit og fortsatt vises.

## 26. Kontroller TextileImage-recorden i CloudKit

**✅ AKSJON – DU**

1. Åpne **CloudKit Database → Development → Private Database**.
2. Velg record type **TextileImage**.
3. Finn recorden der `textileId` er Tekstilig-ID-en til tekstilet du brukte i test 25.
4. Kontroller at `imageId` starter med:

```text
IMG-
```

5. Kontroller feltene:

| Felt | Forventet |
|:---|:---|
| `textileId` | ID-en til valgt tekstil |
| `type` | `fabric` |
| `primary` | `1` |
| `fileName` | `tekstilig-main-...` med filendelse |
| `contentType` | bildets MIME-type |
| `imageAsset` | Asset med bildefil |

6. Noter recordens **Record Name**. Den brukes i neste test: D3BADAD2-0CEA-4D47-A42E-0E7577E8FCAE

## 27. Erstatt hovedbildet uten å opprette ny hovedbilderecord

**✅ AKSJON – DU**

1. Sørg for at simulatorens Bilder inneholder et annet testbilde enn det som allerede er lagret.
2. Åpne samme tekstil i Tekstilig.
3. Trykk **Bytt hovedbilde**.
4. Velg det andre bildet.
5. Vent til lagringen er ferdig.
6. Kontroller visuelt at det nye bildet vises.
7. Åpne samme `TextileImage` i CloudKit Database.
8. Kontroller at **Record Name er den samme som i test 26**.
9. Kontroller at `imageAsset`, `fileName` og `contentType` er oppdatert.
10. Kontroller at det ikke er opprettet en ekstra primær `TextileImage` for samme `textileId`.

Dette validerer at «Bytt hovedbilde» er en oppdatering av samme bildeobjekt, ikke en ny hovedbilderecord hver gang.

## 28. Kontroller at bilde og Piece lever sammen

**✅ AKSJON – DU**

1. Åpne tekstilet som nå har hovedbilde.
2. Kontroller at hovedbildet vises.
3. Kontroller at eksisterende **Stoffstykker** fortsatt vises.
4. Åpne et stoffstykke og avbryt redigeringen uten endring.
5. Gå tilbake til biblioteket og åpne tekstilet igjen.
6. Kontroller at både hovedbilde og Piece-data fortsatt er tilgjengelige.

Denne testen bekrefter at bildevertikalsnittet ikke har brutt den allerede validerte beholdningsflyten.

## 29. Stoppunkt for første TextileImage-produktsteg

**✅ FULLFØRT 2026-09-27**

Test 20–29 er gjennomført og validert i simulator mot privat CloudKit Development-database.

Bekreftet:

- appen bygger i Xcode 27
- Piece-editoren viser permanente etiketter for Lengde og Bredde
- `TextileImage.textileId` og `TextileImage.recordName` er QUERYABLE i Development
- tom hovedbildetilstand fungerer
- bilde kan velges fra Bilder og lagres som `CKAsset`
- bildet lastes tilbake etter ny navigasjon
- **Bytt hovedbilde** oppdaterer samme CloudKit-record
- Piece-data fungerer samtidig med hovedbildet

Det ble observert ett ikke-blokkerende Xcode 27 concurrency-varsel i `PhotosPicker`-labelen fordi `model.isSaving` ble lest direkte fra en Sendable closure. Devpatch 0004 rydder dette før neste funksjonelle steg.

## 30. Legg inn devpatch 0004 – materiale og farge

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0005.zip`, der test 23–29 er validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Kontroller at siste Git-commit/snapshot er `SwiftUIActualApp0005`.
3. Pakk ut `Tekstilig-devpatch-0004.zip`.
4. Kopier innholdet fra patchen inn i den eksisterende Tekstilig-prosjektmappen.
5. Velg **Erstatt** for filer som allerede finnes.
6. Ikke slett lokale filer som er utelatt via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at disse nye filene vises i Project Navigator:

```text
Domain/TextileMaterial.swift
Domain/TextileColor.swift
Data/TextileMaterialRepository.swift
Data/TextileColorRepository.swift
Data/CloudKitTextileMaterialRepository.swift
Data/CloudKitTextileColorRepository.swift
Features/Attributes/TextileAttributesModel.swift
Features/Attributes/TextileAttributesSection.swift
Features/Attributes/TextileMaterialEditorView.swift
Features/Attributes/TextileColorEditorView.swift
```

## 31. Opprett CloudKit-schema for TextileMaterial

**✅ AKSJON – DU**

Dette er første produktsteg som introduserer en ny record-type etter PoC-en. Opprett schemaet før appen kjøres, slik at første detalj-query ikke møter en ukjent record-type.

1. Åpne **CloudKit Database**.
2. Velg container `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Gå til **Schema → Record Types**.
5. Opprett record type:

```text
TextileMaterial
```

6. Opprett feltene:

| Felt | Type |
|:---|:---|
| `materialId` | String |
| `textileId` | String |
| `material` | String |
| `percent` | Int64 |

7. Gå til **Schema → Indexes**.
8. Opprett:

```text
Record Type: TextileMaterial
Field:       textileId
Type:        QUERYABLE
Navn:        TextileMaterial-textileId-queryable
```

9. Opprett også:

```text
Record Type: TextileMaterial
Field:       recordName
Type:        QUERYABLE
Navn:        TextileMaterial-recordName-queryable
```

10. Kontroller at begge indeksene vises før du går videre.

## 32. Opprett CloudKit-schema for TextileColor

**✅ AKSJON – DU**

1. Fortsett i **Development → Schema → Record Types**.
2. Opprett record type:

```text
TextileColor
```

3. Opprett feltene:

| Felt | Type |
|:---|:---|
| `colorId` | String |
| `textileId` | String |
| `group` | String |
| `name` | String |
| `hex` | String |

4. Gå til **Schema → Indexes**.
5. Opprett:

```text
Record Type: TextileColor
Field:       textileId
Type:        QUERYABLE
Navn:        TextileColor-textileId-queryable
```

6. Opprett også:

```text
Record Type: TextileColor
Field:       recordName
Type:        QUERYABLE
Navn:        TextileColor-recordName-queryable
```

7. Kontroller at begge indeksene vises før du går videre.

Ingen `SORTABLE`-indekser eller søkeindekser på `material`/`group` opprettes i dette steget.

## 33. Bygg devpatch 0004 og kontroller concurrency-varselet

**✅ AKSJON – DU**

1. Velg simulatoren som Run Destination.
2. Velg **Product → Build**.
3. Kontroller at build fullføres uten feil.
4. Kontroller spesielt `TextileMainImageSection.swift`.
5. Bekreft at tidligere varsel:

```text
Main actor-isolated property 'isSaving' can not be referenced from a Sendable closure
```

ikke lenger vises på `PhotosPicker`-labelen.

Hvis build feiler eller samme varsel fortsatt vises, stopp her før appen kjøres.

## 34. Kontroller tom materiale- og fargetilstand

**✅ AKSJON – DU**

1. Kjør appen i simulatoren.
2. Åpne et native-opprettet tekstil med `textileId` som starter med `T-`.
3. Finn seksjonene **Materialer** og **Farger**.
4. Kontroller at et tekstil uten registrerte verdier viser:

```text
Ingen materialer registrert
Ingen farger registrert
```

5. Kontroller at knappene **Legg til materiale** og **Legg til farge** er tilgjengelige.
6. Kontroller at eksisterende hovedbilde og stoffstykker fortsatt vises.

## 35. Registrer første materiale

**✅ AKSJON – DU**

1. Trykk **Legg til materiale**.
2. Velg **Ull**.
3. Sett **Andel** til:

```text
80
```

4. Trykk **Lagre**.
5. Kontroller at Materialer-seksjonen viser:

```text
Ull    80 %
```

6. Åpne **CloudKit Database → Development → Private Database → TextileMaterial**.
7. Finn den nye recorden.
8. Kontroller:

| Felt | Forventet |
|:---|:---|
| `materialId` | starter med `MAT-` |
| `textileId` | samme ID som valgt Textile |
| `material` | `Ull` |
| `percent` | `80` |

## 36. Registrer flere materialer og valgfri prosent

**✅ AKSJON – DU**

1. Legg til **Polyester** med andel `20`.
2. Kontroller at begge materialene vises som separate rader.
3. Legg deretter til et tredje materiale ved å velge **Annet**.
4. Skriv et tydelig testenavn, for eksempel:

```text
Testfiber
```

5. La prosentandel stå tom.
6. Lagre.
7. Kontroller at `Testfiber` vises uten prosent.
8. Åpne `Testfiber` igjen, endre navnet til `Testfiber redigert` og lagre.
9. Kontroller at samme CloudKit-record er oppdatert og ikke duplisert.
10. Sveip `Testfiber redigert`, velg **Slett**, og bekreft sletting.
11. Kontroller at Ull og Polyester fortsatt finnes.

## 37. Registrer første farge

**✅ AKSJON – DU**

1. Trykk **Legg til farge**.
2. Velg fargegruppe **Blå**.
3. Sett beskrivende navn til:

```text
Marineblå
```

4. Sett hex til:

```text
#273448
```

5. Trykk **Lagre**.
6. Kontroller at Farger-seksjonen viser **Marineblå**, fargegruppen **Blå** og hex-verdien.
7. Kontroller at en liten fargeprøve vises.
8. Åpne **CloudKit Database → Development → Private Database → TextileColor**.
9. Kontroller:

| Felt | Forventet |
|:---|:---|
| `colorId` | starter med `COL-` |
| `textileId` | samme ID som valgt Textile |
| `group` | `Blå` |
| `name` | `Marineblå` |
| `hex` | `#273448` |

## 38. Valider farge uten hex og redigering

**✅ AKSJON – DU**

1. Legg til en ny farge med gruppe **Grå**.
2. La navn og hex stå tomme.
3. Lagre.
4. Kontroller at raden viser **Grå** uten krav om fargeprøve.
5. Åpne Grå-raden igjen.
6. Sett navn til `Mellomgrå` og hex til `808080` uten `#`.
7. Lagre.
8. Kontroller at appen normaliserer verdien til:

```text
#808080
```

9. Kontroller at samme CloudKit-record er oppdatert.
10. Slett den grå testen og bekreft at Marineblå fortsatt finnes.

## 39. Kontroller at alle vertikalsnitt lever sammen

**✅ AKSJON – DU**

1. Åpne samme tekstil på nytt.
2. Kontroller at hovedbildet fortsatt vises.
3. Kontroller at **Ull 80 %** og **Polyester 20 %** vises.
4. Kontroller at **Marineblå** vises.
5. Kontroller at eksisterende stoffstykker fortsatt vises.
6. Åpne ett stoffstykke og avbryt uten endring.
7. Gå tilbake til biblioteket og inn på samme tekstil igjen.
8. Kontroller at bilde, materialer, farger og Piece-data fortsatt lastes fra CloudKit.

## 40. Bekreft materiale/farge-steget og legg inn devpatch 0005

**✅ FULLFØRT**

Test 30–39 er validert, og devpatch 0005 ble lagt inn på `Tekstilig-SwiftUIActualApp0006`.

## 41. Resultat av første regresjonstest for materiale/farge-editor

**⚠️ FEIL FUNNET I DEVPATCH 0005**

1. Appen bygget og startet korrekt.
2. **Legg til materiale** åpnet editoren.
3. Editoren forsvant deretter raskt uten brukerhandling.
4. Plasseringstestene ble derfor stoppet før punkt 42 i den tidligere planen.

Feilen ble sporet til at `.sheet(item:)` fortsatt var forankret i `TextileAttributesSection`, som ligger i en `List` og bygger flere seksjoner gjennom en transparent `Group`.

## 42. Devpatch 0006 lagt inn – materiale/farge presenteres stabilt

**✅ FULLFØRT**

1. Devpatch 0006 ble lagt inn på prosjektkilden som senere ble snapshot `Tekstilig-SwiftUIActualApp0008.zip`.
2. **Legg til materiale** og **Legg til farge** ble kontrollert på nytt.
3. Editorene stod nå åpne etter første klikk og viste ikke den tidligere umiddelbare lukkingen.
4. Samme symptom ble derimot observert på **Legg til plassering**.

Plassering skal derfor rettes med samme stabile presentasjonsmønster før CloudKit-feltene opprettes.

## 43. Legg inn devpatch 0007 – stabil plasseringseditor

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0008.zip`.

1. Lukk Xcode 27.
2. Kontroller at siste Git-commit/snapshot tilsvarer `SwiftUIActualApp0008`.
3. Pakk ut `Tekstilig-devpatch-0007.zip`.
4. Kopier innholdet over eksisterende Tekstilig-prosjektmappe.
5. Velg **Erstatt** for eksisterende filer.
6. Ikke slett lokale filer som er ignorert via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at disse filene finnes:

```text
Features/Library/TextileDetailView.swift
Features/Location/TextileLocationSection.swift
Features/Location/TextileLocationEditorView.swift
```

Ingen CloudKit-endring skal gjøres i dette punktet.

## 44. Bygg og regresjonstest plasseringseditoren

**✅ AKSJON – DU**

1. Velg simulatoren som vanlig Run Destination.
2. Kjør **Product → Build**.
3. Kontroller at build er vellykket uten nye warnings fra devpatch 0007.
4. Kjør appen.
5. Åpne et vanlig `Textile` opprettet av SwiftUI-appen.
6. Finn seksjonen **Plassering**.
7. Trykk **Legg til plassering**.
8. La editoren stå åpen i minst 10 sekunder uten å skrive.
9. Kontroller at editoren **ikke forsvinner av seg selv**.
10. Trykk **Avbryt**.
11. Gjenta punkt 7–10 minst én gang.
12. Åpne **Legg til materiale** og **Legg til farge** én gang hver og kontroller at disse fortsatt står åpne til du selv velger **Avbryt**.

**Stopp her dersom plasseringseditoren eller attributt-editorene fortsatt forsvinner uten brukerhandling. Ikke opprett CloudKit-feltene før punkt 44 er bestått.**

## 45. Opprett plasseringsfeltene i CloudKit Development

**✅ AKSJON – DU**

Plassering lagres på eksisterende `Textile` record type. Det opprettes ingen ny record type.

1. Åpne CloudKit Database.
2. Velg container `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne schemaet for record type **Textile**.
5. Legg til disse tre feltene som **String** dersom de ikke allerede finnes:

| Felt | Type |
|:---|:---|
| `locationArea` | String |
| `locationShelf` | String |
| `locationContainer` | String |

6. Lagre schemaendringen.
7. Kontroller at alle tre feltene vises på `Textile`.

Det skal ikke opprettes nye indekser for plassering i dette steget.

## 46. Valider tom plassering

**✅ AKSJON – DU**

1. Kjør appen i simulatoren.
2. Åpne et native-opprettet tekstil som ikke har plasseringsdata.
3. Finn seksjonen **Plassering**.
4. Kontroller at den viser **Ingen plassering registrert**.
5. Kontroller at **Legg til plassering** er tilgjengelig.

## 47. Lagre komplett plassering

**✅ AKSJON – DU**

1. Trykk **Legg til plassering** eller **Rediger plassering**.
2. Sett eksempelvis:

```text
Område / rom: Syrom
Hylle: Hylle 2
Beholder / kasse: Kasse B
```

3. Trykk **Lagre**.
4. Kontroller at editoren lukkes.
5. Kontroller at detaljvisningen viser alle tre verdiene.
6. Gå tilbake til biblioteket.
7. Åpne samme tekstil igjen.
8. Kontroller at plasseringen fortsatt vises.

## 48. Kontroller plassering i CloudKit

**✅ AKSJON – DU**

1. Åpne **CloudKit Database → Development → Private Database → Textile**.
2. Finn samme `Textile`-record.
3. Kontroller:

| Felt | Forventet |
|:---|:---|
| `locationArea` | `Syrom` |
| `locationShelf` | `Hylle 2` |
| `locationContainer` | `Kasse B` |

4. Kontroller at samme Textile-record er oppdatert og at ingen ny Textile-record er opprettet.

## 49. Valider delvis plassering og redigering

**✅ AKSJON – DU**

1. Åpne **Rediger plassering** igjen.
2. Tøm **Hylle**.
3. Endre **Beholder / kasse** til `Kasse C`.
4. Behold **Område / rom** som `Syrom`.
5. Lagre.
6. Kontroller at detaljvisningen viser område og beholder, men ikke en tom hylleverdi.
7. Kontroller i CloudKit at `locationShelf` er fjernet/tomt og at øvrige verdier er korrekte.

## 50. Valider at plassering kan fjernes helt

**✅ AKSJON – DU**

1. Åpne **Rediger plassering**.
2. Tøm alle tre feltene.
3. Lagre.
4. Kontroller at detaljvisningen igjen viser **Ingen plassering registrert**.
5. Kontroller i CloudKit at de valgfrie plasseringsfeltene ikke lenger inneholder de gamle verdiene.

## 51. Kontroller at eksisterende data lever sammen med plassering

**✅ AKSJON – DU**

1. Registrer eller behold en gyldig plassering på testtekstilet.
2. Kontroller at hovedbildet fortsatt vises.
3. Kontroller at eksisterende materialer fortsatt vises.
4. Kontroller at eksisterende farger fortsatt vises.
5. Kontroller at eksisterende stoffstykker fortsatt vises.
6. Åpne vanlig **Rediger** for selve tekstilet.
7. Endre navn eller kategori og lagre.
8. Kontroller at plassering, bilde, materialer, farger og stoffstykker fortsatt er bevart.
9. Gå ut og inn av detaljvisningen én gang til og kontroller samme resultat.

## 52. Regresjonstest modalpresentasjon etter lagring

**✅ AKSJON – DU**

1. Etter at plasseringsdata er lagret, trykk **Rediger plassering**.
2. La editoren stå åpen i minst 10 sekunder.
3. Kontroller at den fortsatt ikke lukkes automatisk.
4. Avbryt uten endring.
5. Åpne et eksisterende materiale og en eksisterende farge.
6. La hver editor stå åpen i minst 10 sekunder og avbryt.
7. Kontroller at ingen av de tre editorene lukkes uten brukerhandling.

## 53. Stoppunkt for plassering

**✅ FULLFØRT 2026-09-29**

Devpatch 0007 og plassering er godkjent når alle disse er bekreftet:

- materiale-/fargeeditor forblir åpen til bruker avslutter den
- plasseringseditor forblir åpen til bruker avslutter den
- appen bygger uten nye warnings fra rettingen
- tom plassering fungerer på eldre Textile-records
- komplett plassering kan lagres og leses tilbake
- delvis plassering fungerer
- plassering kan tømmes igjen
- samme Textile-record oppdateres
- bilde, materialer, farger og Piece-data bevares gjennom Textile-redigering

**Punkt 53 er bekreftet. Plassering er validert sammen med eksisterende bilde-, materiale-, farge- og Piece-data.**

## 54. Legg inn devpatch 0008 – strukturert vedlikehold

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0009.zip`, der test 43–53 er validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Kontroller at siste Git-commit/snapshot tilsvarer `SwiftUIActualApp0009`.
3. Pakk ut `Tekstilig-devpatch-0008.zip`.
4. Kopier innholdet over eksisterende Tekstilig-prosjektmappe.
5. Velg **Erstatt** for eksisterende filer.
6. Ikke slett lokale filer som er ignorert via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at disse nye filene vises i Project Navigator:

```text
Domain/TextileCare.swift
Features/Care/TextileCareSection.swift
Features/Care/TextileCareEditorView.swift
```

Ingen Production-endring skal gjøres.

## 55. Opprett vedlikeholdsfeltene i CloudKit Development

**✅ AKSJON – DU**

Vedlikehold lagres på eksisterende `Textile` record type. Opprett feltene før appen forsøker å lagre dem.

1. Åpne CloudKit Database.
2. Velg container `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne schemaet for record type **Textile**.
5. Opprett disse feltene dersom de ikke allerede finnes:

| Felt | Type |
|:---|:---|
| `careWashAllowed` | Int64 |
| `careWashTemperatureC` | Int64 |
| `careWashCycle` | String |
| `careBleach` | String |
| `careTumbleDry` | String |
| `careDrying` | String |
| `careIron` | String |
| `careDryClean` | String |
| `careNotes` | String |

6. Lagre schemaendringen.
7. Kontroller at alle ni feltene vises på `Textile`.

Det skal **ikke** opprettes nye indekser i dette steget. `careWashAllowed` bruker `1` for vask tillatt og `0` for eksplisitt «skal ikke vaskes». Manglende felt betyr «ikke registrert».

## 56. Resultat av første build/runtime-test for devpatch 0008

**⚠️ BUILD OK – RUNTIME-FEIL FUNNET**

1. `Tekstilig-devpatch-0008` ble lagt inn.
2. Appen bygget korrekt i Xcode 27.
3. CloudKit-schemaet fra punkt 55 var opprettet med forventede feltnavn og typer.
4. Ved oppstart ble tekstilbiblioteket stående på **Henter tekstiler …**.
5. Etter venting avsluttet CloudKit med:

```text
CloudKit-feil 20: Operation … was cancelled
```

Feilen oppstod før vedlikeholds-UI kunne testes. Test 57–65 fra den opprinnelige devpatch 0008-planen ble derfor ikke gjennomført.

## 57. Legg inn devpatch 0009 – stabiliser Textile-query

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0010.zip`, som inneholder devpatch 0008 og CloudKit-schemaet fra punkt 55.

1. Lukk Xcode 27.
2. Kontroller at siste Git-commit/snapshot tilsvarer `SwiftUIActualApp0010`.
3. Pakk ut `Tekstilig-devpatch-0009.zip`.
4. Kopier innholdet over eksisterende Tekstilig-prosjektmappe.
5. Velg **Erstatt** for eksisterende filer.
6. Ikke slett lokale filer som er ignorert via `.gitignore`.
7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Ikke gjør flere CloudKit-schemaendringer.

Devpatch 0009 endrer bare hentingen av `Textile` og feildiagnostikken:

- queryen bruker `desiredKeys = nil`, slik at CloudKit returnerer hele Textile-recorden
- den eksplisitte klientlisten over Textile-felter fjernes fra queryen
- parseren er fortsatt tolerant for manglende valgfrie felt
- CloudKit-feilmeldingen viser også retry-/partial-/underliggende informasjon når CloudKit leverer dette

## 58. Bygg devpatch 0009 og valider biblioteklasting

**✅ AKSJON – DU**

1. Velg simulatoren som vanlig Run Destination.
2. Velg **Product → Build**.
3. Kontroller at build er vellykket uten nye warnings fra devpatch 0009.
4. Kjør appen.
5. Vent til fanen **Tekstiler** er ferdig lastet.
6. Kontroller at tekstilene vises som før og at appen ikke blir stående på **Henter tekstiler …**.
7. Vent minst 20 sekunder etter at listen er synlig og kontroller at ingen forsinket CloudKit-feil vises.
8. Dra listen ned for å kjøre en manuell refresh.
9. Kontroller at refresh også fullføres.

**Stopp her dersom biblioteket fortsatt feiler.** Send hele den nye feilmeldingen; devpatch 0009 viser mer CloudKit-diagnostikk dersom tjenesten leverer den.

## 59. Valider tom vedlikeholdstilstand og editorstabilitet

**✅ AKSJON – DU**

1. Åpne et native-opprettet tekstil med `textileId` som starter med `T-`.
2. Finn seksjonen **Vedlikehold**.
3. Kontroller at et tekstil uten registrert vedlikehold viser:

```text
Ingen vedlikeholdsinformasjon registrert
```

4. Trykk **Legg til vedlikehold**.
5. La editoren stå åpen i minst 10 sekunder uten å skrive.
6. Kontroller at editoren ikke forsvinner av seg selv.
7. Trykk **Avbryt**.
8. Åpne editoren én gang til og kontroller samme resultat.

Stopp her dersom editoren lukkes automatisk.

## 60. Registrer vask

**✅ AKSJON – DU**

1. Åpne **Legg til vedlikehold**.
2. Sett **Vask** til **Vask tillatt**.
3. Sett **Temperatur** til `40 °C`.
4. Sett **Program** til **Normalprogram**.
5. La øvrige områder stå som **Ikke registrert**.
6. Trykk **Lagre**.
7. Kontroller at detaljvisningen viser vask med `40 °C` og `Normalprogram`.
8. Gå tilbake til biblioteket og inn på samme tekstil igjen.
9. Kontroller at vaskedata fortsatt vises.

## 61. Registrer øvrige pleievalg

**✅ AKSJON – DU**

1. Åpne **Rediger vedlikehold**.
2. Sett **Bleking** til **Ikke tillatt**.
3. Sett **Tørketrommel** til **Ikke tillatt**.
4. Sett **Annen tørking** til **Hengetørkes**.
5. Sett **Stryking** til **Middels temperatur**.
6. Sett **Rens** til `P`.
7. Trykk **Lagre**.
8. Kontroller at detaljvisningen viser alle valgene med både symbolmarkør og forklarende tekst.

## 62. Registrer vedlikeholdsmerknad

**✅ AKSJON – DU**

1. Åpne **Rediger vedlikehold**.
2. Sett merknad til:

```text
Test: følg vaskelappen ved tvil
```

3. Lagre.
4. Kontroller at merknaden vises i Vedlikehold-seksjonen.
5. Åpne editoren igjen og kontroller at teksten lastes tilbake korrekt.

## 63. Kontroller vedlikehold i CloudKit

**✅ AKSJON – DU**

1. Åpne **CloudKit Database → Development → Private Database → Textile**.
2. Finn samme Textile-record.
3. Kontroller følgende verdier:

| Felt | Forventet |
|:---|:---|
| `careWashAllowed` | `1` |
| `careWashTemperatureC` | `40` |
| `careWashCycle` | `normal` |
| `careBleach` | `notAllowed` |
| `careTumbleDry` | `notAllowed` |
| `careDrying` | `line` |
| `careIron` | `medium` |
| `careDryClean` | `P` |
| `careNotes` | `Test: følg vaskelappen ved tvil` |

4. Kontroller at samme Textile Record Name er beholdt og at ingen ny Textile-record er opprettet.

## 64. Valider «skal ikke vaskes» og avhengige felt

**✅ AKSJON – DU**

1. Åpne **Rediger vedlikehold**.
2. Endre **Vask** fra **Vask tillatt** til **Skal ikke vaskes**.
3. Kontroller at temperatur og program ikke lenger vises i editoren.
4. Lagre.
5. Kontroller at detaljvisningen viser **Skal ikke vaskes**.
6. Kontroller i CloudKit at:
   - `careWashAllowed = 0`
   - `careWashTemperatureC` ikke lenger har `40`
   - `careWashCycle` ikke lenger har `normal`

## 65. Valider delvis vedlikehold og nullstilling

**✅ AKSJON – DU**

1. Åpne **Rediger vedlikehold**.
2. Sett **Vask** tilbake til **Ikke registrert**.
3. Sett Bleking, Tørketrommel, Annen tørking, Stryking og Rens til **Ikke registrert**.
4. Tøm merknaden.
5. Lagre.
6. Kontroller at seksjonen igjen viser **Ingen vedlikeholdsinformasjon registrert**.
7. Kontroller i CloudKit at de tidligere vedlikeholdsverdiene er fjernet fra recorden.

## 66. Kontroller at vedlikehold lever sammen med øvrige produktdata

**✅ AKSJON – DU**

1. Registrer på nytt minst én vedlikeholdsverdi, for eksempel **Vask 30 °C / Skånsomt program**.
2. Kontroller at hovedbildet fortsatt vises.
3. Kontroller at materialer og farger fortsatt vises.
4. Kontroller at plassering fortsatt vises.
5. Kontroller at stoffstykker fortsatt vises.
6. Åpne vanlig **Rediger** for selve tekstilet.
7. Endre navn eller kategori og lagre.
8. Kontroller at vedlikehold, plassering, bilde, materialer, farger og Piece-data fortsatt er bevart.
9. Gå ut og inn av detaljvisningen og kontroller samme resultat.

## 67. Stoppunkt for vedlikehold

**✅ AKSJON – DU**

Vedlikeholdssteget er godkjent når alle disse er bekreftet:

- appen bygger i Xcode 27 uten nye warnings fra vedlikeholds-/querykoden
- Textile-biblioteket lastes og kan refreshes uten CloudKit-feil 20
- vedlikeholdseditoren forblir åpen til bruker avslutter den
- eldre Textile-records uten vedlikehold viser trygg tom tilstand
- vask, temperatur og program kan lagres og leses tilbake
- bleking, tørketrommel, annen tørking, stryking og rens kan lagres
- merknad kan lagres og redigeres
- «skal ikke vaskes» fjerner tidligere temperatur/program
- alle vedlikeholdsfelt kan nullstilles igjen
- samme Textile-record oppdateres
- eksisterende bilde, materialer, farger, plassering og Piece-data bevares gjennom Textile-redigering

**Ikke gå videre til neste produktområde før punkt 67 er bekreftet.**

## 68. Legg inn devpatch 0010 – vekt, elastisitet og krymp

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0011.zip`, der test 1–67 er validert.

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Kontroller at prosjektet du skal oppdatere tilsvarer `Tekstilig-SwiftUIActualApp0011`.
3. Pakk ut `Tekstilig-devpatch-0010.zip` i `Downloads`.
4. Kjør først denne dry-run-kommandoen dersom den utpakkede katalogen heter `Tekstilig-devpatch-0010`:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0010/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

5. Kontroller at rsync bare viser filer fra patchen som nye eller endrede.
6. Kjør deretter den faktiske oppdateringen:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0010/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Kontroller at disse nye filene vises i Project Navigator:

```text
Domain/TextilePhysicalProperties.swift
Features/PhysicalProperties/TextilePhysicalPropertiesSection.swift
Features/PhysicalProperties/TextilePhysicalPropertiesEditorView.swift
```

9. Kontroller at eksisterende `Textile.swift`, `CloudKitTextileRepository.swift`, `TextileLibraryModel.swift` og `TextileDetailView.swift` fortsatt finnes.

Patchen erstatter ikke kataloger; den merger bare nye/endrede filer inn i eksisterende prosjektstruktur.

## 69. Opprett feltene for fysiske egenskaper i CloudKit Development

**✅ AKSJON – DU**

1. Åpne CloudKit Database.
2. Velg containeren `iCloud.com.longfjeld.tekstilig`.
3. Kontroller at miljøet er **Development**.
4. Åpne schemaet for record type **Textile**.
5. Opprett følgende valgfrie felt med nøyaktig disse navnene og typene:

| Felt | Type |
|:---|:---|
| `weightGsm` | Int64 |
| `stretchLevel` | String |
| `stretchDirection` | String |
| `stretchPercent` | Int64 |
| `shrinkageLengthPercent` | Int64 |
| `shrinkageWidthPercent` | Int64 |
| `shrinkageNote` | String |

6. Lagre schemaendringene.
7. Kontroller at alle syv feltene finnes på **Textile**.

Ingen nye indekser kreves i dette steget. Søk-/filterindekser opprettes først når den faktiske søkeflyten implementeres.

## 70. Bygg patchen og valider tom tilstand

**✅ AKSJON – DU**

1. Velg samme simulator/fysiske testenhet som i de siste valideringene.
2. Velg **Product → Build**.
3. Kontroller at build fullføres uten nye feil.
4. Kjør appen.
5. Åpne et eksisterende tekstil som ikke har de nye feltene.
6. Finn seksjonen **Fysiske egenskaper**.
7. Kontroller at den viser:

```text
Ingen vekt, elastisitet eller krymp registrert
```

8. Trykk **Legg til vekt/elastisitet/krymp**.
9. Kontroller at editoren åpnes og forblir åpen.
10. Kontroller at editoren inneholder seksjonene **Vekt**, **Elastisitet** og **Krymp**.
11. Trykk **Avbryt**.
12. Kontroller at ingen data er endret.

Hvis editoren forsvinner av seg selv eller build feiler, stopp her før du oppretter testdata.

## 71. Registrer vekt

**✅ AKSJON – DU**

1. Åpne **Legg til vekt/elastisitet/krymp**.
2. Skriv følgende i feltet for vekt:

```text
320
```

3. La elastisitet og krymp stå tomt/ikke registrert.
4. Trykk **Lagre**.
5. Kontroller at editoren lukkes.
6. Kontroller at detaljvisningen viser:

```text
Vekt    320 g/m²
```

7. Gå ut av tekstilet og inn igjen.
8. Kontroller at `320 g/m²` fortsatt vises.

## 72. Registrer elastisitet

**✅ AKSJON – DU**

1. Åpne **Rediger vekt/elastisitet/krymp**.
2. Sett **Grad** til **Middels**.
3. Sett **Retning** til **Bredde**.
4. Sett **Prosent** til:

```text
25
```

5. Trykk **Lagre**.
6. Kontroller at detaljvisningen viser:
   - `Elastisitet: Middels`
   - `Retning: Bredderetning`
   - `Elastisitet, prosent: 25 %`
7. Åpne editoren igjen.
8. Kontroller at de tre verdiene lastes tilbake korrekt.
9. Trykk **Avbryt**.

## 73. Registrer krymp

**✅ AKSJON – DU**

1. Åpne **Rediger vekt/elastisitet/krymp**.
2. Sett **Lengde i prosent** til:

```text
3
```

3. Sett **Bredde i prosent** til:

```text
1
```

4. Sett merknad til:

```text
Etter vask på 40 °C
```

5. Trykk **Lagre**.
6. Kontroller at detaljvisningen viser:
   - `Krymp, lengde: 3 %`
   - `Krymp, bredde: 1 %`
   - `Krymp, merknad: Etter vask på 40 °C`
7. Gå ut av tekstilet og inn igjen.
8. Kontroller at alle tre verdiene fortsatt vises.

## 74. Kontroller de nye feltene i CloudKit

**✅ AKSJON – DU**

1. Åpne **CloudKit Database → Development → Private Database → Textile**.
2. Finn samme Textile-record som du brukte i test 71–73.
3. Kontroller følgende verdier:

| Felt | Forventet verdi |
|:---|:---|
| `weightGsm` | `320` |
| `stretchLevel` | `medium` |
| `stretchDirection` | `width` |
| `stretchPercent` | `25` |
| `shrinkageLengthPercent` | `3` |
| `shrinkageWidthPercent` | `1` |
| `shrinkageNote` | `Etter vask på 40 °C` |

4. Kontroller at samme Textile Record Name er beholdt.
5. Kontroller at lagringen ikke har opprettet en ekstra Textile-record.

## 75. Valider nullstilling og «Ingen elastisitet»

**✅ AKSJON – DU**

1. Åpne **Rediger vekt/elastisitet/krymp**.
2. Endre **Grad** til **Ingen**.
3. Kontroller at feltene for retning og prosent ikke lenger vises.
4. Trykk **Lagre**.
5. Kontroller at detaljvisningen viser `Elastisitet: Ingen`, uten retning eller prosent.
6. Kontroller i CloudKit at:
   - `stretchLevel = none`
   - `stretchDirection = notApplicable`
   - `stretchPercent` er fjernet/tomt
7. Åpne editoren igjen.
8. Tøm vektfeltet.
9. Sett **Grad** til **Ikke registrert**.
10. Tøm begge krympprosentene og merknaden.
11. Trykk **Lagre**.
12. Kontroller at seksjonen igjen viser **Ingen vekt, elastisitet eller krymp registrert**.
13. Kontroller i CloudKit at alle syv fysiske egenskapsfeltene nå er fjernet/tomme.

## 76. Kontroller samspill med eksisterende produktdata

**✅ AKSJON – DU**

1. Registrer på nytt minst vekt `320`, elastisitet **Middels/Bredde/25 %** og krymp `3 % / 1 %`.
2. Kontroller at hovedbildet fortsatt vises.
3. Kontroller at materialer og farger fortsatt vises.
4. Kontroller at vedlikehold fortsatt vises.
5. Kontroller at plassering fortsatt vises.
6. Kontroller at stoffstykker fortsatt vises.
7. Åpne vanlig **Rediger** for selve tekstilet.
8. Endre navn eller kategori og lagre.
9. Kontroller at fysiske egenskaper, vedlikehold, plassering, bilde, materialer, farger og Piece-data fortsatt er bevart.
10. Gå ut og inn av detaljvisningen og kontroller samme resultat.

## 77. Stoppunkt for fysiske egenskaper

**✅ AKSJON – DU**

Steget er godkjent når alle disse er bekreftet:

- appen bygger i Xcode 27 uten nye feil
- eldre Textile-records uten de nye feltene vises trygt
- editoren for fysiske egenskaper forblir åpen til bruker avslutter den
- vekt kan lagres, leses tilbake og nullstilles
- elastisitetsgrad, retning og valgfri prosent kan lagres og leses tilbake
- `Ingen` elastisitet fjerner prosent og lagrer retning som `notApplicable`
- krymp i lengde og bredde kan lagres separat
- krympmerknad kan lagres og redigeres
- alle syv nye CloudKit-felt kan nullstilles igjen
- samme Textile-record oppdateres
- eksisterende bilde, materialer, farger, vedlikehold, plassering og Piece-data bevares gjennom Textile-redigering

**Ikke gå videre til neste produktområde før punkt 77 er bekreftet.**

## 78. Legg inn devpatch 0041 – første fritekstsøk og kategorifilter

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0016.zip`, der test 1–77 er validert. Den første søkeblokken er bevisst lokal og bruker bare Textile-data som allerede er lastet i biblioteket. Ingen CloudKit-søkeindekser opprettes ennå.

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Kontroller at prosjektet du skal oppdatere tilsvarer `Tekstilig-SwiftUIActualApp0016`.
3. Pakk ut `Tekstilig-devpatch-0041.zip` i `Downloads`.
4. Kjør først dry-run:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0041/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

5. Kontroller at patchen bare endrer `TextileLibraryView.swift` og dokumentasjonsfilene som følger patchen.
6. Kjør den faktiske oppdateringen:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0041/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

7. Åpne `Tekstilig.xcodeproj` i Xcode 27.
8. Velg **Product → Build**.
9. Kontroller at build fullføres uten nye feil.
10. Start appen på den fysiske testtelefonen.
11. Kontroller at tekstilbiblioteket fortsatt lastes som før.
12. Kontroller at søkefeltet **Søk i navn, kategori og plassering** vises.
13. Kontroller at en kategori/filter-knapp vises i toolbaren.

Hvis build eller vanlig biblioteklasting feiler, stopp her før søk testes.

## 79. Valider fritekstsøk på navn

**✅ AKSJON – DU**

1. Finn et eksisterende tekstil med et navn som skiller seg tydelig fra de andre.
2. Skriv en unik del av navnet i søkefeltet.
3. Kontroller at resultatlisten oppdateres fortløpende.
4. Kontroller at tekstilet med matchende navn vises.
5. Kontroller at tekstiler som ikke matcher, skjules.
6. Slett søketeksten.
7. Kontroller at hele biblioteket vises igjen.

## 80. Valider store/små bokstaver og deltreff

**✅ AKSJON – DU**

1. Søk etter en del av et kjent tekstilnavn med annen bruk av store/små bokstaver enn navnet har i biblioteket.
2. Kontroller at tekstilet fortsatt finnes.
3. Søk deretter på en kort delstreng fra midten av navnet.
4. Kontroller at deltreffet fortsatt finner tekstilet.
5. Legg inn et mellomrom før eller etter søkeordet.
6. Kontroller at ytre mellomrom ikke hindrer treff.
7. Tøm søkefeltet.

## 81. Valider søk på kategori og plassering

**✅ AKSJON – DU**

1. Velg et tekstil som har registrert kategori og plassering.
2. Søk på hele eller deler av kategorinavnet.
3. Kontroller at tekstilet vises.
4. Tøm søket.
5. Søk på registrert **Område** for tekstilet.
6. Kontroller at tekstilet vises.
7. Tøm søket.
8. Søk på registrert **Hylle** eller **Beholder**.
9. Kontroller at tekstilet vises.
10. Tøm søkefeltet.

Dette første fritekstsøket omfatter bare navn, kategori og plassering. Materiale, farge, Piece-data, vedlikehold og fysiske egenskaper kobles på i senere søketrinn.

## 82. Valider kategorifilter

**✅ AKSJON – DU**

1. Trykk kategori/filter-knappen i toolbaren.
2. Velg en kategori som minst ett eksisterende tekstil bruker.
3. Kontroller at bare tekstiler i den valgte kategorien vises.
4. Kontroller at filterikonet viser aktiv tilstand.
5. Åpne kategorimenyen igjen.
6. Velg **Alle kategorier**.
7. Kontroller at hele biblioteket vises igjen.

## 83. Kombiner søk og kategorifilter

**✅ AKSJON – DU**

1. Velg en kategori som inneholder minst ett kjent tekstil.
2. Kontroller at kategorifilteret er aktivt.
3. Skriv en del av navnet på ett tekstil i denne kategorien.
4. Kontroller at treffet vises.
5. Endre søket til et navn som finnes i en annen kategori.
6. Kontroller at dette tekstilet ikke vises mens kategorifilteret fortsatt er aktivt.
7. Velg **Alle kategorier**.
8. Kontroller at tekstilet fra den andre kategorien nå kan vises med samme søk.
9. Tøm søket.

## 84. Valider tomt søkeresultat og nullstilling

**✅ AKSJON – DU**

1. Skriv et søkeord som med sikkerhet ikke finnes i biblioteket.
2. Kontroller at visningen viser **Ingen treff**.
3. Kontroller at knappen **Tøm søk** vises.
4. Trykk **Tøm søk**.
5. Kontroller at biblioteket vises igjen.
6. Aktiver et kategorifilter.
7. Skriv et søkeord som ikke gir treff innen valgt kategori.
8. Kontroller at **Ingen treff** vises og at **Nullstill kategori** er tilgjengelig.
9. Trykk **Nullstill kategori**.
10. Kontroller at kategorifilteret fjernes uten å endre lagrede Textile-data.
11. Tøm eventuelt gjenværende søketekst.

## 85. Kontroller regresjon og oppdatering etter redigering

**✅ AKSJON – DU**

1. Tøm søk og kategorifilter.
2. Åpne et eksisterende tekstil fra biblioteket.
3. Kontroller at detaljvisningen fortsatt åpnes stabilt.
4. Gå tilbake til biblioteket.
5. Søk frem samme tekstil på navn.
6. Åpne tekstilet fra søkeresultatet.
7. Rediger navnet eller plasseringen og lagre.
8. Gå tilbake til biblioteket.
9. Tøm det gamle søket og søk på den nye verdien.
10. Kontroller at den nye verdien gir treff.
11. Dra ned for å refreshe biblioteket.
12. Kontroller at søk og kategorifilter fortsatt fungerer etter refresh.
13. Kontroller at bilde, materialer, farger, fysiske egenskaper, vedlikehold, plassering og Piece-data fortsatt er bevart.

## 86. Stoppunkt for første søk og grunnfilter

**✅ AKSJON – DU**

Første søkeblokk er godkjent når alle disse er bekreftet:

- appen bygger i Xcode 27 uten nye feil
- biblioteket lastes og kan refreshes som før
- fritekstsøk på navn fungerer fortløpende
- søket er case-insensitivt og støtter deltreff
- kategori og plassering kan finnes med fritekstsøk
- kategorifilter kan aktiveres og nullstilles
- fritekstsøk og kategorifilter kan kombineres
- tomt resultat gir tydelig **Ingen treff**-visning
- søk/filter endrer ikke CloudKit-data
- tekstiler kan fortsatt åpnes og redigeres fra søkeresultatet
- tidligere validerte Textile-, Piece-, bilde-, materiale/farge-, plassering-, vedlikeholds- og fysiske egenskapsdata er bevart

**Ikke gå videre til neste søk-/filtertrinn før punkt 86 er bekreftet.**



## 87. Legg inn devpatch 0042 – filterpanel og utvidede grunnfiltre

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0017.zip`, der første søkeblokk 78–86 er fullført. Kategorien flyttes inn i et eget filterpanel, og filtrering utvides bare med felt som allerede ligger direkte på `Textile`: plassering/område, vekt og elastisitetsnivå. Det opprettes ingen nye CloudKit-felt eller indekser.

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0042.zip` i `Downloads`.
3. Kjør dry-run:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0042/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

4. Kontroller at patchen endrer `TextileLibraryView.swift`, dokumentasjon og legger til `docs/ARBEIDSMETODIKK.md`.
5. Kjør den faktiske oppdateringen:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0042/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil.
9. Start appen på den fysiske testtelefonen.
10. Kontroller at tekstilbiblioteket lastes.
11. Trykk **Filtre**.
12. Kontroller at filterpanelet inneholder **Kategori**, **Plassering**, **Vekt** og **Elastisitet**.
13. Trykk **Ferdig** og kontroller at panelet lukkes.

Hvis build, biblioteklasting eller åpning/lukking av filterpanelet feiler, stopp på punkt 87.

## 88. Valider kategorifilter i det nye filterpanelet

**✅ AKSJON – DU**

1. Åpne **Filtre**.
2. Velg en kategori som minst ett tekstil bruker.
3. Trykk **Ferdig**.
4. Kontroller at bare tekstiler i kategorien vises.
5. Kontroller at filterikonet viser aktiv tilstand.
6. Åpne **Filtre** igjen.
7. Velg **Alle kategorier**.
8. Trykk **Ferdig**.
9. Kontroller at hele biblioteket vises igjen.

### Observasjon fra validering av punkt 88

Kategori-valg i filterpanelet opplevdes én gang som kortvarig tregt/hengende på testklienten. Tilstanden løste seg ved videre navigering, og test 88–94 ble ellers validert uten funksjonsfeil. Dette behandles som en ikke-blokkerende ytelsesobservasjon som skal følges opp før produksjon dersom den kan reproduseres.

## 89. Valider filter på plassering/område

**✅ AKSJON – DU**

1. Velg et eksisterende tekstil som har et kjent **Område** under plassering.
2. Gå tilbake til biblioteket og åpne **Filtre**.
3. Skriv hele eller en unik del av området i feltet **Område**.
4. Trykk **Ferdig**.
5. Kontroller at tekstilet vises.
6. Kontroller at tekstiler med andre områder skjules når de ikke matcher.
7. Åpne **Filtre** igjen og tøm **Område**.
8. Trykk **Ferdig**.
9. Kontroller at biblioteket igjen er ufiltrert på område.

## 90. Valider minimums- og maksimumsvekt

**✅ AKSJON – DU**

1. Bruk minst ett tekstil med registrert vekt fra test 68–77.
2. Åpne **Filtre**.
3. Sett **Minimum g/m²** lavere enn eller lik tekstilets vekt.
4. Sett **Maksimum g/m²** høyere enn eller lik tekstilets vekt.
5. Trykk **Ferdig**.
6. Kontroller at tekstilet vises.
7. Endre minimumsvekten slik at den blir høyere enn tekstilets registrerte vekt.
8. Trykk **Ferdig**.
9. Kontroller at tekstilet ikke lenger vises.
10. Åpne **Filtre** og fjern begge vektgrensene.
11. Trykk **Ferdig**.
12. Kontroller at tekstilet vises igjen.

Tekstiler uten registrert vekt skal ikke matche når minimum eller maksimum vekt er aktivt.

## 91. Valider filter på elastisitetsnivå

**✅ AKSJON – DU**

1. Bruk et tekstil med et kjent registrert elastisitetsnivå.
2. Åpne **Filtre**.
3. Velg det samme nivået under **Elastisitet**.
4. Trykk **Ferdig**.
5. Kontroller at tekstilet vises.
6. Åpne **Filtre** og velg et annet elastisitetsnivå.
7. Trykk **Ferdig**.
8. Kontroller at tekstilet ikke vises dersom det ikke matcher det valgte nivået.
9. Åpne **Filtre** og velg **Alle nivåer**.
10. Trykk **Ferdig**.
11. Kontroller at elastisitetsfilteret er fjernet.

## 92. Kombiner flere filtre og fritekstsøk

**✅ AKSJON – DU**

1. Finn et tekstil der du kjenner navn, kategori, område, vekt og elastisitetsnivå.
2. Åpne **Filtre**.
3. Velg tekstilets kategori.
4. Angi tekstilets område.
5. Angi et vektintervall som inkluderer tekstilets vekt.
6. Velg tekstilets elastisitetsnivå.
7. Trykk **Ferdig**.
8. Kontroller at tekstilet fortsatt vises.
9. Skriv en unik del av tekstilets navn i søkefeltet.
10. Kontroller at tekstilet fortsatt vises.
11. Endre én filterverdi slik at tekstilet ikke lenger matcher.
12. Kontroller at **Ingen treff** vises.

## 93. Valider nullstilling og regresjon

**✅ AKSJON – DU**

1. Mens ett eller flere filtre er aktive, åpne **Filtre**.
2. Trykk **Nullstill alle filtre**.
3. Trykk **Ferdig**.
4. Kontroller at filterikonet ikke lenger viser aktiv tilstand.
5. Tøm eventuell søketekst.
6. Kontroller at hele biblioteket vises igjen.
7. Åpne et tekstil fra biblioteket.
8. Kontroller at detaljvisningen fortsatt er stabil.
9. Rediger en ufarlig eksisterende verdi og lagre.
10. Gå tilbake til biblioteket.
11. Kontroller at søk og filterpanel fortsatt fungerer.
12. Dra ned for å refreshe og kontroller at filterfunksjonen fortsatt fungerer.
13. Kontroller at filtrering ikke har endret lagrede CloudKit-data.

## 94. Stoppunkt for utvidede grunnfiltre

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil
- filterpanelet åpnes og lukkes stabilt
- kategori kan filtreres fra filterpanelet
- plassering/område kan filtreres med deltreff
- minimums- og maksimumsvekt fungerer
- elastisitetsnivå kan filtreres
- flere filtre kan kombineres
- filtre kan kombineres med eksisterende fritekstsøk
- aktive filtre er synlige via filterikonet
- alle filtre kan nullstilles samlet
- filtrering endrer ikke CloudKit-data
- tidligere validerte funksjoner er bevart

**Ikke gå videre til materiale-/fargebasert søk eller mer avanserte filtre før punkt 94 er bekreftet.**

## 95. Legg inn devpatch 0044 – materiale- og fargebasert søk/filter

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0018.zip`, der test 1–94 er validert. Blokken utvider det eksisterende lokale bibliotekssøket med strukturerte `TextileMaterial`- og `TextileColor`-data. Materiale/farge hentes som egne child-records og bygges inn i et lokalt søkeindeks i appen. Det opprettes ingen nye CloudKit-felt eller feltbaserte søkeindekser i dette steget.

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0044.zip` i `Downloads`.
3. Kjør dry-run:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0044/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

4. Kontroller at patchen bare endrer/legger til filer for bibliotekssøk, materiale/farge-repositories og dokumentasjon.
5. Kjør den faktiske oppdateringen:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0044/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil.
9. Start appen på den fysiske testtelefonen.
10. Vent til tekstilbiblioteket er lastet.
11. Åpne **Filtre**.
12. Kontroller at panelet nå også inneholder **Materiale** og **Farge**.
13. Kontroller at de kan åpnes uten at appen henger eller lukker filterpanelet.
14. Trykk **Ferdig**.

Hvis build, biblioteklasting eller lasting av materiale/farge feiler, stopp på punkt 95.

## 96. Valider fritekstsøk på materiale

**✅ AKSJON – DU**

1. Velg et tekstil som har minst ett kjent materiale, for eksempel **Ull**.
2. Gå tilbake til biblioteket.
3. Skriv hele materialnavnet i søkefeltet.
4. Kontroller at tekstilet vises.
5. Søk deretter på en unik del av materialnavnet.
6. Kontroller at deltreff fortsatt finner tekstilet.
7. Kontroller at søket ikke er avhengig av store/små bokstaver.
8. Tøm søket.

## 97. Valider fritekstsøk på fargegruppe og fargenavn

**✅ AKSJON – DU**

1. Velg et tekstil med kjent fargegruppe og eventuelt beskrivende fargenavn.
2. Søk på fargegruppen, for eksempel **Blå**.
3. Kontroller at tekstilet vises.
4. Tøm søket.
5. Dersom fargen har et eget navn, søk på hele eller deler av navnet.
6. Kontroller at tekstilet vises.
7. Kontroller at søket er case-insensitivt.
8. Tøm søket.

## 98. Valider materialfilter

**✅ AKSJON – DU**

1. Åpne **Filtre**.
2. Velg et materiale som minst ett tekstil bruker.
3. Trykk **Ferdig**.
4. Kontroller at bare tekstiler som har dette materialet vises.
5. Kontroller at tekstiler med flere materialer fortsatt vises dersom ett av materialene matcher.
6. Kontroller at filterikonet viser aktiv tilstand.
7. Åpne **Filtre** igjen.
8. Velg **Alle materialer**.
9. Trykk **Ferdig**.
10. Kontroller at materialfilteret er fjernet.

## 99. Valider fargegruppefilter

**✅ AKSJON – DU**

1. Åpne **Filtre**.
2. Velg en fargegruppe som minst ett tekstil bruker.
3. Trykk **Ferdig**.
4. Kontroller at bare tekstiler med denne fargegruppen vises.
5. Kontroller at et tekstil med flere farger fortsatt vises dersom minst én farge matcher gruppen.
6. Åpne **Filtre** igjen.
7. Velg **Alle farger**.
8. Trykk **Ferdig**.
9. Kontroller at fargefilteret er fjernet.

## 100. Kombiner materiale/farge med eksisterende filtre

**✅ AKSJON – DU**

1. Velg et tekstil med kjent materiale, fargegruppe og kategori.
2. Åpne **Filtre**.
3. Velg tekstilets materiale.
4. Velg tekstilets fargegruppe.
5. Velg tekstilets kategori.
6. Trykk **Ferdig**.
7. Kontroller at tekstilet fortsatt vises.
8. Endre ett av filtrene til en verdi som ikke passer tekstilet.
9. Kontroller at tekstilet forsvinner fra resultatet.
10. Nullstill filtrene.

## 101. Kombiner materiale/farge med fritekstsøk

**✅ AKSJON – DU**

1. Velg et materialfilter som gir minst ett treff.
2. Skriv en del av navnet på ett av treffene i søkefeltet.
3. Kontroller at bare riktig tekstil vises.
4. Endre søket til et tekstil som ikke har det valgte materialet.
5. Kontroller at dette tekstilet ikke vises mens materialfilteret er aktivt.
6. Tøm søket.
7. Nullstill materialfilteret.
8. Gjenta samme kontroll med et fargegruppefilter.
9. Tøm søk og filtre til slutt.

## 102. Valider refresh etter materiale-/fargeendring og regresjon

**✅ AKSJON – DU**

1. Åpne et eksisterende tekstil.
2. Legg til eller rediger et materiale og lagre.
3. Gå tilbake til biblioteket.
4. Dra ned for å refreshe biblioteket.
5. Søk på den nye materialverdien.
6. Kontroller at tekstilet nå finnes.
7. Åpne tekstilet igjen og legg til eller rediger en farge.
8. Gå tilbake til biblioteket og refresh igjen.
9. Søk eller filtrer på den nye fargeverdien.
10. Kontroller at tekstilet finnes.
11. Kontroller at tidligere validerte kategori-, plassering-, vekt- og elastisitetsfiltre fortsatt fungerer.
12. Kontroller at Piece-, bilde-, vedlikeholds-, plassering- og fysiske egenskapsdata er bevart.

## 103. Stoppunkt for materiale- og fargebasert søk/filter

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil
- materiale/farge-søkeindeksen lastes uten å blokkere vanlig bibliotekbruk
- fritekstsøk finner materialnavn
- fritekstsøk finner fargegruppe og beskrivende fargenavn
- materialfilter fungerer, også for tekstiler med flere materialer
- fargegruppefilter fungerer, også for tekstiler med flere farger
- materiale/farge kan kombineres med eksisterende filtre
- materiale/farge kan kombineres med fritekstsøk
- refresh oppdaterer søkeindeksen etter endring i materiale/farge
- filtrering endrer ikke CloudKit-data
- tidligere validerte funksjoner er bevart

**Ikke gå videre til Piece-baserte mål-/tilgjengelighetsfiltre eller «Finn til prosjekt» før punkt 103 er bekreftet.**


## 104. Legg inn devpatch 0045 – første «Finn til prosjekt»

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0019.zip`, der test 1–103 er validert. Første prosjektsøk bruker eksisterende Textile-, materiale- og Piece-data lokalt og oppretter ingen nye CloudKit-felt eller indekser.

1. Lukk Xcode 27 dersom Tekstilig-prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0045.zip` i `Downloads`.
3. Kjør dry-run:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0045/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

4. Kontroller at patchen bare endrer/legger til filer for ContentView, Piece-bulklesing, prosjektsøk og dokumentasjon.
5. Kjør den faktiske oppdateringen:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-0045/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil.
9. Start appen på fysisk testtelefon.
10. Kontroller at fanene **Tekstiler** og **Finn til prosjekt** vises.
11. Åpne **Finn til prosjekt**.
12. Vent til dataene er lastet.
13. Kontroller at kriteriene for lengde, bredde, kategori, materiale, vekt og elastisitet vises.

Stopp på punkt 104 dersom build eller innlasting feiler.

## 105. Valider grunnflyt og tomt søk

**✅ AKSJON – DU**

1. Åpne **Finn til prosjekt**.
2. Kontroller at **Finn tekstiler** ikke kan brukes uten minst ett kriterium.
3. Angi ett enkelt kriterium som du vet minst ett stoff kan oppfylle.
4. Trykk **Finn tekstiler**.
5. Kontroller at resultatseksjonen oppdateres.
6. Trykk **Nullstill kriterier**.
7. Kontroller at alle felt/valg nullstilles og at søkeresultatet skjules igjen.

## 106. Valider nødvendig sammenhengende lengde

**✅ AKSJON – DU**

1. Finn et tekstil med et kjent stoffstykke og noter stykkets totale lengde og eventuell reservasjon.
2. Beregn tilgjengelig lengde som total lengde minus reservert lengde.
3. Åpne **Finn til prosjekt**.
4. Angi et lengdekrav som er mindre enn eller lik den tilgjengelige lengden.
5. Trykk **Finn tekstiler**.
6. Kontroller at tekstilet vises.
7. Øk kravet til mer enn tilgjengelig lengde.
8. Trykk **Finn tekstiler** på nytt.
9. Kontroller at tekstilet ikke lenger vises.

## 107. Valider minimumsbredde og krav på samme Piece

**✅ AKSJON – DU**

1. Bruk et tekstil med minst ett kjent Piece.
2. Angi et lengdekrav og et breddekrav som samme Piece oppfyller.
3. Trykk **Finn tekstiler**.
4. Kontroller at tekstilet vises.
5. Endre bredden til mer enn det aktuelle stykket har.
6. Trykk **Finn tekstiler** igjen.
7. Kontroller at tekstilet ikke vises.
8. Dersom tekstilet har flere stoffstykker, kontroller at appen ikke kombinerer lengde fra ett Piece med bredde fra et annet; minst ett enkelt Piece må oppfylle begge kravene.

## 108. Valider reservasjon mot tilgjengelig lengde

**✅ AKSJON – DU**

1. Velg et Piece med en delvis reservasjon, eller opprett en testreservasjon på et eksisterende stykke.
2. Noter total lengde, reservert lengde og beregnet tilgjengelig lengde.
3. Åpne **Finn til prosjekt**.
4. Angi et lengdekrav som er større enn tilgjengelig lengde, men mindre enn eller lik total lengde.
5. Trykk **Finn tekstiler**.
6. Kontroller at dette Piece ikke gjør tekstilet til et treff.
7. Reduser lengdekravet til tilgjengelig lengde eller lavere.
8. Trykk **Finn tekstiler** igjen.
9. Kontroller at tekstilet nå vises dersom øvrige aktive krav også er oppfylt.
10. Kontroller at resultatet viser at en del av stykket er reservert når dette gjelder.

## 109. Valider kategori og materiale

**✅ AKSJON – DU**

1. Nullstill kriteriene.
2. Velg en kategori som et kjent tekstil bruker.
3. Velg ett av materialene på samme tekstil.
4. Trykk **Finn tekstiler**.
5. Kontroller at tekstilet vises.
6. Endre materiale til et materiale tekstilet ikke har.
7. Trykk **Finn tekstiler** igjen.
8. Kontroller at tekstilet ikke lenger vises.
9. Sett materiale tilbake og velg en kategori som ikke matcher.
10. Kontroller at tekstilet fortsatt filtreres bort.

## 110. Valider vekt og elastisitet

**✅ AKSJON – DU**

1. Nullstill kriteriene.
2. Velg et tekstil med registrert vekt og elastisitetsnivå.
3. Sett et vektintervall som inkluderer tekstilets vekt.
4. Velg tekstilets elastisitetsnivå.
5. Trykk **Finn tekstiler**.
6. Kontroller at tekstilet vises.
7. Endre maksimums- eller minimumsvekt slik at tekstilets vekt faller utenfor intervallet.
8. Trykk **Finn tekstiler** igjen.
9. Kontroller at tekstilet filtreres bort.
10. Gjenopprett vektintervallet og velg feil elastisitetsnivå.
11. Kontroller at tekstilet filtreres bort.

## 111. Valider kombinerte absolutte krav og forklarbare treff

**✅ AKSJON – DU**

1. Velg et kjent tekstil der du kjenner tilgjengelig Piece-lengde, bredde, kategori, materiale, vekt og elastisitet.
2. Angi alle disse kravene slik at tekstilet skal passe.
3. Trykk **Finn tekstiler**.
4. Kontroller at tekstilet vises.
5. Kontroller at resultatet viser hvilket tilgjengelig stykke som passer med lengde × bredde.
6. Kontroller at materiale vises når registrert.
7. Kontroller at vekt vises når registrert.
8. Endre ett absolutt krav slik at tekstilet ikke lenger passer.
9. Kontroller at tekstilet forsvinner fra resultatene.

## 112. Valider navigasjon, refresh og regresjon

**✅ AKSJON – DU**

1. Utfør et prosjektsøk som gir minst ett treff.
2. Trykk på et treff.
3. Kontroller at riktig `TextileDetailView` åpnes.
4. Gå tilbake til prosjektsøket.
5. Dra ned for å refreshe.
6. Kjør samme søk på nytt.
7. Kontroller at resultatet fortsatt er korrekt.
8. Gå til fanen **Tekstiler**.
9. Kontroller at vanlig fritekstsøk og filterpanel fortsatt fungerer.
10. Åpne et tekstil og kontroller at tidligere validerte editorer/Piece-funksjoner fortsatt er stabile.
11. Kontroller at prosjektsøk ikke har endret noen CloudKit-data.

## 113. Stoppunkt for første «Finn til prosjekt»

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil
- egen **Finn til prosjekt**-fane vises og lastes stabilt
- minst ett kriterium kreves før søk
- nødvendig sammenhengende tilgjengelig lengde fungerer
- minimumsbredde fungerer
- samme Piece må oppfylle aktive dimensjonskrav
- reservasjon reduserer tilgjengelig søkbar lengde
- kategori og materiale kan brukes som absolutte krav
- vektintervall fungerer
- elastisitetsnivå fungerer
- flere krav kan kombineres
- treff viser forklarende Piece-dimensjoner og relevante metadata
- treff kan åpne riktig tekstildetalj
- refresh og vanlig bibliotekfunksjonalitet er bevart
- prosjektsøk endrer ikke CloudKit-data

**Ikke gå videre til reservasjon direkte fra prosjektsøk, flere kriterietyper eller mer avansert rangering før punkt 113 er bekreftet.**

## UX-/ytelsesobservasjoner etter test 104–113

Følgende er registrert som ikke-blokkerende oppfølgingspunkter etter validering av første «Finn til prosjekt»:

- appstart ble observert som merkbart tregere etter innføring av prosjektsøk og lokale child-record-indekser
- første fokus på numeriske felt i «Finn til prosjekt» kan ha merkbar forsinkelse selv om resten av appen er responsiv
- Piece-data i prosjektsøket kan være foreldet etter redigering i en annen visning frem til pull-to-refresh; dette skal senere erstattes med automatisk invalidasjon/oppdatering
- når en hel visuell rad representerer én handling eller ett valg, skal hele raden være trykkbar; brukeren skal ikke måtte treffe selve teksten, tallet eller en liten kontrollflate

Disse punktene skal tas med i en egen UX-/ytelsesopprydding og endrer ikke godkjenningen av test 104–113.

## 114. Legg inn devpatch 0050 – reservasjon direkte fra prosjektsøk

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0020.zip`, der test 1–113 er validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0050.zip` i `Downloads`.
3. Kjør dry-run med vanlig rsync-metode.
4. Kontroller at patchen bare endrer prosjektsøk, legger til reservasjonsskjermen og oppdaterer dokumentasjon.
5. Kjør den faktiske rsync-oppdateringen.
6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil eller varsler.
9. Start appen på fysisk testtelefon.
10. Åpne **Finn til prosjekt** og utfør et søk som gir minst ett treff.
11. Kontroller at treffet har knappen **Reserver stykke** når Piece ikke allerede er reservert.

Stopp på punkt 114 dersom build eller åpning av reservasjon ikke fungerer.

## 115. Valider åpning og foreslått lengde

**✅ AKSJON – DU**

1. Angi et konkret minimumskrav til lengde i prosjektsøket.
2. Kjør søket.
3. Trykk **Reserver stykke** på et treff.
4. Kontroller at reservasjonsskjermen viser stykkets totale lengde, bredde og nåværende tilgjengelige lengde.
5. Kontroller at reservert lengde er forhåndsutfylt med søkets lengdekrav når stykket ikke allerede har en reservasjon.
6. Kontroller at prosjektfeltet kan fylles ut.

## 116. Valider tastatur og lagringskrav

**✅ AKSJON – DU**

1. Trykk i feltet for reservert lengde.
2. Kontroller at talltastaturet åpnes.
3. Trykk **Ferdig** og kontroller at tastaturet lukkes.
4. La prosjektfeltet være tomt og kontroller at **Lagre** ikke kan brukes.
5. Angi en reservert lengde større enn stykkets totale lengde og kontroller at **Lagre** ikke kan brukes.
6. Angi en gyldig lengde og et prosjektnavn.
7. Kontroller at **Lagre** blir tilgjengelig.

## 117. Valider ny reservasjon fra søkeresultat

**✅ AKSJON – DU**

1. Bruk et hittil ureservert Piece.
2. Angi en gyldig reservert lengde og et tydelig testprosjektnavn.
3. Trykk **Lagre**.
4. Vent til reservasjonsskjermen lukkes.
5. Kontroller at prosjektsøket oppdateres uten manuell pull-to-refresh.
6. Kjør samme søk på nytt dersom resultatet ikke allerede er oppdatert.
7. Kontroller at tilgjengelig lengde er redusert med den reserverte lengden.
8. Kontroller at treffet viser reservasjonen og prosjektnavnet når stykket fortsatt oppfyller søkekravene.

## 118. Valider at reservasjon påvirker treff umiddelbart

**✅ AKSJON – DU**

1. Bruk Piece fra punkt 117.
2. Sett lengdekravet høyere enn gjenværende tilgjengelig lengde, men ikke høyere enn total lengde.
3. Trykk **Finn tekstiler**.
4. Kontroller at Piece ikke lenger gjør tekstilet til et treff.
5. Reduser lengdekravet til gjenværende tilgjengelig lengde eller lavere.
6. Trykk **Finn tekstiler** igjen.
7. Kontroller at tekstilet vises dersom øvrige krav er oppfylt.

## 119. Valider redigering av eksisterende reservasjon

**✅ AKSJON – DU**

1. Kjør et søk der et allerede reservert Piece fortsatt er tilgjengelig som treff.
2. Kontroller at knappen heter **Endre reservasjon**.
3. Åpne reservasjonen.
4. Kontroller at eksisterende reservert lengde og prosjektnavn er forhåndsutfylt.
5. Endre lengden til en annen gyldig verdi.
6. Endre prosjektnavnet.
7. Lagre.
8. Kontroller at prosjektsøket bruker de nye verdiene uten manuell pull-to-refresh.

## 120. Valider persistens i tekstildetalj

**✅ AKSJON – DU**

1. Trykk på treffet og åpne riktig tekstildetalj.
2. Finn det aktuelle stoffstykket.
3. Kontroller at reservert lengde og prosjektnavn samsvarer med det som ble lagret fra prosjektsøket.
4. Gå tilbake til **Finn til prosjekt**.
5. Kontroller at søket fortsatt fungerer.

## 121. Valider omstart og regresjon

**✅ AKSJON – DU**

1. Avslutt appen helt.
2. Start appen på nytt.
3. Åpne **Finn til prosjekt**.
4. Kjør et søk som inkluderer stykket fra reservasjonstesten.
5. Kontroller at reservasjonen fortsatt påvirker tilgjengelig lengde korrekt.
6. Gå til **Tekstiler** og kontroller at vanlig bibliotek, fritekstsøk og filterpanel fortsatt fungerer.
7. Åpne et tekstil og kontroller at eksisterende Piece-redigering fortsatt fungerer.

## 122. Stoppunkt for reservasjon direkte fra prosjektsøk

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil eller varsler
- et søkeresultat kan åpne reservasjon direkte
- søkets lengdekrav foreslås som reservasjon for et ureservert Piece
- reservasjon krever gyldig lengde og prosjektnavn
- talltastaturet kan lukkes med **Ferdig**
- reservasjonen lagres i eksisterende Piece-record
- Piece-indeksen oppdateres automatisk etter lagring
- ny reservasjon påvirker tilgjengelig lengde og nye søkeresultater umiddelbart
- eksisterende reservasjon kan redigeres fra søkeresultatet
- reservasjonen er synlig med samme data i tekstildetaljen
- reservasjonen overlever omstart
- tidligere bibliotek-, søke-, filter- og Piece-funksjoner er bevart

**Ikke gå videre til flere kriterietyper, flere samtidige reservasjoner per Piece eller mer avansert rangering før punkt 122 er bekreftet.**

## Observasjon etter test 114–122

Test 114–122 er funksjonelt validert. Under punkt 118 måtte **Finn til prosjekt** refreshe manuelt før endret tilgjengelig lengde slo gjennom i søkeresultatet. Reservasjonen var lagret korrekt, men den lokale Piece-indeksen kunne være foreldet. Dette tas eksplisitt inn i UX-/ytelsesblokken 123–131 og endrer ikke godkjenningen av reservasjonsflyten.

## 123. Legg inn devpatch 0051 – UX-/ytelsesopprydding

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0021.zip`, der test 1–122 er funksjonelt validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0051.zip` i `Downloads`.
3. Kjør dry-run med vanlig rsync-metode.
4. Kontroller at patchen bare endrer app-/prosjektsøk-/Piece-UX og relevant dokumentasjon.
5. Kjør den faktiske rsync-oppdateringen.
6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil eller varsler.
9. Start appen på fysisk testtelefon.
10. Kontroller at appen åpner direkte i **Tekstiler** som før.

Stopp på punkt 123 dersom build eller vanlig oppstart feiler.

## 124. Valider utsatt lasting av «Finn til prosjekt»

**✅ AKSJON – DU**

1. Avslutt appen helt.
2. Start appen på nytt og bli stående i fanen **Tekstiler**.
3. Kontroller at biblioteket blir tilgjengelig normalt.
4. Legg merke til om oppstarten oppleves raskere enn før devpatch 0051.
5. Åpne deretter **Finn til prosjekt**.
6. Kontroller at eventuell lasting av prosjektdata skjer først når denne fanen åpnes.
7. Vent til skjermen er klar og kontroller at eksisterende kriterier og funksjoner fortsatt er tilgjengelige.

## 125. Valider fokus og tastatur i numeriske prosjektfelt

**✅ AKSJON – DU**

1. Stå i **Finn til prosjekt** etter at dataene er ferdig lastet.
2. Trykk i raden for **Lengde minst (cm)**.
3. Kontroller at feltet får fokus og talltastaturet åpnes uten den tidligere markante forsinkelsen, eller noter eventuell gjenværende forsinkelse.
4. Skriv inn en verdi.
5. Trykk **Ferdig** og kontroller at tastaturet lukkes.
6. Gjenta for **Bredde minst (cm)**.
7. Gjenta kort for minimum/maksimum vekt.
8. Kontroller at **Finn tekstiler** fortsatt bruker de angitte tallverdiene korrekt.

## 126. Valider automatisk Piece-oppdatering etter redigering i Tekstiler

**✅ AKSJON – DU**

1. Finn et kjent Piece og noter lengden.
2. Gå til **Tekstiler** og åpne tekstilet som eier stykket.
3. Rediger Piece og endre lengden til en tydelig annen testverdi.
4. Lagre og kontroller at den nye verdien vises i tekstildetaljen.
5. Gå til fanen **Finn til prosjekt** uten å utføre pull-to-refresh.
6. Kjør et søk der den nye lengden påvirker om stykket skal være treff.
7. Kontroller at prosjektsøket bruker den nye Piece-verdien uten manuell refresh.
8. Sett Piece tilbake til ønsket verdi etter testen dersom testverdien var midlertidig.

## 127. Valider umiddelbar oppdatering etter reservasjon

**✅ AKSJON – DU**

1. Kjør et prosjektsøk som gir et ureservert eller delvis reservert Piece som treff.
2. Åpne **Reserver stykke** eller **Endre reservasjon**.
3. Endre reservert lengde til en verdi som tydelig påvirker gjenværende tilgjengelig lengde.
4. Lagre.
5. Ikke dra ned for å refreshe.
6. Kontroller at søkeresultatet oppdateres direkte etter lagring.
7. Kjør søket på nytt med et lengdekrav som skiller gammel og ny tilgjengelig lengde.
8. Kontroller at treffet følger den nye reservasjonen.

## 128. Valider helrad-klikk på stoffstykker

**✅ AKSJON – DU**

1. Åpne et tekstil med minst ett registrert stoffstykke.
2. Trykk helt til venstre i den visuelle Piece-raden, men ikke direkte på dimensjonsteksten.
3. Kontroller at Piece-editoren åpnes.
4. Lukk editoren.
5. Trykk helt til høyre i samme rad der det er tom flate.
6. Kontroller at Piece-editoren åpnes igjen.
7. Kontroller at swipe for **Slett** fortsatt fungerer og avbryt sletting.

## 129. Valider helrad-fokus i Piece-editoren

**✅ AKSJON – DU**

1. Åpne et eksisterende stoffstykke.
2. Trykk på teksten **Lengde** eller tom flate i samme rad, ikke direkte i tallet.
3. Kontroller at lengdefeltet får fokus og talltastaturet åpnes.
4. Trykk **Ferdig** og kontroller at tastaturet lukkes.
5. Trykk på teksten **Bredde** eller tom flate i bredderaden.
6. Kontroller at breddefeltet får fokus.
7. Lukk editoren uten å endre verdier dersom testen ikke skal endre Piece-data.

## 130. Valider fanebytte, refresh og regresjon

**✅ AKSJON – DU**

1. Bytt flere ganger mellom **Tekstiler** og **Finn til prosjekt**.
2. Kontroller at ingen fane fryser eller viser stale data etter normal navigasjon.
3. Kjør et vanlig bibliotekssøk og kontroller at fritekstsøk/filter fortsatt fungerer.
4. Kjør et prosjektsøk og kontroller at kriteriene fortsatt fungerer.
5. Dra ned for manuell refresh i **Finn til prosjekt** og kontroller at dette fortsatt fungerer som eksplisitt fallback.
6. Åpne et søkeresultat og kontroller at riktig tekstildetalj åpnes.
7. Kontroller at vanlig Piece-redigering og reservasjon fortsatt fungerer.

## 131. Stoppunkt for UX-/ytelsesopprydding

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil eller varsler
- vanlig appstart gjør ikke lenger unødvendig full lasting av prosjektsøk før fanen åpnes
- første fokus i numeriske prosjektfelt er forbedret eller eventuell gjenværende plattformforsinkelse er dokumentert
- talltastaturet kan lukkes med **Ferdig**
- Piece-data oppdateres i prosjektsøk etter redigering uten krav om manuell refresh
- reservasjon oppdaterer aktive prosjektresultater direkte
- hele Piece-raden kan trykkes for redigering
- lengde-/bredderaden i Piece-editoren kan trykkes for å fokusere feltet
- swipe-sletting er bevart
- bibliotekssøk, filter, prosjektsøk, Piece-redigering og reservasjon er bevart

**Ikke gå videre til flere prosjektkriterier eller mer avansert rangering før punkt 131 er bekreftet.**

## 132. Legg inn devpatch 0052 – utvidede prosjektkriterier

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0022.zip`, der test 1–131 er funksjonelt validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0052.zip` i `Downloads`.
3. Kjør dry-run med vanlig rsync-metode.
4. Kontroller at patchen bare erstatter `ProjectSearchView.swift`, `PieceEditorView.swift` og relevant dokumentasjon.
5. Kjør den faktiske rsync-oppdateringen.
6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil eller varsler.
9. Start appen på fysisk testtelefon.
10. Kontroller at appen åpner normalt i fanen **Tekstiler**.
11. Åpne **Finn til prosjekt** og vent til skjermen er ferdig lastet.
12. Kontroller at de eksisterende kriteriene fremdeles vises, og at de nye kriteriene **Fargegruppe**, **Elastisitetsretning**, **Maks krymp (%)**, **Vaskbarhet** og **Min vasketemperatur** også er tilgjengelige.

Stopp på punkt 132 dersom build, vanlig oppstart eller lasting av **Finn til prosjekt** feiler.

## 133. Valider markørplassering i Piece-editoren

**✅ AKSJON – DU**

1. Gå til **Tekstiler** og åpne et tekstil med et eksisterende stoffstykke.
2. Åpne stoffstykket for redigering.
3. Trykk på **Lengde**-raden slik at det eksisterende lengdetallet får fokus.
4. Kontroller at markøren står bak det eksisterende tallet, ikke foran eller midt i tallet.
5. Skriv inn ett ekstra siffer og kontroller at sifferet legges til bakerst.
6. Fjern testsifferet igjen slik at korrekt lengde beholdes.
7. Trykk **Ferdig**.
8. Trykk på **Bredde**-raden.
9. Kontroller at markøren også her står bak eksisterende tall.
10. Lukk editoren uten å lagre dersom ingen reell verdi skal endres.

## 134. Valider fargegruppe som prosjektkrav

**✅ AKSJON – DU**

1. Finn et tekstil som har en kjent registrert fargegruppe, for eksempel **Blå**.
2. Kontroller at tekstilet har minst ett tilgjengelig stoffstykke.
3. Åpne **Finn til prosjekt**.
4. Nullstill kriteriene.
5. Velg den registrerte fargegruppen under **Fargegruppe**.
6. Trykk **Finn tekstiler**.
7. Kontroller at tekstilet vises som treff.
8. Kontroller at resultatet forklarer hvilken fargegruppe som traff, og viser beskrivende fargenavn dersom dette er registrert.
9. Velg deretter en annen fargegruppe som tekstilet ikke har.
10. Trykk **Finn tekstiler** på nytt.
11. Kontroller at tekstilet ikke lenger vises som treff.

## 135. Valider elastisitetsretning

**✅ AKSJON – DU**

1. Finn et tekstil med registrert elastisitetsnivå og kjent elastisitetsretning.
2. Åpne **Finn til prosjekt** og nullstill kriteriene.
3. Velg tekstilets registrerte elastisitetsnivå.
4. Velg tekstilets registrerte retning under **Elastisitetsretning**.
5. Trykk **Finn tekstiler**.
6. Kontroller at tekstilet vises som treff og at resultatet forklarer elastisitetsnivå og retning.
7. Endre bare retningen til en retning tekstilet ikke har.
8. Trykk **Finn tekstiler** igjen.
9. Kontroller at tekstilet ikke lenger vises.
10. Velg **Ingen** under **Elastisitet**.
11. Kontroller at **Elastisitetsretning** blir deaktivert og ikke kan stå igjen som et motstridende krav.

## 136. Valider maksimumskrav til krymp

**✅ AKSJON – DU**

1. Finn et tekstil der krymp er registrert både i lengde og bredde, og noter begge prosentverdiene.
2. Kontroller at tekstilet har minst ett tilgjengelig stoffstykke.
3. Åpne **Finn til prosjekt** og nullstill kriteriene.
4. Skriv inn en verdi i **Maks krymp (%)** som er lik eller høyere enn begge registrerte krympverdier.
5. Trykk **Finn tekstiler**.
6. Kontroller at tekstilet vises som treff og at begge krympverdiene forklares i resultatet.
7. Endre maksimumsverdien slik at minst én av tekstilets registrerte krympverdier er høyere enn kravet.
8. Trykk **Finn tekstiler** igjen.
9. Kontroller at tekstilet ikke lenger vises.
10. Finn om mulig et tekstil som mangler krymp i én eller begge retninger.
11. Kjør samme aktive maksimumskrav.
12. Kontroller at tekstilet med manglende krympdata ikke godkjennes som sikkert treff.

## 137. Valider vaskbarhet og minimum vasketemperatur

**✅ AKSJON – DU**

1. Finn et tekstil som er registrert som vaskbart og har en kjent vasketemperatur.
2. Åpne **Finn til prosjekt** og nullstill kriteriene.
3. Velg **Må kunne vaskes** under **Vaskbarhet**.
4. Trykk **Finn tekstiler**.
5. Kontroller at det vaskbare tekstilet kan vises som treff.
6. Velg en **Min vasketemperatur** som er lik eller lavere enn tekstilets registrerte tillatte temperatur.
7. Trykk **Finn tekstiler** igjen.
8. Kontroller at tekstilet fortsatt er treff og at vaskedata forklares i resultatet.
9. Velg en minimumstemperatur som er høyere enn tekstilets registrerte temperatur.
10. Trykk **Finn tekstiler** igjen.
11. Kontroller at tekstilet ikke lenger vises.
12. Velg **Skal ikke vaskes** under **Vaskbarhet**.
13. Kontroller at **Min vasketemperatur** blir deaktivert og nullstilt.
14. Kjør søket og kontroller at bare tekstiler som eksplisitt er registrert som ikke vaskbare kan tilfredsstille dette kravet.
15. Kontroller at et tekstil med ukjent vaskbarhet ikke behandles som sikkert treff for et aktivt vaskekrav.

## 138. Valider kombinasjon av gamle og nye prosjektkriterier

**✅ AKSJON – DU**

1. Velg et kjent tekstil med nok registrerte data til å teste flere kriterier samtidig.
2. Åpne **Finn til prosjekt** og nullstill kriteriene.
3. Angi et realistisk minimumskrav til tilgjengelig lengde.
4. Angi et realistisk minimumskrav til bredde.
5. Velg riktig kategori.
6. Velg riktig materiale.
7. Velg riktig fargegruppe.
8. Angi et vektintervall som omfatter tekstilets registrerte vekt.
9. Velg korrekt elastisitetsnivå og eventuelt korrekt elastisitetsretning.
10. Angi krymp- og vaskekrav som tekstilet oppfyller dersom disse dataene er registrert.
11. Trykk **Finn tekstiler**.
12. Kontroller at tekstilet vises som treff.
13. Endre ett enkelt kriterium til en verdi tekstilet ikke oppfyller.
14. Trykk **Finn tekstiler** igjen.
15. Kontroller at tekstilet forsvinner fra resultatet.
16. Sett kriteriet tilbake til korrekt verdi og kontroller at treffet kommer tilbake.

## 139. Valider resultatforklaring, reservasjon og regresjon

**✅ AKSJON – DU**

1. Kjør et prosjektsøk som bruker minst to av de nye kriteriene og som gir minst ett treff.
2. Kontroller at resultatet fortsatt viser tilgjengelig lengde og bredde for konkret Piece.
3. Kontroller at materiale og eventuell vekt fortsatt vises som før.
4. Kontroller at aktive nye kriterier forklares med forståelig tekst i resultatraden.
5. Åpne tekstildetaljen fra søkeresultatet og kontroller at riktig tekstil åpnes.
6. Gå tilbake til søkeresultatet.
7. Åpne **Reserver stykke** eller **Endre reservasjon**.
8. Lagre en gyldig reservasjon eller en ufarlig testendring.
9. Kontroller at aktivt søkeresultat oppdateres uten manuell pull-to-refresh.
10. Kontroller at de nye kriteriene fremdeles er aktive og brukes etter oppdateringen.
11. Nullstill kriteriene og kontroller at alle gamle og nye kriterier går tilbake til standardverdiene.
12. Kjør et enkelt søk med bare et tidligere støttet kriterium, for eksempel minimumslengde eller materiale.
13. Kontroller at den tidligere validerte søkefunksjonen fortsatt fungerer.

## 140. Stoppunkt for utvidede prosjektkriterier

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- appen bygger uten nye feil eller varsler
- Piece-editoren plasserer markøren bak eksisterende lengde-/breddetall ved fokus
- fargegruppe fungerer som deterministisk prosjektkrav
- elastisitetsretning kan kombineres med elastisitetsnivå uten motstridende valg
- maksimumskrav til krymp krever registrerte krympdata og filtrerer korrekt
- vaskbarhet og minimum vasketemperatur filtrerer korrekt, og ukjente data godkjennes ikke som sikre treff
- gamle og nye kriterier kan kombineres som AND-krav
- resultatraden forklarer relevante nye treffegenskaper
- eksisterende Piece-valg, reservasjon, automatisk oppdatering og gamle prosjektkriterier er bevart
- sorteringen er fortsatt den eksisterende deterministiske sorteringen; egnethetsrangering er ikke innført i denne blokken
- ingen nye CloudKit-felt eller indekser er nødvendige

**Ikke gå videre til egnethetsrangering eller rikere reservasjonsmodell før punkt 140 er bekreftet.**

## 141. Legg inn devpatch 0053 – søkefeedback og egnethetsrangering

**✅ AKSJON – DU**

Denne patchen bygger på `Tekstilig-SwiftUIActualApp0023.zip`, der test 1–140 er funksjonelt validert.

1. Lukk Xcode 27 dersom prosjektet er åpent.
2. Pakk ut `Tekstilig-devpatch-0053.zip` i `Downloads`.
3. Kjør dry-run med vanlig rsync-metode.
4. Kontroller at patchen bare erstatter `ProjectSearchView.swift` og relevant dokumentasjon.
5. Kjør den faktiske rsync-oppdateringen.
6. Åpne `Tekstilig.xcodeproj` i Xcode 27.
7. Velg **Product → Build**.
8. Kontroller at build fullføres uten nye feil eller varsler.
9. Start appen på fysisk testtelefon.
10. Åpne **Finn til prosjekt** og vent til skjermen er ferdig lastet.
11. Kontroller at alle tidligere kriterier fortsatt vises.

Stopp på punkt 141 dersom build, vanlig oppstart eller lasting av **Finn til prosjekt** feiler.

## 142. Valider visuell feedback på «Finn tekstiler»

**✅ AKSJON – DU**

1. Angi et gyldig prosjektkriterium som gir treff.
2. Finn knappen **Finn tekstiler** og kontroller at tekst, plassering og skillelinjen under ser ut som før 0053.
3. Trykk **Finn tekstiler** én gang.
4. Kontroller at hele knappen gir en tydelig, kort visuell puls når trykket registreres.
5. Trykk knappen på nytt.
6. Kontroller at feedbacken gjentas ved hvert trykk, at knappen ikke forskyves, og at søkeresultatet fortsatt oppdateres normalt.

## 143. Valider «best fit» mellom flere Piece på samme tekstil

**✅ AKSJON – DU**

1. Finn eller opprett et tekstil med minst to tilgjengelige stoffstykker som begge kan dekke samme prosjektkrav, men med ulik tilgjengelig lengde.
2. Noter tilgjengelig lengde på begge stykkene.
3. Åpne **Finn til prosjekt** og nullstill kriteriene.
4. Angi **Lengde minst** slik at begge stykkene er store nok.
5. Trykk **Finn tekstiler**.
6. Kontroller at resultatet bruker stoffstykket med minst overskytende lengde, ikke automatisk det største stykket.
7. Kontroller at resultatraden viser **Tilpasning** og antall centimeter ekstra lengde.

## 144. Valider «best fit» mellom flere tekstiler

**✅ AKSJON – DU**

1. Bruk et lengdekrav som gir minst to søkeresultater med ulik overskytende tilgjengelig lengde.
2. Trykk **Finn tekstiler**.
3. Kontroller at resultatet med minst overskytende lengde står først.
4. Angi også **Bredde minst** slik at minst to resultater fortsatt oppfyller kravene.
5. Trykk **Finn tekstiler** igjen.
6. Kontroller at lengde fortsatt er første rangeringskriterium.
7. Dersom to treff har samme lengdeoverskudd, kontroller at treffet med minst breddeoverskudd kommer først.
8. Kontroller at resultatradene forklarer både ekstra lengde og ekstra bredde når begge dimensjonskrav er aktive.

## 145. Valider rangering med bare breddekrav

**✅ AKSJON – DU**

1. Nullstill kriteriene.
2. Angi bare **Bredde minst** med en verdi som gir minst to treff.
3. Trykk **Finn tekstiler**.
4. Kontroller at treffet med minst overskytende bredde rangeres først.
5. Kontroller at **Tilpasning** viser ekstra bredde, men ikke en konstruert lengdeverdi.

## 146. Valider søk uten dimensjonskrav

**✅ AKSJON – DU**

1. Nullstill kriteriene.
2. Velg ett ikke-dimensjonalt krav, for eksempel **Materiale** eller **Fargegruppe**.
3. Trykk **Finn tekstiler**.
4. Kontroller at søket fungerer normalt og ikke krever lengde eller bredde.
5. Kontroller at **Tilpasning** ikke vises når ingen dimensjonskrav er aktive.
6. Kontroller at resultatene fortsatt har stabil og deterministisk rekkefølge.

## 147. Valider reservasjon sammen med egnethetsrangering

**✅ AKSJON – DU**

1. Kjør et søk med **Lengde minst** som gir minst ett treff.
2. Noter første treff og verdien for ekstra lengde.
3. Åpne **Reserver stykke** eller **Endre reservasjon** på et relevant treff.
4. Lagre en gyldig reservasjon som endrer tilgjengelig lengde, men fortsatt lar minst ett treff oppfylle søket.
5. Kontroller at søkeresultatet oppdateres uten manuell refresh.
6. Kontroller at rangering og **Tilpasning** beregnes på nytt ut fra ny tilgjengelig lengde.
7. Kontroller at et stykke som ikke lenger oppfyller minimumslengden forsvinner fra resultatet.

## 148. Valider kombinerte kriterier og regresjon

**✅ AKSJON – DU**

1. Nullstill kriteriene.
2. Angi både lengde, bredde og minst to tidligere validerte egenskapskrav.
3. Trykk **Finn tekstiler**.
4. Kontroller at alle aktive krav fortsatt behandles som AND-krav.
5. Kontroller at rangeringen bare rangerer blant tekstiler/stykker som faktisk oppfyller alle kravene.
6. Åpne et treff og gå tilbake til søkeresultatet.
7. Kontroller at kriteriene og resultatene er bevart.
8. Nullstill kriteriene.
9. Kontroller at alle kriterier og søkeresultater nullstilles som før.

## 149. Stoppunkt for søkefeedback og første egnethetsrangering

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- **Finn tekstiler** gir tydelig visuell feedback ved hvert trykk
- søkehandlingen og tidligere kriterier fungerer uendret
- når lengde er angitt, velges og rangeres minst overskytende passende lengde først
- når både lengde og bredde er angitt, brukes bredde som sekundært best-fit-kriterium
- med bare breddekrav prioriteres minst overskytende passende bredde
- resultatraden forklarer dimensjonsoverskuddet når dimensjonskrav er aktive
- søk uten dimensjonskrav fungerer fortsatt deterministisk
- reservasjon beregner best-fit på nytt uten manuell refresh
- ingen ny poengscore, maskinlæring eller skjult anbefalingslogikk er innført
- ingen CloudKit-schemaendring er nødvendig

**Ikke gå videre til rikere reservasjonsmodell eller mer avansert poengbasert rangering før punkt 149 er bekreftet.**


# Punkt 3 mot 1.0 – rask registrering

## 150. Legg inn devpatch 0055 – første hurtigregistreringsblokk

**✅ AKSJON – DU**

1. Legg inn filene fra `Tekstilig-devpatch-0055.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 som kjøredestinasjon.
4. Bygg og kjør appen.
5. Kontroller at Tekstilig starter og at eksisterende tekstiler lastes som før.
6. Åpne **Nytt tekstil**.
7. Kontroller at skjermen nå viser **Bilde**, **Navn** og en sammenfoldet **Plassering (valgfritt)**, og at kategori ikke lenger kreves ved førstegangsregistrering.

Stopp på punkt 150 dersom prosjektet ikke bygger, appen ikke starter eller den nye hurtigregistreringen ikke vises.

## 151. Valider hurtigregistrering med bare navn

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil**.
2. Ikke velg eller ta bilde.
3. Skriv et unikt testnavn.
4. La **Plassering (valgfritt)** være sammenfoldet og tom.
5. Trykk **Lagre**.
6. Finn det nye tekstilet i biblioteket.
7. Åpne tekstilet og kontroller at navn er lagret og at manglende bilde/plassering ikke hindret opprettelsen.

## 152. Valider bilde fra Bilder under førstegangsregistrering

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil** på nytt.
2. Trykk **Velg fra Bilder**.
3. Velg et tydelig bilde, gjerne et bilde med høy oppløsning og en kjent orientering.
4. Kontroller at bildet vises som forhåndsvisning i registreringsskjermen.
5. Skriv et unikt navn.
6. Trykk **Lagre**.
7. Åpne det nyopprettede tekstilet.
8. Kontroller at hovedbildet er lagret, har riktig orientering og ser visuelt korrekt ut.
9. Kontroller at registreringsflyten ikke opprettet et ekstra/duplisert Textile.

## 153. Valider direkte kamera på fysisk iPhone

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil** på fysisk iPhone.
2. Trykk **Ta bilde**.
3. Dersom iOS spør om kameratilgang, velg **Tillat**.
4. Ta et bilde av et stoff eller annet tydelig testmotiv.
5. Bekreft bildet i kameragrensesnittet.
6. Kontroller at bildet vises som forhåndsvisning i **Nytt tekstil**.
7. Skriv et unikt navn og trykk **Lagre**.
8. Åpne tekstilet etter lagring.
9. Kontroller at bildet vises korrekt som hovedbilde og at orienteringen er riktig.

## 154. Valider bytte av bilde før lagring

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil**.
2. Ta et bilde eller velg et bilde fra Bilder.
3. Kontroller at forhåndsvisningen vises.
4. Bruk **Ta nytt bilde** eller **Velg annet**.
5. Velg/tar et annet tydelig bilde.
6. Kontroller at forhåndsvisningen erstattes av det nye bildet.
7. Skriv et unikt navn og lagre.
8. Åpne tekstilet og kontroller at bare det sist valgte bildet brukes som hovedbilde.

## 155. Valider valgfri plassering under hurtigregistrering

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil**.
2. Skriv et unikt navn.
3. Utvid **Plassering (valgfritt)**.
4. Fyll inn minst **Område / rom** og én av de andre plasseringene.
5. Lagre tekstilet.
6. Åpne det nye tekstilet.
7. Kontroller at plasseringen vises korrekt i plasseringseksjonen.
8. Kontroller at ingen materiale-, farge-, Piece- eller vedlikeholdsdata måtte fylles inn for å lagre.

## 156. Valider generelt notatfelt på eksisterende tekstil

**✅ AKSJON – DU**

1. Åpne et eksisterende tekstil.
2. Trykk **Rediger**.
3. Finn seksjonen **Notat**.
4. Skriv en unik testtekst som ikke finnes i navn, materiale, farge eller plassering.
5. Trykk **Lagre**.
6. Kontroller at notatet vises i en egen **Notat**-seksjon på tekstildetaljen.
7. Åpne **Rediger** på nytt og kontroller at samme tekst fortsatt står i notatfeltet.

## 157. Valider notat i fritekstsøk og regresjon

**✅ AKSJON – DU**

1. Gå tilbake til tekstilbiblioteket.
2. Søk etter den unike teksten du lagret i punkt 156.
3. Kontroller at riktig tekstil kommer som treff.
4. Tøm søket.
5. Åpne et eldre tekstil som ikke har generelt notat.
6. Kontroller at tekstilet fortsatt åpnes normalt og at eldre CloudKit-records ikke krever `notes`-felt.
7. Rediger navn eller kategori på et eksisterende tekstil og lagre.
8. Kontroller at eksisterende redigeringsflyt fortsatt fungerer.
9. Åpne **Finn til prosjekt** og kontroller at skjermen fortsatt laster uten endringer i eksisterende kriterier/resultater.

## 158. Stoppunkt for første hurtigregistreringsblokk

**✅ STOPPUNKT**

Blokken er godkjent når alle disse er bekreftet:

- nytt tekstil kan fortsatt opprettes med bare navn
- kategori er ikke nødvendig i førstegangsregistreringen
- bilde kan velges fra Bilder før Textile opprettes
- kamera kan brukes direkte på fysisk iPhone
- forhåndsvisningen viser valgt/tatt bilde før lagring
- valgt bilde lagres som hovedbilde uten duplisert Textile
- plassering kan registreres valgfritt i samme hurtigflyt
- generelt Textile-notat kan lagres og vises på eksisterende tekstil
- notat inngår i fritekstsøk
- eldre Textile-records uten `notes` fungerer fortsatt
- eksisterende prosjekt-/Piece-funksjonalitet er ikke påvirket

**Ikke gå videre til neste del av punkt 3 (ny iPhone-hovedside med Nylig registrert og automatisk aktivert bibliotek) før punkt 158 er bekreftet.**

## 159. Legg inn devpatch 0056 – korrigering av bildeknapper

**✅ AKSJON – DU**

1. Legg inn filene fra `Tekstilig-devpatch-0056.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 som kjøredestinasjon.
4. Bygg og kjør appen.
5. Åpne **Nytt tekstil**.
6. Kontroller at **Ta bilde** vises som en tydelig prominent knapp med sentrert tekst og uten forskjøvet ikon-/tekstlayout.

Stopp på punkt 159 dersom prosjektet ikke bygger, appen ikke starter eller **Ta bilde** fortsatt ser feiljustert ut.

## 160. Retest bildebytte i hurtigregistreringen

**✅ AKSJON – DU**

1. Åpne **Nytt tekstil** på fysisk iPhone.
2. Trykk **Ta bilde**, ta et testbilde og bekreft bildet.
3. Kontroller at forhåndsvisningen vises.
4. Trykk **Ta nytt bilde**.
5. Kontroller at kamera åpnes.
6. Avbryt kameraet eller ta og bekreft et nytt testbilde.
7. Trykk **Velg annet**.
8. Kontroller at bildebiblioteket åpnes – ikke kameraet.
9. Velg et annet bilde fra Bilder.
10. Kontroller at forhåndsvisningen erstattes av bildet du nettopp valgte.
11. Skriv et unikt navn og trykk **Lagre**.
12. Åpne det lagrede tekstilet og kontroller at det sist valgte bildet er hovedbildet.

Punkt 160 er godkjent når **Ta nytt bilde** og **Velg annet** konsekvent åpner hver sin riktige kilde og begge kan erstatte forhåndsvisningen før lagring.

**Ikke gå videre til neste del av punkt 3 før punkt 159–160 er bekreftet.**

## 161. Legg inn devpatch 0057 – ny iPhone-hovedside

**✅ AKSJON – DU**

1. Legg inn filene fra `Tekstilig-devpatch-0057.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 som kjøredestinasjon.
4. Bygg og kjør appen.
5. Åpne fanen **Tekstiler**.
6. Kontroller at appen bygger og starter uten nye feil.

Stopp på punkt 161 dersom prosjektet ikke bygger eller appen ikke starter.

## 162. Valider normaltilstanden på iPhone-forsiden

**✅ AKSJON – DU**

1. Sørg for at søkefeltet er tomt og at ingen filtre er aktive.
2. Gå til fanen **Tekstiler**.
3. Kontroller at hele biblioteklisten ikke vises automatisk.
4. Kontroller at **Registrer nytt stoff** er en tydelig primærhandling.
5. Kontroller at seksjonen **Nylig registrert** vises når biblioteket har tekstiler.
6. Kontroller at **Vis alle tekstiler** vises.
7. Kontroller at **Finn til prosjekt** vises.
8. Kontroller at filterknappen fortsatt ligger øverst til venstre.

Stopp på punkt 162 dersom forsiden fortsatt domineres av hele biblioteklisten eller de låste hovedhandlingene mangler.

## 163. Valider Nylig registrert og bildevisning

**❗️ RETEST ETTER DEVPATCH 0058**

1. Kontroller at **Nylig registrert** viser maksimalt fem tekstiler.
2. Finn minst ett nylig tekstil med hovedbilde og kontroller at en kompakt thumbnail vises.
3. Finn om mulig et nylig tekstil uten bilde og kontroller at det vises en rolig bilde-placeholder uten feil.
4. Kontroller at navn vises tydelig under hvert kort.
5. Opprett eventuelt et nytt testtekstil og kontroller at det kommer først i **Nylig registrert** etter lagring.
6. Rediger et eldre tekstil uten å opprette det på nytt.
7. Kontroller at det gamle tekstilet ikke flyttes først bare på grunn av redigeringen.

## 164. Valider navigasjon fra Nylig registrert

**✅ AKSJON – DU**

1. Trykk på et tekstil i **Nylig registrert**.
2. Kontroller at korrekt tekstildetalj åpnes.
3. Kontroller at bilde og eksisterende metadata lastes som før.
4. Gå tilbake til tekstiloversikten.
5. Kontroller at oversikten fortsatt vises og at appen ikke har aktivert hele biblioteklisten uten grunn.

## 165. Valider Vis alle tekstiler

**✅ AKSJON – DU**

1. Trykk **Vis alle tekstiler**.
2. Kontroller at den komplette eksisterende tekstillisten vises.
3. Scroll i listen og åpne et tekstil.
4. Gå tilbake og kontroller at listen fortsatt fungerer som før.
5. Kontroller at en **Oversikt**-handling er tilgjengelig i verktøylinjen når listen er åpnet eksplisitt.
6. Trykk **Oversikt**.
7. Kontroller at den rolige hovedsiden vises igjen.

## 166. Valider automatisk liste ved søk

**✅ AKSJON – DU**

1. Start fra den rolige tekstiloversikten uten aktive filtre.
2. Trykk i søkefeltet.
3. Skriv en søketekst som gir minst ett kjent treff.
4. Kontroller at komplett resultatliste vises umiddelbart uten at **Vis alle tekstiler** må trykkes.
5. Kontroller at treffene fortsatt bruker eksisterende fritekstsøk, inkludert navn og andre registrerte søkbare egenskaper.
6. Fjern hele søketeksten.
7. Kontroller at visningen går tilbake til den rolige oversikten når **Vis alle tekstiler** ikke var aktivert manuelt.

## 167. Valider automatisk liste ved filter

**✅ AKSJON – DU**

1. Start fra den rolige tekstiloversikten med tomt søk.
2. Åpne filterknappen øverst til venstre.
3. Aktiver ett filter som gir kjente treff.
4. Lukk filtervisningen.
5. Kontroller at den komplette filtrerte resultatlisten vises uten at **Vis alle tekstiler** må trykkes.
6. Kontroller at filterikonet tydelig viser at filter er aktivt.
7. Åpne filtre igjen og nullstill alle filtre.
8. Lukk filtervisningen.
9. Kontroller at visningen går tilbake til den rolige oversikten når listen ikke var åpnet manuelt.

## 168. Valider kombinasjon av søk/filter og Finn til prosjekt

**✅ AKSJON – DU**

1. Aktiver et filter og skriv samtidig en søketekst.
2. Kontroller at resultatlisten følger både søk og filter som før.
3. Tøm søket og nullstill filteret.
4. Kontroller at oversikten vises igjen.
5. Trykk **Finn til prosjekt** på oversikten.
6. Kontroller at appen skifter til den eksisterende fanen **Finn til prosjekt**.
7. Utfør et enkelt kjent prosjektsøk og kontroller at eksisterende funksjonalitet fortsatt virker.
8. Gå tilbake til fanen **Tekstiler** og kontroller at tekstiloversikten fortsatt fungerer.

## 169. Stoppunkt for roadmap-punkt 3 – Rask registrering

**❗️ STOPPUNKT – avventer korrigeringstest 174**

Roadmap-punkt 3 kan markeres ferdig når alle disse er bekreftet:

- hurtigregistreringen fra test 150–160 fungerer fortsatt
- normal iPhone-start viser en rolig oversikt i stedet for hele biblioteket
- **Nylig registrert** viser inntil fem faktiske nyregistreringer med bilde/placeholder
- redigering alene endrer ikke hva som regnes som nylig registrert
- nylige tekstiler kan åpnes direkte
- **Vis alle tekstiler** åpner komplett bibliotek og kan gå tilbake til oversikten
- søk aktiverer resultatlisten uten ekstra handling
- filtre aktiverer resultatlisten uten ekstra handling
- søk og filter kan fortsatt kombineres
- **Finn til prosjekt** åpner eksisterende prosjektfunksjon
- ingen eksisterende detalj-, Piece-, reservasjons- eller prosjektsøkfunksjon er brutt

**Ikke gå videre til roadmap-punkt 4 før punkt 161–169 er eksplisitt validert.**


## 170. Legg inn devpatch 0058 – korrigering før punkt 3 avsluttes

**✅ AKSJON – DU**

1. Legg inn filene fra `Tekstilig-devpatch-0058.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 som kjøredestinasjon.
4. Bygg og kjør appen.
5. Gå til fanen **Tekstiler** med tomt søk og uten aktive filtre.
6. Kontroller at den rolige hovedsiden vises.

Stopp på punkt 170 dersom prosjektet ikke bygger, appen ikke starter eller tekstiloversikten ikke vises normalt.

## 171. Retest umiddelbar thumbnail etter hurtigregistrering

**✅ AKSJON – DU**

1. Trykk `+` øverst på tekstilsiden.
2. Ta et tydelig bilde med kamera.
3. Skriv et unikt navn.
4. Trykk **Lagre**.
5. Vent til registreringsarket lukkes.
6. Kontroller at det nye tekstilet ligger først under **Nylig registrert**.
7. Kontroller at thumbnail-bildet vises med én gang uten omstart, manuell refresh eller ny navigasjon.

Punkt 171 er godkjent når både tekstilet og hovedbildet er synlige umiddelbart etter lagring.

## 172. Valider kamera og Bilder på eksisterende tekstil

**✅ AKSJON – delvis validert; første kameraforsøk kunne lukkes umiddelbart**

1. Åpne et eksisterende tekstil som ikke har hovedbilde.
2. Finn seksjonen **Hovedbilde**.
3. Kontroller at **Ta bilde** er tilgjengelig på fysisk iPhone/iPad.
4. Trykk **Ta bilde**, ta et testbilde og bekreft det.
5. Kontroller at bildet lagres og vises som hovedbilde.
6. Trykk **Velg annet** eller tilsvarende bildevalg etter at hovedbildet finnes.
7. Kontroller at bildebiblioteket åpnes.
8. Velg et annet bilde og kontroller at hovedbildet erstattes.
9. Kontroller at bildeoperasjonene ikke lager et nytt Textile-record.

Punkt 172 er godkjent når eksisterende tekstiler kan få eller bytte hovedbilde både fra kamera og Bilder, og bildet lagres gjennom samme JPEG-optimalisering som hurtigregistreringen.

## 173. Valider ryddet hovedside og filterverktøylinje

**✅ AKSJON – DU**

1. Gå tilbake til den rolige tekstiloversikten.
2. Kontroller at den store **Registrer nytt stoff**-knappen ikke lenger vises på hovedsiden.
3. Kontroller at `+` i topplinjen fortsatt åpner **Nytt tekstil**.
4. Kontroller at den store **Finn til prosjekt**-knappen ikke lenger vises på hovedsiden.
5. Kontroller at fanen **Finn til prosjekt** nederst fortsatt åpner prosjektfunksjonen som før.
6. Kontroller at **Vis alle tekstiler** fortsatt er tilgjengelig på hovedsiden.
7. Åpne filtervisningen.
8. Kontroller at **Nullstill** står øverst til venstre og **Ferdig** øverst til høyre.
9. Kontroller at **Nullstill** er deaktivert når ingen filter er aktive.
10. Aktiver minst ett filter og kontroller at **Nullstill** blir aktiv.
11. Trykk **Nullstill** og kontroller at alle filterverdier går tilbake til standard uten at filterarket lukkes.
12. Trykk **Ferdig** og kontroller at filterarket lukkes normalt.

Punkt 170, 171 og 173 er validert. Punkt 172 avdekket at kameraet på et eksisterende tekstil uten bilde kunne vises kort og deretter lukkes på første forsøk. Retest dette i punkt 174 før roadmap-punkt 3 avsluttes.


## 174. Retest stabil kameraåpning på eksisterende tekstil uten bilde

**✅ AKSJON – DU**

1. Legg inn `Tekstilig-devpatch-0059.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 og bygg/kjør appen.
4. Åpne et eksisterende tekstil som ikke har hovedbilde.
5. Trykk **Ta bilde** én gang.
6. Kontroller at kameraet åpnes og forblir stabilt åpent på første forsøk.
7. Avbryt kameraet og kontroller at du returnerer normalt til tekstildetaljen.
8. Trykk **Ta bilde** på nytt, ta et bilde og bekreft det.
9. Kontroller at bildet optimaliseres, lagres og vises som hovedbilde som før.

Punkt 174 er **ikke godkjent**. Testen viste at kameraet fortsatt kunne åpnes og lukkes igjen på første forsøk for hvert tekstil, selv med `fullScreenCover`. Andre åpning var stabil. Dette viser at problemet ikke bare skyldes presentasjonstypen.

## 175. Retest kamera med presentasjon eid av TextileDetailView

**✅ AKSJON – DU**

1. Legg inn `Tekstilig-devpatch-0060.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 og bygg/kjør appen.
4. Åpne et eksisterende tekstil uten hovedbilde.
5. Trykk **Ta bilde** én gang.
6. Kontroller at kameraet åpnes og forblir stabilt åpent på første forsøk.
7. Avbryt kameraet og kontroller at du returnerer normalt til samme tekstildetalj.
8. Gå til et **annet** eksisterende tekstil uten hovedbilde.
9. Trykk **Ta bilde** én gang og kontroller at kameraet også her er stabilt allerede på første forsøk.
10. Avbryt, gå tilbake til ett av tekstilene og ta et bilde.
11. Kontroller at bildet optimaliseres, lagres og vises som hovedbilde som før.
12. Kontroller at **Velg fra Bilder** fortsatt fungerer på samme tekstil.

Punkt 175 er godkjent når kameraet er stabilt på første åpning for minst to forskjellige tekstiler, og både avbryt, bildeopptak og Bilder fungerer normalt.

Når punkt 175 er validert, kan punkt 172 og stoppunkt 169 markeres ✅ og roadmap-punkt 3 **Rask registrering** avsluttes.

## 176. Retest 0061 – bygg og stabil kameraåpning

**✅ AKSJON – DU**

1. Legg inn `Tekstilig-devpatch-0061.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPhone med iOS 27 og bygg prosjektet.
4. Kontroller at `TextileDetailView` bygger uten typecheck-feilen fra 0060.
5. Kjør appen.
6. Åpne et eksisterende tekstil uten hovedbilde.
7. Trykk **Ta bilde** én gang.
8. Kontroller at kameraet åpnes og forblir stabilt åpent på første forsøk.
9. Avbryt kameraet og kontroller at du returnerer normalt til samme tekstildetalj.
10. Gå til et annet eksisterende tekstil uten hovedbilde.
11. Trykk **Ta bilde** én gang og kontroller at kameraet også her er stabilt på første forsøk.
12. Ta og bekreft et bilde på ett av tekstilene.
13. Kontroller at bildet optimaliseres, lagres og vises som hovedbilde.
14. Kontroller at **Velg fra Bilder** fortsatt fungerer.

Punkt 176 er godkjent når både build og første kameraåpning fungerer stabilt for minst to forskjellige tekstiler.

Punkt 175 ble ikke funksjonstestet fordi devpatch 0060 ikke bygget i Xcode 27. Når punkt 176 er validert, kan punkt 172 og stoppunkt 169 markeres ✅ og roadmap-punkt 3 **Rask registrering** avsluttes.

## 177. Retest 0062 – korrekt target-path, build og stabil kameraåpning

**✅ AKSJON – DU**

1. Legg inn `Tekstilig-devpatch-0062.zip` i prosjektet med samme relative plassering.
2. Slett `Features/Library/TextileDetailView.swift` i prosjektroten dersom filen finnes der. Ikke slett `Tekstilig/Features/Library/TextileDetailView.swift`.
3. Åpne prosjektet i Xcode 27.
4. Velg en fysisk iPhone med iOS 27 som kjøredestinasjon.
5. Bygg prosjektet.
6. Kontroller at `TextileDetailView` bygger uten feilen `The compiler is unable to type-check this expression in reasonable time`.
7. Kjør appen.
8. Åpne et eksisterende tekstil uten hovedbilde.
9. Trykk **Ta bilde** én gang.
10. Kontroller at kameraet åpnes og forblir stabilt på første forsøk.
11. Avbryt kameraet og kontroller at du returnerer normalt til samme tekstildetalj.
12. Gå til et annet eksisterende tekstil uten hovedbilde.
13. Trykk **Ta bilde** én gang og kontroller at kameraet også her er stabilt på første forsøk.
14. Ta og bekreft et bilde på ett av tekstilene.
15. Kontroller at bildet optimaliseres, lagres og vises som hovedbilde.
16. Kontroller at **Velg fra Bilder** fortsatt fungerer.

Punkt 177 er godkjent når både build og første kameraåpning fungerer stabilt for minst to forskjellige tekstiler.

Punkt 176 regnes som build-blokkert av feil relativ filplassering i devpatch 0060/0061, ikke som en funksjonell test av kameraarkitekturen. Når punkt 177 er validert, kan punkt 172 og stoppunkt 169 markeres ✅ og roadmap-punkt 3 **Rask registrering** avsluttes.


## 178. Fastsett kriterier for «Kan kompletteres»

**✅ BESLUTTET**

Et tekstil regnes som **Kan kompletteres** dersom minst ett av disse fire kriteriene mangler:

- hovedbilde
- materiale
- kategori
- lagringssted

Farge, Piece/dimensjoner, vekt, elastisitet, krymp, vedlikehold og notat gjør ikke i seg selv registreringen ufullstendig.

Statusen skal være en diskret hjelp og ikke presenteres som feil eller advarsel. Biblioteket skal kunne filtreres på **Kan kompletteres**, og detaljvisningen skal forklare hvilke av de fire feltene som mangler.

## 179. Legg inn devpatch 0064 og bygg

**✅ VALIDERT**

1. Legg inn filene fra `Tekstilig-devpatch-0064.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg fysisk test-iPhone som kjøredestinasjon.
4. Bygg og kjør appen.
5. Kontroller at biblioteket og eksisterende tekstiler åpnes normalt.

Resultat: validert OK av bruker.

## 180. Valider status i full tekstilliste

**✅ VALIDERT**

1. Åpne **Vis alle tekstiler**.
2. Finn et tekstil som mangler minst ett av hovedbilde, materiale, kategori eller lagringssted.
3. Kontroller at tekstilet viser **Kan kompletteres**.
4. Finn et tekstil som har alle fire kriteriene.
5. Kontroller at dette tekstilet ikke viser statusen.

Resultat: validert OK av bruker.

## 181. Valider filter «Kan kompletteres»

**✅ VALIDERT**

1. Åpne **Filtre**.
2. Aktiver **Kan kompletteres**.
3. Kontroller at bare tekstiler som mangler minst ett av de fire kriteriene vises.
4. Nullstill filteret.
5. Kontroller at vanlig tekstilliste gjenopprettes.

Resultat: validert OK av bruker.

## 182. Valider forklaring i detaljvisning

**✅ VALIDERT**

1. Åpne et tekstil som er markert **Kan kompletteres**.
2. Finn seksjonen **Registrering**.
3. Kontroller at detaljvisningen konkret oppgir hvilke av de fire kriteriene som mangler.

Resultat: validert OK av bruker.

## 183. Valider oppdatering etter komplettering

**✅ VALIDERT**

1. Legg til eller rediger ett eller flere manglende kriterier.
2. Kontroller at detaljstatusen oppdateres etter lagring.
3. Fyll inn alle fire kriteriene på et testtekstil.
4. Kontroller at **Kan kompletteres** forsvinner.
5. Gå tilbake til biblioteket.
6. Kontroller at status og filtergrunnlag oppdateres uten app-omstart.

Resultat: validert OK av bruker.

**Observasjon – iOS/iPadOS 27:** Xcode kan logge `-[UIApplication setStatusBarHidden:animationParameters:] API has been deprecated and is a no-op on 27.0 and later.` Det finnes ikke et direkte kall til dette API-et i Tekstilig-koden. Ingen funksjonell feil er observert. Ingen spekulativ kodeendring gjøres nå.

## 184. Valider «Kan kompletteres» på iPad

**✅ AKSJON – DU**

Roadmap-punkt 4 skal fungere godt også på større skjerm. Test den allerede implementerte funksjonen før ny kode skrives.

1. Bruk siste fungerende kode der devpatch 0064 er implementert.
2. Åpne prosjektet i Xcode 27.
3. Velg en fysisk iPad med iPadOS 27 som kjøredestinasjon.
4. Bygg og kjør appen.
5. Åpne **Vis alle tekstiler**.
6. Kontroller at **Kan kompletteres** vises tydelig, men diskret, uten å bryte radlayouten.
7. Åpne **Filtre** og aktiver **Kan kompletteres**.
8. Kontroller at filtreringen fungerer som på iPhone.
9. Åpne et ufullstendig tekstil.
10. Kontroller at seksjonen **Registrering** og listen over mangler er lett å lese og ikke får uheldig layout på iPad.
11. Fyll inn ett manglende felt og lagre.
12. Kontroller at statusen oppdateres som forventet.

**Stopp på punkt 184 dersom layout, navigasjon eller oppdatering av status avviker fra iPhone. Ikke gå videre til punkt 185 før punkt 184 er validert.**

## 185. Valider «Kan kompletteres» på Mac

**✅ VALIDERT – første vellykkede native macOS-build**

Punkt 184 er validert på iPad. Punkt 185 er første gang den native macOS-appen bygges som del av 1.0-løpet. Første buildforsøk stoppet i `PieceEditorView.swift` på ubetinget UIKit-avhengighet. Devpatch 0066 gjorde denne Piece-editor-hjelpekoden plattformbetinget.

Neste build kom lenger, men stoppet på fem macOS-inkompatible SwiftUI-modifikatorer:

```text
TextileLibraryView:
- 'NavigationBarDrawer(displayMode:)' is unavailable in macOS
- 'topBarLeading' is unavailable in macOS
- TextField has no member 'textInputAutocapitalization'

TextileLocationEditorView:
- TextField has no member 'textInputAutocapitalization'

TextilePhysicalPropertiesEditorView:
- TextField has no member 'keyboardType'
```

Devpatch 0067 gjør disse og øvrige forekomster av samme type iOS-spesifikke tekst-/tastaturmodifikatorer plattformbetinget. iPhone/iPad beholder eksisterende oppførsel; på macOS brukes standard macOS-søkefelt, toolbarplassering og tastatur-/tekstfeltoppførsel. Ingen Textile-, Piece-, reservasjons-, søke- eller CloudKit-logikk endres.

Etter 0067 kom macOS-kompileringen videre, men stoppet i `TextileLibraryView` med `Branches have mismatching types`. Feilen ligger i den beregnede `libraryListContent`, som kan returnere enten `ContentUnavailableView` eller `List`. Devpatch 0068 markerer denne egenskapen eksplisitt med `@ViewBuilder`, slik at SwiftUI kan bygge de alternative view-grenene korrekt på macOS. Ingen søke-, filter-, Textile-, Piece- eller CloudKit-logikk endres.

1. Legg inn `Tekstilig-devpatch-0068.zip` i prosjektet med samme relative plassering.
2. Åpne prosjektet i Xcode 27.
3. Velg macOS-appen som kjøredestinasjon på Apple Silicon Mac.
4. Bygg prosjektet.
5. Kontroller at build ikke lenger stopper på de fem feilene listet over.
6. Dersom build fortsatt feiler, stopp her og rapporter **første reelle byggfeil**. Ikke fortsett med funksjonstestene nedenfor.
7. Når build lykkes, kjør appen.
8. Åpne komplett tekstilliste.
9. Kontroller at **Kan kompletteres** vises uten å forstyrre den eksisterende Mac-/split-view-layouten.
10. Aktiver filteret **Kan kompletteres**.
11. Kontroller at bare ufullstendige tekstiler vises.
12. Åpne et ufullstendig tekstil.
13. Kontroller at **Registrering** viser de manglende feltene tydelig.
14. Kompletter minst ett manglende felt og lagre.
15. Kontroller at detaljvisning og bibliotekstatus oppdateres uten app-omstart.
16. Åpne et eksisterende stoffstykke dersom Mac-UI-et tillater dette, og kontroller at Piece-editoren åpnes uten at eksisterende Piece-data endres utilsiktet.

**Stopp på punkt 185 dersom build, layout, navigasjon eller statusoppdatering feiler. Ikke gå videre til punkt 186 før punkt 185 er eksplisitt validert.**

## 186. Stoppunkt for roadmap-punkt 4 – Ufullstendige registreringer

**✅ FULLFØRT**

Roadmap-punkt 4 kan markeres ferdig når alle disse er eksplisitt bekreftet:

- kriteriene fra punkt 178 er fortsatt riktige
- test 179–183 er validert på fysisk iPhone
- test 184 er validert på iPad
- test 185 er validert på Mac
- **Kan kompletteres** er diskret og forståelig på alle tre plattformer
- filteret fungerer på alle tre plattformer
- detaljvisningen forklarer hva som mangler
- statusen oppdateres etter komplettering uten app-omstart
- eksisterende Textile-, bilde-, Piece-, reservasjons- og prosjektsøkfunksjon er ikke brutt

**Roadmap-punkt 4 er validert og avsluttet. Arbeidet fortsetter sekvensielt med punkt 187 og roadmap-punkt 5 – iCloud-/CloudKit-robusthet.**

## 187. Legg inn devpatch 0069 – første iCloud-/CloudKit-robusthetsblokk

**✅ AKSJON – DU**

Roadmap-punkt 4 er nå validert på iPhone, iPad og Mac og avsluttes. Devpatch 0069 starter roadmap-punkt 5 med den første, avgrensede robusthetsblokken for lasting av selve tekstilbiblioteket.

Denne patchen skal ikke endre Textile-data, søk, filtre, bilder, Piece eller CloudKit-schema. Den gjør bare tre ting i bibliotekets første last:

- oversetter vanlige CloudKit-feil til forståelige brukerbeskjeder
- beholder **Prøv igjen** ved faktisk lastefeil
- erstatter en langvarig, uforklart spinner med **Venter på iCloud** dersom første lasting fortsatt pågår etter omtrent åtte sekunder

1. Legg inn `Tekstilig-devpatch-0069.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27.
3. Velg fysisk test-iPhone med iOS 27 som kjøredestinasjon.
4. Bygg prosjektet.
5. Kjør appen med vanlig fungerende nettverk og iCloud-oppsett.
6. Kontroller at biblioteket åpnes normalt og at eksisterende tekstiler fortsatt vises.
7. Åpne minst ett eksisterende tekstil og gå tilbake til biblioteket.
8. Kontroller at søk og filter fortsatt kan aktiveres normalt.

**Stopp på punkt 187 dersom prosjektet ikke bygger eller normal biblioteklast er endret/broken. Ikke gå videre til punkt 188 før punkt 187 er validert.**

## 188. Valider forståelig tilstand uten nettverk

**✅ AKSJON – DU**

Denne testen skal utføres på test-iPhone, ikke på Mac-en som inneholder prosjektfilene.

1. Avslutt Tekstilig helt på test-iPhone.
2. Slå av Wi-Fi og mobildata på test-iPhone slik at enheten ikke har nettverk.
3. Start Tekstilig på nytt.
4. Observer første lasting av tekstilbiblioteket.
5. Dersom CloudKit returnerer nettverksfeilen raskt, kontroller at appen viser en forståelig iCloud-/nettverksmelding i stedet for rå `CloudKit-feil <nummer>`.
6. Dersom CloudKit ikke har returnert feil etter omtrent åtte sekunder, kontroller at **Henter tekstiler …** erstattes av **Venter på iCloud** med forklaring om nettverk/iCloud/iCloud Drive.
7. Kontroller at appen ikke blir stående med bare en uforklart spinner.
8. Slå på Wi-Fi eller mobildata igjen.
9. Hvis **Prøv igjen** vises, trykk den.
10. Kontroller at tekstilbiblioteket lastes normalt når nettverket er tilbake.

**Stopp på punkt 188 dersom appen fortsatt bare viser en uforklart spinner, viser en rå teknisk CloudKit-feil som hovedbeskjed, eller ikke kan hente biblioteket igjen etter at nettverket er tilbake.**

## 189. Regresjonstest etter gjenopprettet iCloud-tilgang

**✅ AKSJON – DU**

1. Sørg for at test-iPhone igjen har normalt nettverk.
2. Avslutt og start Tekstilig på nytt.
3. Kontroller at biblioteket lastes uten at feiltilstanden fra punkt 188 blir hengende igjen.
4. Åpne **Vis alle tekstiler**.
5. Kontroller at **Kan kompletteres** fortsatt vises korrekt.
6. Aktiver og nullstill filteret **Kan kompletteres**.
7. Åpne et eksisterende tekstil og kontroller at detaljvisningen fortsatt laster som før.
8. Gå tilbake til biblioteket og kontroller at normal navigasjon fungerer.

Når punkt 187–189 er validert, er første robusthetsblokk for biblioteklast godkjent. Neste blokk skal eksplisitt teste og håndtere iCloud/iCloud Drive-tilgjengelighet og deretter spre samme forståelige feilpresentasjon til bilde-, attributt- og Piece-last uten å endre datamodellen.

### Observasjon etter punkt 189

**✅ Punkt 187–189 er validert.** Etter gjenopprettet nettverk/iCloud lastet selve tekstilbiblioteket igjen, men metadataene som brukes av **Kan kompletteres** måtte hentes på nytt med manuell refresh før statusen og filteret var tilgjengelig. Dette blokkerer ikke valideringen av punkt 187–189, men følges opp direkte i punkt 190.

## 190. Legg inn devpatch 0070 – last kompletteringsmetadata på nytt etter «Prøv igjen»

**✅ VALIDERT**

Devpatch 0070 bygger på `Tekstilig-SwiftUIActualApp0038.zip` og retter bare gjenopprettingen etter en bibliotekfeil. Når **Prøv igjen** brukes, skal appen nå hente både Textile-listen og de eksisterende materiale-/farge- og bildemetadataene som brukes av **Kan kompletteres**.

1. Legg inn `Tekstilig-devpatch-0070.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27.
3. Velg fysisk test-iPhone med iOS 27 som kjøredestinasjon.
4. Bygg og kjør appen med normalt nettverk og kontroller at biblioteket åpnes som før.
5. Avslutt Tekstilig helt.
6. Slå av Wi-Fi og mobildata på test-iPhone.
7. Start Tekstilig og vent til den viser feil-/ventetilstanden fra punkt 188.
8. Slå på nettverk igjen.
9. Dersom **Prøv igjen** vises, trykk den én gang.
10. Vent til biblioteket er ferdig lastet.
11. Åpne **Vis alle tekstiler** uten å utføre pull-to-refresh eller annen manuell refresh.
12. Kontroller at tekstiler som mangler ett av kriteriene fortsatt viser **Kan kompletteres**.
13. Åpne **Filtre**.
14. Kontroller at filteret **Kan kompletteres** kan aktiveres uten manuell refresh.
15. Aktiver filteret og kontroller at forventede tekstiler vises.
16. Nullstill filteret og kontroller at vanlig liste gjenopprettes.

**Stopp på punkt 190 dersom manuell refresh fortsatt er nødvendig for å få tilbake «Kan kompletteres»-status eller filteret etter «Prøv igjen». Ikke gå videre til neste robusthetsblokk før punkt 190 er validert.**

## 191. Legg inn devpatch 0071 – forståelige feil i detaljdata

**✅ VALIDERT**

Devpatch 0071 bygger på `Tekstilig-SwiftUIActualApp0039.zip`. Punkt 190 er validert. Denne blokken endrer bare presentasjonen av CloudKit-feil ved lasting av tre eksisterende detaljdatasett:

- hovedbilde
- materiale og farge
- stoffstykker

De tre modellene gjenbruker nå samme `CloudKitUserFacingError` som biblioteket. Ingen repository-, lagrings-, Textile-, Piece-, bilde- eller CloudKit-schema-logikk endres.

1. Legg inn `Tekstilig-devpatch-0071.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27.
3. Velg fysisk test-iPhone med iOS 27 som kjøredestinasjon.
4. Bygg prosjektet.
5. Kjør appen med normalt nettverk og fungerende iCloud.
6. Åpne et eksisterende tekstil som har hovedbilde, minst ett materiale og minst ett stoffstykke.
7. Kontroller at hovedbilde, materiale/farge og stoffstykker lastes som før.
8. Gå tilbake til biblioteket.

**Stopp på punkt 191 dersom prosjektet ikke bygger eller noen av de tre detaljseksjonene ikke lenger laster normalt. Ikke gå videre til punkt 192 før punkt 191 er validert.**

## 192. Valider detaljfeil uten nettverk

**✅ VALIDERT ETTER DEVPATCH 0077**

Første gjennomføring av punkt 192 viste tre forhold som skal korrigeres før punkt 193:

- redigering/lagring av selve Textile kunne vise rå `CKErrorDomain error 3` uten nettverk
- **Materialer** viste en forståelig feil, mens **Farger** ikke viste tilsvarende overordnet lastefeil; lagring av farge kunne også vise rå CloudKit-feil
- ved scrolling fra bunnen og oppover i tekstildetaljen kunne visningen hoppe og bli stående i en scroll-loop rundt **Fysiske egenskaper**

Devpatch 0072 gjør målrettet følgende:

- bruker samme forståelige `CloudKitUserFacingError` ved lagring av Textile og farge
- viser eksplisitt feiltilstand også i Farger-seksjonen
- markerer automatiske detaljlastinger for hovedbilde, materiale/farge og stoffstykker som forsøkt også når de feiler, slik at scrolling/rebygging av List-seksjoner ikke starter samme mislykkede CloudKit-last om igjen
- **Prøv igjen** starter fortsatt en eksplisitt ny last når brukeren velger det

Ingen datamodell, repository- eller CloudKit-schema-logikk endres.

1. Legg inn `Tekstilig-devpatch-0072.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27, velg fysisk test-iPhone og bygg/kjør appen.
3. Med normalt nettverk: åpne et eksisterende tekstil, scroll helt til bunnen og deretter helt til toppen. Kontroller at scrolling er normal før offline-testen starter.
4. Gå tilbake til biblioteket og sørg for at det er ferdig lastet med normalt nettverk.
5. Slå av Wi-Fi og mobildata på test-iPhone. Ikke avslutt appen.
6. Åpne et eksisterende tekstil fra den allerede innlastede listen.
7. Vent på lasting av **Hovedbilde**, **Materialer/Farger** og **Stoffstykker**.
8. Kontroller at en eventuell feil i hovedbildeseksjonen er formulert som forståelig nettverk/iCloud-feil og ikke som rå CloudKit-feil.
9. Kontroller at både **Materialer** og **Farger** gir en forståelig feiltilstand når den felles attributtlasten feiler.
10. Kontroller det samme for **Stoffstykker** dersom denne lasten feiler.
11. Mens nettverket fortsatt er av: scroll helt til bunnen av tekstildetaljen og deretter oppover forbi **Fysiske egenskaper** minst to ganger. Kontroller at visningen ikke hopper tilbake eller kommer i en scroll-loop.
12. Trykk **Rediger** på tekstilet, endre kategori og forsøk **Lagre**. Kontroller at feilen beskriver iCloud/nettverk forståelig og ikke viser `CKErrorDomain error 3`. Avbryt editoren etter kontrollen.
13. Åpne eller legg til en farge og forsøk **Lagre**. Kontroller at også denne feilen er forståelig og ikke viser rå CloudKit-feil. Avbryt editoren etter kontrollen.
14. Kontroller til slutt at selve tekstildetaljen fortsatt er lesbar og navigerbar selv om CloudKit-delene har feil.

CloudKit kan i enkelte tilfeller levere cachede data selv uten nettverk. Det er tilstrekkelig at kallene som faktisk feiler bruker den forståelige feilpresentasjonen.

**Stopp på punkt 192 dersom en av de observerte rå feilene fortsatt vises, Farger mangler feiltilstand, scrolling fortsatt går i loop, eller detaljvisningen blir ubrukelig. Ikke slå på nettverket og gå videre til punkt 193 før punkt 192 er eksplisitt validert.**

### Resultat etter devpatch 0072

Build og scrolling er validert. Scroll-loopen rundt **Fysiske egenskaper** er løst, og redigering av selve Textile viser forståelig offline-feil. Retesten avdekket to resterende forhold:

- **Materialer/Farger** brukte én felles lastestatus. Når begge kall feilet offline ble samme nettverksproblem kommunisert både under Materialer og Farger. Etter at nettverket kom tilbake kunne materiallasten lykkes mens fargelasten fortsatt stod med egen feiltilstand.
- **Rediger plassering** brukte fortsatt `localizedDescription` direkte og kunne derfor vise rå `CKErrorDomain` ved lagring offline.

Devpatch 0073 skiller lastefeil for materialer og farger. Dersom begge feiler samtidig og ingen data er lastet, vises én felles feiltilstand i stedet for dobbeltkommunikasjon. Dersom bare ett datasett feiler, vises feilen bare i riktig seksjon, og **Prøv igjen** laster bare det aktuelle datasettet. Plasseringseditoren bruker samme brukerrettede CloudKit-feiloversettelse som de øvrige editorene.

Retest punkt 192 slik:

1. Legg inn `Tekstilig-devpatch-0073.zip` med vanlig dry-run og rsync.
2. Bygg og kjør med normalt nettverk.
3. Åpne et tekstil med registrert materiale. Kontroller at Materialer og Farger ikke viser feil ved normal last.
4. Slå av Wi-Fi og mobildata uten å avslutte appen, og åpne et annet allerede innlastet tekstil.
5. Hvis både materiale- og fargelast feiler, kontroller at nettverksproblemet vises **én gang** som en felles feiltilstand, ikke som to nesten like feilmeldinger.
6. Slå nettverket på igjen og bruk **Prøv igjen**. Kontroller at materialer og farger lastes tilbake og at gammel feiltilstand forsvinner.
7. Slå nettverket av igjen. Åpne **Rediger plassering**, gjør en ufarlig endring og trykk **Lagre**. Kontroller at feilen er forståelig og ikke viser `CKErrorDomain`. Avbryt editoren etter kontrollen.
8. Scroll tekstildetaljen helt ned og opp forbi **Fysiske egenskaper** og kontroller at scroll-loopen fortsatt er borte.

**Stopp fortsatt på punkt 192 dersom én av disse kontrollene feiler. Punkt 193 skal ikke kjøres før denne retesten er eksplisitt validert.**

### Resultat etter devpatch 0073

Dobbeltkommunikasjonen for Materialer/Farger er samlet til én felles feiltilstand når begge kall feiler. Retesten avdekket likevel at første attributtlast etter appoppstart i enkelte tilfeller kan få en kortvarig CloudKit nettverks-/servicefeil selv om testtelefonen allerede har nettverk. Da blir Materialer/Farger stående i feiltilstand til brukeren velger **Prøv igjen**.

Devpatch 0074 endrer bare den automatiske førstegangs-lastingen av materiale og farge: ved en CloudKit-feil som eksplisitt er klassifisert som midlertidig (`networkUnavailable`, `networkFailure`, `serviceUnavailable`, `zoneBusy` eller `requestRateLimited`) venter modellen kort og gjør **ett** automatisk nytt forsøk før feiltilstanden vises. Andre feil retries ikke automatisk. Manuell **Prøv igjen** beholdes uendret dersom også andre forsøk feiler.

Retest punkt 192 slik:

1. Legg inn `Tekstilig-devpatch-0074.zip` med vanlig dry-run og rsync.
2. Sørg for at test-iPhone har normalt fungerende nettverk og iCloud.
3. Avslutt Tekstilig helt og start appen på nytt.
4. Åpne et eksisterende tekstil med registrert materiale.
5. Kontroller at **Materialer og farger** lastes uten at en kortvarig første CloudKit-feil blir stående som permanent feiltilstand.
6. Gjenta full avslutning/start og åpning av tekstildetaljen minst én gang til.
7. Slå av Wi-Fi og mobildata uten å avslutte appen, og åpne et annet allerede innlastet tekstil.
8. Kontroller at en reell offline-feil fortsatt ender i den forståelige felles feiltilstanden etter det ene automatiske forsøket, og at appen ikke står i en retry-loop.
9. Slå nettverket på igjen og trykk **Prøv igjen**. Kontroller at Materialer/Farger lastes og at feiltilstanden forsvinner.
10. Slå nettverket av igjen, åpne **Rediger plassering**, gjør en ufarlig endring og trykk **Lagre**. Kontroller at feilen er brukerrettet og ikke viser `CKErrorDomain`.
11. Scroll helt ned og opp forbi **Fysiske egenskaper** og kontroller at scroll-loopen fortsatt er borte.

**Stopp på punkt 192 dersom normal førstegangs-last fortsatt blir stående i feil, offline-testen går i automatisk retry-loop, Rediger plassering viser rå CloudKit-feil, eller scroll-problemet kommer tilbake. Punkt 193 er fortsatt sperret til punkt 192 er eksplisitt validert.**

### Diagnostisk retest etter devpatch 0075

Devpatch 0074 løste ikke førstegangsfeilen for **Materialer og farger**. Andre CloudKit-data lastes normalt med nettverk tilgjengelig, så flere automatiske retries skal ikke legges inn før den faktiske feilen er identifisert. Devpatch 0075 er derfor kun diagnostikk for attributtlasten. Brukergrensesnitt og lagringslogikk endres ikke.

1. Legg inn `Tekstilig-devpatch-0075.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27 og velg fysisk test-iPhone.
3. Vis Xcode-konsollen.
4. Sørg for at telefonen har normalt nettverk og fungerende iCloud.
5. Avslutt Tekstilig helt og start appen på nytt fra Xcode.
6. Åpne ett eksisterende tekstil som reproduserer feilen **Kunne ikke hente materiale og farge**.
7. Vent til feilen vises.
8. Finn konsollinjene som starter med `[Tekstilig][Attributes]`.
9. Kopier hele denne sammenhengende diagnostikkblokken tilbake til utviklingsloggen/chatten. Ta med `NSError domain/code`, `CKError code/name`, eventuell `partialErrors` og eventuell `underlying`-linje.
10. Stopp testen her. Ikke gå videre til punkt 193 før årsaken er analysert og punkt 192 er validert.

**Devpatch 0075 skal ikke regnes som en funksjonell retting. Den skal bare gjøre den underliggende CloudKit-feilen synlig i Xcode-konsollen uten å vise teknisk diagnostikk til sluttbrukeren.**

## 193. Valider gjenoppretting av detaljdata

**✅ AKSJON – DU**

1. Slå på Wi-Fi eller mobildata igjen.
2. I hver detaljseksjon som viser feil, trykk **Prøv igjen** én gang.
3. Kontroller at hovedbildet lastes tilbake dersom hovedbildeseksjonen feilet.
4. Kontroller at materiale/farge lastes tilbake dersom attributtseksjonen feilet.
5. Kontroller at stoffstykkene lastes tilbake dersom Piece-seksjonen feilet.
6. Kontroller at ingen duplikate bilder, materialer, farger eller stoffstykker blir opprettet av gjenlastingen.
7. Gå tilbake til biblioteket og kontroller at vanlig navigasjon fortsatt fungerer.

**Når punkt 191–193 er validert, er den felles feilpresentasjonen for bibliotekets og detaljvisningens viktigste lesekall godkjent. Neste blokk skal eksplisitt teste iCloud-konto/iCloud Drive-utilgjengelighet før roadmap-punkt 5 vurderes avsluttet.**


### Diagnoseresultat etter devpatch 0075 og retest med devpatch 0076

Diagnostikken viste at normal førstegangs-last med fungerende nettverk ikke feilet med en nettverksfeil. Begge kallene ble kansellert av CloudKit:

```text
CKErrorDomain code=20
Operation ... was cancelled
```

`CKError` kode 20 er `operationCancelled`. Dette passer med at attributtlasten kjøres fra en SwiftUI `.task` på en del av detaljvisningen som kan bli kansellert når `List`/seksjoner bygges på nytt. Modellen behandlet tidligere denne kanselleringen som en vanlig CloudKit-feil og satte samtidig `loadedTextileID` før lastingen var ferdig. Dermed kunne den kansellerte lasten bli stående som permanent feiltilstand og automatisk ny last ble sperret.

Devpatch 0076 retter bare denne cancellation-håndteringen:

- `operationCancelled` og Swift `CancellationError` vises ikke som nettverk/iCloud-feil
- en kansellert automatisk last markerer ikke tekstilet som ferdig lastet
- `loadedTextileID` settes først når den automatiske attributtlasten har nådd en stabil slutt
- kansellering under den korte transient-retry-ventingen svelges ikke
- reelle CloudKit-feil bruker fortsatt eksisterende brukerrettede feilpresentasjon

#### Retest punkt 192 etter devpatch 0076

1. Legg inn `Tekstilig-devpatch-0076.zip` med vanlig dry-run og rsync.
2. Sørg for at test-iPhone har normalt nettverk og fungerende iCloud.
3. Åpne prosjektet i Xcode 27, bygg og kjør på fysisk test-iPhone.
4. Avslutt Tekstilig helt og start appen på nytt fra Xcode.
5. Åpne et eksisterende tekstil med registrert materiale og/eller farge.
6. Kontroller at **Materialer/Farger** lastes normalt og at `operationCancelled` ikke blir stående som brukerrettet feiltilstand.
7. Gjenta full avslutning/start og åpning av samme eller et annet tekstil minst én gang.
8. Slå deretter av Wi-Fi og mobildata uten å avslutte appen, og åpne et annet allerede innlastet tekstil.
9. Kontroller at en faktisk offline-feil fortsatt vises som forståelig iCloud-/nettverksfeil.
10. Kontroller at Materialer/Farger ikke viser dobbeltkommunikasjon når begge kall feiler.
11. Åpne **Rediger plassering**, gjør en ufarlig endring og trykk **Lagre**. Kontroller at feilen fortsatt er brukerrettet og ikke viser rå `CKErrorDomain`.
12. Scroll helt ned og opp forbi **Fysiske egenskaper** og kontroller at scroll-loopen fortsatt er borte.
13. Slå nettverket på igjen og bruk **Prøv igjen** dersom en feiltilstand vises. Kontroller at dataene lastes og at gammel feiltilstand forsvinner.

**Stopp fortsatt på punkt 192 dersom Materialer/Farger får permanent feil ved normal førstegangs-last, en reell offline-feil presenteres rått, Rediger plassering viser `CKErrorDomain`, eller scroll-problemet kommer tilbake. Punkt 193 er sperret til punkt 192 er eksplisitt validert.**

### Rotårsaksretting etter devpatch 0076 – devpatch 0077

Retesten etter devpatch 0076 viste at **Materialer og farger** kunne bli stående permanent på `Henter materiale og farge …`. En samlet gjennomgang av `TextileDetailView`, `TextileAttributesSection` og `TextileAttributesModel` viste at problemet ikke lå i CloudKit-repositoryene.

Attributtlasten var eid av en `.task` på `TextileAttributesSection`. Samtidig bytter denne seksjonen selve SwiftUI-strukturen mellom én felles loading/error-seksjon og to separate Materialer/Farger-seksjoner når `isLoading` endrer verdi. Denne ombyggingen kunne få SwiftUI til å kansellere tasken som selv startet state-endringen. CloudKit rapporterte dette som `CKErrorDomain code=20` (`operationCancelled`).

Devpatch 0077 flytter derfor eierskapet til den automatiske attributtlasten opp til det stabile skjermnivået i `TextileDetailView`, ved siden av den eksisterende Piece-lastingen. `TextileAttributesSection` viser nå bare state og starter ikke sin egen livssyklusstyrte last. Ingen repository-, datamodell-, CloudKit-schema- eller lagringslogikk endres. Cancellation-håndteringen fra 0076 beholdes.

#### Retest punkt 192 etter devpatch 0077

1. Legg inn `Tekstilig-devpatch-0077.zip` med vanlig dry-run og rsync.
2. Sørg for at test-iPhone har normalt nettverk og fungerende iCloud.
3. Åpne prosjektet i Xcode 27, bygg og kjør på fysisk test-iPhone.
4. Avslutt Tekstilig helt og start appen på nytt fra Xcode.
5. Åpne et eksisterende tekstil med registrert materiale og/eller farge.
6. Kontroller at **Materialer/Farger** går fra eventuell kort lasting til faktisk innhold, og ikke blir stående permanent på `Henter materiale og farge …`.
7. Gjenta full avslutning/start og åpning av samme eller et annet tekstil minst én gang.
8. Kontroller at scrolling helt ned og opp forbi **Fysiske egenskaper** fortsatt fungerer uten hopp eller loop.
9. Slå av Wi-Fi og mobildata uten å avslutte appen, og åpne et annet allerede innlastet tekstil.
10. Kontroller at en faktisk offline-feil i Materialer/Farger vises som forståelig iCloud-/nettverksfeil, uten dobbeltkommunikasjon og uten rå `CKErrorDomain`.
11. Åpne **Rediger plassering**, gjør en ufarlig endring og trykk **Lagre**. Kontroller at feilen fortsatt er brukerrettet.
12. Slå nettverket på igjen og bruk **Prøv igjen** dersom feiltilstand vises. Kontroller at dataene lastes tilbake og at gammel feiltilstand forsvinner.

**Stopp fortsatt på punkt 192 dersom Materialer/Farger blir stående på permanent loading, får permanent feil med normalt nettverk, reell offline-feil presenteres rått, Rediger plassering viser `CKErrorDomain`, eller scroll-problemet kommer tilbake. Punkt 193 er sperret til punkt 192 er eksplisitt validert.**



## 194. Avklar forholdet mellom iCloud Drive og CloudKit på fysisk iPhone

**✅ VALIDERT**

Testen ble gjennomført på fysisk test-iPhone med normalt nettverk. iCloud Drive-synkronisering for enheten ble slått av, mens iCloud-kontoen og nettverket forble tilgjengelige.

Resultat:

- Tekstilig fortsatte å laste bibliotek og detaljdata normalt
- ingen CloudKit-feil eller ventetilstand oppstod
- ingen rå `CKErrorDomain`-feil ble vist
- appen oppførte seg som normalt

Konklusjon: iCloud Drive-filsynkronisering er ikke i seg selv en forutsetning for Tekstilig sin private CloudKit-database. Den tidligere antakelsen om at avslått iCloud Drive alene skulle gjøre CloudKit utilgjengelig var derfor feil. Roadmap-punkt 5 skal videre teste faktisk CloudKit-tilgjengelighet, ikke iCloud Drive-bryteren som sådan.

## 195. Tidligere gjenopprettingstest for iCloud Drive utgår

**⏭️ UTGÅR ETTER RESULTATET I 194**

Den opprinnelige testen skulle slå iCloud Drive på igjen og kontrollere at Tekstilig gjenopprettet CloudKit-tilgangen. Punkt 194 viste at CloudKit-tilgangen aldri forsvant da iCloud Drive-synkronisering ble slått av. Det finnes derfor ingen relevant gjenopprettingstilstand å validere her.

Ingen appkode skal endres som følge av dette punktet. Arbeidet fortsetter direkte til punkt 196.

## 196. Valider manglende iCloud-konto i simulator

**✅ AKSJON – DU**

Dette er neste aktive test. Den skal gjøres i en iOS 27-simulator som **ikke er logget inn på iCloud**, slik at den fysiske testtelefonens Apple-konto ikke må logges ut.

1. Åpne Xcode 27.
2. Opprett om nødvendig en ny iPhone-simulator med iOS 27.
3. Start simulatoren og kontroller i **Innstillinger** at den ikke er logget inn med en Apple-konto/iCloud.
4. Velg denne simulatoren som Run Destination i Xcode.
5. Bygg og kjør Tekstilig.
6. Vent på bibliotekets første last.
7. Kontroller at Tekstilig ikke blir stående med en uforklart spinner.
8. Kontroller at manglende iCloud-/CloudKit-konto presenteres som en forståelig tilgjengelighets- eller iCloud-feil, ikke som rå `CKErrorDomain`-tekst.
9. Kontroller at appen fortsatt er navigerbar og ikke krasjer.
10. Noter den nøyaktige teksten som vises dersom resultatet avviker fra forventningen.

**Stopp på punkt 196 dersom manglende iCloud-konto ikke gir en forståelig tilstand, appen blir stående permanent på loading, viser rå teknisk feil eller krasjer. Ikke gå videre til punkt 197 før punkt 196 er eksplisitt validert.**

## 197. Stoppunkt for roadmap-punkt 5 – iCloud-/CloudKit-robusthet

**✅ STOPPUNKT**

Roadmap-punkt 5 kan avsluttes når følgende er eksplisitt validert:

- biblioteket viser forståelig ventetilstand eller feil uten nettverk
- **Prøv igjen** gjenoppretter bibliotek og kompletteringsmetadata uten manuell refresh
- hovedbilde, materiale/farge og stoffstykker bruker forståelige feiltilstander
- Textile-, farge- og plasseringslagring viser ikke rå CloudKit-feil ved utilgjengelig nettverk
- Materialer/Farger har stabil async-livssyklus uten cancellation-loop eller permanent spinner
- avslått iCloud Drive-synkronisering alene blokkerer ikke Tekstilig så lenge iCloud-konto, CloudKit og nettverk er tilgjengelige
- manglende iCloud-konto gir forståelig tilstand uten krasj eller permanent spinner

**Ikke start roadmap-punkt 6 – Eksport og backup – før punkt 196 er validert og dette stoppunktet kan markeres ✅.**

## 198. Fastsett backupformat for roadmap-punkt 6 – Eksport og backup

**✅ BESLUTTET**

Roadmap-punkt 5 er fullført og validert. Punkt 6 starter med å låse et versjonert backupformat før eksportkode implementeres. Formatet skal være menneskelesbart, bevare alle data som finnes i dagens domenemodell og samtidig være egnet som kontrakt for roadmap-punkt 7 – Import og restore.

### Foreslått format for Tekstilig backup v1

En eksport leveres som én vanlig ZIP-fil med navn etter mønsteret:

```text
Tekstilig-backup-YYYY-MM-DD-HHmmss.zip
```

ZIP-filen inneholder:

```text
Tekstilig-backup-YYYY-MM-DD-HHmmss/
├── backup.json
└── images/
    ├── IMG-....jpg
    ├── IMG-....png
    └── ...
```

`backup.json` er UTF-8 JSON med et eksplisitt formatversjonsfelt. Data organiseres per tekstil slik at et tekstil og alle tilhørende underobjekter kan forstås og senere gjenopprettes samlet.

Foreslått toppnivå:

```json
{
  "format": "tekstilig-backup",
  "formatVersion": 1,
  "exportedAt": "2026-10-11T20:00:00Z",
  "textiles": []
}
```

Hvert tekstilobjekt skal inneholde alle verdier som finnes i dagens modell:

- `textileID`
- `name`
- `category`
- `createdAt`
- `updatedAt`
- `schemaVersion`
- plassering: `locationArea`, `locationShelf`, `locationContainer`
- `notes`
- vedlikehold: vask tillatt, temperatur, program, bleking, tørketrommel, tørking, stryking, rens og vedlikeholdsnotat
- `weightGsm`
- elastisitet: nivå, retning og prosent
- krymp: lengdeprosent, breddeprosent og notat
- tilhørende `materials`
- tilhørende `colors`
- tilhørende `pieces`
- tilhørende `images`-metadata

Tilhørende objekter beholder sine permanente Tekstilig-ID-er:

- `Piece.pieceID`
- `TextileMaterial.materialID`
- `TextileColor.colorID`
- `TextileImage.imageID`

CloudKit `recordName` er lagringsidentitet i dagens database, men skal **ikke** være nødvendig som gjenopprettingsidentitet. Backupformatet skal derfor bygge restore-logikken på Tekstilig-ID-ene. CloudKit record names kan eventuelt tas med som diagnostisk kildeinformasjon senere, men restore skal ikke være avhengig av dem.

For hvert bilde inneholder `backup.json` metadataene:

- `imageID`
- `type`
- `isPrimary`
- `fileName`
- `contentType`
- relativ `backupPath`, for eksempel `images/IMG-....jpg`

Selve bildebytene lagres i `images/` og skal ikke base64-kodes inn i JSON. Dette holder JSON-filen lesbar og unngår unødvendig oppblåsing av backupen.

### Dataprinsipper

1. Backupen skal inneholde alle Textile-records som appen behandler som ordinære brukerdata.
2. Alle tilhørende Piece-, Material-, Color- og TextileImage-data skal eksporteres.
3. Diagnostikk-/PoC-records skal ikke eksporteres som brukerdata.
4. Tomme/valgfrie verdier skal representeres eksplisitt og forutsigbart slik at senere import kan skille mellom manglende og faktiske verdier.
5. Datoer skal lagres som ISO 8601 i UTC.
6. Eksporten skal ikke endre data i CloudKit.
7. En backup skal være selvstendig: JSON + bilder skal være nok til å bygge senere restore uten tilgang til den opprinnelige CloudKit-databasen.
8. Første versjon trenger ikke støtte inkrementell backup. Hver eksport er en komplett snapshot-backup.
9. Første versjon trenger ikke kryptere ZIP-filen. Brukeren velger selv hvor filen lagres/deles via systemets fil-/share-grensesnitt. Eventuell kryptert backup vurderes separat senere dersom behovet oppstår.

### Plattformflyt

Samme eksportfunksjon skal brukes på iPhone, iPad og Mac. Brukeren starter eksport fra en tydelig administrativ handling, appen bygger backupen i en midlertidig katalog, pakker den som ZIP og presenterer systemets vanlige lagre/dele-grensesnitt. Ingen plattform skal ha et eget backupformat.

### Hvorfor dette formatet anbefales

- ZIP er et åpent og lett tilgjengelig containerformat.
- JSON er menneskelesbart og enkelt å versjonere.
- Bilder beholdes som vanlige bildefiler i stedet for å gjemmes i binære databasefiler.
- `formatVersion` gjør senere schemaendringer håndterbare.
- Tekstilig-ID-ene gir en applikasjonseid identitet som kan brukes av senere import/restore uten å være bundet til CloudKit record names.
- Samme format kan brukes som testkontrakt i roadmap-punkt 7.

### Ikke implementert i punkt 198

Dette punktet endrer ingen Swift-kode og oppretter ingen backupfil. Først etter eksplisitt godkjenning implementeres eksporten i små, sekvensielle steg.

**Punkt 198 er eksplisitt godkjent. Backupformat v1 er låst som kontrakt for videre eksport og senere import/restore.**

## 199. Legg inn devpatch 0081 – backupmodell og in-memory snapshot

**✅ AKSJON – DU**

Devpatch 0081 er første kodeblokk i roadmap-punkt 6. Den skriver ikke ZIP eller andre filer. Målet er å validere at alle dagens brukerdata kan samles i den versjonerte backupmodellen fra punkt 198, serialiseres til JSON og leses tilbake uten tap.

Patchen introduserer:

- `TekstiligBackupDocument` og underobjekter for Textile, vedlikehold, fysiske egenskaper, materialer, farger, Piece og bildemetadata
- `TekstiligBackupBuilder`, som leser ordinære brukerdata via eksisterende repositories
- innsamling av primærbilder i minnet med separat `backupPath` for senere ZIP-skriving
- en Debug-diagnostikk som serialiserer `backup.json` i minnet og dekoder den tilbake igjen

Ingen CloudKit-data lagres, endres eller slettes i dette steget. Ingen backupfil skrives til disk.

1. Legg inn `Tekstilig-devpatch-0081.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27.
3. Velg fysisk test-iPhone som kjøredestinasjon.
4. Bygg prosjektet.
5. Kontroller at build fullføres uten nye feil eller warnings fra backupfilene.
6. Kjør appen.
7. Kontroller kort at fanene **Tekstiler** og **Finn til prosjekt** fortsatt åpnes normalt.

**Stopp på punkt 199 dersom prosjektet ikke bygger eller eksisterende hovedflyt er påvirket. Ikke gå videre til punkt 200 før punkt 199 er validert.**

## 200. Valider backupmodellen i Debug-diagnostikk

**✅ AKSJON – DU**

1. Åpne fanen **Utvikling**.
2. Finn seksjonen **Roadmap 6: backupmodell**.
3. Trykk **Test backupmodell** én gang.
4. Vent til testen er ferdig.
5. Kontroller at resultatet viser **JSON round-trip OK**.
6. Kontroller at antall **Tekstiler** er større enn 0 og virker rimelig sammenlignet med biblioteket.
7. Kontroller at tellerne for Materialer, Farger, Stoffstykker og Bilder er ikke-negative og virker plausible ut fra testdataene.
8. Kontroller at **JSON-størrelse** er større enn 0 B.
9. Dersom minst ett tekstil har hovedbilde, kontroller at **Bilder** er større enn 0 og at **Bildedata** er større enn 0 B.
10. Kontroller at appen ikke viser noen backupfeil.

Denne testen validerer at JSON-kontrakten kan rundtrippes og at bildebytes kan samles separat i minnet. Den validerer ennå ikke ZIP-fil eller deling/lagring.

**Stopp på punkt 200 dersom JSON round-trip feiler, tellingene er åpenbart feil, eller eksisterende CloudKit-data ikke kan samles. Ikke gå videre til punkt 201 før punkt 200 er validert.**

## 201. Regresjon etter in-memory backupdiagnostikk

**✅ AKSJON – DU**

1. Gå tilbake til fanen **Tekstiler**.
2. Åpne et eksisterende tekstil med materiale, farge, Piece og hovedbilde dersom tilgjengelig.
3. Kontroller at disse dataene fortsatt lastes normalt.
4. Gå tilbake til biblioteket og kontroller at søk/filter fortsatt fungerer.
5. Åpne **Finn til prosjekt** og utfør ett kjent søk.
6. Kontroller at backupdiagnostikken ikke har endret eller opprettet brukerdata.

Når punkt 199–201 er validert kan neste blokk skrive den allerede validerte snapshotmodellen til en midlertidig backupmappe (`backup.json` + `images/`) før ZIP-pakking implementeres.



### Devpatch 0082 – byggretting for punkt 199

**✅ Retest av 199 (200–201 er fortsatt sperret).** Xcode 27 rapporterte seks actor-isolation-feil: fem standardargumenter som opprettet `@MainActor`-isolerte CloudKit-repositories fra en ikke-isolert default-argument-kontekst, og ett tilsvarende standardargument for `TekstiligBackupBuilder` i diagnostikkmodellen.

0082 flytter kun disse opprettelsene til eksplisitte `@MainActor`-isolerte `convenience init()`-metoder. Dependency injection med fem repositories / én builder beholdes. Ingen eksportlogikk, dataflyt eller CloudKit-operasjoner endres.

1. Legg inn `Tekstilig-devpatch-0082.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27 og velg fysisk test-iPhone.
3. Velg **Product → Build**.
4. Kontroller at de seks actor-isolation-feilene er borte og at build lykkes.
5. Kjør appen og kontroller at **Tekstiler** og **Finn til prosjekt** åpnes normalt.
6. Bekreft **199 OK** før du går videre til punkt 200.

**Stopp ved enhver byggfeil; ikke gå videre til 200 før 199 er eksplisitt validert.**


### Devpatch 0083 – JSON round-trip i punkt 200

**199 ✅ godkjent av bruker. 200 ✅ retest. 201 ❗️ avventer.**

Første kjøring av 200 kunne serialisere og dekode JSON, men `decoded == snapshot.document` feilet. `Date` fra CloudKit kan inneholde sub-millisekundpresisjon, mens godkjent ISO 8601-format serialiserer millisekunder. Direkte likhet mellom opprinnelig `Date` og dekodet `Date` er derfor ikke en korrekt test av backupfilens tapsfrihet.

0083 endrer **bare diagnostikkens sammenligning**: `encode(original) → decode → encode(decoded)`, og krever byte-identisk, deterministisk JSON etter round-trip. Dette kontrollerer at den **lagrede backuprepresentasjonen** kan leses og skrives uten endring. Hvis den feiler, rapporteres første avvik med byteposisjon og korte tekstutdrag. Ingen datoer i CloudKit endres, ingen produksjonsdata normaliseres, og ingen eksportfiler skrives.

1. Legg inn `Tekstilig-devpatch-0083.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27, velg test-iPhone og kjør **Product → Build**.
3. Start appen og åpne **Utvikling → Roadmap 6: backupmodell**.
4. Trykk **Test backupmodell** én gang og vent på resultatet.
5. Kontroller at **JSON round-trip OK** vises, og at tellinger/JSON-størrelse oppfyller kravene i punkt 200.
6. Hvis testen feiler, noter hele den nye feilmeldingen og stopp på 200.
7. Når **200** er eksplisitt validert, gå videre til **201** etter eksisterende testinstruks.

**Ikke marker 200 eller 201 som godkjent før brukeren bekrefter.**


### Devpatch 0084 – kompilatorretting i punkt 200

**199 ✅. 200 ✅ fortsatt blokkert. 201 ❗️ avventer.**

0083 introduserte en byggefeil i `BackupDiagnosticModel.firstDifference`: `zip(left, right)` gir en `Zip2Sequence` uten `firstIndex`. 0084 bytter bare posisjonsoppslaget til `enumerated().first(where:)?.offset`, og beholder eksisterende JSON-sammenligning, feilrapportering og backupformat uendret.

1. Legg inn `Tekstilig-devpatch-0084.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27, velg test-iPhone og kjør **Product → Build**.
3. Kontroller at byggfeilen i `BackupDiagnosticModel` er borte. Hvis build feiler, stopp på 200.
4. Kjør appen og åpne **Utvikling → Roadmap 6: backupmodell**.
5. Trykk **Test backupmodell** og kontroller **JSON round-trip OK** og øvrige krav i punkt 200.
6. Hvis testen feiler, send hele feilmeldingen og stopp på 200.
7. Bare etter eksplisitt godkjenning av 200 kan punkt 201 utføres.


## 202. Devpatch 0085 – midlertidig filstruktur for backup

**198–201 ✅ validert av bruker. 202 ❗️ ikke validert.**

Dette er en avgrenset første eksportblokk: snapshotet skrives til en privat midlertidig mappe som `backup.json` og `images/`. Diagnostikken leser filene tilbake, kontrollerer byte-likhet og sletter mappen. **ZIP-pakking, deling og varig backup er ikke implementert i 0085.**

1. Legg inn `Tekstilig-devpatch-0085.zip` med vanlig dry-run og rsync.
2. Åpne prosjektet i Xcode 27 og velg test-iPhone.
3. Velg **Product → Build** og kontroller at build lykkes. Stopp ved byggfeil.
4. Kjør appen og åpne **Utvikling → Roadmap 6: backupmodell**.
5. Trykk **Test backupmodell** og vent til kjøringen er ferdig.
6. Kontroller både **JSON round-trip OK** og **backup.json og bilder skrevet og kontrollert**.
7. Kontroller at antall tekstiler og bilder fortsatt er korrekt.
8. Gå tilbake til biblioteket og kontroller at et kjent tekstil åpnes normalt.

**Stopp på 202 ved feil. Ikke gå videre til ZIP-/eksportblokken før 202 er eksplisitt godkjent.**


### Devpatch 0086 – retting av duplisert bildesti i punkt 202

**198–201 ✅. 202 ❗️ avventer retest.** Bygg av 0085 var vellykket, men staging av backup stoppet med «Duplisert bildesti i backup: images/». Den opprinnelige filstien var avledet bare fra `imageID`; dette er ikke tilstrekkelig til å garantere unik filsti mellom ulike tekstiler. 0086 avleder filstien fra både `textileID` og `imageID` med filnavnsikker UTF-8-hex-koding. Opprinnelige ID-er og metadata beholdes uendret i JSON. Eksisterende kontroll mot reelle duplikater er beholdt. Ingen CloudKit-skriving eller ZIP-eksport.

1. Legg inn `Tekstilig-devpatch-0086.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27 og bygg prosjektet. Stopp dersom build feiler.
3. Start appen og åpne **Utvikling → Roadmap 6: backupmodell**.
4. Trykk **Test backupmodell** og vent til testen er ferdig.
5. Kontroller at både **JSON round-trip OK** og **backup.json og bilder skrevet og kontrollert** vises, og at tellingene stemmer.
6. Åpne et kjent tekstil med hovedbilde i biblioteket og kontroller at visningen fortsatt fungerer.

**Stopp på 202 dersom samme eller en ny feil oppstår. Ikke fortsett til ZIP-/eksportblokken før 202 er eksplisitt validert.**
