# SwiftUI – videre implementering

**Status:** Textile 1–9 ✅ · Piece 10–18 ✅ · hovedbilde 20–29 ✅ · materiale/farge 30–39 ✅ · plassering 43–53 ✅ · vedlikehold/query 54–67 ✅ · fysiske egenskaper 68–77 ✅ · første søk/grunnfilter 78–86 ✅ · utvidede grunnfiltre fra 87 ❗️  

> **Fast arbeidsmetodikk:** Les `ARBEIDSMETODIKK.md` før nye kodeendringer. `SWIFTUI-IMPLEMENTERING.md` er hovedsporet. Nye/ikke-validerte punkter markeres ❗️ og endres først til ✅ etter brukerens validering. Ved konkrete feil kan hovedsporet midlertidig erstattes av målrettet ad-hoc feilisolering; når feilen er løst fortsetter arbeidet fra neste ufullførte nummererte punkt.
**Miljø:** Development · Xcode 27 · iOS/iPadOS 27

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
