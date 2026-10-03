# SwiftUI – videre implementering

**Status:** Textile 1–9 ✅ · Piece 10–18 ✅ · hovedbilde 20–29 ✅ · materiale/farge 30–39 ✅ · plassering 43–53 ✅ · vedlikehold/query 54–67 ✅ · fysiske egenskaper fra 68 ❗️  
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

