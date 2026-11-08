# SwiftUI – videre implementering

**Gjeldende status 2026-11-07:** Kodegrunnlag `SwiftUIActualApp0086`, Git-commit `d3a0a62`. Test 237 ✅ validert OK av prosjekteieren. Test 238 ✅ fullført etter prosjekteierens uttrykkelige godkjenning av skrivebeskyttet identitetsavstemming og diagnostikkens filtrering på macOS 27.2. Dette godkjenner ikke import/restore eller CloudKit-skriving/-sletting. Hele test 230 er ✅ brukervalidert 2026-11-06, inkludert negativtesten med en annen gyldig ZIP og etterkontroll av uendret journalbinding. CloudKit-skriving under import/restore er fortsatt sperret. Test 230 og 238 er fullført og publisert på GitHub. Identitetsstrategien er godkjent i B-050; test 239 ✅ er samlet brukervalidert 2026-11-07, inkludert alle elleve punkter, 38 beståtte syntetiske tester, begge plattformbygg og etterkontroll. Godkjenningen gjelder bare isolert beslutningsmodell. Test 240 ✅ er samlet brukervalidert for isolert adapter og skrivebeskyttet beslutningsrapport, inkludert praktisk UI-test etter én særskilt godkjent test 238-lesing. Test 241 fase A ✅ er samlet brukergodkjent for isolert identitetsleser med 87 beståtte tester, begge appbygg og sikkerhetsetterkontroll. Test 241 B.1 ✅ er samlet brukergodkjent for syntetisk miljøverifikasjon; B.2 ✅ er brukervalidert for isolert lokal miljøkontroll på macOS; senere CloudKit-lesetester forblir ❗️. Se [PROSJEKTSTATUS.md](PROSJEKTSTATUS.md) for samlet status.

**Historisk delstatus før utvidede grunnfiltre:** Textile 1–9 ✅ · Piece 10–18 ✅ · hovedbilde 20–29 ✅ · materiale/farge 30–39 ✅ · plassering 43–53 ✅ · vedlikehold/query 54–67 ✅ · fysiske egenskaper 68–77 ✅ · første søk/grunnfilter 78–86 ✅ · utvidede grunnfiltre fra 87 ❗️

> **Fast arbeidsmetodikk:** Les `ARBEIDSMETODIKK.md` før nye kodeendringer. `SWIFTUI-IMPLEMENTERING.md` er hovedsporet. Nye/ikke-validerte punkter markeres ❗️ og endres først til ✅ etter brukerens validering. Ved konkrete feil kan hovedsporet midlertidig erstattes av målrettet ad-hoc feilisolering; når feilen er løst fortsetter arbeidet fra neste ufullførte nummererte punkt.
**Miljø:** Development · Xcode 27.2 · iOS/iPadOS/macOS 27.2. Versjon 27 i eldre testinstruksjoner beholdes som historikk.

> **Historisk status 2026-10-11 (avløst av senere validering av punkt 185–186):** Roadmap-punkt 3 **Rask registrering** er lukket ✅. Devpatch 0064 og test 179–183 er validert ✅, og punkt 184 er validert på iPad ✅. Første native macOS-build er fortsatt blokkert i **punkt 185**. Devpatch 0066 fjernet første UIKit-blokkering i `PieceEditorView`; neste build avdekket flere iOS-spesifikke SwiftUI-modifikatorer. Devpatch 0067 retter denne plattformkompatibiliteten uten å endre forretningslogikk. Arbeidet fortsetter strengt sekvensielt fra **punkt 185**. Se også `LEVERANSE-OG-TESTMETODIKK.md` for fast leveranse-, rsync-, test-, Git- og snapshot-arbeidsflyt.

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

**199 ✅ godkjent av bruker. 200 ✅ retest. 201 ✅ avventer.**

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

**199 ✅. 200 ✅ fortsatt blokkert. 201 ✅ avventer.**

0083 introduserte en byggefeil i `BackupDiagnosticModel.firstDifference`: `zip(left, right)` gir en `Zip2Sequence` uten `firstIndex`. 0084 bytter bare posisjonsoppslaget til `enumerated().first(where:)?.offset`, og beholder eksisterende JSON-sammenligning, feilrapportering og backupformat uendret.

1. Legg inn `Tekstilig-devpatch-0084.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27, velg test-iPhone og kjør **Product → Build**.
3. Kontroller at byggfeilen i `BackupDiagnosticModel` er borte. Hvis build feiler, stopp på 200.
4. Kjør appen og åpne **Utvikling → Roadmap 6: backupmodell**.
5. Trykk **Test backupmodell** og kontroller **JSON round-trip OK** og øvrige krav i punkt 200.
6. Hvis testen feiler, send hele feilmeldingen og stopp på 200.
7. Bare etter eksplisitt godkjenning av 200 kan punkt 201 utføres.


## 202. Devpatch 0085 – midlertidig filstruktur for backup

**198–201 ✅ validert av bruker. 202 ✅ ikke validert.**

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

**198–201 ✅. 202 ✅ avventer retest.** Bygg av 0085 var vellykket, men staging av backup stoppet med «Duplisert bildesti i backup: images/». Den opprinnelige filstien var avledet bare fra `imageID`; dette er ikke tilstrekkelig til å garantere unik filsti mellom ulike tekstiler. 0086 avleder filstien fra både `textileID` og `imageID` med filnavnsikker UTF-8-hex-koding. Opprinnelige ID-er og metadata beholdes uendret i JSON. Eksisterende kontroll mot reelle duplikater er beholdt. Ingen CloudKit-skriving eller ZIP-eksport.

1. Legg inn `Tekstilig-devpatch-0086.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27 og bygg prosjektet. Stopp dersom build feiler.
3. Start appen og åpne **Utvikling → Roadmap 6: backupmodell**.
4. Trykk **Test backupmodell** og vent til testen er ferdig.
5. Kontroller at både **JSON round-trip OK** og **backup.json og bilder skrevet og kontrollert** vises, og at tellingene stemmer.
6. Åpne et kjent tekstil med hovedbilde i biblioteket og kontroller at visningen fortsatt fungerer.

**Stopp på 202 dersom samme eller en ny feil oppstår. Ikke fortsett til ZIP-/eksportblokken før 202 er eksplisitt validert.**


### Devpatch 0088 – kildeidentitet og rotårsaksanalyse for 202

**198–201 ✅ · 202 ✅ blokkert.** Diagnostikk i 0087 viser at samme `textileID=T0001` og `imageID` opptrer flere ganger. `TekstiligBackupBuilder` går gjennom hver post fra `fetchTextiles()` og legger til bilde for hver forekomst; `TekstiligBackupStager` oppdager deretter duplisert sti. Filnavn er ikke rotårsaken. `CloudKitTextileRepository.fetchTextiles()` returnerer CloudKit-poster uten kontroll av dupliserte logiske `textileID`-verdier. Om det finnes flere CloudKit-records eller en annen kilde til gjentatte resultater, må fastslås fra recordName før vi korrigerer data eller lagringsflyt.

0088 legger derfor en **fail-fast identitetskontroll ved inngangen til backupbyggingen**, og rapporterer alle CloudKit `recordName` for samme `textileID`. Den fjerner ikke duplikater, omskriver ikke CloudKit og legger ikke til kompenserende eksportlogikk. Dette er diagnostikk for å bekrefte rotårsaken, ikke en godkjent funksjonell rettelse.

1. Legg inn `Tekstilig-devpatch-0088.zip` med vanlig dry-run og rsync.
2. Bygg i Xcode 27. Stopp ved byggefeil.
3. Åpne **Utvikling → Roadmap 6: backupmodell** og trykk **Test backupmodell**.
4. Send hele feilmeldingen med `textileID` og CloudKit `recordName`-verdier.
5. Stopp på **202 ✅**. Ikke slett eller slå sammen CloudKit-poster før recordidentitet og årsak er vurdert. ZIP-eksport avventer.

**Fast feilrettingsprinsipp:** Identifiser først rotårsaken i eksisterende dataflyt og rett den på riktig nivå. Unngå kompenserende logikk, ekstra lag og ineffektiv duplisering som bare skjuler feilen.


## 203. Devpatch 0089 – ZIP og eksport til Filer/Finder

**198–202 ✅ validert av bruker. 203 ✅ avventer test.**

ZIP32-arkiv med `backup.json` og `images/` (lagret uten ytterligere komprimering, siden bildene allerede er komprimerte). ZIP-verifisering leser alle arkivoppføringer, kontrollerer byteinnhold og CRC32 mot de validerte stagingfilene. Eksport via systemets `fileExporter` skriver til valgt plassering. Ingen CloudKit-data endres.

1. Legg inn `Tekstilig-devpatch-0089.zip` med vanlig dry-run og rsync.
2. Åpne Xcode 27 og bygg prosjektet. **Stopp ved byggefeil.**
3. Kjør appen på test-iPhone og åpne **Utvikling → Roadmap 6: backupmodell**.
4. Trykk **Test backupmodell** og vent til resultatet vises.
5. Kontroller **JSON round-trip OK**, **backup.json og bilder skrevet og kontrollert** og **ZIP opprettet og innhold kontrollert**. Stopp ved feil.
6. Trykk **Lagre backup som ZIP …**, velg en mappe i **Filer**, og lagre.
7. Åpne **Filer**, finn ZIP-filen og pakk den ut. Kontroller at den inneholder `backup.json` og `images/` med forventet antall bilder.
8. Åpne biblioteket igjen og kontroller at et kjent tekstil med bilde fungerer.
9. På iPad og Mac, når tilgjengelig: gjenta eksport og kontroller at lagringsdialogen og ZIP-filen fungerer. Rapporter plattformene separat.

**203 skal bare markeres ✅ etter eksplisitt godkjenning.**


## 204. Devpatch 0090 – lesbare bildefilnavn i ZIP-backup

**198–204 ✅ validert av bruker på iPhone, iPad og macOS.**

Tidligere UTF-8-hex-koding av tekstil-ID og bilde-ID ble innført mens duplikate CloudKit-testposter (`T0001`) ennå ikke var identifisert. Disse testpostene er nå fjernet, og årsaken til den opprinnelige feilen er avklart. `TextileImage.newPrimaryDraft` genererer bilde-ID som `IMG-<UUID>`, så eksporten bruker nå `images/<imageID>.<filtype>` uten unødvendig hex-koding. Eksisterende duplikatkontroll i staging, JSON-referanser og ZIP-verifisering beholdes. Ingen CloudKit-data endres.

1. Installer `Tekstilig-devpatch-0090.zip` over gjeldende prosjekt (som allerede inneholder 0089), med vanlig dry-run og rsync.
2. Bygg prosjektet i Xcode 27. **Stopp ved byggefeil.**
3. På Mac: Kjør **Utvikling → Roadmap 6: backupmodell → Test backupmodell**. Kontroller at JSON round-trip, staging og ZIP-verifisering er OK. **Stopp ved feil.**
4. Eksporter ZIP til Finder, pakk ut og kontroller at bilder har lesbare navn av typen `IMG-<UUID>.jpeg` (eller tilsvarende filtype), at antall bilder stemmer og at `backup.json` peker til de faktiske filene. **Stopp ved feil.**
5. Gjenta backupmodelltest og ZIP-eksport på iPhone og iPad; kontroller filnavn og åpne et kjent tekstil med bilde etterpå.
6. Rapporter resultat for hver plattform. **204 markeres først ✅ etter eksplisitt godkjenning.**


## 205. Devpatch 0091 – les og valider eksisterende ZIP-backup (skrivebeskyttet)

**198–204 ✅ validert av bruker. 205 ✅ avventer test.**

Første fase av roadmap 7. Leser ZIP32 med lagrede (ikke komprimerte) oppføringer fra filvelgeren, validerer ZIP-struktur, CRC32, formatversjon, unike tekstil-ID-er og samsvar mellom bildefiler og referanser i `backup.json`. Viser antall tekstiler, stoffstykker og bilder. Ingen CloudKit-skriving. Foreløpig ingen faktisk gjenoppretting.

1. Installer `Tekstilig-devpatch-0091.zip` over komplett kodeversjon 0047. Bygg i Xcode 27. **Stopp ved byggefeil.**
2. På Mac: Åpne **Utvikling → Diagnostikk → Roadmap 7: les backup (kun kontroll)** og trykk **Velg ZIP-backup …**. Velg en ZIP eksportert fra Tekstilig.
3. Kontroller at «Backup lest og validert – ingen data importert» vises og at antall tekstiler, stoffstykker og bilder stemmer. **Stopp ved feil.**
4. Kontroller at biblioteket er uendret.
5. Gjenta punkt 2–4 på iPhone og iPad med eksporterte ZIP-filer. **Stopp ved første feil.**
6. Rapporter resultatene. **205 markeres først ✅ etter eksplisitt godkjenning.**

Merk: Negative tester og detaljert forhåndsvisning tas i egne testpunkter etter at leseflyten er validert.


## 206. Devpatch 0092 – felles aktivitetsvisning for backup og import

**198–205 ✅ validert av bruker på iPhone, iPad og macOS. 206 ✅ avventer test.**

`BackupActivityLabel` gir enhetlig systemindikator (`ProgressView`) med operasjonstekst for både backupbygging og ZIP-import. Valg av ZIP setter aktiv tilstand og leser filbytes utenfor UI-aktøren; eksisterende validering og CloudKit-data endres ikke. Samtidig oppstart av backup og import sperres i diagnostikkvisningen. Selve ZIP-valideringen bruker fortsatt eksisterende synkron leser; full flytting av CPU-tung validering ut av hovedaktøren må vurderes separat hvis store arkiver gir merkbar frysing. Faktisk restore er ennå ikke implementert, men skal gjenbruke samme aktivitetsmønster.

1. Installer devpatch 0092 på siste komplette 0048 og bygg på Mac. Stopp ved byggefeil.
2. Kjør **Test backupmodell** og kontroller roterende indikator med «Bygger og kontrollerer backup …» mens arbeidet pågår. Stopp ved feil.
3. Velg en ZIP-backup under Roadmap 7 og kontroller roterende indikator med «Leser og kontrollerer backup …» og deretter godkjent resultat. Stopp ved feil.
4. Kontroller at tidligere eksport og bibliotek fungerer uendret.
5. Gjenta på iPhone og iPad. Rapporter hver plattform. **206 ❗️ inntil eksplisitt godkjent.**


## 207. Devpatch 0093 – forhåndsvisning av validert backup (skrivebeskyttet)

**198–206 ✅ validert av bruker på iPhone, iPad og macOS. 207 ❗️ avventer test.**

Viser eksportdato, backupformat/-versjon, antall tekstiler, stoffstykker, bilder, materialregistreringer og fargeregistreringer etter vellykket ZIP-validering. Bruker samme `TekstiligBackupReader.Result` som punkt 205 og samme aktivitetsindikator som punkt 206. Ingen ny ZIP-parser, ingen CloudKit-skriving og ingen restore-knapp.

1. Installer devpatch 0093 over komplett kodeversjon 0049, og bygg for macOS i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en tidligere eksportert ZIP-backup, og vent på fullført validering.
3. Kontroller at **Forhåndsvisning av backup** viser eksportdato, format `tekstilig-backup`, formatversjon `1`, og forventede antall tekstiler, stoffstykker og bilder. Kontroller også material- og fargeregistreringer. **Stopp ved feil.**
4. Kontroller at ingen data er importert og at biblioteket er uendret.
5. Velg en annen gyldig ZIP og kontroller at forhåndsvisningen oppdateres. **Stopp ved feil.**
6. Gjenta på iPhone og iPad. **207 markeres først ✅ etter eksplisitt godkjenning.**

Neste arbeid: negative valideringstester og analyse av CloudKit-importstrategi før skriveoperasjoner.


## 208. Devpatch 0094 – negative ZIP-valideringstester (kun minne)

**198–207 ✅ validert av bruker på iPhone, iPad og macOS. 208 ✅ avventer test.**

Diagnostikkvisningen kan teste tre ugyldige varianter av en allerede godkjent ZIP: avkortet arkiv, endret ZIP-header og endret filinnhold (CRC32). Testene endrer bare kopier i minnet, og bruker den eksisterende `TekstiligBackupReader` uten CloudKit-skriving eller endringer av originalfilen.

1. Installer `Tekstilig-devpatch-0094.zip` over komplett kodeversjon 0050. Bygg for macOS i Xcode 27. Stopp ved byggefeil.
2. Åpne **Utvikling → Diagnostikk → Roadmap 7** og velg en gyldig, nylig eksportert ZIP-backup. Kontroller at forhåndsvisningen vises. Stopp ved feil.
3. Trykk **Test avvisning av ugyldige ZIP-filer**. Kontroller meldingen **OK: 3/3 ugyldige ZIP-varianter ble avvist. Ingen data importert.** Stopp ved feil.
4. Kontroller at den gyldige forhåndsvisningen fortsatt vises og at biblioteket er uendret.
5. Gjenta på iPhone og iPad. Rapporter alle plattformer. **208 ❗️ til eksplisitt godkjenning.**

Neste fase: kontroll av semantiske feil i JSON og analyse av sikker CloudKit-gjenoppretting før skriveoperasjoner.


## 209. Devpatch 0095 – negativ semantisk validering av backupinnhold

**198–209 ✅ validert av bruker på alle plattformer.**

Samme semantiske kontroll brukes av ZIP-leseren og en skrivebeskyttet diagnostikk for ugyldig formatversjon, feil i bildefilstier, duplisert tekstil-ID og tom tekstil-ID. Det kreves minst ett tekstil i valgt backup. Ingen CloudKit-skriving.

1. Installer `Tekstilig-devpatch-0095.zip` over komplett kodeversjon 0051. Bygg macOS-appen i Xcode 27. Stopp ved feil.
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**. Velg en gyldig backup med minst ett tekstil. Kontroller forhåndsvisningen.
3. Trykk **Test avvisning av ugyldig backupinnhold**. Kontroller meldingen **OK: 4/4 ugyldige innholdsvarianter ble avvist. Ingen data importert.** Stopp ved feil.
4. Kontroller at gyldig forhåndsvisning fortsatt vises og biblioteket er uendret.
5. Gjenta på iPhone og iPad. **209 ❗️ inntil eksplisitt godkjent.**

Neste steg: analysere CloudKit-transaksjonsgrenser og importstrategi før skriveoperasjoner.


### Devpatch 0096 – rettelse av byggefeil i test 209

**209 ✅ – bygget og validert av bruker på alle plattformer etter rettelsen i 0096.** Byggefeilen `Cannot find 'imagePaths' in scope` i `TekstiligBackupReader.read(_:)` kom av at `imagePaths` ble flyttet inn i `validateDocument` i devpatch 0095, mens resultatkonstruksjonen fortsatt refererte til den lokale variabelen. Etter vellykket validering består `files` av `backup.json` og nøyaktig de refererte bildefilene. Derfor brukes `files.count - 1` som bildeantall, uten ny validering eller duplisert opptelling. Ingen endringer i backupformat eller CloudKit.

1. Installer devpatch 0096 over komplett kodeversjon 0052 (med devpatch 0095 inkludert), og bygg i Xcode 27 på Mac. Stopp ved byggefeil.
2. Åpne **Utvikling → Diagnostikk → Roadmap 7** og velg en gyldig backup med minst ett tekstil. Kontroller bildeantall i forhåndsvisningen. Stopp ved feil.
3. Kjør **Test avvisning av ugyldig backupinnhold**. Kontroller meldingen **OK: 4/4 ugyldige innholdsvarianter ble avvist. Ingen data importert.** Stopp ved feil.
4. Kontroller at biblioteket er uendret, og gjenta på iPhone og iPad. **209 forblir ❗️ til eksplisitt godkjenning.**


### Devpatch 0097 – integrasjonstest av automatisk patchinstallasjon

**Arbeidsflyt ❗️ – avventer lokal validering.** Dette er en dokumentasjonsoppdatering, ikke en ny SwiftUI-funksjon. Test 209 er validert OK av bruker. Patchen er bevisst begrenset til denne dokumentasjonsfilen for å teste at `project-workflow` pakker ut, kopierer og SHA-256-verifiserer filen på korrekt prosjektsti.

1. Kjør `./project-workflow.sh tekstilig --dry-run` fra `project-workflow`-mappen med devpatch 0097 i konfigurert innboks. Kontroller at målet er `docs/SWIFTUI-IMPLEMENTERING.md`, **ikke** `Tekstilig-devpatch-0097/docs/...`. Stopp ved feil.
2. Kjør `./project-workflow.sh tekstilig` for installasjon, kontroll, commit, push og eksport. Stopp ved feil.
3. Kjør `./project-workflow.sh tekstilig --status`. Forvent `last_successful_patch=0097`, `last_successful_export=0055`, `next_patch=0098`, `next_export=0056`, `pending=null`.
4. Last opp `Tekstilig-SwiftUIActualApp0055.zip`. Kontroller ZIP-innhold og at ingen feilplassert `Tekstilig-devpatch-0097/`-mappe finnes. Arbeidsflyt-testen markeres først ✅ etter godkjent resultat.

Ingen Xcode-bygging kreves for denne dokumentasjonspatchen. Neste funksjonelle Tekstilig-test blir 210.


## 210. Devpatch 0098 – skrivebeskyttet importplan mot iCloud

**210 ✅ – validert av bruker på macOS, iPhone og iPad.**

Etter vellykket ZIP-lesing kan brukeren trykke **Beregn importplan (kun kontroll)**. Appen henter eksisterende tekstil-ID-er fra privat CloudKit og beregner antall nye og overlappende tekstiler for «Importer bare nye», samt størrelsen på biblioteket som må håndteres ved «Erstatt hele biblioteket». Ingen CloudKit-skriving, sletting eller gjenoppretting utføres. Sammenligningen er et øyeblikksbilde og gir ikke transaksjonsgaranti.

1. Installer devpatch 0098 over komplett versjon 0055 med `project-workflow`, og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, og velg en gyldig backup. Kontroller at forhåndsvisningen vises. **Stopp ved feil.**
3. Trykk **Beregn importplan (kun kontroll)**. Kontroller at aktivitetsindikatoren vises, og at antall eksisterende tekstiler, nye ID-er og overlappende ID-er virker riktig. Ved backup av samme bibliotek forventes normalt 0 nye tekstiler. **Stopp ved feil.**
4. Kontroller at biblioteket er uendret; ingen import eller sletting skal ha skjedd. **Stopp ved feil.**
5. Gjenta på iPhone og iPad. **210 markeres først ✅ etter eksplisitt godkjenning.**

Neste fase: konkret sikker importstrategi, konfliktregler for tilhørende records/bilder og vurdering av CloudKit-grenser før skriveoperasjoner.


## 211. Devpatch 0099 – oversikt over tilhørende backupdata i importplan (kun kontroll)

**211 ✅ – validert av bruker på macOS, iPhone og iPad (bygg OK, ett ufarlig kompilatorvarsel).**

Utvider eksisterende importplan med antall stoffstykker, bilder, materialer og farger fra den allerede validerte backupen. For «Importer bare nye» vises disse tallene separat for tekstiler som ville blitt importert, og tekstiler som ville blitt hoppet over på grunn av overlappende tekstil-ID. For «Erstatt hele biblioteket» vises tilsvarende totalsummer fra backupen. Eksisterende underposter i CloudKit er **ikke** lest; planen er fortsatt et skrivebeskyttet øyeblikksbilde og **ikke** en transaksjonssikker restore-plan. Ingen CloudKit-skriving.

1. Installer devpatch 0099 over komplett versjon 0056 via `project-workflow`. Bygg i Xcode 27. **Stopp ved byggefeil.**
2. Velg en gyldig ZIP under **Utvikling → Diagnostikk → Roadmap 7** og trykk **Beregn importplan (kun kontroll)**. Kontroller at importplanen nå viser tekstiler, stoffstykker, bilder, materialer og farger for både nye og overlappende tekstiler. **Stopp ved feil.**
3. Bruk gjerne backup fra samme bibliotek: «Ville importert» skal da normalt vise 0 tekstiler og 0 tilhørende poster, mens «Ville hoppet over» skal vise innholdet i backupen. **Stopp ved feil.**
4. Kontroller at advarselen om at eksisterende underposter i CloudKit ikke er sammenlignet vises, og at biblioteket er uendret. **Stopp ved feil.**
5. Gjenta på iPhone og iPad. **211 markeres først ✅ etter eksplisitt godkjenning.**

Neste steg: kartlegg entydig CloudKit-recordidentitet og feil-/rollbackstrategi før noen skriveoperasjon aktiveres.


## 212. Devpatch 0100 – sikkerhetsvurdering av import (kun kontroll)

**212 ❗️ – avventer eksplisitt validering. 211 ✅ validert av bruker.**

Utvider den eksisterende skrivebeskyttede importplanen med en tydelig sperre mot CloudKit-skriving og antall **logiske tekstil-ID-er som forekommer mer enn én gang** i eksisterende CloudKit-data. Dette er et relevant faresignal fordi `textileID` er et applikasjonsfelt, mens `CKRecord.ID.recordName` er en separat CloudKit-identitet. Beregningen bruker allerede innleste tekstiler og gjør ingen ekstra CloudKit-kall. Den ubrukte variabelen `duplicates` er fjernet fra diagnostikkvisningen (kompilatorvarsel fra 211).

1. Installer devpatch 0100 på komplett versjon 0057 med `project-workflow`, og bygg i Xcode 27. Kontroller at advarselen om ubrukte `duplicates` er borte. **Stopp ved byggefeil.**
2. Velg en gyldig backup i **Utvikling → Diagnostikk → Roadmap 7** og trykk **Beregn importplan (kun kontroll)**. Kontroller at **Sikkerhetsvurdering før eventuell import** vises med antall dupliserte tekstil-ID-er i iCloud og **Skriving til CloudKit: SPERRET (ikke implementert)**. **Stopp ved feil.**
3. Kontroller at tidligere antall for begge importmetoder fortsatt vises, og at ingen data er endret. **Stopp ved feil.**
4. Gjenta på iPhone og iPad. **212 forblir ❗️ til bruker eksplisitt godkjenner.**

### Arkitekturgrunnlag før CloudKit-skriving (ikke implementert)

- **Identitet:** `textileID`, `pieceID`, `materialID`, `colorID` og `imageID` er logiske felt i backupen. Eksisterende `save`-metoder oppretter nye `CKRecord`-navn når `cloudRecordName` mangler. De er derfor ikke alene tilstrekkelige for idempotent import eller rollback. En restore må bygge en eksplisitt logisk-ID → record-ID-oversikt, inkludert underposter.
- **Importer bare nye:** Gjør ny lesing av eksisterende tekstiler og underposter før oppstart. Ikke skriv dersom logiske ID-er er tvetydige. Import av ett tekstil må inkludere tilhørende poster og bilder, med journal over nøyaktig hvilke CloudKit-records som ble opprettet. Ved delvis feil må journalen kunne brukes til kontrollert opprydding; opprydding kan selv feile og må rapporteres.
- **Erstatt hele biblioteket:** Skal ikke implementeres som «slett alt, så importer». En sikker strategi krever fullstendig snapshot/tilbakeføringsmulighet, bekreftelse, kontroll av alle record-typer, og eksplisitt håndtering av delvis feil. CloudKit gir ikke én atomisk transaksjon på tvers av alle disse postene og CKAsset-filene.
- **Samtidige endringer:** Importplanen er et øyeblikksbilde, ikke en lås. Før hver skrivefase må relevante konflikter vurderes på nytt. Eksakt «alt eller ingenting» kan ikke loves for et helt bibliotek med denne arkitekturen.
- **Backupbilder:** Leseren verifiserer ZIP og refererte bildefiler, men `Result` eksponerer foreløpig ikke bildebytes til en importør. En egen kontrollert tilgang til verifiserte bildedata må bygges før bildeskriving.
- **Gjeldende sikkerhetsgrense:** Ingen import-/restore-knapper som skriver eller sletter CloudKit-data er aktivert. Test 212 er bare diagnostikk.

Neste steg etter 212: utvikle og teste en **skrivebeskyttet identitets-/avhengighetskartlegging** av alle CloudKit-record-typer og avklare en realistisk feil- og oppryddingsmodell før første skriveoperasjon.


## 213. Devpatch 0101 – skrivebeskyttet kartlegging av CloudKit-identiteter

**212 ✅ og 213 ✅ validert av bruker.**

Legger til «Kartlegg CloudKit-identiteter (kun kontroll)» under Roadmap 7. Leser Textile, Piece, TextileMaterial og TextileColor via eksisterende repositorier, samt mengden tekstil-ID-er med primærbilde. Viser antall poster, dupliserte logiske ID-er, manglende CloudKit recordName og foreldreløse underposter. Bildekartleggingen er eksplisitt ufullstendig: bilde-recordName, ikke-primære bilder og duplikate bilde-ID-er er ennå ikke kontrollert. Ingen skriving/sletting.

1. Installer devpatch 0101 via `project-workflow` på komplett versjon 0058. Bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig backup og trykk **Kartlegg CloudKit-identiteter (kun kontroll)**. Kontroller at aktivitetsindikator vises, og at antall for tekstiler, stoffstykker, materialer og farger virker rimelige. **Stopp ved feil.**
3. Kontroller at rapporten viser duplikater, foreldreløse poster og manglende recordName, samt tydelig begrensning for bilder og **Skriving til CloudKit: SPERRET**. **Stopp ved feil.**
4. Kontroller at biblioteket er uendret. Gjenta på iPhone og iPad. **213 forblir ❗️ til eksplisitt godkjenning.**

Neste steg: fullstendig skrivebeskyttet bildeidentitetskartlegging og konkrete konfliktregler før import.


## 214. Devpatch 0102 – fullstendig skrivebeskyttet kartlegging av bildeposter

**214 ✅ – validert OK av bruker. 213 ✅ godkjent av bruker.**

Identitetskartleggingen leser metadata fra alle `TextileImage`-poster (unntatt kjent diagnostikkpost), uten å hente CKAsset-bytes. Rapporterer totalt antall, primærbilder, dupliserte logiske `imageID`, tekstiler med flere primærbilder, manglende `imageId`/`textileId`, foreldreløse poster og manglende `recordName`. Bruker paginering og avbryter rapporten ved CloudKit-feil. Dette er en skrivebeskyttet oversikt, ikke en importgaranti.

1. Installer devpatch 0102 på komplett versjon 0059 med `project-workflow`; bygg i Xcode 27. **Stopp ved byggefeil.**
2. Velg gyldig ZIP under **Utvikling → Diagnostikk → Roadmap 7**, og trykk **Kartlegg CloudKit-identiteter (kun kontroll)**. Kontroller at rapporten inneholder ny seksjon «Bildeposter (alle, unntatt diagnostikk)» med antall, primærbilder, duplikater og foreldreløse poster. **Stopp ved feil.**
3. Kontroller at **Skriving til CloudKit: SPERRET** vises og at biblioteket er uendret. Gjenta på iPhone og iPad. **214 validert OK av bruker.**


## 215. Devpatch 0103 – konfliktregler for «Importer bare nye» (kun kontroll)

**215 ✅ – validert OK av bruker. 214 ✅ godkjent av bruker.**

Ny knapp **Kontroller importkonflikter (kun kontroll)**. Leser eksisterende tekstiler og vurderer logiske ID-er i den validerte backupen. Avviser foreløpig importplan ved dupliserte tekstil-ID-er i CloudKit/backup, tomme tekstil-ID-er, dupliserte underpost-ID-er på tvers av backupen eller tomme underpost-ID-er. Eksisterende tekstiler hoppes over sammen med alle sine underposter. Resultatet **FORELØPIG OK** betyr ikke at import er trygg: kontroll av eksisterende underpost-ID-er i CloudKit, samtidige endringer og håndtering av delvise feil gjenstår. Ingen CloudKit-skriving eller -sletting.

1. Installer devpatch 0103 på komplett versjon 0060 med `project-workflow`, og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig backup og trykk **Kontroller importkonflikter (kun kontroll)**. Kontroller at status, nye/overlappende tekstiler, dupliserte/tomme ID-er og begrensninger vises. **Stopp ved feil.**
3. Kontroller at **Skriving til CloudKit: SPERRET** vises og at biblioteket er uendret. Gjenta på iPhone og iPad. **215 validert OK av bruker.**


## 216. Devpatch 0104 – konfliktkontroll mot eksisterende CloudKit-underposter (kun kontroll)

**216 ✅ – validert OK av bruker på macOS, iPhone og iPad. 215 ✅ godkjent.**

Konfliktkontrollen henter nå paginerte logiske ID-er fra alle eksisterende stoffstykker, bilder, materialer og farger. Bildeoppslaget henter kun `imageId`, aldri CKAsset-data, og utelater kjent diagnostikkpost. Sammenligningen mot live-ID-er gjelder bare underpostene til **nye** tekstiler som ville blitt importert; underposter til overlappende tekstiler hoppes over. Dupliserte eller tomme underpost-ID-er i live-biblioteket og kollisjoner mot nye backup-underposter gir **AVVIST**. Feil i et eneste CloudKit-oppslag avviser kontrollen. **FORELØPIG OK** er fortsatt ikke klarsignal til import: samtidige endringer og delvis feil er ikke løst. Ingen CloudKit-skriving eller -sletting.

1. Installer devpatch 0104 på komplett versjon 0061 med `project-workflow` og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig ZIP-backup og trykk **Kontroller importkonflikter (kun kontroll)**. Kontroller at rapporten viser duplikater/tomme ID-er i iCloud og kollisjoner for stoffstykker, bilder, materialer og farger. **Stopp ved feil.**
3. Kontroller at rapporten viser **Skriving til CloudKit: SPERRET**, at biblioteket er uendret, og gjenta på iPhone og iPad. **216 godkjent ✅ av bruker.**


## 217. Devpatch 0105 – to påfølgende CloudKit-lesinger (kun kontroll)

**217 ✅ – validert OK av bruker. 216 ✅ godkjent.**

Ny knapp **Kontroller endringer mellom to CloudKit-lesinger (kun kontroll)**. Leser tekstiler, stoffstykker, alle bilde-ID-er, materialer og farger to ganger og sammenligner sorterte identiteter, foreldre og recordName (for tekstiler også updatedAt). Feil i en lesing gir AVVIST. Testen oppdager enkelte samtidige endringer, men er **ikke** atomisk, oppdager ikke alle feltendringer eller endringer som skjer etter kontrollen, og gir aldri klarsignal til skriving. Bildeinnhold og bilde-recordName inngår ikke. Ingen CloudKit-skriving eller -sletting.

1. Installer devpatch 0105 på komplett versjon 0062 med `project-workflow` og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig ZIP-backup og trykk **Kontroller endringer mellom to CloudKit-lesinger (kun kontroll)**. Kontroller at rapporten viser to opptellinger, status og eksplisitte begrensninger. **Stopp ved feil.**
3. Kontroller at rapporten viser **Skriving til CloudKit: SPERRET**, at biblioteket er uendret, og gjenta på iPhone og iPad. **217 godkjent ✅ av bruker.**


## 218. Devpatch 0106 – simulering av avbrutt import (kun i minnet)

**218 ✅ – validert OK av bruker. 217 ✅ godkjent av bruker.**

Ny knapp **Simuler avbrutt import (kun i minnet)** under Roadmap 7. Bruker ett tekstil fra en allerede validert ZIP-backup og bygger en tenkt operasjonsrekkefølge: tekstil, stoffstykker, materialer, farger og bilder. Simulerer avbrudd før hver operasjon og etter siste, fører en journal over tenkte opprettelser og kontrollerer om kompensasjon i omvendt rekkefølge tømmer den simulerte tilstanden. Ingen CloudKit-kall og ingen skriving. Testen er **ikke** bevis for at CloudKit-rollback fungerer: delvise nettverksfeil, CKAsset, ukjent serversvar, appavslutning og samtidig endring krever en separat, vedvarende og idempotent implementasjon.

1. Installer devpatch 0106 på komplett versjon 0063 med `project-workflow`, og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7** og velg en gyldig ZIP-backup med minst ett tekstil. Trykk **Simuler avbrutt import (kun i minnet)**. Kontroller at rapporten viser antall planlagte operasjoner, injiserte avbrudd, **Journal tilbakeført ... OK**, og **Simulerte gjenstående poster ... 0**. **Stopp ved feil.**
3. Kontroller at **Skriving til CloudKit: SPERRET** vises og at biblioteket er uendret. Gjenta på iPhone og iPad. **218 validert OK av bruker.**


## 219. Devpatch 0107 – vedvarende lokal testjournal (ingen CloudKit-skriving)

**219 ✅ – validert OK av bruker. 218 ✅ godkjent av bruker.**

Diagnostikken oppretter en JSON-testjournal under appens Application Support med atomisk filskriving og umiddelbar kontroll ved gjenlesing. Journalen inneholder unik journal-ID, ett eksempeltekstil, planlagt operasjonsrekkefølge og status «interrupted-test-only», med **null fullførte operasjoner**. En separat knapp leser journalen på nytt (også etter fullstendig appavslutning), validerer innholdet og sletter den lokale testfilen. Ukjent eller skadet journal beholdes for feilsøking. Eksisterende journal overskrives aldri. Dette er **ikke** automatisk gjenopptakelse, kompensasjon eller en virkelig importjournal. Ingen CloudKit-skriving.

1. Installer devpatch 0107 på komplett versjon 0064 med `project-workflow`, bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig ZIP-backup med tekstiler og trykk **Opprett lokal testjournal (ingen import)**. Kontroller «opprettet og lest tilbake: OK», fullførte 0 og «Skriving til CloudKit: SPERRET». **Stopp ved feil.**
3. Avslutt appen helt, åpne den igjen, gå til samme diagnostikkside og trykk **Les og slett lokal testjournal** (du trenger ikke velge backup igjen). Kontroller «Journal gjenfunnet ... OK», «Lokal testjournal slettet: OK» og at CloudKit er sperret. **Stopp ved feil.**
4. Trykk **Les og slett lokal testjournal** en gang til og kontroller «Ingen lokal testjournal funnet». Kontroller at biblioteket er uendret. Gjenta på iPhone og iPad. **219 validert OK av bruker.**


## 220. Devpatch 0108 – ukjent serversvar og idempotent gjentakelse (kun simulering)

**220 ✅ – validert OK av bruker. 219 ✅ godkjent av bruker.**

Ny knapp under Roadmap 7: **Simuler ukjent serversvar og trygg gjentakelse (kun i minnet)**. Bruker ett tekstil fra validert ZIP-backup og lager logiske operasjonsnøkler for tekstil, stoffstykker, materialer, farger og bilder. For hver operasjon simuleres to mulige utfall av et manglende serversvar: serveren har lagret posten, eller den har ikke lagret den. Simulert gjenlesing og gjentakelse skal gi nøyaktig én logisk post per nøkkel. Dupliserte eller tomme logiske nøkler avvises. **Dette er ikke CloudKit-idempotens:** modellen verifiserer verken CKRecord.ID, CKRecord.changeTag, konkurrerende skrivere, asset-tilstand eller faktisk serversvar. Ingen CloudKit-kall eller -skriving.

1. Installer devpatch 0108 på komplett versjon 0065 med `project-workflow`, og bygg i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg gyldig ZIP-backup med minst ett tekstil, trykk **Simuler ukjent serversvar og trygg gjentakelse (kun i minnet)**. Kontroller **Simulering av ukjent serversvar: OK**, at scenarier er større enn null og **Dupliserte logiske poster etter gjentakelse: 0**. **Stopp ved feil.**
3. Kontroller **Skriving til CloudKit: SPERRET** og uendret bibliotek. Gjenta på iPhone og iPad. **220 validert OK av bruker.**


## 221. Devpatch 0109 – stabile kandidat-ID-er og eierskapskonflikt (kun simulering)

**221 ✅ – validert OK av bruker. 220 ✅ godkjent av bruker.**

Ny knapp i Roadmap 7: **Simuler stabile CloudKit-ID-er og eierskapskonflikt (kun i minnet)**. Testen bruker første tekstil i valgt, validert ZIP-backup, lager deterministiske *kandidatnavn* fra type og logisk ID, avviser tomme/dupliserte nøkler og simulerer to utfall ved tapt serversvar. Den kontrollerer også at en post med samme kandidatnavn, men en annen eier, **må avvises**. Navnene er **ikke** verifisert mot eksisterende CKRecord.ID-strategi i appen eller mot CloudKit; denne testen gir ingen tillatelse til import. Ingen CloudKit-skriving.

1. Installer devpatch 0109 på komplett eksport 0066 via `project-workflow`. Bygg med ⌘B i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig ZIP-backup med minst ett tekstil. Trykk **Simuler stabile CloudKit-ID-er og eierskapskonflikt (kun i minnet)**.
3. Kontroller **Simulering av stabile kandidat-ID-er: OK**, **Kollisjon med annen eier avvist: OK** og **Skriving til CloudKit: SPERRET**. **Stopp ved feil.**
4. Kontroller uendret bibliotek og gjenta på iPhone og iPad. **221 validert OK av bruker.**


## 222. Devpatch 0110 – kartlegg eksisterende CKRecord.ID-strategi (kun kontroll)

**222 ✅ – validert OK av bruker. 221 ✅ godkjent av bruker.**

Ny knapp **Vis faktisk CKRecord.ID-strategi (kun kontroll)** i Roadmap 7. Rapporten dokumenterer funn ved inspeksjon av `save`-metodene i `CloudKitTextileRepository`, `CloudKitPieceRepository`, `CloudKitTextileMaterialRepository`, `CloudKitTextileColorRepository` og `CloudKitTextileImageRepository` fra komplett versjon 0067: eksisterende `cloudRecordName` gir oppslag og oppdatering med `CKRecord.ID(recordName:)`; manglende `cloudRecordName` gir ny `CKRecord(recordType:)` med servergenerert ID. Logiske ID-er lagres som felt. Derfor er test 221 sine kandidatnavn ikke en del av eksisterende persistensstrategi. Dette er en kildekodebasert rapport, ikke live serververifikasjon. Ingen CloudKit-lesing eller -skriving utføres av knappen.

1. Installer devpatch 0110 på komplett versjon 0067 via `project-workflow`; bygg med ⌘B i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7** og trykk **Vis faktisk CKRecord.ID-strategi (kun kontroll)**. Ingen backup kreves.
3. Kontroller at rapporten viser de fem repository-typene, forskjellen mellom eksisterende og ny post, og at logisk ID ikke er CKRecord.ID. Kontroller **Skriving til CloudKit: SPERRET**. **Stopp ved feil.**
4. Kontroller at biblioteket er uendret. Gjenta på iPhone og iPad. **222 validert OK av bruker.**


## 223. Devpatch 0111 – kontroll av faktiske CloudKit-ID-er før import (kun lesing)

**223 ✅ – validert av bruker. 222 ✅ godkjent av bruker.**

Ny knapp **Kontroller eksisterende CloudKit-ID-er før import (kun lesing)**. Leser tekstiler, stoffstykker, materialer, farger og bilde-ID-er fra CloudKit; sammenligner logiske ID-er i validert backup og eksisterende bibliotek. Eksisterende tekstiler skal hoppes over. Avviser dupliserte CloudKit-ID-er, tomme/dupliserte tekstil-ID-er i backup, manglende recordName for fire posttyper og kollisjoner for underposter til nye tekstiler. Bilde-recordName og CKAsset kontrolleres ikke. Resultatet er ikke en atomisk snapshot, og gir aldri tillatelse til skriving. Ingen import er implementert.

UX-feil fra test 222: knappene **Vis faktisk CKRecord.ID-strategi** og **Les og slett lokal testjournal** flyttet ut av betingelsen som krevde valgt backup. De skal nå være tilgjengelige før backup velges. Andre backup-avhengige tester krever fortsatt valgt backup.

1. Installer devpatch 0111 på komplett eksport 0068 via `project-workflow`. Bygg med ⌘B i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7** uten å velge backup. Kontroller at **Vis faktisk CKRecord.ID-strategi** og **Les og slett lokal testjournal** er tilgjengelige. Trykk **Vis faktisk CKRecord.ID-strategi** og kontroller at rapporten vises. **Stopp ved feil.**
3. Velg gyldig ZIP-backup og trykk **Kontroller eksisterende CloudKit-ID-er før import (kun lesing)**. Kontroller at rapporten viser nye/hoppede tekstiler, duplikater, kollisjoner, status og **Skriving til CloudKit: SPERRET**. Ved ingen konflikter forventes **FORELØPIG OK – IKKE SKRIVEKLAR**. **Stopp ved feil.**
4. Kontroller uendret bibliotek og gjenta på iPhone og iPad. **223 forblir ❗️ til bruker validerer.**


## 224. Devpatch 0112 – vurder stabile import-ID-er mot eksisterende CloudKit (kun lesing)

**224 ✅ – validert OK av bruker. 223 ✅ godkjent av bruker.**

Ny knapp **Vurder stabile import-ID-er mot CloudKit (kun lesing)**. Lager import-spesifikke kandidatnavn fra posttype og logisk ID for *nye* tekstiler og deres stoffstykker/materialer/farger; sammenligner kandidatnavn mot kjente `cloudRecordName` fra CloudKit. Avviser tomme/dupliserte type/ID-par, kollisjoner og svært lange kandidatnavn. Denne diagnostikken lager ikke CKRecord-objekter, skriver ikke CloudKit og endrer ikke normale repository-save-metoder. Den verifiserer **ikke** bilde-recordName, eierskap eller atomisk snapshot; «FORELØPIG OK» gir aldri skrivetillatelse.

1. Installer devpatch 0112 på komplett eksport 0069 via `project-workflow`. Bygg med ⌘B i Xcode 27. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg gyldig ZIP-backup og trykk **Vurder stabile import-ID-er mot CloudKit (kun lesing)**. **Stopp ved feil.**
3. Kontroller status, antall kandidater, duplikater, kollisjoner og at bilde-recordName ikke er kontrollert. Bekreft **Skriving til CloudKit: SPERRET**. **Stopp ved feil.**
4. Kontroller uendret bibliotek på Mac, iPhone og iPad. **224 forblir ❗️ til bruker validerer.**


## 225. Devpatch 0113 – bildeidentiteter og eierskap (kun lesing)

**225 ✅ – validert OK av bruker. 224 ✅ godkjent av bruker.**

Ny knapp **Kontroller bildeidentiteter og eierskap (kun lesing)**. Henter alle `TextileImage`-recordnavn, logiske `imageId` og eier `textileId` med paginering uten å hente `CKAsset`. Sammenligner bilde-ID-er fra nye tekstiler i valgt backup med eksisterende bildeposter, avviser tomme/dupliserte ID-er, kollisjoner med eksisterende imageID, kandidatnavnkollisjoner og mangelfulle eksisterende bildeidentiteter. Rapporterer også kollisjoner med annen eier. Ingen endring i normale save-metoder. Ingen CloudKit-skriving. Snapshot er ikke atomisk, og kontrollen gir ingen importtillatelse.

1. Installer devpatch 0113 på komplett eksport 0070 med `project-workflow`. Bygg i Xcode 27 med ⌘B. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg en gyldig ZIP-backup og trykk **Kontroller bildeidentiteter og eierskap (kun lesing)**. **Stopp ved feil.**
3. Kontroller antall CloudKit-bilder, nye bilder, duplikater, kollisjoner og eierskap. Bekreft **Skriving til CloudKit: SPERRET**. Ved ingen funn forventes **FORELØPIG OK – IKKE SKRIVEKLAR**. **Stopp ved feil.**
4. Bekreft at biblioteket er uendret. Gjenta på iPhone og iPad. **225 forblir ❗️ til bruker validerer.**


## 226. Devpatch 0114 – samlet importkontroll for fem CloudKit-posttyper (kun lesing)

**226 ✅ – validert OK av bruker. 225 ✅ godkjent av bruker.**

Ny knapp **Samlet importkontroll for alle fem posttyper (kun lesing)**. Leser metadata for Textile, Piece, TextileMaterial, TextileColor og TextileImage, velger bare tekstiler som mangler i CloudKit, og vurderer logiske ID-er, eier, duplikater, kandidatnavn og kollisjoner samlet. Ingen CKAsset lastes ned. CloudKit-lesing er ikke atomisk; status FORELØPIG OK er ikke skrivetillatelse. Ingen save/delete.

1. Installer devpatch 0114 på komplett eksport 0071 via `project-workflow`. Bygg i Xcode 27 med ⌘B. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg gyldig ZIP-backup, trykk **Samlet importkontroll for alle fem posttyper (kun lesing)**. **Stopp ved feil.**
3. Kontroller at alle fem posttyper og antall kandidater vises, status **FORELØPIG OK – IKKE SKRIVEKLAR** ved konfliktfritt resultat (ellers **AVVIST** med årsak), samt **Skriving til CloudKit: SPERRET**. **Stopp ved feil.**
4. Kontroller at biblioteket er uendret; gjenta på iPhone og iPad. **226 validert OK av bruker.**


## 227. Devpatch 0115 – vedvarende skrivebeskyttet operasjonsplan

**227 ✅ – validert OK av bruker. 226 ✅ godkjent av bruker.**

Ny knapp **Lagre kontrollert importplan i lokal testjournal (ingen import)** aktiveres bare etter konfliktfri **Samlet importkontroll for alle fem posttyper (kun lesing)**. Den lagrer operasjonsrekkefølge for alle fem posttyper til `Application Support/TekstiligImportDiagnostics/read-only-import-plan-v1.json` med atomisk filskriving og leser den tilbake for verifisering. Alle operasjoner har status planlagt og null fullførte. Eksisterende journal overskrives ikke. Ingen CloudKit-skriving; planen er ikke en virkelig importjournal, og CloudKit-snapshot er ikke atomisk.

1. Installer devpatch 0115 på komplett eksport 0072 via `project-workflow`; bygg i Xcode 27 med ⌘B. **Stopp ved byggefeil.**
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg gyldig backup. Kontroller at journal-knappen er deaktivert før samlet importkontroll.
3. Kjør **Samlet importkontroll for alle fem posttyper (kun lesing)**. Bare ved status **FORELØPIG OK – IKKE SKRIVEKLAR**: trykk **Lagre kontrollert importplan i lokal testjournal (ingen import)**.
4. Kontroller **Lokal importplan lagret og lest tilbake: OK**, antall operasjoner, **Fullførte: 0**, og **Skriving til CloudKit: SPERRET**. Trykk igjen og kontroller at overskriving **AVVIST**.
5. Kontroller uendret bibliotek. Test på iPhone og iPad. Merk at journalfilen bevisst beholdes for senere test av gjenfinning og sletting. **227 forblir ❗️ til bruker validerer.**


## 228. Devpatch 0116 – gjenfinn og valider lokal importplanjournal etter omstart

**228 ✅ – validert OK av bruker etter omstart med 4 operasjoner. 227 ✅ godkjent av bruker.**

Ny knapp **Gjenfinn og valider importplanjournal (ingen import)** er tilgjengelig uten valgt backup. Leser den eksisterende `read-only-import-plan-v1.json` fra Application Support etter omstart, validerer formatversjon, tilstand, null fullførte operasjoner, ikke-tom operasjonsliste, tillatte posttyper og unike/ikke-tomme operasjons-ID-er. Tester også ugyldig status, duplikat og uventet fremdrift på **minnekopier**. Ugyldig eller uleselig journal avvises, og filen beholdes for feilsøking. Journalen slettes ikke av denne testen. Ingen CloudKit-lesing eller -skriving. Dette er fremdeles ikke en ekte gjenopptakelsesmekanisme.

1. Installer devpatch 0116 på komplett eksport 0073 med `project-workflow`; bygg med ⌘B. Stopp ved byggefeil.
2. Avslutt appen helt og start den på nytt. Åpne **Utvikling → Diagnostikk → Roadmap 7** **uten** å velge backup.
3. Trykk **Gjenfinn og valider importplanjournal (ingen import)**. Kontroller **Importplanjournal gjenfunnet og validert: OK**, journal-ID, antall operasjoner, **Fullførte: 0**, negativtestene **avvist: OK** og **Skriving til CloudKit: SPERRET**. Stopp ved feil.
4. Trykk knappen på nytt og kontroller samme journal-ID (filen beholdes). Kontroller at biblioteket er uendret. Gjenta på iPhone og iPad **der test 227 opprettet journal**. Merk at journalen er lokal per enhet.
5. Dersom journalen ikke finnes, **ikke** opprett en ny uten å avklare resultatet først; meld tilbake **Ingen lagret importplanjournal funnet**.


### Rettelse for test 228 – devpatch 0117

**228 ❗️ – ny validering kreves.** Test 227 lagret operasjons-ID-er med faktiske posttypenavn (`Textile`, `Piece`, `TextileMaterial`, `TextileColor`, `TextileImage`), mens første versjon av test 228 validerte mot feilaktige små bokstaver og kortnavn. Derfor ble en gyldig journal avvist etter omstart. Devpatch 0117 retter bare tillatte posttypenavn i validatoren; eksisterende journal skal **ikke slettes eller overskrives**. Kjør test 228 på nytt uten valgt backup og kontroller samme journal-ID ved gjentatt kontroll. Ingen CloudKit-skriving.


### Diagnostisk rettelse for test 228 – devpatch 0118

**228 ❗️ – fortsatt ikke validert.** På macOS avviser også devpatch 0117 eksisterende journal. Vi bevarer den opprinnelige journalfilen og viser nå hvert avvik i journalens versjon, status, fremdrift, duplikater eller operasjons-ID-format. Validatorens regler endres ikke. Rapporten begrenses til de første avvikene og viser journal-ID og antall operasjoner. **Ingen lokal journal endres eller slettes, og CloudKit-skriving er sperret.**

1. Installer devpatch 0118 på den samme Mac-en uten å slette appen eller journalen. Bygg i Xcode.
2. Åpne Utvikling → Diagnostikk → Roadmap 7 og velg «Gjenfinn og valider importplanjournal (ingen import)». Backup er ikke nødvendig.
3. Hvis rapporten viser AVVIST, kopier hele rapporten med «Valideringsfeil» og send den til gjennomgang. Ikke opprett en ny journal.
4. Hvis rapporten viser OK, gjenta kontrollen og verifiser samme journal-ID og uendret bibliotek. Først da kan 228 godkjennes.


### Rettelse test 228 – devpatch 0119 (basert på full eksport 0076)

**228 ❗️ – avventer ny validering.** Årsak bekreftet med devpatch 0118: test 227 tillot tom operasjonsliste (0 nye tekstiler), mens test 228 avviser den. Rettelse: Journalopprettelse avviser nå 0 operasjoner og skriver ingen fil. En egen knapp kan etter bekreftelse slette **bare** lokal `read-only-import-plan-v1.json` når den dekoder korrekt, har schemaVersion 1, state `planned-read-only`, 0 operasjoner og 0 fullførte. Alle andre journaler beholdes. Ingen CloudKit-skriving eller automatisk nettsletting.

❗️ Test: 1. Bygg. 2. På Mac, slett tom lokal journal med den nye knappen og bekreft. 3. Velg backup der alle tekstiler allerede finnes i CloudKit; kjør samlet importkontroll og forsøk å lagre journal; forvent tydelig AVVIST 0 operasjoner. 4. Sørg for at minst ett tekstil i backup ikke finnes i CloudKit (testdata kan slettes manuelt via appen etter eget valg), kjør samlet kontroll på nytt og lagre journal; forvent >0 operasjoner. 5. Avslutt og start appen på nytt, gjenfinn journal uten backup; forvent OK og samme journal-ID ved gjentakelse. 6. Bekreft ingen importskriving og ingen uønsket endring i biblioteket. Ikke marker 228 som godkjent før bruker har bekreftet.


## 229. Devpatch 0120 – lokal SHA-256-binding mellom ZIP-backup og eksisterende testjournal

**229 ✅ – validert OK av bruker. 228 ✅ validert OK av bruker.**

Eksisterende journal fra test 228 bevares uendret. Ny lokal sidefil `read-only-import-binding-v1.json` lagrer journal-ID, operasjons-ID-er og SHA-256 av de eksakte ZIP-bytene som brukeren velger. Bindingen overskrives ikke. Kontroll avviser endret ZIP, feil journal-ID og endret operasjonsliste. Negativtesten for endret ZIP utføres kun i minnet. **Begrensning:** Den gamle journalen inneholder ikke hash fra opprettelsestidspunktet; bindingen beviser derfor ikke historisk at journalen opprinnelig ble opprettet fra denne ZIP-en. Dette må bygges inn ved journalopprettelse før faktisk import kan vurderes. Ingen CloudKit-skriving.

1. Installer devpatch 0120 på komplett eksport 0077 og bygg i Xcode. Stopp ved feil.
2. Åpne Roadmap 7, velg samme ZIP-backup som ved test 228. Trykk «Bind valgt backup til eksisterende testjournal (kun lokalt)». Kontroller OK, journal-ID og SHA-256. Stopp ved avvisning.
3. Trykk «Kontroller backupbinding mot journal (kun lokalt)». Kontroller OK og at endret ZIP avvises i minnet.
4. Avslutt og start appen på nytt, velg den samme ZIP-filen og kjør kontrollen på nytt. Kontroller samme journal-ID og OK.
5. Velg en annen gyldig ZIP-backup dersom tilgjengelig og kontroller at den avvises ved ulik hash. Velg deretter originalen på nytt og kontroller OK. Ikke slett journalen eller sidefilen. CloudKit skal være uendret.


## 230. Devpatch 0121 – SHA-256 i journalen ved opprettelse (kun lokalt)

**230 ✅ fullstendig brukervalidert 2026-11-06.** Prosjekteieren har bekreftet den nye skrivebeskyttede diagnostikkfunksjonen i appen, korrekt avvisning av `Tekstilig-backup2.zip` ved avvikende SHA-256 og korrekt godkjenning av `Tekstilig-backup.zip` ved samsvar. Etterkontrollen viste uendret journal-ID, ZIP-binding og operasjonstall:

- Journal-ID: `3EC77AF2-223E-4556-AAFB-98376557CE47`.
- Lagret ZIP SHA-256: `004ced842dd8da950c7d3552d149bb1ca9af02e72d2491219e2ad376374bf963`.
- Planlagte operasjoner: 4. Fullførte operasjoner: 0.
- Alternativ ZIP SHA-256: `f34f8804d9ce1789e28eb71d5d476653add318a7ca30a13eebeb98249bd860b9`.

Ingen faktisk import, restore eller CloudKit-skriving ble utført. Godkjenningen gjelder journalbinding og skrivebeskyttet diagnostikk; CloudKit-skriving/-sletting under import/restore er fortsatt sperret. Test 238 er fortsatt ✅ fullført. Tidligere ❗️-statuser for test 230 nedenfor og i senere testbeskrivelser er historikk fra før denne godkjenningen.

### Historikk og gjennomført testprosedyre

**Statuspresisering 2026-11-01:** Gjennomførte kontroller er tidligere validert, jf. punkt 231. Negativtest med en annen gyldig ZIP med ulikt innhold/hash er fortsatt ❗️ uavklart. Delstatusen nedenfor og testprosedyren beholdes som historikk.

**230 ❗️ – avventer validering. 229 ✅ validert OK av bruker.**

**Minimal rettelse 2026-11-01 – implementert, ikke brukervalidert:** `verifyBoundReadOnlyJournal()` bruker nå `existingIdentityDiagnosticURL("read-only-import-plan-v2.json")` med `create: false`, i stedet for URL-kjeden som kunne opprette Application Support-katalogen. Manglende katalog/journal gir eksisterende kontrollerte AVVIST-melding. Hashkontroll, godkjennings-/avvisningsmeldinger, journalformat og øvrige URL-kallere er uendret. Verifikasjonen leser ikke baseline og utfører ingen CloudKit-operasjoner. Ved gjenstående negativtest skal eksisterende grunnlag bevares; bruk bare «Velg ZIP-backup …» og «Kontroller ny journal og backupbinding (kun lokalt)». Ikke gjenta historikkens journalopprettelse. Alternativ ZIP må være en eksisterende gyldig backup med forskjellig SHA-256. Restpunktet forblir ❗️ til begge utfall er bekreftet av brukeren.

**Diagnostikkutvidelse 2026-11-06 – implementert, ikke brukervalidert:** I **Utvikling → Diagnostikk → Roadmap 7: les backup (kun kontroll)** finnes nå «Vis eksisterende v2-journalbinding (kun lesing)», uten krav om valgt ZIP. Knappen ligger før «Vis faktisk CKRecord.ID-strategi (kun kontroll)». Den leser bare eksisterende v2-journal gjennom URL-hjelperen med `create: false`, bruker eksisterende validator og viser full journal-ID, lagret ZIP SHA-256 og planlagt operasjonstall. Manglende eller ugyldig journal gir AVVIST; ikke opprett eller erstatt journalen. Ingen ZIP-/baseline-lesing eller CloudKit-operasjoner. Sammenlign hele lagrede hashverdien mot de to kontrollerte backupene før negativtesten. Funksjonen er ikke kjørt mot brukerens journal; test 230-restpunktet forblir ❗️.

Ny, separat `read-only-import-plan-v2.json` lagrer journal-ID, planlagte operasjoner og SHA-256 av de validerte ZIP-bytene **i samme atomiske filskriving**. Krever konfliktfri samlet CloudKit-forhåndskontroll og minst én operasjon. Eksisterende v1-journal og binding fra test 229 beholdes uendret. Eksisterende v2-journal overskrives aldri. Kontroll leser v2-filen, validerer format og sammenligner hash med valgt ZIP; endret ZIP avvises i minnet. Ingen CloudKit-skriving. V2 er fortsatt kun diagnostikk og kan ikke gjenoppta reell import.

1. Installer devpatch 0121 på full eksport 0078, bygg med Xcode 27. Stopp ved feil.
2. Velg samme gyldige ZIP som tidligere, kjør «Samlet importkontroll for alle fem posttyper (kun lesing)». Krever minst én kandidat og «FORELØPIG OK – IKKE SKRIVEKLAR». Stopp ved avvisning.
3. Trykk «Opprett ny importplanjournal med innebygd SHA-256 (kun lokalt)». Kontroller OK, journal-ID, SHA-256, >0 operasjoner, Fullførte 0, CloudKit SPERRET.
4. Trykk samme knapp igjen og kontroller at overskriving avvises. Trykk «Kontroller ny journal og backupbinding (kun lokalt)» og kontroller OK.
5. Avslutt appen, start igjen, velg samme ZIP og kontroller v2-journalen på nytt. Kontroller samme journal-ID og SHA-256.
6. Velg en annen gyldig ZIP med ulikt innhold og kontroller AVVIST ved hash-avvik. Velg originalen igjen og kontroller OK. Behold alle journalfiler for senere tester.

## 231. Devpatch 0122 – sammenlign v2-journaloperasjoner med valgt backup

**230 ✅ for gjennomførte kontroller (negativ test med annen ZIP ❗️ ikke utført). 231 ❗️ – avventer brukerens test.**

Ny knapp **Kontroller journaloperasjoner mot backup (kun lokalt)** leser v2-journalen og valgt, validert ZIP uten å endre filer. Kontrollerer SHA-256, at alle operasjons-ID-er finnes i backupen, at alle underposter for valgte tekstiler er med, at underposter ikke er inkludert uten sin eier, og at backupen ikke inneholder dupliserte ID-er innen posttype. Ekstra operasjon og utelatt underpost simuleres kun i minnet. Kontrollen beviser **ikke** at alle tekstiler som er nye relativt til CloudKit er inkludert: Dette krever ny serverlesing og vurdering av samtidighet i senere tester. Ingen CloudKit-skriving.

1. Installer devpatch 0122 på komplett eksport 0079, bygg i Xcode 27.
2. Velg **samme ZIP-backup som i test 230**, åpne Roadmap 7, og trykk **Kontroller journaloperasjoner mot backup (kun lokalt)**. Ingen ny samlet importkontroll er nødvendig.
3. Kontroller **Journaloperasjoner mot valgt backup: OK**, journal-ID, operasjonstall, SHA-256 og **Skriving til CloudKit: SPERRET**. Negativtester skal vise at ekstra operasjon er avvist og, dersom underposter finnes, at utelatt underpost avvises.
4. Avslutt og start appen, velg samme backup og gjenta kontrollen. Bekreft uendret journal-ID og bibliotek. Test 231 markeres først ✅ etter brukerbekreftelse.


## 232. Devpatch 0123 – ny CloudKit-lesing mot lagret v2-importplan

**231 ✅ godkjent av bruker. 232 ❗️ – avventer test.**

Ny knapp **Kontroller v2-journal mot CloudKit på nytt (kun lesing)** leser alle fem posttyper fra CloudKit, sammenligner nåværende komplette importkandidatmengde med den lagrede v2-journalen, kontrollerer dupliserte ID-er, recordName og kollisjoner, og avviser endret kandidatsett. Valgt ZIP og journalens SHA-256 valideres først. En negativtest manipulerer kun en minnekopi. Journalen og CloudKit endres aldri.

**Begrensning:** V2-journalen lagrer ikke opprinnelig CloudKit-snapshot, og kontrollen kan derfor **ikke** bevise at eksisterende poster er uendret historisk. CloudKit-lesingene er heller ikke atomiske; dette er **ikke** en garanti for trygg import eller en skriveklar plan. Endringer som ikke påvirker kandidatmengden kan gå uoppdaget.

1. Installer devpatch 0123 på full eksport 0080 og bygg i Xcode 27. Stopp ved byggefeil.
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**, velg samme ZIP som for test 230–231. Trykk **Kontroller v2-journal mot CloudKit på nytt (kun lesing)**.
3. Kontroller **FORELØPIG OK – IKKE SKRIVEKLAR**, samme journal-ID, operasjonstall, fem posttyper lest, negativtest OK og **Skriving til CloudKit: SPERRET**. Ved AVVIST: send hele rapporten og stopp; **ikke** endre eller slette journalen for å få grønt resultat.
4. Avslutt appen helt, start igjen, velg samme backup og gjenta. Kontroller samme journal-ID.
5. Dersom et disponibelt testtekstil kan legges til i CloudKit med samme logiske ID som et planlagt nytt tekstil, kan konfliktkontrollen testes separat; **ikke** endre CloudKit bare for denne testen uten en avtalt oppryddingsplan. Rapporter om testen ble utelatt.
6. Kontroller at biblioteket er uendret. Behold v2-journal og ZIP. Den åpne negative testen med en annen ZIP fra 230 er fortsatt ❗️.


## 233. Devpatch 0124 – samtidighetsporter (kun deterministisk minnesimulering)

**232 ✅ godkjent av bruker. 233 ❗️ avventer test.**

Ny knapp **Simuler samtidighetskonflikter før import (kun i minnet)** leser eksisterende v2-journal og kontrollert ZIP, men simulerer serverposter lokalt. En fail-closed beslutningsfunksjon sammenligner hypotetiske recordName, logisk ID og changeTag; avviser endret tag, slettet post, ny logisk ID-kollisjon og manglende opprinnelig snapshot. Positiv kontroll bruker identiske minnebilder. **Ingen ekte CloudKit-recordChangeTag leses eller lagres; ingen atomisk serverkontroll eller importskriving er implementert.** Eksisterende v2-journal og backupbinding beholdes. Dette er et avgrenset første steg mot samtidighetsbeskyttelse, ikke en fullført løsning.

1. Installer devpatch 0124 på komplett eksport 0081 og bygg i Xcode 27. Stopp ved feil.
2. Åpne Utvikling → Diagnostikk → Roadmap 7, velg samme ZIP som for test 230–232.
3. Trykk **Simuler samtidighetskonflikter før import (kun i minnet)**. Kontroller **Samtidighetskontroll (kun simulering): OK**, samme journal-ID, og at endret changeTag, ny logisk ID-kollisjon, slettet post og manglende snapshot alle er avvist. Kontroller **Skriving til CloudKit: SPERRET**.
4. Avslutt og start appen, velg samme ZIP og gjenta. Kontroller samme journal-ID og ingen endringer i biblioteket.
5. Behold journal og backup. Ikke marker 233 som godkjent før bruker har validert. Negativtesten med en annen ZIP fra test 230 er fortsatt ❗️.


## 234. Devpatch 0125 – les ekte CloudKit-recordChangeTag (kun lesing)

**233 ✅ validert OK av bruker. 234 ❗️ avventer validering.**

Ny knapp **Les faktiske CloudKit-versjoner (kun lesing)** henter CKRecord-metadata fra alle fem posttyper i privat Development-database. Den bruker paginerte CloudKit-spørringer, teller poster og manglende `recordChangeTag`, og avviser feil i enkeltposter, uventet posttype eller dupliserte `recordName`. Ingen endringer gjøres i v2-journal, backup eller CloudKit. Denne testen oppretter **ikke** historisk snapshot og gjør **ikke** import skriveklar.

1. Installer devpatch 0125 på full eksport 0082 og bygg i Xcode 27. Stopp ved feil.
2. Åpne **Utvikling → Diagnostikk → Roadmap 7**. Trykk **Les faktiske CloudKit-versjoner (kun lesing)**. Backup er ikke nødvendig for denne metadata-kontrollen.
3. Forvent **Faktiske CloudKit-versjoner (kun lesing): OK**, fem posttyper, antall poster og antall uten changeTag. Dersom noen poster mangler changeTag, noter dette som avvik; ikke godkjenn som full dekning. Kontroller **Skriving til CloudKit: SPERRET**.
4. Avslutt og start appen igjen og gjenta. Kontroller at resultatet fortsatt er OK. Antall poster kan endres dersom andre enheter endrer CloudKit; rapporter slike avvik.
5. Kontroller at biblioteket er uendret. Behold v2-journal og backup. Negativtesten med en annen ZIP fra 230 er fortsatt ❗️.


## 235. Devpatch 0126 – bevar og sammenlign faktiske CloudKit-versjoner (kun lesing)

**234 ✅ validert OK av bruker. 235 ❗️ avventer validering.**

To nye knapper i Roadmap 7 lagrer en **separat, uforanderlig lokal baseline** (`read-only-cloudkit-versions-v1.json`) med alle fem posttypers `recordName` og `recordChangeTag`, knyttet til v2-journal-ID og backupens SHA-256. Lagret baseline overskrives ikke. En ny CloudKit-lesing sammenligner alle poster og versjonstagger; tillegg, sletting og endret tag avvises. Manglende changeTag og CloudKit-lesefeil avvises. **Begrensning:** Baseline er hentet med flere ikke-atomiske spørringer, og en lik baseline gir ingen garanti mot endringer mellom kontroll og fremtidig skriving. Ingen CloudKit-skriving.

1. Installer devpatch 0126 på full eksport 0083. Bygg i Xcode 27 og stopp ved feil.
2. Åpne Utvikling → Diagnostikk → Roadmap 7. Velg samme ZIP-backup som for v2-journalen.
3. Trykk **Lagre CloudKit-versjonsbaseline for v2-journal (kun lesing)**. Kontroller OK, journal-ID, antall poster og CloudKit SPERRET. Ved AVVIST: send rapporten, ikke slett filer.
4. Trykk samme knapp igjen. Forvent AVVIST fordi baseline ikke kan overskrives.
5. Trykk **Sammenlign CloudKit med lagret versjonsbaseline (kun lesing)**. Forvent OK og uendret journal-ID dersom ingen andre enheter har endret CloudKit.
6. Avslutt appen helt, start igjen, velg samme ZIP og gjenta sammenligningen. Kontroller OK, samme journal-ID og antall poster.
7. Kontroller at biblioteket er uendret. Behold v1/v2-journal, backupbinding, versjonsbaseline og ZIP. **Ikke fremprovoser CloudKit-endringer** i denne testen. Negativtesten med en annen ZIP fra 230 er fortsatt ❗️.


## 236. Devpatch 0127 – skriveport mot faktisk CloudKit-baseline (ingen skriving)

**235 ✅ godkjent av bruker. 236 ❗️ avventer validering.**

Ny knapp **Test skriveport mot CloudKit-baseline (ingen skriving)** leser v2-journal og lagret baseline, kontrollerer valgt ZIP-hash, henter alle fem CloudKit-posttypers faktiske versjoner på nytt og avviser avvik. Deretter kjøres deterministiske minnetester som avviser endret `recordChangeTag`, slettet post, ny post og duplikater. Filer overskrives ikke. **Dette er ikke en reell atomisk skriveport**: CloudKit kan endres etter lesing, og ingen `CKRecord`-lagring er utført. Skriving er fortsatt sperret.

1. Installer devpatch 0127 på full eksport 0084. Bygg i Xcode 27 og stopp ved feil.
2. Åpne Utvikling → Diagnostikk → Roadmap 7 og velg samme ZIP som journalen og baseline er bundet til.
3. Trykk **Test skriveport mot CloudKit-baseline (ingen skriving)**. Forvent **KONTROLL OK – IKKE SKRIVEKLAR**, uendret journal-ID, antall poster, negative minnetester OK og **CloudKit: SPERRET**. Ved AVVIST: send rapporten, ikke slett journal eller baseline.
4. Avslutt appen helt, start igjen, velg samme ZIP og gjenta kontrollen. Bekreft samme journal-ID og OK.
5. Bekreft uendret bibliotek og behold alle journaler, baseline og backup. Negativtesten med annen ZIP fra test 230 er fortsatt ❗️.


## 237. Devpatch 0128 – create-only identitet og duplikatvern (kun simulering)

**236 ✅ validert OK av bruker. 237 ✅ validert OK av prosjekteieren; status korrigert 2026-11-01 etter uttrykkelig bekreftelse.**

Ny knapp **Simuler create-only og duplikatvern (ingen skriving)** validerer v2-journal og SHA-256 mot valgt ZIP og kjører en ren minnemodell. To skrivere med identisk recordName avvises for forsøk nummer to; to ulike genererte recordName for samme logiske ID tillates begge, og denne **reelle designrisikoen skal vises eksplisitt**. Alle fem posttyper testes med egne identitetsrom. **Ingen CKRecord lagres; dette beviser ikke atomisk CloudKit-atferd eller unikhet for logiske ID-er.** Vi må velge og teste en konkret identitetsstrategi før faktisk import.

1. Installer devpatch 0128 på full eksport 0085. Bygg i Xcode 27; stopp ved feil.
2. Åpne Utvikling → Diagnostikk → Roadmap 7 og velg samme ZIP som er bundet til v2-journalen.
3. Trykk **Simuler create-only og duplikatvern (ingen skriving)**. Kontroller **Create-only og duplikatvern (kun simulering): OK**, journal-ID og operasjonstall, avvist andre skriver med samme recordName, **RISIKO PÅVIST** for ulike genererte recordName og fem identitetsrom. Kontroller **CloudKit: SPERRET**.
4. Avslutt og start appen igjen, velg samme ZIP og gjenta. Kontroller samme journal-ID og resultat.
5. Kontroller uendret bibliotek. Behold journal, baseline og ZIP. Negativtest med annen ZIP fra 230 er fortsatt ❗️.

## 238. Skrivebeskyttet identitetsrapport ved import

**238 ✅ fullført – eksplisitt brukervalidert 2026-11-01 på macOS 27.2, innenfor skrivebeskyttet identitetsavstemming og verifisering av diagnostikkens filtrering.**

Historisk oppstart: Punktet var først avgrenset til videre avklaring av identitetsstrategi etter test 222 og simulering 237, uten implementering eller detaljert testprosedyre. Oppfølgende analyse viste behov for en etterprøvbar rapport i appen før videre vurdering.

Knappen **Vis identitetsavstemming (test 238, kun lesing)** leser eksisterende repository-data for alle fem posttyper og viser deterministisk sorterte identitetsrader i diagnostikkvisningen. Alle backup-underposter er med, også når tekstilet finnes i CloudKit. For hver type/logisk ID vises forventede eiere fra backup, alle observerte eiere/recordnavn, hypotetisk kandidatnavn, journaltilhørighet og tilgjengelige baseline-/versjonstagger. Duplikater, eieravvik, manglende underposter og kandidatnavnkollisjoner oppgis konkret. CloudKit-poster som ikke finnes i backupen vises også. Kjente Textile/Piece/Image-diagnostikkposter utelates av repositoryene.

Valgt ZIP kontrolleres mot eksisterende v2-journals SHA-256, journaloperasjonene mot backupen, og baseline mot journal-ID/ZIP-hash og en ny versjonslesing. Manglende/ugyldige bindinger merkes **IKKE VERIFISERT**, men identitetsradene vises hvis identitetslesingen lykkes. Ved feil i et identitetsoppslag vises **UFULLSTENDIG**, ikke et godkjent delresultat. Ingen lesesti oppretter kataloger. Rapporten er bare i minnet/UI; ingen journal, baseline, ZIP eller backup endres. Ingen importbeslutninger eller ny identitetsstrategi er implementert.

### Sekvensiell brukertest 238 – gjennomført testprosedyre

**Mengdeutvidelse – implementert og brukervalidert innenfor testomfanget:** Rapporten viser nå begge mengdedifferanser mellom allerede innleste versjonsposter og identitetsposter, med nøkkel `posttype + recordName`. Alle differanser listes sortert med posttype, recordnavn, tilhørighet til verifisert baseline og eksakt treff mot de tre eksisterende PoC-filterparene. Bare poster i versjonslesingen som treffer et slikt filterpar merkes **FORVENTET FILTRERING**; øvrige differanser merkes **UVENTET DIFFERANSE – årsak UAVKLART**. Filtertreff verifiserer filterregelen, ikke postens historiske opprinnelse. Antall vises per posttype. Ingen nye CloudKit-oppslag eller filoperasjoner er lagt til. **238 ✅.**

Forutsetninger: Bruk eksisterende ZIP, v2-journal og baseline fra tidligere tester på samme enhet. Ikke opprett eller erstatt grunnlaget. Ha fungerende iCloud/Development-tilgang og unngå samtidige bibliotekendringer. Mangler grunnlaget, stopp og rapporter dette. Ikke bruk gamle opprett-/lagre-/slett-knapper i denne testen.

1. Bygg appen i Xcode 27.2 på valgt målplattform. Stopp ved byggefeil. Åpne **Utvikling → Diagnostikk → Roadmap 7**.
2. Velg den eksisterende ZIP-backupen og vent på vellykket ZIP-validering. Stopp ved feil. Trykk deretter **Vis identitetsavstemming (test 238, kun lesing)** og vent til indikator er borte.
3. Kontroller SHA-256, journal-ID, journaloperasjoner og baselinebinding. Forvent binding OK og uendret baseline dersom biblioteket ikke er endret. Ved **IKKE VERIFISERT**, **AVVIK** eller **UFULLSTENDIG**: behold grunnlaget, rapporter hele avviket og stopp valideringen. Ikke lag ny baseline for å få grønt resultat.
4. Kontroller antall per type og konkrete rader for tilgjengelige Textile-, Piece-, Material-, Color- og Image-poster mot kjent backup/bibliotek. Forvent at underposter til eksisterende tekstiler er med, og at alle matchende faktiske recordnavn og eiere vises. Ikke forvent at eksisterende recordnavn samsvarer med beregnet kandidatnavn. Rapporter typer uten testdata som manglende praktisk dekning; ikke opprett data for denne testen.
5. Kontroller at faktiske avvik forklares konkret. Manglende post for et nytt tekstil beskriver fravær, ikke en beslutning om import. Duplikater, feil eier, manglende underpost under eksisterende tekstil eller navnekollisjon skal rapporteres for vurdering; ikke korriger data i denne testen. Uventet eller uforklarlig rapportresultat er stoppbetingelse. Negative scenarioer som ikke finnes i datasettet rapporteres som ikke praktisk testet.
6. Kontroller de konkrete listene **bare i versjonslesing** og **bare i identitetslesing**, per-type-antall og baseline-tilhørighet. Hypotesen om 43 mot 40 er bekreftet bare dersom de tre faktiske differansene er `Textile:swiftui-poc-textile-v1`, `Piece:swiftui-poc-piece-v1` og `TextileImage:swiftui-poc-textile-image-v1`, og motsatt differanse er tom. Andre resultater skal rapporteres som uavklarte; stopp før godkjenning, uten å endre data eller baseline. De to tidligere uendrede kjøringene på macOS 27.2 bekreftet den opprinnelige rapporten; mengdeutvidelsen ble deretter særskilt brukervalidert, jf. resultatet nedenfor.
7. Trykk rapportknappen igjen uten å endre grunnlaget. Forvent identisk sortert rapport når serverdata er uendret. Kontroller at biblioteket er uendret og at **CloudKit: SPERRET** står i rapporten. Bekreft resultat og faktisk plattform-/scenariodekning til prosjekteieren før 238 eventuelt markeres ✅.

### Brukervalidert resultat – 2026-11-01

Prosjekteieren har uttrykkelig godkjent test 238 som ✅ bestått på macOS 27.2. ZIP ↔ v2-journal, journaloperasjoner ↔ backup, ZIP/journal ↔ baseline og baseline ↔ ny CloudKit-versjonslesing er alle OK.

Versjonslesingen inneholder 43 unike poster og identitetslesingen 40 unike poster. De tre postene som bare finnes i versjonslesingen, finnes alle i verifisert baseline og treffer de eksakte eksisterende PoC-filtrene:

| Posttype | RecordName |
| --- | --- |
| Textile | `swiftui-poc-textile-v1` |
| Piece | `swiftui-poc-piece-v1` |
| TextileImage | `swiftui-poc-textile-image-v1` |

Dette er forventet filtrering. Motsatt differanse er 0, og ingen uventede mengdedifferanser er observert. Filtertreffene bekrefter filterkriteriene, ikke postenes historiske opprinnelse.

Fire poster finnes bare i backupen og svarer til de fire planlagte journaloperasjonene. Ingen operasjoner er utført. Bildepost `IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC`, eier `T0001`, recordName `74B85BA7-9EBF-48FD-A04A-828329F9B237`, beholdes uendret som en sannsynlig historisk rest; faktisk foreldreløshet er ikke fullstendig verifisert.

Godkjenningen gjelder skrivebeskyttet identitetsavstemming og verifisering av diagnostikkens filtrering. Den godkjenner ikke faktisk import/restore, CloudKit-skriving eller -sletting, endelig valg eller implementering av identitetsstrategi, atomisk konsistens mellom separate CloudKit-lesinger eller fullstendig verifikasjon av historisk eierskap og bildeinnhold. Brukervalideringen gjelder macOS 27.2; den dokumenterer ikke en gjennomført brukertest på iOS/iPadOS eller negative scenarioer som ikke inngikk i datasettet.

Begrensning: Identiteter og versjonstagger leses i separate, ikke-atomiske oppslag. Baseline inneholder ikke logisk ID eller eier. Rapporten dokumenterer observerte identiteter og avstemte bindinger, ikke historisk eierskap, CKAsset-innhold, atomisitet, idempotens eller trygg import. Negative minnetester erstatter ikke praktisk CloudKit-testing. CloudKit-skriving under import/restore er fortsatt sperret. Negativtesten med annen gyldig ZIP fra test 230 er fortsatt ❗️ uavklart.


## 239. Identitetsbeslutninger i minnet – ingen skriving

**239 ✅ – fullført, alle elleve punkter og testen samlet uttrykkelig brukervalidert 2026-11-07.** Arkitektur og testomfang er godkjent i [B-050](BESLUTNINGSLOGG.md#b-050--identitetsbeslutninger-før-import-og-restore). Særskilt godkjenning 2026-11-07 omfatter ren Swift-modell og isolert `swiftc`-testprogram; ingen appkobling eller reell import er godkjent. Test 230 og 238 er fullført, brukervalidert og publisert på GitHub; tidligere åpne statusnotater for 230 er historikk.

### Formål og forutsetninger

Den implementerte rene Swift-modellen klassifiserer strukturerte, syntetiske identiteter som gjenbruk eksisterende identitet, kandidat for ny opprettelse, stopp ved konflikt eller stopp ved ugyldig/manglende grunnlag. Alle fem posttyper omfattes: Textile, Piece, TextileMaterial, TextileColor og TextileImage. Klassifisering er ingen importbeslutning eller skrivetillatelse.

Implementeringsgodkjenningen er gitt, og alle elleve testpunkter er nå uttrykkelig brukervalidert innenfor det isolerte omfanget. Modellen bruker den foreløpige strategien `diagnostic-hex-v1-provisional`: `tekstilig-import-v1-` etterfulgt av små heksadesimale UTF-8-byte for `posttype:logiskID`, samme formel som test 238. Algoritmen er ikke godkjent som permanent produksjonsformat. Modellen godtar ikke-tomme synlige ASCII-identifikatorer uten mellomrom; den normaliserer ikke eldre identiteter. Kandidater over 255 byte avvises. Ingen eksisterende backup, journal eller baseline skal brukes som muterbart testgrunnlag. ZIP-/journalbinding, baseline, lesedekning, delvis import og ukjent utfall representeres bare som syntetiske verdier i minnet. Ikke kjør eldre opprett-/slett-/lagre-knapper eller CloudKit-diagnostikk som del av test 239.

### Implementering og automatiserte kontroller – 2026-11-07

- `Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift` er en eksplisitt `nonisolated` verdimodell uten imports eller IO. Immutable `Key`, `Identity`, `Observed`, `InventoryRecord`, `Version`, `Binding`, `Coverage` og `Input` representerer bare mottatte verdier. Recordadressen omfatter container, miljø, konto, database, zone/eier og recordnavn. Nøkkelen er posttype + logisk ID; tekstileier vurderes separat.
- `evaluate(_:)` returnerer sorterte `Row`/`Report` med `reuseExisting`, `candidateForCreation`, `stopConflict` eller `stopInvalidBasis` og strukturerte, sorterte `Stop`-grunner. `permitsCloudKitWriting` er alltid `false`; kandidatens produksjonsgodkjenning er alltid `false`. Globale grunnlagsfeil/duplikater stopper hele rapporten, mens øvrige radkonflikter gir `hasStops`. Rapporten er ikke en skriveplan.
- Eksisterende recordnavn bevares. Nye underposter under eksisterende tekstiler stoppes som utvidelse av importomfanget. Foreldre til eksisterende underposter må være observert; nye familier kan ha en gyldig kandidat som forelder. Journaloperasjonenes nøkler må svare til komplette nye tekstilfamilier; delvis utførte/uavklarte operasjoner stoppes. Dette er ikke en utførelsesjournal.
- Lesedekning og bindinger må være eksplisitt oppgitt i syntetiske inndata. Modellen beregner ikke ZIP-hash, gjør ingen serverlesing og beviser ikke at påstått full dekning er sann. Baseline og gjeldende inventar kontrolleres internt for tagger, adresse/type, duplikater, tillegg og fravær. Ingen adapter til reelle data er implementert.
- `Tests/ImportIdentityDecisionModelTests.swift` ligger utenfor appmappen og kompileres sammen med den faktiske modellfilen. Ingen Xcode-testtarget, pakke eller prosjektendring. Modellfilen inkluderes automatisk i appens eksisterende synkroniserte `Tekstilig`-gruppe.
- **Første automatiserte resultat før kodegjennomgang: 26 bestått, 0 feilet**, exitkode 0. Hvert tilfelle skriver PASS/FAIL; feil gir exitkode 1. Kjøringen brukte ekstra sandkasse som blokkerte nettverk, filskriving og lesing fra brukermappen. Testprogrammet importerer bare Darwin for feilexit; modellen importerer ingen rammeverk.
- Testtilfelle 01–03: entydig gjenbruk og nye kandidater for alle fem typer, eksakt formel/versjon, gjentakelse og omvendt inndatarekkefølge. 04–08: duplikater i backup/observerte data, feil eier, manglende og tvetydig forelder. 09–10: kollisjoner på tvers av identiteter/typer og de tre eksakte PoC-navnene. 11–14: endret/ny/slettet versjon, manglende tag/baseline og ufullstendig lesing. 15–17: feil/manglende binding, operasjonsavvik, delvis import og ukjent serverutfall. 18–26: ugyldige/lange identiteter, sperret komplettering, inventaravvik, duplisert recordadresse, ugyldig recordnavn, deterministisk konfliktrekkefølge, immutable inndata, ingen skriveautorisasjon, syntetisk historisk rest utenfor planen og separate identitetsrom per posttype.
- PoC-testen bruker den samme rene `nameConflicts(proposed:inventory:)`-regelen direkte med de tre eksakte PoC-navnene. Dette er en enhetstest av kollisjonsregelen, ikke en påstand om at hex-formelen kan generere disse navnene. End-to-end-kollisjoner med beregnede navn testes separat. Tvetydige foreldre avvises allerede av duplikatkontrollen.
- macOS og generisk iOS/iPadOS bygger med Xcode 27.2 og `CODE_SIGNING_ALLOWED=NO`. Ingen app er startet. Modellens første actor-advarsel skyldtes prosjektets standard `MainActor`-isolasjon; eksplisitt `nonisolated` fjernet den. Endelige bygg viser bare AppIntents-metadataadvarsel uten framework-avhengighet.
- Statisk kontroll og appenes SwiftFileList bekrefter modellinkludering og uendret diagnostikk/repositories. Ingen reelle ZIP-er, journaler, baseline eller CloudKit-data er lest eller endret. B-050 er urørt; den daterte opprinnelige beslutningen og roadmapets tidligere planstatus erstattes ikke av denne implementeringsoppføringen. Gjeldende implementeringsstatus står her og i PROSJEKTSTATUS.

### Rettelser etter kodegjennomgang – P1/P2 – 2026-11-07

Rotårsak P1: inventarkontrollen krevde bare at observerte identiteter fantes i inventaret. En inventarpost uten identitetsobservasjon kunne derfor bli oversett selv med angivelig komplett dekning. `evaluate(_:)` avstemmer nå begge retninger med nøkkel posttype + full recordadresse. Uforklart inventarpost gir global `stopInvalidBasis` med `unexplainedInventoryRecord`, adresse og ingen opprettelseskandidat.

De tre eksakte type/navn-parene fra PoC-filtrene håndteres eksplisitt. Manglende identitetsobservasjon for et slikt filtertreff gir `unresolvedFilteredIdentity` og stopper fortsatt hele rapporten. Filteret forklarer bare utelatelsen; det avklarer ikke logisk ID/eier og gjør ikke navnet ledig. Feil posttype med samme navn behandles som uforklart inventar. Fullt observerte PoC-navngitte poster inngår i vanlig identitetsavstemming og beholder plass i navneinventaret. Metadata alene fra de tre filtrerte postene i test 238 er derfor ikke tilstrekkelig grunnlag for en vellykket beslutningsrapport; ingen ny serverlesing eller adapter er implementert her.

Rotårsak P2: `allSatisfy` uten komplett nøkkel-/antallskontroll og søk etter stoppkode hvor som helst i rapporten kunne skjule manglende eller feilplasserte beslutninger. Testprogrammet sammenligner nå komplette forventede `Report`-verdier: eksakt sortert nøkkelsett, radantall, beslutningsvariant, tilknyttet stoppnøkkel/adresse, alle stoppgrunner og globale stopp. Positive tester krever alle forventede gjenbruk/kandidater. Kollisjonsfixture har nå full identitetsobservasjon for den opptatte posten, slik at testen isolerer navnekollisjon fra P1-grunnlagsfeilen.

**Gjeldende automatisert resultat: 38 bestått, 0 feilet**, exitkode 0 i samme ekstra sandkasse. De opprinnelige 26 scenarioene er bevart med strengere påstander. Nye regresjons-/kontrolltilfeller:

| Tilfelle | Forventning og kontrollert resultat |
| --- | --- |
| 27–28 | Uforklart eller utelatt identitet i ellers komplett inventar gir nøyaktig grunnlagsstopp for alle rader. |
| 29 | Forelder med for langt kandidatnavn stoppes; alle barna får `parentStopped` med riktig foreldrenøkkel. Foreldrekollisjon og barnestopp dekkes også i 09. |
| 30–31 | Samme navn kolliderer bare i samme fulle adresse; andre zones/kontoer er ulike. Observasjoner/versjoner utenfor input-scope avvises. |
| 32 | ZIP-hash og journal-ID varierer separat for valgt ZIP, journal, forventet journal-ID og baselinebinding; hvert avvik avvises. |
| 33 | Samme operasjonsliste har planlagt, fullført og ukjent utfall samtidig; feilnøkler og stoppvarianter kontrolleres eksakt. |
| 34–35 | PoC-filter krever eksakt type/navn; fullt observerte PoC-navn forblir opptatt uten å anta uavklart identitet. |
| 36–37 | Testorakelet avviser bevisst tomme, manglende, ekstra og dupliserte rader, feil beslutningsvariant og feilplasserte/ekstra stoppgrunner. |
| 38 | Uforklarte og filtrerte inventaravvik har komplett, deterministisk konfliktrekkefølge ved endret inndatarekkefølge. |

Begge appbygg er kontrollert på nytt: macOS og generisk iOS/iPadOS **BUILD SUCCEEDED**, uten signering eller appkjøring. Bare AppIntents-metadataadvarsel gjenstår. Modellen har fortsatt ingen imports, IO eller skriveautorisasjon. B-050, test 230/238-diagnostikk, repositories, backup-/journalformat og Xcode-prosjektstruktur er urørt. Ingen reelle data er lest eller endret. Ved denne automatiserte kontrollen avventet alle elleve punkter brukervalidering; de er senere samlet godkjent, jf. sluttresultatet nedenfor. Påstander om komplett lesing er fortsatt mottatte verdiopplysninger, ikke bevis for atomiske CloudKit-observasjoner eller senere skrivesikkerhet.

Kompilering og isolert kjøring fra prosjektroten (bare verktøyet skriver byggeartefakter under `/private/tmp`):

```sh
mkdir -p /private/tmp/tekstilig-test239
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test239/module-cache Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tests/ImportIdentityDecisionModelTests.swift -o /private/tmp/tekstilig-test239/identity-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test239/identity-tests
```

Bruk aktuell brukermappesti i sandkasseprofilen dersom testen kjøres på en annen maskin. Stien over dokumenterer utført lokal kontroll, ikke et permanent prosjektkrav. Ved kompilatorfeil, sandkassefeil eller FAIL: stopp; ikke kjør appdiagnostikk eller endre testgrunnlag som omgåelse. Denne sekvensielle gjennomgangen av de elleve punktene er nå fullført og uttrykkelig godkjent av brukeren, jf. sluttresultatet nedenfor.

### Sluttresultat og brukergodkjenning – 2026-11-07

**239 ✅ fullført og uttrykkelig brukervalidert 2026-11-07.** Prosjekteieren har godkjent alle punktene 239.1–239.11 og testen samlet etter sekvensiell gjennomgang. Sluttresultatet er **38 syntetiske tester bestått, 0 feilet**, exitkode 0, vellykkede macOS- og iOS/iPadOS-bygg med Xcode 27.2 og gjennomført skrivefri etterkontroll uten avvik. Tidligere resultater ble gjenbrukt der de var tilstrekkelige.

Godkjenningen gjelder bare den isolerte Swift-beslutningsmodellen og det syntetiske testoppsettet. Den godkjenner ikke faktisk CloudKit-import/restore, faktisk idempotens, atomisitet mellom lesinger, produksjonsformat for kandidatnavn eller CloudKit-skriving/-sletting. `permitsCloudKitWriting` og kandidatenes `approvedForProduction` er fortsatt `false`. Faktisk testkjøring er utført isolert på Mac; iOS/iPadOS-dekningen omfatter bygg, ikke funksjonskjøring på fysisk iPhone/iPad.

Etterkontrollen bekreftet IO-fri modellkallkjede, uendrede inndata, manglende skriveautorisasjon og urørt eksisterende diagnostikk, repositories og dataformater. Modellen har ikke lest eller endret faktiske ZIP-er, journaler, baseline eller CloudKit-poster. Xcodes lokale brukerfil er bevart utenfor oppgaveendringene. Ingen modellkobling til import/restore eller reelle data er implementert. Git-status korrigert 2026-11-07: Test 239 er committet i `ae16a30`, integrert i `main` og publisert på GitHub.

### Strengt sekvensiell testplan – gjennomført og godkjent

Utfør punktene i oppgitt rekkefølge og stopp ved første avvik. Hvert punkt gjelder alle relevante posttyper; feil i én type stopper sekvensen.

1. **✅ Bygg og avhengighetskontroll.** Etter godkjent implementering: bygg med Xcode 27.2 for macOS og iOS/iPadOS, og gjennomgå modellens kallkjede før kjøring. Forvent en ren modell med syntetiske inndata, uten filsystem-, repository- eller CloudKit-avhengigheter. Byggverktøyets ordinære byggefiler omfattes ikke av modellens IO-forbud. **Stopp** ved byggefeil, skjult IO eller uavklart avhengighet; ikke start funksjonstestene.
2. **✅ Entydig eksisterende identitet.** Gi modellen én syntetisk CloudKit-post med tilfeldig recordnavn, samsvarende posttype/logisk ID/eier og entydig forelder der relevant. Forvent gjenbruk av akkurat det eksisterende recordnavnet; ingen innholdsoppdatering eller skriveklar markering. **Stopp** hvis kandidatnavnet overtar, feil post velges eller gjenbruk tolkes som overskrivingstillatelse.
3. **✅ Ny identitet.** Gi en manglende logisk identitet med komplett syntetisk grunnlag, ledig navn og gyldig forelderavhengighet. Forvent en kandidat med eksplisitt algoritmeversjon og deterministisk navn, uten skriveautorisasjon. Eksisterende tekstiler skal ikke bli kandidater for komplettering. **Stopp** ved tilfeldig/versjonsløst navn, navnegrensebrudd som ikke avvises eller utvidelse av importomfanget.
4. **✅ Gjentakelse og rekkefølge.** Kjør de samme minnetilfellene på nytt, deretter med endret inndatarekkefølge. Forvent samme beslutninger og kandidatnavn, med deterministisk sortert resultat. **Stopp** ved endret klassifisering/navn eller rekkefølgeavhengig valg av identitet.
5. **✅ Dupliserte logiske ID-er.** Tilfør først to backup-poster med samme type/logiske ID, deretter to observerte CloudKit-poster med samme type/logiske ID og forskjellige recordnavn. Forvent eksplisitt konflikt og stopp i begge tilfeller; ingen automatisk sammenslåing eller valg. **Stopp** testen hvis modellen gjenbruker/oppretter en post eller skjuler duplikatet.
6. **✅ Eierkonflikt og tvetydig forelder.** Test først samme underpost-ID med annen eier, deretter flere foreldre med samme logiske tekstil-ID og en manglende/ugyldig forelderavhengighet. Forvent konkrete stoppgrunner uten automatisk flytting. **Stopp** testen hvis en underpost godtas med feil eller uavklart eier.
7. **✅ Recordnavnkollisjon.** La kandidatens navn være opptatt av en annen identitet, deretter annen posttype. Legg også inn de tre eksakte filtrerte PoC-postene i syntetisk navneinventar og test at et navn opptatt av en filtrert post avvises; ikke endre den validerte kandidatnavnformelen fra test 238 for å frembringe tilfellet. Forvent eksplisitt stopp og at filtrering ikke frigjør navn. **Stopp** testen hvis posttypefilter eller PoC-filter skjuler kollisjonen.
8. **✅ Baseline og lesedekning.** Endre én syntetisk versjonstag; test deretter tillegg/sletting relativt til baseline, manglende tag og ufullstendig lesing/identitetsdekning. Forvent stopp ved endret eller utilstrekkelig grunnlag, uten automatisk baselinejustering. **Stopp** testen hvis fravær tolkes som sikker ny identitet eller en kontroll godkjennes på ufullstendig grunnlag.
9. **✅ ZIP-/journalbinding.** Gi modellen syntetisk feil ZIP-hash, feil journal-ID og operasjonsgrunnlag som ikke samsvarer med backupidentitetene. Forvent stopp ved ugyldig binding/plan. Ingen ZIP eller journal skal åpnes for å lage testen. **Stopp** ved godkjenning av avvik eller forsøk på å reparere bindingen.
10. **✅ Delvis import og ukjent serverutfall.** Gi modellen syntetisk tidligere utførte og uavklarte operasjoner. Forvent eksplisitt stopp med krav om separat gjenopptakingsavklaring. **Stopp** ved nye tilfeldige identiteter, automatisk gjentakelse, antakelse om at feil betyr «ikke lagret», eller godkjenning av gjenopptaking uten bevisgrunnlag.
11. **✅ Etterkontroll og brukervalidering.** Gjennomgå kjørte kall og bekreft at modellkjøringen bare brukte minnedata; kontroller ingen nye skrivende/lesende IO-baner. Forvent at ingen eksisterende filer, CloudKit-poster, ZIP-er, journaler eller baseline er endret av modellen. Bevar Xcodes lokale brukerfil; Xcodes egne UI-oppdateringer er ikke modellens testdata. Ikke gjør nye CloudKit-oppslag for denne etterkontrollen. **Stopp** ved enhver modellutløst IO eller uavklart bivirkning. Rapporter faktisk plattform-/scenariodekning og avvent brukerens uttrykkelige validering før noen punkter markeres godkjent.

### Avgrensning og stoppunkt

Testen beviser bare modellens beslutninger for de syntetiske tilfellene. Den beviser ikke CloudKit-atomisitet, faktisk idempotens, fullstendig duplikatvern mellom klienter eller trygg produksjonsimport. Ikke-atomiske lesinger kan bli foreldet før senere skriving. Fremtidig utførelsesjournal, gjenopptaking, bilderestore og serverbasert samtidighetskontroll krever egne beslutninger og tester. Den historiske T0001-bildeposten, de tre faktiske PoC-postene og de fire planlagte journaloperasjonene skal ikke endres eller utføres.

**Stopp etter test 239 og brukerens vurdering. CloudKit-skriving/-sletting under import/restore forblir sperret. Ingen videre utviklingsoppgave startes automatisk.**


## 240. Isolert adapter og skrivebeskyttet beslutningsrapport

**240 ✅ – fullført, alle åtte testpunkter og testen samlet uttrykkelig brukervalidert 2026-11-07.** Bygger på B-050 og fullført test 239. Ingen import, restore, utførelsesjournal eller ny CloudKit-leser er implementert. Test 239 er publisert i `ae16a30`; tidligere opplysninger om upubliserte endringer er korrigert separat uten å endre testresultatene.

### Implementering og sikkerhetsgrenser

`ImportIdentityDiagnosticAdapter` er en `nonisolated` verdibasert adapter/rapport uten imports eller IO. Strukturerte backupidentiteter, observasjoner, versjonsinventar, baseline, v2-journal og lesedekning tilpasses modellens `Input`; rapporttekst parses aldri. Journalens eksisterende `posttype:ID`-felt dekodes etter journalformatet. Duplikater og råverdier beholdes uten normalisering. Ukjente typer, ugyldig format og uverifiserte verdier gir eksplisitt grunnlagsstopp; de repareres ikke.

`reconcileImportIdentities()` bevarer verdier som allerede leses av test 238, inkludert dekodet journal/baseline før bindingen valideres, samt feil fra binding og lesinger. Den nye knappen **«Vis identitetsbeslutninger (test 240, kun minnegrunnlag)»** ligger under test 238-kontrollene i **Utvikling → Roadmap 7: les backup (kun kontroll)** i DEBUG-bygg på begge plattformer. Knappen bruker bare et tidligere innlest minnegrunnlag i samme visning/kjøreøkt. Den er deaktivert uten grunnlag eller mens lesing pågår. ZIP-valg og ny test 238-kjøring nullstiller grunnlag/rapport. Ingen automatisk kjøring eller ny lesing følger av test 240-knappen.

Dagens repository-resultater og baseline mangler verifisert konto-/zonekontekst, og bildeleseren trimmer ID/eier. Adapteren erklærer derfor scope uverifisert og råverdier ikke verifisert; tom kontekst er en ugyldig plassholder som gir stopp, aldri en antatt faktisk adresse. Filtrerte PoC-poster beholdes i versjonsinventaret og gir `unresolvedFilteredIdentity` uten tilsvarende identitetsobservasjon. Positiv syntetisk klassifisering er mulig; dagens faktiske test 238-grunnlag forventes å gi STOPP. Ingen ny lesing eller endring av filtre for å omgå dette er godkjent.

Journalens diagnostiske null-fullførtstatus oversettes bare til planlagte operasjoner. Andre format-/statusverdier gir stopp; samlet fullførtantall brukes aldri til å dikte opp status per operasjon. Forventet journal-ID i adapterbindingen kommer fra baselinebindingen; dette er intern samsvarskontroll, ingen uavhengig historisk autentisering. Baseline lagrer ikke faktisk scope eller eierskap. Ikke-atomiske lesinger gir fortsatt ingen garanti mot senere endringer.

### Strengt sekvensiell testplan – gjennomført og godkjent

Alle åtte punkter er ✅ etter brukerens uttrykkelige godkjenning av den samlede blokken. Opprinnelige handlinger og stoppkriterier beholdes nedenfor; den praktiske kontrollen i punkt 8 er senere gjennomført etter særskilt godkjenning av én skrivebeskyttet test 238-kjøring. Brukeren bruker Xcode GUI; Codex utfører isolerte kommandolinjekontroller. Stopp ved første avvik, og ikke kjør andre diagnostikkknapper som omgåelse.

1. **✅ Bygg og kallkjede.** Bygg macOS, deretter generisk iOS/iPadOS med Xcode 27.2. Gjennomgå ny knapp → `render` → `adapt` → `evaluate` og minnefangsten i test 238. Forvent vellykkede bygg, modellinkludering og ingen nye IO-/CloudKit-kall fra rapportknappen. **Stopp** ved byggefeil eller uavklart skrivebivirkning.
2. **✅ Isolert regresjon.** Etter bygg: kompiler og kjør eksisterende test 239-program (38 syntetiske tester), deretter adapterprogrammet med kommandoene nedenfor. Forvent exitkode 0 og ingen FAIL. Programmer kjøres uten nettverk, filskriving eller lesing fra brukermappen. **Stopp** straks ved kompilator-, isolasjons- eller testfeil; ikke bruk reelle data for feilsøking.
3. **✅ Positive adaptertilfeller.** Kontroller adaptertest 01–03: alle fem typer og komplette nøkkelsett, eksakte eksisterende recordnavn, versjoner/binding/lesedekning og nye versjonerte kandidater med forelderavhengigheter. Forvent komplett rapport og begge skrive-/produksjonsflagg `false`. **Stopp** ved tapte felt/duplikater eller skriveklar klassifisering.
4. **✅ Uavklart grunnlag og PoC.** Kontroller test 04–07 og 13–20 for manglende kontekst/råbevis, tre eksakte PoC-poster, uforklart inventar, feil dekning/versjoner/format/operasjoner og ugyldige råidentiteter. Forvent komplette stopprapporter; PoC-navn forblir opptatt. **Stopp** ved antatt kontekst, normalisering, bortfiltrering eller kandidat på utilstrekkelig grunnlag.
5. **✅ Binding og duplikater.** Kontroller test 08–12: ZIP-hash og journal-ID varierer separat, manglende journal/baseline og duplikater i backup/CloudKit. Forvent riktige stoppgrunner, nøkler og adresser for alle rader. **Stopp** ved automatisk reparasjon eller valg mellom duplikater.
6. **✅ Determinisme og presentasjon.** Kontroller test 21–23 for gjentakelse/endret rekkefølge, uendrede inndata, avvisning av tomt positivt resultat og tydelig manglende skriveautorisasjon. Bruk Xcode GUI til kildeinspeksjon av knappens plassering/deaktivering; ikke start appen i denne kontrollen, siden eksisterende appoppstart kan lese CloudKit. Praktisk UI-kjøring avventet opprinnelig separat godkjenning; den er nå gjennomført og godkjent, jf. sluttresultatet nedenfor. **Stopp** ved automatisk serverlesing eller foreldet rapport etter ZIP-valg.
7. **✅ Etterkontroll og samlet brukervalidering.** Kontroller diff, uendret modell/repositories/dataformater og at ingen nye kall kan opprette kataloger eller skrive data. Bevar Xcode-brukerfilen. Forvent `git diff --check` uten feil og ingen ZIP-/journal-/baseline-/CloudKit-endringer fra ny kode. Rapporter faktisk dekning og avvent samlet godkjenning. **Stopp** ved avvik; ingen automatisk statusendring.
8. **✅ Faktisk datarapport – gjennomført etter særskilt godkjenning.** Ingen ny CloudKit-lesing kjøres i denne blokken. Hvis minnegrunnlag ikke finnes, er knappen deaktivert. Før en senere praktisk kontroll må prosjekteieren særskilt godkjenne eksisterende test 238-lesing. Deretter kan test 240-knappen gjenbruke akkurat dette grunnlaget uten nye oppslag; forvent konkrete stopp for uverifisert kontekst/råverdier og filtrerte identiteter. **Opprinnelig stoppunkt: avvent særskilt bestilling; punktet inngikk ikke i den isolerte testkjøringen.** Brukeren har senere gjennomført det etter én særskilt godkjent, skrivebeskyttet test 238-kjøring; ikke opprett journal/baseline eller endre PoC-poster for å få positivt resultat.

Isolerte kommandoer fra prosjektroten, etter vellykkede appbygg (bruk riktig brukermappesti i isolasjonsprofilen):

```sh
mkdir -p /private/tmp/tekstilig-test240
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test240/module-cache Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tests/ImportIdentityDecisionModelTests.swift -o /private/tmp/tekstilig-test240/model-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test240/model-tests
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test240/module-cache Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tekstilig/Diagnostics/ImportIdentityDiagnosticAdapter.swift Tests/ImportIdentityDiagnosticAdapterTests.swift -o /private/tmp/tekstilig-test240/adapter-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test240/adapter-tests
```

Byggeverktøyets artefakter under `/private/tmp` er ikke brukerens importgrunnlag. Testen beviser adapterens behandling av gitte verdier, ikke reell CloudKit-dekning, atomisitet, faktisk idempotens eller produksjonssikker import. Historisk T0001-bildepost, tre PoC-poster og fire planlagte journaloperasjoner skal forbli urørt. CloudKit-skrivesperren gjelder fortsatt.

### Faktiske tekniske kontroller – 2026-11-07

- Statisk Swift-syntakskontroll og begge appbygg bestått: macOS og generisk iOS/iPadOS med Xcode 27.2, uten signering eller appkjøring. Bare eksisterende AppIntents-metadataadvarsel om manglende framework-avhengighet.
- Sekvensielt etter bygg: eksisterende modellprogram **38 PASS, 0 FAIL**, deretter nytt adapterprogram **23 PASS, 0 FAIL**, begge exitkode 0 i isolasjon uten nettverk, filskriving eller lesing fra brukermappen. Testprogrammet stopper ved første FAIL. Test 239-programmets gamle sluttmelding om manglende brukervalidering er utdatert; godkjent teststatus 239 ✅ er uendret.
- Adaptertestene sammenligner komplette positive/negative rapporter, nøkkelsett, radantall, beslutningsvarianter og konkrete stoppgrunner/adresser. Tap av data, duplikater, uverifisert scope/råverdier, PoC-filtertreff, feil ZIP-/journalbinding, manglende grunnlag, versjonsavvik og ukjente formater/typer inngår. Inndata og rapportrekkefølge kontrolleres også.
- Statisk etterkontroll: ny knapp kaller bare `render` → `adapt` → `evaluate` i minnet. Minnefangsten legger ingen IO-kall til eksisterende test 238-lesing. Ingen nye kall til URL-hjelpere, `save`/`delete`, journal-/baselinelagring eller filsystem. Repositoryer, beslutningsmodellen fra 239 og dataformater er urørt. `git diff --check` bestått.
- Ingen faktisk ZIP-, journal-, baseline- eller CloudKit-lesing som del av ny testkjøring. Ingen app startet og ingen data endret. Ved denne opprinnelige tekniske kontrollen var knappens praktiske visning/livsløp bare kontrollert statisk, og test 240 avventet brukervalidering. Punkt 8 var da ikke utført eller godkjent. Dette er historikk fra før den senere praktiske kontrollen og samlede godkjenningen nedenfor.

### Sluttresultat og brukergodkjenning – 2026-11-07

**240 ✅ fullført og uttrykkelig brukervalidert 2026-11-07.** Prosjekteieren har godkjent alle åtte testpunkter og testen samlet. Sluttresultat: **38/38 eksisterende modelltester og 23/23 adaptertester bestått**, 0 feil, samt vellykkede macOS- og iOS/iPadOS-bygg med Xcode 27.2. Brukeren har gjennomført praktisk UI-test etter én særskilt godkjent, skrivebeskyttet test 238-kjøring i samme kjøreøkt. Test 240-rapporten gjenbrukte minnegrunnlaget og viste forventet `STOPP` ved uverifisert CloudKit-kontekst og manglende recordkontekst.

Godkjenningen gjelder bare den isolerte adapteren og den skrivebeskyttede beslutningsrapporten. Den godkjenner ikke faktisk import, restore, CloudKit-skriving/-sletting, produksjonsbruk av kandidatidentiteter, faktisk idempotens eller atomisk konsistens. `permitsCloudKitWriting` og kandidatenes `approvedForProduction` er fortsatt `false`. Den særskilte godkjenningen gjaldt én lesekjøring; den gir ingen generell tillatelse til nye CloudKit-oppslag. Ingen ny testkjøring eller datalesing er utført ved denne dokumentasjonsoppdateringen.


## 241. Fase A – isolert, skrivebeskyttet CloudKit-identitetsleser

**241 fase A ✅ – fullført og uttrykkelig brukergodkjent 2026-11-07.** B-050 og de validerte testene 239–240 er grunnlaget. Fase A tillater bare syntetisk transport og lokale `CKRecord`-verdier i testene. Ingen faktisk CloudKit-lesing, appkjøring, import, restore eller skriving er godkjent. Det er ikke lagt til en ny UI-startknapp for faktisk lesing.

### Implementering og avgrensning

- `ImportIdentityReadTransport` har bare `context()` og `page(type:after:)`. `ImportIdentityReadDiagnostic.read(using:)` leser to passeringer for alle fem typer innen ett eksplisitt privat scope. Observerte ID-/eierstrenger beholdes eksakt; manglende felt og feil datatype representeres separat med `RawField`. Feil datatype bevares som typenavn og beskrivelse, ikke som en gjenopprettbar original `CKRecordValue`. Råobservasjoner beholdes i rapporten også ved STOPP; ingen normalisering eller PoC-filtrering.
- `CloudKitIdentityDiagnosticTransport` dekoder recordType, ID/eier, recordName, zoneID og changeTag fra samme `CKRecord`. Textile bruker sin rå textileId som eier; underposter bruker rå textileId. Transporten ber bare om identitetsfeltene, ikke imageAsset. Alle tre eksakte PoC-navn inngår som vanlige observasjoner. Eksisterende repository-filtre og lagringsmetoder er urørt.
- Side-/postfeil, avbrudd, gjentatt/ugyldig cursor, ugyldige råfelt/metadata, feil recordtype/scope og duplikater gir STOPP. Allerede mottatte observasjoner beholdes; komplette dekningsflagg gis ikke ved feil. Like sorterte passeringer er ikke atomisk snapshot, fullstendig serverbevis eller skrivetillatelse. Dekningen gjelder de fem forespurte typene innen valgt zone, ikke ukjente recordtyper eller andre zones.
- Container og privat database kommer fra de faktisk brukte objektene. Konto hentes via accountStatus/userRecordID, miljø på macOS fra appens signeringsinformasjon, og faktisk zone/eier fra hver record. Konto/kontekst kontrolleres før lesing og etter hver passering. Endringer eller kontrollfeil gir STOPP. Kortvarige kontoendringer tilbake til samme verdi mellom kontrollene kan ikke utelukkes; ingen kontoendringsvarsling/serverlås er implementert.
- Miljøbevis bruker bare `com.apple.developer.icloud-container-environment`; DEBUG og push-entitlements brukes ikke. På macOS benyttes `SecCodeCopySelf` → `SecCodeCopyStaticCode` → `SecCodeCopySigningInformation`. Manglende/ukjent signeringsmiljø gir STOPP før CloudKit-kall. iOS/iPadOS har foreløpig ingen etablert entitlement-leser og stopper tilsvarende; dette er en eksplisitt begrensning, ikke produksjonsklar kontekstverifikasjon. Verken faktisk signeringsoppslag eller kontooppslag kjøres i fase A-testene. SDK-et garanterer ikke at oversettelsen fra kjørende kode til filsystemets statiske kode er en sikker identitetsbinding; denne mekanismen er ikke godkjent som grunnlag for importskriving.
- `ReadResult.applying(to:)` kobler strukturerte nåobservasjoner til eksisterende `ImportIdentityDiagnosticAdapter.Snapshot`; `render(using:)` viser råobservasjoner, kontekst, lesefeil og den eksisterende beslutningsrapporten. Begge metodene er eksplisitt `@MainActor`, i samsvar med leserens hjelpere og kallsteder. Ingen global concurrency-innstilling eller eksisterende beslutningsmodell er endret.
- Historisk baseline og journal bevares uendret. Nåværende kontekst tilordnes aldri baselineposter som mangler scope. Lesefeil går videre til adapterens lesedekning og gir grunnlagsstopp. Manglende eller ugyldige råstrenger har bare tomme plassholdere i modellinput; original feltstatus og feilbevis beholdes i leserrapporten og hindrer godkjenning. Faktisk legacy-baseline forventes fortsatt å gi STOPP inntil historisk kontekstbinding er avklart separat. En positiv syntetisk baseline med oppgitt scope er ikke bevis for slik historisk binding.

### Rotårsaker og målrettede rettelser

1. Første macOS-bygg feilet fordi `SecCodeCopySigningInformation` krevde `SecStaticCode`, mens koden sendte `SecCode`. SDK-signaturene ble kontrollert; minimal rettelse bruker `SecCodeCopyStaticCode` før oppslaget. Begge appbygg bestod deretter.
2. Det nye isolerte testprogrammet feilet ved kompilering fordi `ReadResult.applying(to:)` og `render(using:)` kalte MainActor-hjelpere uten eksplisitt isolasjon. Appmålet bruker `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, `SWIFT_APPROACHABLE_CONCURRENCY = YES` og Swift 5.0; det isolerte oppsettet arver ikke Xcode-innstillingene. To eksplisitte `@MainActor`-annotasjoner retter avviket uten globale konfigurasjonsendringer eller concurrency-omgåelser. De berørte testkallstedene ligger allerede på MainActor.

### Strengt sekvensiell testplan – fase A gjennomført og godkjent

Alle åtte fase A-punkter er ✅ etter brukerens uttrykkelige samlede godkjenning. Opprinnelige handlinger og stoppkriterier beholdes; godkjenningen omfatter ingen praktisk CloudKit-kontroll. Brukeren bruker Xcode GUI til bygg/kildegjennomgang; Codex utfører kommandolinjekontrollene. Ingen app skal startes som del av fase A. Forventet STOPP i et negativt scenario er bestått kontroll; testprogrammet avslutter med feil straks ved første uventede resultat.

1. **✅ Isolert kompilering og lesertester.** Etter kontroll av isolasjonen: kompiler og kjør de 26 syntetiske testene med kommandoene nedenfor. Forvent 26 PASS, 0 FAIL og exitkode 0. **Stopp** ved kompilator-/test-/isolasjonsfeil, før ny rettelse eller videre kontroller.
2. **✅ Appbygg.** Bygg macOS, deretter generisk iOS/iPadOS uten signering eller appkjøring. Forvent vellykkede bygg og begge nye appfiler inkludert. **Stopp** ved ny byggefeil eller uventet avhengighet; ikke åpne faktisk transport som feilsøkingsvei.
3. **✅ Regresjon.** Kjør eksisterende modelltester (38) og adaptertester (23) sekvensielt i isolasjon. Forvent alle bestått og uendrede sikkerhetsgrenser. **Stopp** ved første FAIL; ingen endring av tidligere teststatuser.
4. **✅ Råfelt, PoC og sideinndeling.** Gjennomgå lesertest 01–09, 12–14 og 25: eksakte to passeringer, minimal feltliste, lokale CKRecord-felt/metadata, feil datatyper, ugyldige råverdier, side-/postfeil, cursor og duplikater. Forvent at feil/PoC-poster ikke filtreres bort, og at ufullstendig grunnlag gir STOPP. **Stopp** ved normalisering, tapte observasjoner eller feil komplett-markering.
5. **✅ Avbrudd og kontekst.** Gjennomgå test 10–11 og 15–19: avbrudd før/under lesing, manglende kontekst, feil zone/eier, kontobytte og feil ved etterkontroll. Forvent presise stoppgrunner og ingen automatisk retry/reparasjon. **Stopp** hvis uavklart miljø/konto eller avbrudd kan gi positiv rapport.
6. **✅ Konsistens og beslutningsbro.** Gjennomgå test 20–24 og 26: endrede identiteter/eiere/tags/tillegg/fravær, endret rekkefølge, komplett forventet beslutningsrapport, manglende historisk baselinescope og delvis lesing. Forvent bevarte recordnavn, STOPP ved avvik, uendret kildesnapshot og ingen skrive-/produksjonsgodkjenning. **Stopp** ved antatt historisk kontekst, atomisitetsløfte eller skjulte stoppårsaker.
7. **✅ Sikkerhetsetterkontroll.** Følg `read` → injisert transport → rådekoding og `applying/render` → eksisterende adapter/modell. Kontroller at testene bare konstruerer falsk transport/lokale CKRecord-verdier, og at ingen faktisk transportinstans opprettes eller kjøres fra appen/testene. Forvent ingen skriveruter, katalogopprettelse, dataformat-/repository-endringer eller ZIP-/journal-/baselinetilgang. **Stopp** ved uavklart bivirkning.
8. **✅ Leveranse og samlet brukervalidering.** Kontroller Git-status, filutvalg, nye filer og `git diff --check`; bevar Xcode-brukerfilen uten staging. Forvent kun avtalte endringer. Rapporter faktisk dekning og avvent samlet godkjenning. **Stopp etter fase A**; faktisk CloudKit-lesing, signerings-/kontoverifikasjon og praktisk UI-kobling krever særskilt bestilling/godkjenning.

Kompilering og kjøring av lesertestene fra prosjektroten (bruk aktuell brukermappesti i isolasjonsprofilen):

```sh
mkdir -p /private/tmp/tekstilig-test241
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test241/module-cache -framework CloudKit -framework Security Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tekstilig/Diagnostics/ImportIdentityDiagnosticAdapter.swift Tekstilig/Diagnostics/ImportIdentityReadDiagnostic.swift Tekstilig/Diagnostics/CloudKitIdentityDiagnosticTransport.swift Tests/ImportIdentityReadDiagnosticTests.swift -o /private/tmp/tekstilig-test241/reader-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test241/reader-tests
```

Testene bekrefter ikke faktisk CloudKit-paginering, konto-/miljøbevis, atomisitet, server-idempotens eller skrivesikkerhet. Lokalt opprettede CKRecord-verdier har ingen servergenerert changeTag; rådekodertesten kontrollerer bevaring av nil, mens gyldige tagger testes som syntetiske transportverdier. Ingen eksisterende ZIP, journal, baseline, historisk T0001-post eller PoC-post endres. De fire journaloperasjonene forblir planlagt og ikke utført.

### Faktisk teknisk sluttkontroll for fase A – 2026-11-07

- Isolert kompilering av det nye testprogrammet bestått etter de to eksplisitte MainActor-annotasjonene. Deretter **26/26 lesertester PASS, 0 FAIL**, exitkode 0.
- Etter rettelsen: macOS og generisk iOS/iPadOS **BUILD SUCCEEDED** med Xcode 27.2, `CODE_SIGNING_ALLOWED=NO`, uten appkjøring. Begge nye appfiler er bekreftet i begge SwiftFileList. Bare AppIntents-metadataadvarsel om manglende framework-avhengighet.
- Deretter sekvensiell regresjon: **38/38 modelltester og 23/23 adaptertester PASS, 0 FAIL**, exitkode 0. Til sammen 87 syntetiske tester bestått. Regresjonsbinærene var allerede kompilert fra de uendrede modell-/adapterfilene; disse kildefilene er kontrollert urørt. Modellprogrammets gamle sluttmelding om manglende brukervalidering endrer ikke godkjent test 239-status.
- Alle testprogrammene kjørte med nettverk, filskriving og lesing fra brukermappen blokkert. Test 241 bruker bare falsk transport og lokalt opprettede CKRecord-verdier; den faktiske transportens kontekst-/signerings-/serverkall er ikke kjørt. Ingen faktisk ZIP, journal eller baseline er lest/endret.
- Full statisk kallkjedekontroll er gjennomført: ingen save/delete, assetinnholdslesing, filskriving, katalogopprettelse eller automatisk faktisk leserstart. Eksisterende diagnostikk, adapter, modell, repositories, entitlements, prosjektinnstillinger og dataformater er urørt. Endringene er begrenset til tre nye Swift-filer og fire dokumenter; Xcode-brukerfilen beholdes separat. Diffkontroller også for nye filer bestått; ingen staging/commit/merge/push.
- Ved den tekniske sluttkontrollen avventet fase A og alle åtte punkter samlet brukergodkjenning; dette er historikk fra før den uttrykkelige godkjenningen nedenfor. Praktisk faktisk transport, reelt miljø-/kontobevis, signert app og iOS/iPadOS-miljøleser er ikke validert. Historisk baselinebinding og senere samtidighets-/skrivesikkerhet er fortsatt egne avklaringer. Ingen videre fase startes automatisk.

### Sluttresultat og brukergodkjenning – fase A – 2026-11-07

**Test 241 fase A ✅ fullført og uttrykkelig brukergodkjent 2026-11-07.** Godkjenningen gjelder den isolerte, skrivebeskyttede identitetsleseren, syntetisk transport og beslutningsbroen. Sluttresultatet er **26/26 nye lesertester PASS, 38/38 modelltester PASS og 23/23 adaptertester PASS – totalt 87 PASS, 0 FAIL**, samt vellykkede macOS- og iOS/iPadOS-bygg med Xcode 27.2. Sikkerhetsetterkontrollen er bestått. Ingen faktisk CloudKit-transport, signerings-/kontooppslag eller appkjøring er utført.

**Fase B og alle praktiske CloudKit-kontroller forblir ❗️**, ikke gjennomført eller godkjent. iOS/iPadOS-miljøet er fortsatt uverifisert og gir STOPP; historisk baselinebinding er uavklart, og to like lesepasseringer gir ingen atomisitetsgaranti. Godkjenningen åpner ikke for import, restore, CloudKit-skriving/-sletting eller produksjonsgodkjenning av kandidatidentiteter. Eksisterende ZIP, journal, baseline, PoC-poster og historiske data skal bevares.


## 241 fase B.1 – sikker CloudKit-miljøverifikasjon

**241 fase B.1 ✅ – fullført og uttrykkelig brukergodkjent 2026-11-07.** Fase A og alle åtte tilhørende punkter forblir ✅. B.1 gjennomføres bare med injiserte testverdier; ingen faktisk signeringskontroll, konto-/identitetslesing, annen CloudKit-transport eller appkjøring er godkjent her. Øvrig fase B og praktiske CloudKit-kontroller forblir ❗️.

### Implementert mekanisme og sikkerhetsgrenser

- Ny `CloudKitEnvironmentVerification` med injisert `CloudKitEnvironmentEvidenceSource`. På macOS utfører systemkilden i rekkefølge: `SecCodeCopySelf` → `SecCodeCheckValidity` → `SecTaskCreateFromSelf` → `SecTaskCopyValueForEntitlement`. Signaturvalideringen må lykkes før task-/entitlement-oppslag. API-signaturene og dokumentasjonen er kontrollert i installert Xcode 27.2 SDK. Den gamle oversettelsen til SecStaticCode og uttrekket uten signaturvalidering er fjernet fra den aktive implementeringen; fase A-beskrivelsen ovenfor bevarer historikken.
- Bare `com.apple.developer.icloud-container-environment` leses. CFError, manglende verdi, feil CF-datatype og ukjent streng gir hver sin uverifisert-årsak. Bare eksakte `Development` og `Production` godtas; ingen trimming, bokstavkonvertering, DEBUG-/push-/byggkonfigurasjonsfallback.
- `Outcome` skiller verifisert Development, verifisert Production, uverifisert med årsak og verifisert miljøavvik med forventet/observert verdi. `expectedEnvironment` må oppgis eksplisitt i transportens initializer og i diagnostikkens `Context`; ingen standardverdi er innført. Manglende forventning stopper før bevisoppslag. `valid(_:)` krever samsvar også for injiserte kontekstverdier.
- `withVerifiedEnvironment` åpner konto-/identitetskontinuasjonen bare ved verifisert, samsvarende miljø. Den faktiske transporten nullstiller godkjent-flagget før ny kontekstkontroll og åpner recordlesing først etter vellykket kontekst. Direkte page-kall uten slik kontroll avvises. Ingen faktisk transportinstans eller ny UI-start er lagt til testene/appen.
- iOS/iPadOS-kilden er eksplisitt ikke støttet og gir uverifisert miljø/STOPP før Security- eller CloudKit-oppslag. Ingen privat API eller alternativ signaturparser er innført. Ukjent miljø skal ikke omgås ved valg av forventet miljø.
- Lokalt prosess-/signeringsbevis beskriver miljømålet etter CloudKit-SDK-kontrakten. Det er ikke serverattestasjon, bevis for nettverkskontakt, atomisitet, faktisk idempotens eller skrivetillatelse. Historisk baselinebinding og øvrige fase B-spørsmål er fortsatt uavklart. ZIP, journal, baseline, repositories og normale lagringsmetoder beholdes.

### Sekvensiell testplan – alle sju B.1-punkter godkjent ✅

Brukeren bruker Xcode GUI til bygg/kildegjennomgang; Codex kjører isolerte kommandolinjekontroller. Stopp ved første uventede feil. Forventet STOPP i negative tilfeller er riktig resultat. Ingen faktisk beviskilde eller CloudKit-transport kjøres; ingen app startes.

1. **✅ Kompilering og syntetiske miljøtester.** Kompiler det utvidede leserprogrammet med ny miljøfil og kjør isolert. Forvent 41 PASS, 0 FAIL: de opprinnelige 26 scenarioene med eksplisitt syntetisk forventet Development er bevart; 15 nye tilfeller er lagt til. **Stopp** ved kompilator-/test-/isolasjonsfeil før videre kontroller.
2. **✅ Beviskjede og nøyaktig miljø.** Gjennomgå tilfelle 27–35: verifisert Development/Production, feil ved Self/signatur/task, manglende entitlement, feil ved uttrekk, feil datatype og ukjente/tomme/feilstavede verdier. Forvent eksakt API-rekkefølge, konkrete resultatvarianter og ingen videre kall etter feil. **Stopp** hvis signaturfeil eller konvertering kan gi verifisert resultat.
3. **✅ Forventning og plattform.** Gjennomgå tilfelle 36–38 og 41: manglende forventning, begge retninger av miljøavvik, ikke støttet iOS-lignende kilde og ugyldige injiserte kontekster. Forvent at forventet/observert miljø holdes adskilt og at uavklart grunnlag gir STOPP uten standardverdi. **Stopp** ved antatt Development/Production eller akseptert avvik.
4. **✅ Konto-/recordport.** Gjennomgå tilfelle 39–40 med samme gate som den faktiske transporten: ti ulike miljøfeil skal gi eksakt stopprapport og null fake konto-/recordkall; verifisert Production med eksplisitt samsvar skal bare åpne fake kontinuasjon. Kontroller statisk at faktisk page er sperret før kontekst. **Stopp** ved ett konto-/recordkall etter miljøfeil.
5. **✅ Modell- og adapterregresjon.** Kjør eksisterende 38 modelltester, deretter 23 adaptertester, sekvensielt i isolasjon. Forvent alle PASS og uendrede sikkerhetsgrenser. **Stopp** ved FAIL; ikke endre tidligere godkjente teststatuser.
6. **✅ Appbygg.** Bygg macOS, deretter generisk iOS/iPadOS med Xcode 27.2, uten signering eller appkjøring. Forvent begge bygg vellykket og ny miljøfil inkludert. **Stopp** ved ny byggefeil eller plattformomgåelse; ikke kjør reell diagnostikk for å feilsøke.
7. **✅ Sikkerhet og Git.** Følg source → evaluate → withVerifiedEnvironment → kontekst/page-port, og kontroller også adapter-/modellkoblingen. Forvent bare offentlige API-er, bare riktig entitlement, ingen skriveruter, datagrunnlagsendring eller faktisk transport i testene. Kontroller diff, nye filer, Git-status og separat Xcode-brukerfil. **Stopp** ved uventet fil eller bivirkning. Avvent samlet brukergodkjenning.

Isolert leser-/miljøtest fra prosjektroten (bruk aktuell brukermappesti i profilen):

```sh
mkdir -p /private/tmp/tekstilig-test241-b1
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test241-b1/module-cache -framework CloudKit -framework Security Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tekstilig/Diagnostics/ImportIdentityDiagnosticAdapter.swift Tekstilig/Diagnostics/CloudKitEnvironmentVerification.swift Tekstilig/Diagnostics/ImportIdentityReadDiagnostic.swift Tekstilig/Diagnostics/CloudKitIdentityDiagnosticTransport.swift Tests/ImportIdentityReadDiagnosticTests.swift -o /private/tmp/tekstilig-test241-b1/reader-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test241-b1/reader-tests
```

Fase A-kommandoen ovenfor dokumenterer det historiske oppsettet før `Context` fikk eksplisitt miljøforventning. Bruk B.1-kommandoen for gjeldende leserprogram. Syntetiske bevisverdier tester beslutnings-/kallrekkefølgen; de beviser ikke faktiske Security-resultater. Praktisk kontroll i en signert macOS-app, først uten CloudKit-kontakt, gjenstår og krever særskilt godkjenning. iOS/iPadOS skal fortsatt stoppe; videre serverlesing og øvrig fase B er ikke startet.

### Faktiske tekniske resultater – B.1 – 2026-11-07

- API-signaturene kontrollert statisk mot macOS 27.2 SDK. Nytt testprogram kompilerte uten feil og bestod **41/41 leser-/miljøtester**, inkludert 15 nye tilfeller. Deretter sekvensielt **38/38 modelltester** og **23/23 adaptertester**; totalt **102 PASS, 0 FAIL**, alle exitkode 0. Regresjonsbinærene er tidligere kompilert fra de kontrollerte, uendrede modell-/adapterkildene.
- Alle tre programmer kjørte med nettverk, filskriving og brukermappelesing blokkert. Miljøtesten brukte bare injiserte statuser/entitlement-verdier og fake konto-/recordtellere, aldri systembeviskilden eller faktisk transport. Ingen app, konto-/identitetslesing eller signeringsoppslag er kjørt.
- Deretter macOS- og generisk iOS/iPadOS-bygg **BUILD SUCCEEDED**, Xcode 27.2, uten signering/appkjøring. Ny miljøfil er bekreftet i begge SwiftFileList. Bare AppIntents-metadataadvarsel om manglende framework-avhengighet.
- Statisk sikkerhetsgjennomgang og diffkontroller bestått. Kontooppslag ligger bare i kontinuasjonen etter verifisert miljøsamsvar; recordoppslag krever bestått kontekst. Ingen fallback, privat API, nye skriveruter eller automatisk leserstart. Modellen, eksisterende adapter/diagnostikk, repository-filtre, lagringsmetoder, entitlements, Xcode-konfigurasjon og dataformater er urørt. Xcode-brukerfilen holdes separat og unstaged.
- Ved denne tekniske kontrollen avventet alle B.1-punkter samlet brukergodkjenning; dette er historikk fra før godkjenningen nedenfor. Fase A er fortsatt ✅. Praktisk lokal verifikasjon i signert macOS-app gjenstår; iOS/iPadOS er fortsatt uverifisert og stopper. Baselinebinding og atomisitet er ikke løst. Ingen videre fase eller faktisk CloudKit-lesing startes uten særskilt godkjenning.

### Sluttresultat og brukergodkjenning – B.1 – 2026-11-07

**Test 241 B.1 ✅ fullført og uttrykkelig brukergodkjent 2026-11-07.** Alle sju B.1-punkter er godkjent innen det syntetiske omfanget. Sluttresultat: 41/41 leser-/miljøtester (15 nye), 38/38 modelltester og 23/23 adaptertester – **102 PASS, 0 FAIL**. macOS- og iOS/iPadOS-bygg samt sikkerhets-/diffkontroller er bestått. Ingen faktisk Security-beviskilde, konto-/identitetslesing, CloudKit-transport eller app er kjørt.

**B.2 ❗️ og praktisk validering gjenstår**, uten tillatelse til å starte dem. Fase A beholdes ✅. Miljøbevis i en faktisk signert macOS-app er ikke praktisk validert; iOS/iPadOS er fortsatt uverifisert/STOPP. Historisk baselinebinding og manglende atomisitetsgaranti består. Godkjenningen gir ingen import-/restore-, CloudKit-skrive-/slette- eller produksjonstillatelse for kandidatidentiteter.


## 241 fase B.2 – isolert lokal miljødiagnostikk på macOS

**241 B.2 ✅ – fullført og uttrykkelig brukervalidert.** Fase A og B.1 beholdes ✅. Grunnlag: publisert `2edc002`. Denne utvidelsen åpner bare lokal miljøkontroll; ingen CloudKit-oppslag, import, restore eller skrivetillatelse. Historiske begrensninger ovenfor bevares.

### Implementering og kontrollert kallkjede

`TekstiligApp` kontrollerer `--diagnostic-local-cloudkit-environment` før rotvisningen opprettes. Bare macOS med `DEBUG` kan velge `LocalCloudKitEnvironmentDiagnosticView`; `ContentView`, biblioteket og vanlig diagnostikk opprettes da ikke. iOS/iPadOS og Release har fortsatt bare eksisterende oppstartsvei. Det er derfor avgjørende å bruke riktig parameter i macOS/Debug; vanlig oppstart kan starte bibliotekets automatiske CloudKit-lesinger.

Den isolerte visningen har ingen standard for forventet miljø, én kontrollknapp og ingen automatisk kjøring. Knappen kaller bare `CloudKitEnvironmentVerification.evaluate(source: SystemCloudKitEnvironmentEvidenceSource(), expected: expectedEnvironment)`. Systemkilden bruker de fire lokale Security-kallene fra B.1. Ingen transport, repository, fil-/kataloghjelper, journal, baseline eller ZIP inngår. Resultat og miljøvalg er `@State` uten lagring; miljøbytte fjerner gammelt resultat. Den opprinnelige B.2-visningen endret ikke verifikator, entitlements eller normal lagringslogikk. Den særskilt godkjente signeringsrettelsen nedenfor gjelder bare macOS/Debug.

Rapporten viser forventet miljø, verifisert lokalt miljø eller konkret STOPP-årsak, og forventet/observert verdi ved avvik. Metodebeskrivelsen viser API-kjeden og eksakt entitlement-nøkkel uten å hevde at den er gjennomført. Bare verifisert resultat eller miljøavvik viser vellykket signatur-/entitlement-bevis; uverifisert grunnlag viser utilstrekkelig bevis og hva som feilet. Dette er lokalt signeringsbevis, ikke serverattestasjon eller verifikasjon av konto, container, database eller atomisitet.

### Sekvensiell praktisk testprosedyre – Xcode 27.2 – alle seks punkter godkjent ✅

Utføres av brukeren etter gjennomgang av de tekniske resultatene. Codex har ikke startet appen. Stopp ved første uventede avvik; ikke bruk andre diagnostikkknapper eller start vanlig appmodus som del av B.2.

1. **✅ Forbered isolert, signert kjøring.** I Xcode 27.2: velg scheme **Tekstilig**, mål **My Mac**, og kontroller ordinær signering under **Signing & Capabilities**. Åpne **Product → Scheme → Edit Scheme… → Run → Info**, velg **Debug**. Under **Run → Arguments → Arguments Passed On Launch**, legg til og aktiver nøyaktig `--diagnostic-local-cloudkit-environment`. Bygg med **Product → Build**. Forvent vellykket bygg med signering aktivert; tidligere `CODE_SIGNING_ALLOWED=NO`-bygg er ikke praktisk signeringsbevis. **Stopp** ved feil eller usikker parameter/konfigurasjon før appstart. Ikke endre entitlements for å fremtvinge et resultat.
2. **✅ Start og kontroller isolasjon.** Start med **Product → Run**. Forvent bare skjermen **Test 241 B.2 – isolert lokal miljøkontroll**, miljøvalg **Velg eksplisitt …**, forventet miljø **Ikke valgt** og resultat **Ikke kontrollert**. Ingen vanlig bibliotek-/utviklingsvisning skal vises. **Stopp og avslutt appen** hvis vanlig UI vises; det er da ikke garantert at biblioteklesing er unngått. Ingen backup skal velges.
3. **✅ Manglende forventning.** Uten miljøvalg: trykk **Kontroller lokalt signert CloudKit-miljø**. Forvent **STOPP – uverifisert miljø**, at forventet miljø ikke er valgt, og at ingen bevisoppslag er utført. Bevis skal omtales som utilstrekkelig, ikke som vellykket signaturkontroll. **Stopp** ved antatt miljø eller et verifisert resultat.
4. **✅ Lokal signatur og miljø.** Velg eksplisitt det miljøet som forventes for denne signerte appen (prosjektets gjeldende testmål er Development; dette velges av brukeren og er ikke et bevis). Kontroller at forrige resultat fjernes, og trykk knappen. Ved samsvar forventes **Verifisert lokalt miljø: Development** (eller Production hvis det var det eksplisitte testmålet), samsvar med forventningen og vellykket lokalt signatur-/entitlement-bevis. Ved manglende entitlement, signaturfeil eller annet uavklart grunnlag forventes konkret STOPP; registrer hele resultatet og **stopp videre test**, uten fallback eller automatisk reparasjon. En kontrollert STOPP er sikker håndtering, men beviser ikke vellykket miljøverifikasjon i appen.
5. **✅ Forventningsavvik.** Bare etter vellykket punkt 4: velg motsatt miljø. Forvent at tidligere resultat fjernes før ny kontroll. Trykk samme knapp. Forvent **STOPP – miljøavvik**, korrekt forventet verdi og samme verifiserte lokale miljø som i punkt 4. Beviset er fortsatt lokalt; ingen serverlesing følger av kontrollen. **Stopp** ved samsvar, automatisk videreføring eller manglende avvik.
6. **✅ Avslutt og rapporter.** Avslutt appen. Deaktiver oppstartsparameteren i Xcode først etter avslutning, uten å starte vanlig appmodus som del av testen. Rapporter resultatene sekvensielt, inkludert miljø, bevisstatus og eventuelle STOPP-årsaker. Forvent at ingen testdata eller lokale rapportfiler er opprettet av diagnostikken. **Stopp etter rapporten** og avvent samlet brukergodkjenning; ingen faktisk CloudKit-kontakt er godkjent. Statisk kallkjedekontroll underbygger fravær av appens CloudKit-kall; UI-tekst alene er ikke nettverksbevis.

### Faktiske tekniske kontroller – 2026-11-07

Status om gjenstående brukervalidering i de tekniske oppføringene nedenfor er historikk før samlet godkjenning; sluttresultatet står nederst.

- Først macOS-bygg, deretter generisk iOS/iPadOS-bygg: **BUILD SUCCEEDED**, Xcode 27.2, uten signering eller appkjøring. Første begrensede macOS-forsøk ble blokkert av SwiftUI-makroverktøyets tilgang (også eksisterende kode); identisk bygg bestod med nødvendig tilgang uten koderettelse. Ingen uventet kodefeil er observert.
- Deretter ny kompilering av eksisterende leser-/miljøprogram og isolert kjøring: **41 PASS, 0 FAIL**, exitkode 0. Nettverk, filskriving og lesing av brukermappen var blokkert under kjøring. Testene bruker syntetiske beviskilder og fake transport; faktisk systembeviskilde eller app er ikke kjørt. Programmets historiske avslutningstekst om B.1-validering endrer ikke den dokumenterte brukergodkjenningen.
- De uendrede modell-/adaptertestene (38/23) er ikke kjørt på nytt i B.2; de inngår i det tidligere godkjente B.1-resultatet. Ingen nye automatiserte UI-tester er lagt til. Tomt miljøvalg, knappehandling, resultatvisning og oppstartsisolasjon er statisk kontrollert og kompilert; faktisk UI-livsløp og signert Security-kjede gjenstår for brukeren.
- Sikkerhetsetterkontroll: isolert rot → lokal visning → evaluate → systemkildens Security-kall. Ingen withVerifiedEnvironment-kontinuasjon, faktisk transport, konto-/recordlesing, filskriving eller datagrunnlagsendring nås. B.2-punktene forblir ❗️; ingen CloudKit-skrivesperre åpnes. iOS/iPadOS-miljø, historisk baselinebinding og atomisitet er fortsatt uavklart.


### B.2 – macOS/Debug-signering rettet – 2026-11-07

**B.2 og alle seks praktiske punkter forblir ❗️.** Brukerens første praktiske forsøk viste: «STOPP – uverifisert miljø. Signaturen er validert, men CloudKit-miljøentitlement mangler.» Observasjonen bevares; den dokumenterer korrekt stopp før rettelsen, ikke vellykket miljøverifikasjon.

Rotårsak: felles entitlements-fil ba ikke om `com.apple.developer.icloud-container-environment`. Nøkkelen manglet også i generert `.xcent` og signert macOS-app. Den eksisterende Mac Team-profilen tillot både Development og Production; profilen manglet ikke denne tillatelsen. Ingen profilfornyelse eller miljøfallback er innført.

Særskilt godkjent rettelse: `Tekstilig/Tekstilig-macOS-Debug.entitlements` inneholder alle eksisterende kildefilrettigheter uendret, med eneste tillegg miljønøkkelen som streng `Development`. Bare Debug-konfigurasjonen har `CODE_SIGN_ENTITLEMENTS[sdk=macosx*]` satt til den nye filen. Felles fil, iOS/iPadOS og Release er uendret. Miljøverifikatoren og diagnostikkens eksplisitte forventningsvalg er uendret. Dette er et faktisk miljøvalg for macOS/Debug, også ved normal appstart; det er ikke bare rapportmetadata og gir ingen tillatelse til CloudKit-kontakt.

Teknisk kontroll, sekvensielt:

- Plist-/prosjektvalidering bestått; den nye filen har eksakt samme rettigheter som originalen pluss miljønøkkelen. Eksisterende profil tillater Development og riktig container.
- Signert macOS/Debug-bygg med Xcode 27.2 **BUILD SUCCEEDED**, uten appkjøring eller `-allowProvisioningUpdates`. Både generert `Tekstilig.app.xcent` og `codesign -d --entitlements -` viser `com.apple.developer.icloud-container-environment = Development`, riktig container og øvrige rettigheter. Nybyggets innebygde profil tillater Development/containeren. `codesign --verify --strict --verbose=2` bekrefter «valid on disk» og «satisfies its Designated Requirement». Første verifikasjon i begrenset kjøring ga CSSMERR_TP_NOT_TRUSTED; samme skrivebeskyttede kontroll bestod med tilgang til systemets tillitstjenester, uten ny signering eller kodeendring.
- Effektive Xcode-innstillinger kontrollert: macOS/Debug bruker den nye filen; macOS/Release og iOS/Debug/Release bruker fortsatt `Tekstilig/Tekstilig.entitlements`. Avgrensningen omfatter ikke noen andre SDK-er.
- Generisk iOS/iPadOS-regresjonsbygg uten signering: **BUILD SUCCEEDED**. Byggene har bare den kjente AppIntents-metadataadvarselen. Ingen Release-bygg eller iOS/iPadOS-signering er utført i denne kontrollen; Release-avgrensningen er kontrollert i prosjektet og effektive bygginnstillinger.
- Ny kompilering og isolert kjøring av modell-, adapter- og leser-/miljøprogram, i denne rekkefølgen: **38/38 + 23/23 + 41/41 PASS = 102 PASS, 0 FAIL**. Nettverk, filskriving og lesing av brukermappen var blokkert under testkjøring. Ingen faktisk systembeviskilde eller CloudKit-transport er kjørt.
- Sikkerhets-/diffkontroll: ingen endringer i miljøverifikator, repositories, beslutningsmodell, adapter, eksisterende transport, ZIP, journal, baseline eller lagringsmetoder. Kun eksisterende isolert oppstartsvei kan brukes til senere lokal kjøring; ingen konto-/recordlesing er lagt til. Xcode-brukerfil og eksisterende schemesendring bevares uten staging.

**Neste praktiske handling:** Avslutt eventuell gammel app, bygg den nye macOS/Debug-versjonen i Xcode med ordinær signering og den dokumenterte isolasjonsparameteren aktiv. Følg deretter de seks punktene ovenfor fra starten. I punkt 4 skal dette macOS/Debug-bygget testes med eksplisitt forventet **Development**; i punkt 5 velges **Production** for forventet miljøavvik. Ikke endre entitlement som del av testen. Codex har ikke startet appen eller kjørt Security-verifikatoren i appprosessen; runtime-/UI-resultatet etter rettelsen gjenstår. Signaturkontroll på disk er ikke praktisk validering av B.2 og ikke CloudKit-serverbevis.


### Sluttresultat og brukergodkjenning – B.2

**Test 241 B.2 ✅ fullført og uttrykkelig brukervalidert.** Brukeren har bekreftet forventede resultater etter macOS/Debug-signeringsrettelsen: Development gir verifisert lokalt miljø og samsvar; Production som forventning gir korrekt STOPP ved avvik mot observert Development. Alle seks praktiske punkter er godkjent. Dette validerer lokal signatur-/entitlement-kontroll i macOS-appen, ikke en app signert for Production eller kontakt med CloudKit-serveren.

Sluttgrunnlaget omfatter 102 PASS/0 FAIL (38 modell-, 23 adapter- og 41 leser-/miljøtester), signert macOS/Debug-bygg, iOS/iPadOS-bygg uten signering, kontrollert `.xcent`, signert app og provisioningprofil samt sikkerhets-/diffkontroller. Codex har ikke startet appen eller utført CloudKit-operasjoner; praktisk kjøring er utført av brukeren.

**Senere CloudKit-lesetester og øvrig fase B forblir ❗️**, uten tillatelse til nye konto-/recordoppslag. iOS/iPadOS-miljø, historisk baselinebinding og atomisitet er fortsatt uavklart. Ingen import, restore, CloudKit-skriving/-sletting eller produksjonsgodkjenning av kandidatidentiteter er godkjent. Fase A og B.1 beholdes ✅.


## 241 fase B.3 – isolert CloudKit Development-lesing

**B.3 ✅ – fullført og endelig brukergodkjent 2026-11-08; alle seks praktiske punkter ✅.** Utgangspunkt: publisert `6b35055`. B.2 beholdes ✅. Implementering og syntetiske kontroller gir **ingen tillatelse til faktisk appkjøring eller CloudKit-oppslag**. Praktisk gjennomføring nedenfor krever særskilt godkjenning før oppstart/lesing.

### Implementering og sikkerhetsgrenser

- macOS/DEBUG-parameter `--diagnostic-cloudkit-development-read` velger `DevelopmentIdentityReadDiagnosticView` før `ContentView`, biblioteket eller vanlig diagnostikk opprettes. B.3 har prioritet hvis også B.2-parameteren er aktiv. Uten B.3 er eksisterende B.2-/normalruting bevart. iOS/iPadOS og Release har ingen B.3-rute.
- `DevelopmentIdentityReadSession` opprettes med inaktive fabrikk-closures. Verken rapportvisning, initialisering eller miljøvalg starter lesing. Bare «Les CloudKit Development-identiteter (kun lesing)» starter økten. Forventet miljø er låst til `.development`; det finnes ikke et Production-valg i B.3.
- `start()` sperrer parallelle starter, nullstiller forrige økt og kontrollerer lokal signatur/entitlement med systemkilden før transportfabrikken kalles. Deretter opprettes transporten for `iCloud.com.longfjeld.tekstilig`, privat database og standardzone, med eksplisitt forventet Development. Transportens eksisterende miljøkontroll før konto-/brukeridentitetsoppslag og recordport beholdes uendret. En tidligere B.2-kontroll brukes ikke som snarvei.
- Eksisterende `ImportIdentityReadDiagnostic.read(using:)` utfører to passeringer med paginering for alle fem posttyper og kontrollerer kontekst før/etter passeringene. Ingen repository-filtre brukes; PoC-poster beholdes dersom de finnes i leseområdet. `desiredKeys` omfatter bare logisk ID og eierfelt, aldri bildeinnhold/CKAsset.
- Separat rapport formatterer strukturert `ReadResult` direkte, uten backup, journal, baseline, adapterbeslutninger eller rapporttekst-parsing. Den viser preflight, kontekst/beviskilde, antall og fullføringsstatus per posttype i begge passeringer, sorterte rå-ID-er/eiere, faktiske recordnavn, observert zone/zoneOwner og changeTag. Manglende/feiltypede råverdier og delvise resultater beholdes. Feil og STOPP-årsaker vises; feiltekst er ikke et nytt strukturert CKError-format.
- «Avbryt lesing» og visningens `onDisappear` ber om kooperativ Task-avbrytelse. Start er sperret til oppgaven faktisk avsluttes; pågående SDK-kall kan måtte returnere før avbruddet er ferdig. Delvise observasjoner beholdes og merkes STOPP. Ingen automatisk gjentakelse; en ny runde krever et nytt eksplisitt knappetrykk.
- Ingen fil-/kataloghjelpere, lagring, eksport, import/restore eller save/delete inngår. Uendret beslutningsmodell/adapter er ikke koblet til utføring. Konfigurert standardzone er ikke bevis for dekning av andre zones. To like passeringer er ikke atomisk snapshot, validering av alle foreldre-/eierrelasjoner eller verifikasjon av historisk baselinebinding. Historiske data skal ikke repareres eller filtreres bort for å få et godkjent resultat.

### Faktiske tekniske kontroller – 2026-11-08

- macOS- og generisk iOS/iPadOS-bygg bestod i forrige del av B.3, med de samme appkildene som nå, Xcode 27.2 og `CODE_SIGNING_ALLOWED=NO`. Bare kjent AppIntents-metadataadvarsel. Appbygg er ikke gjentatt etter rettelsen som bare endret testfilen. Ingen app er startet, og B.3-signering/runtime er ikke praktisk kontrollert.
- Første kompilering av det isolerte programmet stoppet på manglende MainActor-isolasjon i `Fixture` og den lokale `report`-funksjonen. Rotårsak: appmålet har standard MainActor-isolasjon, det isolerte oppsettet har ikke det. Etter særskilt godkjenning ble bare disse to testhjelperne merket `@MainActor`; ingen produksjonskode eller globale compilerinnstillinger ble endret som retting.
- Ny kompilering og isolert kjøring: **11/11 nye B.3-tester PASS, 0 FAIL**. Dekker inaktiv oppstart/rapport/idle-avbrudd; eksakt to femtype-passeringer; fast Development-forventning; Production og åtte bevisfeil før transport/konto/record; transportens egen miljøport; delvise side-/postfeil; avbrudd før oppstart og under side; parallellsperre/eksplisitt ny start; deterministisk rapport med ugyldige råverdier.
- Deretter sekvensielt **38/38 modelltester, 23/23 adaptertester og 41/41 leser-/miljøtester PASS** fra eksisterende B.2-binærer med kontrollerte, uendrede kildefiler. Samlet **113 PASS, 0 FAIL**, exitkode 0. Alle programmer kjørte med nettverk, filskriving og brukermappelesing blokkert. Ingen faktisk transport eller systembeviskilde ble kjørt. Historiske statuslinjer i regresjonsprogrammene endrer ikke dokumenterte brukergodkjenninger.
- Statisk kallkjede- og diffkontroll bestått: oppstartsvalg → isolert visning → eksplisitt start → lokal miljøport → utsatt fabrikk → eksisterende transportport/leser → minnerapport. Ingen automatisk lesing, produksjonsfallback eller nye skriveruter. Eksisterende repositories, verifikator, leser, adapter/modell, signering, ZIP, journal og baseline er urørt. Lokale Xcode-/scheme-endringer er holdt utenfor oppgaven og staging.

Isolert B.3-program fra prosjektroten:

```sh
mkdir -p /private/tmp/tekstilig-test241-b3
xcrun swiftc -DDEBUG -module-cache-path /private/tmp/tekstilig-test241-b1/module-cache -framework Security -framework Combine Tekstilig/Diagnostics/ImportIdentityDecisionModel.swift Tekstilig/Diagnostics/ImportIdentityDiagnosticAdapter.swift Tekstilig/Diagnostics/CloudKitEnvironmentVerification.swift Tekstilig/Diagnostics/ImportIdentityReadDiagnostic.swift Tekstilig/Diagnostics/DevelopmentIdentityReadSession.swift Tests/DevelopmentIdentityReadSessionTests.swift -o /private/tmp/tekstilig-test241-b3/session-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test241-b3/session-tests
```

### Sekvensiell praktisk B.3-plan – alle seks punkter godkjent ✅

**Status etter brukervalidering 2026-11-08:** Alle seks punkter og B.3 samlet er uttrykkelig brukergodkjent, inkludert etterkontrollen. Nye app-/CloudKit-lesekjøringer krever særskilt godkjenning; ingen ny runde gjennomføres som del av dokumentasjonsoppdateringen. Syntetiske resultater godkjenner ikke nettverkstilgang. Brukeren benytter Xcode GUI; Codex kan bistå med avtalte tekniske kontroller.

1. **✅ Forbered og bygg.** Etter praktisk godkjenning: velg Tekstilig, My Mac, Debug og ordinær macOS/Debug-signering i Xcode 27.2. Sett `--diagnostic-cloudkit-development-read` under Product → Scheme → Edit Scheme… → Run → Arguments. Deaktiver B.2-parameteren for tydelighet (B.3 har ellers prioritet). Bygg før start. Forvent uendret Development-signering fra B.2. **Stopp** ved bygge-/signeringsfeil eller usikker rute; ingen normal appstart som del av testen.
2. **✅ Kontroller inaktiv isolert oppstart.** Start appen først når det er godkjent. Forvent bare «Test 241 B.3 – isolert Development-lesing», låst Development, ingen gjennomført miljøkontroll/observerte poster, aktiv leseknapp og deaktivert avbryt-knapp. Ingen bibliotek eller vanlig diagnostikk. **Stopp og avslutt** ved feil visning eller automatisk aktivitet. UI-tekst er ikke alene nettverksbevis; syntetisk/statisk kontroll underbygger inaktiv oppstart.
3. **✅ Start én godkjent leserunde.** Trykk «Les CloudKit Development-identiteter (kun lesing)» én gang. Forvent lokal Development-kontroll før transport, deretter transportens nye kontroll før konto/record. Leseknappen skal være sperret under kjøring. **Stopp** ved miljø-/konto-/nettverksfeil; behold rapporten og ikke forsøk automatisk eller gjentatt kjøring. Ingen Production-fallback.
4. **✅ Gjennomgå resultatet.** Forvent riktig container, Development, privat database, konto og konfigurert/observert zone/zoneOwner. Ved fullført runde: begge passeringer og fullført status for alle fem typer, deterministiske rader med råverdier/recordnavn/changeTag. Antall er observerte, ikke forhåndslåst til 43. PoC-poster skal ikke filtreres bort. Ved post-/sidefeil, ugyldige verdier, duplikater, endret kontekst/passering eller ufullstendig dekning: forvent STOPP og behold delresultatet. **Stopp** ved ethvert uavklart avvik; ingen reparasjon eller godkjenning av historisk eierskap.
5. **✅ Avbrudd og parallellsperre.** Praktisk ny runde krever egen uttrykkelig godkjenning hvis den første er avsluttet. Under en godkjent pågående runde: kontroller sperret leseknapp, trykk «Avbryt lesing» og vent til avslutning. Forvent STOPP/avbrudd, bevarte eventuelle delrader og ingen automatisk ny runde. **Stopp** ved ny automatisk aktivitet eller uklar avslutning. Rask fullføring kan gjøre praktisk avbrudd uobserverbart; rapporter dette, ikke kjør flere runder uten godkjenning. Den syntetiske avbruddstesten er ikke bevis for øyeblikkelig SDK-avbrudd.
6. **✅ Etterkontroll og avslutning.** Avslutt appen og rapporter resultatene. Kontroller at bare avtalte kilde-/dokumentendringer og lokale Xcode-/scheme-filer finnes, uten nye rapport-/testdatafiler. ZIP, journal og baseline skal ikke ha vært brukt. **Stopp etter rapporten** og avvent brukergodkjenning av B.3. Ingen import, restore, skrivetillatelse, atomisitetsgaranti eller videre fase følger av rapporten.


### Delvis praktisk brukervalidering – 2026-11-08

Brukervalidert 2026-11-08: isolert macOS/DEBUG-oppstart og vellykket eksplisitt CloudKit Development-lesing. Rapporten viste **to samsvarende passeringer med 43 poster i hver**, med **alle fem posttyper**. Dette lukker praktisk punkt 2–4 innen det bekreftede positive testforløpet, ikke uprøvde feilsituasjoner. Punkt 1 (særskilt praktisk bygg-/signeringskontroll) er ikke uttrykkelig bekreftet i denne meldingen; punkt 5 (SDK-avbrudd/parallellsperre i praksis) og punkt 6 (avsluttende etterkontroll) gjenstår. **B.3 samlet forblir ❗️.**

Den kjente `TextileImage`-posten med eier `T0001` dokumenteres som observasjon. Tidligere identifisert referanse: logisk ID `IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC`, recordName `74B85BA7-9EBF-48FD-A04A-828329F9B237`. Den er fortsatt en sannsynlig historisk rest; denne lesingen beviser ikke historisk eierskap eller at posten er foreldreløs. Ingen reparasjon, sletting eller migrering er utført eller godkjent.

Brukerens validering er grunnlaget for de praktiske resultatene; Codex har ikke startet appen eller utført CloudKit-oppslag ved denne oppdateringen. Tidligere tekniske resultater (**113 PASS, 0 FAIL**, begge appbygg) beholdes. Ingen nye kjøringer er utført. Like passeringer gir fortsatt ingen atomisitetsgaranti, historisk baselinebinding eller skrivetillatelse. Ingen generell tillatelse til flere CloudKit-leserunder følger av denne statusoppdateringen.

### Historisk forslag til avgrenset avbruddstest – før brukergodkjenning av punkt 5

Denne prosedyren bevares som historikk fra før brukergodkjenning av punkt 5. Punkt 5 er nå ✅ etter brukerens bekreftelse; prosedyren gir ingen tillatelse til en ny appkjøring/CloudKit-runde.

1. Bekreft først det gjenstående grunnlaget i praktisk punkt 1: macOS/Debug, ordinær Development-signering og riktig isolasjonsparameter. Bruk allerede utførte bygg-/signeringskontroller som underlag; ikke endre kode, signering, testdata eller nettverksoppsett for å forsinke lesingen. Innhent uttrykkelig godkjenning til **én** ny leserunde for avbruddstesten før start. Stopp hvis grunnlaget/godkjenningen mangler.
2. Start bare den isolerte B.3-visningen. Kontroller inaktiv tilstand og låst Development. Trykk «Les CloudKit Development-identiteter (kun lesing)» én gang. Når «Leser identiteter og metadata i to passeringer …» vises, kontroller at leseknappen er deaktivert.
3. Mens lesingen fortsatt pågår: trykk «Avbryt lesing» én gang. Forvent «Avbrudd bedt om – venter på at lesingen avsluttes …», deaktivert avbryt-knapp og fortsatt sperret lesestart frem til oppgaven avsluttes. Pågående SDK-kall kan returnere før kooperativ avbrytelse fullføres; ikke krev øyeblikkelig nettverksstopp.
4. Vent på avslutning uten flere knappetrykk. Forvent STOPP/«Lesing avbrutt», beholdte eventuelle delrader og ingen automatisk ny runde. Leseknappen kan først bli tilgjengelig igjen etter at oppgaven har avsluttet. Hvis lesingen var ferdig før avbruddet kunne registreres, noter **ikke observerbart**; SDK-avbrudd forblir ❗️. Ikke gjenta uten ny godkjenning. Ved uklar avslutning eller uventet ny aktivitet: stopp videre forsøk og rapporter tilstanden, uten reparasjon.
5. Registrer manuelt om avbruddet faktisk inntraff under en pågående lesing, vist STOPP-årsak, eventuell delvis typedekning/postantall og knappetilstand etter avslutning. Ingen rapporteksport eller lokal lagring fra diagnostikken. Avslutt appen og gjennomfør punkt 6 som egen etterkontroll. Rapporter til brukervalidering; ikke marker punkt 5 eller B.3 automatisk som godkjent. Testen kan underbygge brukerutløst kooperativ avbrytelse i dette forløpet, ikke garantere at et serverkall stoppet øyeblikkelig.


### Historikk – brukervalidering av punkt 1 og 5 og avsluttende etterkontroll – 2026-11-08

**Punkt 1–5 ✅ er nå uttrykkelig brukervalidert. Punkt 6 og B.3 samlet beholdes ❗️ til brukeren har godkjent denne etterkontrollen.** Tidligere beskrivelser av uavklarte punkt 1/5 nedenfor/ovenfor er historikk fra før denne bekreftelsen.

- Punkt 1: signert macOS/Debug-bygg bestått med Apple Development og Mac Team-profil. Både `.xcent` og signert app hadde eksakt `com.apple.developer.icloud-container-environment = Development`; streng `codesign`-kontroll bestod. B.3-parameteren ble bekreftet i bygget og aktiv i lokalt Debug-scheme. Dette kontrollresultatet er nå brukergodkjent.
- Punkt 2–4: tidligere brukergodkjent isolert oppstart og eksplisitt Development-lesing med to samsvarende passeringer, **43 poster i hver**, alle fem posttyper. Den kjente TextileImage-posten med eier T0001 beholdes som observasjon uten reparasjon eller bevist historisk eierskap/foreldreløshet.
- Punkt 5: brukeren har uttrykkelig godkjent avbrudd/parallellsperre etter praktisk validering. Det er ikke oppgitt nye postantall eller en målt SDK-responstid for avbruddsforløpet; ingen slike detaljer tilføyes. Godkjenningen er ikke en garanti for øyeblikkelig avbrudd av en serverforespørsel.
- Etterkontroll av kallkjeden: macOS/DEBUG-rute → separat visning uten automatisk start → eksplisitt start/parallellsperre → lokal Development-port før transportfabrikk → transportens egen miljø-/konto-/recordport → eksisterende metadata-leser → minnerapport. Avbrudd er kooperativt; ingen automatisk gjentakelse. Feltutvalget omfatter bare ID/eier; ingen bildeinnhold.
- Ingen CloudKit-save/delete, import/restore, fil-/kataloghjelpere eller baselineoppdatering er koblet inn. Eksisterende repositories, verifikator, leser, modell/adapter, signering og dataformater er uendret mot HEAD. ZIP, journal og baseline inngår ikke i B.3-kallkjeden og er ikke åpnet eller endret ved etterkontrollen.
- Tidligere resultater gjenbrukes på uendrede kilder: **11 + 38 + 23 + 41 = 113 PASS, 0 FAIL**, macOS- og iOS/iPadOS-bygg bestått, deretter signert macOS/Debug-bygg og signatur-/entitlement-kontroll bestått. Bygglogger kontrollert; bare kjent AppIntents-metadataadvarsel. Ingen nye tester, bygg, appkjøring eller CloudKit-oppslag i etterkontrollen.
- Git-/diffkontroll bestått: bare åtte avtalte B.3-filer pluss de to kjente lokale Xcode-/scheme-endringene; ingen staging, commit, merge eller push. Nye filer og dokumentasjon er kontrollert. Bare dokumentasjon endres i denne oppgaven. Ingen nye rapport-, ZIP-, journal- eller baselinefiler i filutvalget. Kilde-/testfiler er uendret siden siste signerte bygg.

**Vurdering:** Ingen konkrete avvik identifisert innen B.3-omfanget. B.3 er klar for endelig brukergodkjenning av punkt 6 og testen samlet, men dette er ikke en slik godkjenning. Standardzone-dekning, kooperativ SDK-avbrytelse, uavklart iOS/iPadOS-miljø, historisk baselinebinding, full foreldre-/eierverifikasjon og manglende atomisitetsgaranti består som dokumenterte begrensninger. Ingen videre CloudKit-lesing eller skrivetillatelse følger av etterkontrollen.


### Sluttresultat og endelig brukergodkjenning – B.3 – 2026-11-08

**Test 241 B.3 ✅ fullført og endelig brukergodkjent 2026-11-08. Alle seks praktiske punkter, inkludert avsluttende etterkontroll, er godkjent.** Brukeren har validert isolert macOS/Debug-oppstart, eksplisitt Development-lesing med to samsvarende passeringer og 43 poster i hver fordelt på alle fem posttyper, samt avbrudd/parallellsperre. Signert macOS/Debug-bygg, eksakt Development-entitlement, gyldig signatur og B.3-parameter er kontrollert. Etterkontrollen fant ingen konkrete avvik innen testomfanget.

Sluttgrunnlag: **113 PASS, 0 FAIL** (11 B.3-, 38 modell-, 23 adapter- og 41 leser-/miljøtester), vellykkede macOS-/iOS-/iPadOS-bygg og signert macOS/Debug-kontroll. Resultatene er gjenbrukt på uendrede kilder; ingen nye tester, appkjøring eller CloudKit-oppslag er utført ved godkjenningsoppdateringen. Praktiske leseresultater og avbruddsvalidering er bekreftet av brukeren.

Godkjenningen gjelder bare den isolerte, skrivebeskyttede Development-diagnostikken. Ingen import, restore, CloudKit-skriving/-sletting, baselineoppdatering eller produksjonsgodkjenning av kandidatidentiteter. T0001-bildeposten forblir kun observert og urørt. Standardzone-dekning, uverifisert iOS/iPadOS-miljø, historisk baselinebinding, full foreldre-/eierverifikasjon, manglende atomisitetsgaranti og kooperativ SDK-avbrytelse består som begrensninger. Ingen generell tillatelse til nye CloudKit-lesinger eller neste fase følger av godkjenningen. Tidligere delstatuser beholdes som historikk.


## 242.1 – isolert relasjonsmodell med syntetiske data

**242.1 ✅ – fullført og uttrykkelig brukergodkjent 2026-11-08, alle fem valideringspunkter ✅.** Bare denne deltesten er implementert. Test 242 samlet og senere integrasjon/baselineavklaring er ikke fullført. Grunnlag: publisert `f11881f` på main; arbeidsgren `codex/test-242-1-relationship-model`. Tidligere test 239–241-resultater beholdes.

### Kontrakt og avgrensning

`TextileRelationshipModel` er en `nonisolated` verdimodell uten imports, IO, CloudKit-API-er eller avhengighet til importbeslutningsmodellen. Den oppretter ingen filer, oppdager ingen konto/kontekst og kalles ikke av appens UI, repositories eller diagnostikkleser. Inndata er typed Textile-foreldre, underposter av Piece/TextileMaterial/TextileColor/TextileImage og eksplisitt dekningsbevis for Textile-lesing i en bestemt kontekst.

Modellen bevarer rå ID-/eierfelt som manglende, streng eller feil datatype med beskrivelse. Container, miljø, konto, database, zone og zoneOwner bevares som egne rå felt; recordnavn og valgfrie changeTags beholdes. Ingen trimming, bokstavkonvertering eller ID-/recordnavn-generering. Alle innsendte underposter får én rad, også ved duplikater; alle foreldre og dekningsoppføringer beholdes. Utdata sorteres deterministisk, og feiltekst sorteres uten å fjerne verdier/duplikater.

Fem relasjonsutfall:

| Utfall | Betydning |
|---|---|
| `uniqueObservedParent` | Nøyaktig én matchende, gyldig observert Textile i samme kontekst og komplett grunnlag. |
| `parentNotObservedWithCompleteCoverage` | Ingen slik forelder observert i det eksplisitt komplette leseområdet; ikke bevis for historisk sletting eller datakorrupsjon. |
| `incompleteCoverage` | Kontekst/dekning mangler, er tvetydig, uverifisert eller ufullstendig, har lesefeil eller inneholder uavklarte foreldreobservasjoner. Ingen fraværskonklusjon. |
| `ambiguousParent` | Flere matchende foreldreobservasjoner i samme kontekst ved ellers komplett grunnlag; også identiske duplikater bevares. |
| `invalidOwner` | Eier mangler, har feil datatype eller bryter modellens eksplisitte tokenregel. Råverdien beholdes. |

Rekkefølge: ugyldig eier diagnostiseres først, deretter manglende/ugyldig underpostkontekst og øvrige dekningsproblemer. Ufullstendig grunnlag overstyrer både entydighet og tvetydighet; observerte treff beholdes i raden. Deretter avgjør antall foreldretreff 0/1/flere. Tokenregelen er samme konservative diagnostiske regel som identitetsmodellen: ikke-tom streng av ASCII 33–126; T0001 er gyldig, whitespace/ikke-ASCII normaliseres ikke. Foreldre-recordnavn kontrolleres som ikke-tomt, inntil 255 UTF-8-byte og ASCII 32–126. Dette fastsetter ikke et nytt produksjonsformat.

Dekningsbevis er oppgitt av kalleren, ikke verifisert av modellen. Det må være nøyaktig én oppføring for underpostens komplette kontekst, med `contextVerified` og `textileReadComplete` sanne og uten lesefeil. Ugyldig foreldre-ID/recordnavn i samme kontekst gir ufullstendig grunnlag. En forelder med ukjent/ugyldig kontekst kan ikke utelukkes og gir konservativt ufullstendig grunnlag. Gyldig annen kontekst blandes ikke inn. Dette hevder ikke komplett lesing av underposter, andre zones eller hele CloudKit-databasen.

Modellen validerer relasjonen fra innsendt eier, ikke at underpostens egen ID, innhold eller changeTag er gyldig eller at historisk baseline er bundet. `permitsCloudKitWriting` er alltid false. Ingen importbeslutning, kandidatidentitet, reparasjon, slettingskonklusjon eller autorisasjon er introdusert. T0001-scenarioet er syntetisk: samme bilde-ID/recordnavn som kjent observasjon brukes som referanse, uten oppslag eller endring av den faktiske posten.

### Sekvensiell brukervalidering av 242.1 – alle fem punkter godkjent ✅

1. **✅ Bygg og isolasjon.** Gjennomgå ny modell og testprogram; bygg macOS og generisk iOS/iPadOS uten appkjøring. Forvent inkludering i begge bygg og ingen IO-/CloudKit-avhengigheter eller nye appkall. **STOPP** ved byggefeil eller integrasjon utenfor 242.1.
2. **✅ Kompiler og kjør syntetiske tester.** Bruk oppsettet nedenfor (Codex/Terminal; Xcode GUI brukes til bygg/kildegjennomgang). Forvent **25 PASS, 0 FAIL**, komplette forventede rapporter og alle fire undertyper. **STOPP** ved kompilatorfeil, FAIL, tom/manglende/ekstra beslutningsrad eller skrive-/nettverksbivirkning.
3. **✅ Gjennomgå fem utfall og kontekst.** Test 02–20 dekker entydig, ikke observert, ufullstendig, tvetydig og ugyldig eier; alle seks kontekstfelter, manglende/duplisert dekningsbevis, lesefeil og ugyldige foreldre. Forvent at ukjent grunnlag aldri gir sikkert fravær, og at treff ikke blandes mellom kontekster. **STOPP** ved feilplassert utfall, filtrerte råverdier eller antatt kontekst.
4. **✅ T0001, determinisme og grenser.** Test 21–25 viser T0001 med komplett/ufullstendig dekning og eksisterende forelder, eksakt bokstavsamsvar, diagnostisk prioritet, bevarte ugyldige underpost-ID-er og stabile fullrapporter ved omordnet input. Forvent ingen slettings-/korrupsjonspåstand, ingen endring av input og ingen skrivetillatelse. **STOPP** ved normalisering, tap av observasjoner eller importbeslutning.
5. **✅ Etterkontroll og stopp.** Kontroller filutvalg, diff og uendrede eksisterende modeller, repositories, signering og dataformater. Forvent kun ny modell/test og relevant dokumentasjon, separat fra kjente lokale Xcode-/scheme-endringer. **STOPP etter rapporten** og avvent brukergodkjenning. Ingen appstart, CloudKit, baselineendring eller neste deltest følger av resultatet.

Isolert oppsett fra prosjektroten (bruk aktuell brukermappesti i isolasjonsprofilen):

```sh
mkdir -p /private/tmp/tekstilig-test242-1
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test241-b1/module-cache Tekstilig/Diagnostics/TextileRelationshipModel.swift Tests/TextileRelationshipModelTests.swift -o /private/tmp/tekstilig-test242-1/relationship-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test242-1/relationship-tests
```

### Faktiske tekniske resultater – 2026-11-08

Oppføringen nedenfor bevarer teknisk status før brukergodkjenningen; sluttstatus følger nederst.

- Først macOS/Debug-bygg, deretter generisk iOS/iPadOS/Debug-bygg med Xcode 27.2 og `CODE_SIGNING_ALLOWED=NO`: **BUILD SUCCEEDED** for begge. Ny modell bekreftet i begge SwiftFileList. Bare kjent AppIntents-metadataadvarsel; ingen signert app eller appkjøring kontrollert i 242.1.
- Deretter isolert kompilering av bare modellen og testprogrammet og kjøring med nettverk, filskriving og lesing av brukermappen blokkert: **25 PASS, 0 FAIL**, exitkode 0. Ingen rettingsforsøk nødvendig. Test-orakelet sammenligner komplette rader, råverdier, antall, foreldretreff, utfallsvariant, årsaker og rapportgrunnlag; tomme eller manglende rader kan ikke oppfylle positive forventninger.
- Ingen nye regresjonskjøringer av uendrede 239–241-programmer; deres tidligere validerte resultater beholdes. Modellen kompileres uten disse kildene, og ingen eksisterende kallere er endret.
- Statisk sikkerhetskontroll og diffkontroll bestått. Ingen kodeendringer i eksisterende importbeslutninger, adapter, leser, repositories, UI, baseline-/journal-/backupformat eller signering. Ingen faktisk CloudKit, app, ZIP, journal eller baseline er åpnet eller endret i oppgaven. Lokale Xcode-/scheme-endringer er bevart, og ingen filer er staged. **242.1 forblir ❗️** frem til brukervalidering; ingen senere deltest er implementert.


### Sluttresultat og brukergodkjenning – 242.1 – 2026-11-08

**242.1 ✅ fullført og uttrykkelig brukergodkjent 2026-11-08, inkludert alle fem valideringspunkter.** Sluttgrunnlag: **25 syntetiske tester PASS, 0 FAIL**, vellykkede macOS- og iOS/iPadOS-bygg, og samlet kontroll av isolasjon, komplette rapporter, alle fem utfall, kontekst, råverdier/duplikater, T0001 og determinisme. Ny kompilering og kjøring av eksisterende testprogram bekreftet 25 PASS/0 FAIL ved samlet validering; ingen nye testtilfeller ble lagt til.

Godkjenningen gjelder bare den isolerte verdimodellen for relasjoner. Kalleren må fortsatt levere faktisk deknings-/kontekstbevis; modellen beviser ikke CloudKit-dekning, historisk sletting, datakorrupsjon, historisk baselinebinding eller gyldigheten av underpostens egen identitet/versjon. Ingen UI-/leserintegrasjon, importbeslutning, reparasjon eller skrivetillatelse følger av godkjenningen. Eksisterende importmodeller, repositories og baseline er uendret. Test 242 samlet og senere deltester er ikke fullført eller startet. Ingen appkjøring eller CloudKit-operasjon er utført ved denne godkjenningsoppdateringen. Tidligere delstatuser beholdes som historikk.


## 242.2 – isolert, deterministisk relasjonsrapport

**242.2 ✅ – fullført og uttrykkelig brukergodkjent 2026-11-08; alle fem valideringspunkter ✅.** Grunnlag: publisert `1c9ab60`; arbeidsgren `codex/test-242-2-relationship-report`. 242.1 beholdes ✅. Ingen UI-, leser- eller importintegrasjon og ingen senere deltest er implementert.

### Kontrakt og sikkerhetsgrenser

Ny `TextileRelationshipReport.make(_:)` tar bare `TextileRelationshipModel.Input` og kaller den uendrede 242.1-modellen. Resultatet inneholder modellens komplette `Report` som grunnlag, én strukturert rad per modell-/underpostobservasjon og en beregnet tekstvisning. Ingen rapporttekst parses. Rapporten har ingen imports, IO eller CloudKit-avhengigheter og kalles ikke fra appflyt eller eksisterende diagnostikk.

Hver rad viser posttype, rå logisk ID/eier med forskjell på manglende/streng/feil datatype, faktisk recordnavn, alle seks kontekstfelter, valgfri changeTag, alle foreldretreff med deres rå identitet/recordnavn/kontekst/tag, modellens uendrede utfall/årsaker og konkret norsk begrunnelse. Strenger vises med escaping slik at kontrolltegn ikke lager ekstra fysiske rader eller skjules ved trimming. Duplikater beholdes både i struktur og tekst. Ingen foreldrekandidat velges ved tvetydighet.

Teksten viser også antall per undertype, totalt radantall og hele foreldre-/dekningsgrunnlaget, inkludert ubrukte, ugyldige, ufullstendige og dupliserte oppføringer/feiltekster. Rekkefølgen kommer fra den deterministiske modellen; ingen selvstendig omklassifisering eller konteksttilordning. Manglende kontekst er eksplisitt, aldri en standardkonto/-zone.

Diagnostisk STOPP vises ved andre relasjonsutfall enn entydig observert forelder, og ved tomt underpostgrunnlag. Entydige rader merkes **OBSERVERT**, ikke skriveklare. Overskriften viser STOPP hvis minst én rad stopper; øvrige rader beholdes. Dette er en rapportstatus, ikke ny importpolitikk eller en utførelsesport. Ekstra grunnlagsoppføringer vises, men relasjonsutfall følger modellens avgrensning til den aktuelle radens kontekst. Ugyldig grunnlag forklares med konkrete modellårsaker (manglende/duplisert dekningsbevis, uverifisert kontekst, ufullstendig Textile-lesing, lesefeil, uavklart foreldreobservasjon eller ugyldig eier/forelder).

`permitsCloudKitWriting` er alltid false, også ved bare entydige rader. Rapporten verifiserer ikke sannheten i caller-levert kontekst/dekning, underpostens egen ID/versjon, historisk baselinebinding eller atomisitet. Den genererer ingen kandidatnavn og reparerer ingenting. T0001 betyr bare den observerte rå eieren; «forelder ikke observert» er ikke bevis for sletting, korrupsjon eller faktisk foreldreløshet.

### Sekvensiell brukervalidering av 242.2 – alle fem punkter godkjent ✅

1. **✅ Bygg og isolasjon.** Gjennomgå rapportens eneste modellkall og rene formattering. Bygg macOS og generisk iOS/iPadOS uten appstart. Forvent inkludering i begge bygg, ingen IO-/CloudKit-avhengigheter og uendret 242.1/importmodell/repositories/baseline. **STOPP** ved byggefeil, datatilgang eller integrasjon utenfor 242.2.
2. **✅ Kompiler og kjør syntetiske tester.** Bruk oppsettet nedenfor via Codex/Terminal; Xcode GUI brukes til bygg/kildegjennomgang. Forvent **15 PASS, 0 FAIL**, deretter de eksisterende **25 modelltestene PASS, 0 FAIL** i isolasjon. **STOPP** ved kompilatorfeil, FAIL eller skrive-/nettverksbivirkning.
3. **✅ Radantall, råverdier og fullstendig grunnlag.** Gjennomgå test 01–11: tomt grunnlag gir ikke falsk suksess, alle fire undertyper har forventede rader/antall, dupliserte underposter/foreldre beholdes, alle kontekstfelt/recordmetadata vises og ugyldig/ufullstendig grunnlag gir STOPP med konkret årsak. **STOPP** ved tapt eller ekstra rad, skjult feiltekst, råverdinormalisering eller antatt kontekst.
4. **✅ Blandede utfall og determinisme.** Test 12 sammenligner eksakt fem ulike utfall/foreldretreff/årsaker på riktige underpostidentiteter i samme rapport. Test 13 sammenligner full struktur og tekst ved gjentakelse/omordnet input. Test 14–15 kontrollerer T0001, uendret input og skrivetillatelse false. **STOPP** ved feilplassert begrunnelse, vilkårlig foreldrevalg, historisk slutning eller import-/skrivegodkjenning.
5. **✅ Etterkontroll og stopp.** Kontroller diff, nye filer og filutvalg; skill kjente lokale Xcode-/scheme-endringer fra oppgaven. Forvent kun ny rapport/test og relevant dokumentasjon, uten endring av 242.1-modellen, importbeslutninger, repositories eller baseline. **STOPP etter rapporten** og avvent brukergodkjenning. Ingen appkjøring, CloudKit, commit, merge, push eller neste deltest følger av testen.

Isolert testoppsett fra prosjektroten (bruk aktuell brukermappesti i profilen):

```sh
mkdir -p /private/tmp/tekstilig-test242-2
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test241-b1/module-cache Tekstilig/Diagnostics/TextileRelationshipModel.swift Tekstilig/Diagnostics/TextileRelationshipReport.swift Tests/TextileRelationshipReportTests.swift -o /private/tmp/tekstilig-test242-2/report-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test242-2/report-tests
```

### Faktiske tekniske resultater – 2026-11-08

Oppføringen nedenfor bevarer teknisk status før samlet brukergodkjenning; sluttstatus følger nederst.

- macOS/Debug og generisk iOS/iPadOS/Debug med Xcode 27.2, uten signering/appkjøring: **BUILD SUCCEEDED**, ny rapport bekreftet i begge SwiftFileList. Bare kjent AppIntents-metadataadvarsel. En hjelpetekst ble presisert fra «nedenfor» til «i dekningsoversikten»; avsluttende bygg og ny kompilering/testkjøring bekrefter gjeldende tekstversjon. Ingen bygge-/testfeil.
- **15/15 rapporttester PASS, 0 FAIL**, exitkode 0, med komplette rad-/observasjonsforventninger, eksplisitt sorteringsrekkefølge, eksakte blandede utfall og sammenligning av full struktur/tekst. **25/25 eksisterende 242.1-modelltester PASS, 0 FAIL** fra binæren med kontrollerte uendrede modell-/testkilder. Totalt **40 PASS, 0 FAIL**; rapporttesten ble også kjørt på nytt etter tekstpresiseringen. Ingen nye modelltester eller endring av 242.1-resultatet.
- Testprogrammene kjørte med nettverk, filskriving og brukermappelesing blokkert. Ingen faktisk observasjonskilde, app, CloudKit, bildeinnhold, ZIP, journal eller baseline ble brukt.
- Statisk sikkerhets-/diffkontroll bestått. Eneste produksjonskilde-tillegg er den isolerte rapporten; eksisterende appflyt, relasjonsmodell, importmodell, repositories, dataformater og signering er urørt. Lokale Xcode-/scheme-endringer er bevart uten staging. **242.2 forblir ❗️**, alle fem punkter avventer brukervalidering; test 242 samlet er ikke fullført.


### Sluttresultat og brukergodkjenning – 242.2 – 2026-11-08

**242.2 ✅ fullført og uttrykkelig brukergodkjent 2026-11-08, inkludert alle fem valideringspunkter.** Samlet validering bekrefter én rad per innsendt underpost, alle fire undertyper, deterministisk struktur/tekst, bevarte råverdier og duplikater, korrekte blandede utfall/foreldretreff, konkrete STOPP-årsaker ved uavklart relasjonsgrunnlag og ubetinget skrivetillatelse false. T0001 gir ingen historisk slettings-/korrupsjonskonklusjon.

Sluttgrunnlag: **15 rapporttester + 25 modelltester = 40 PASS, 0 FAIL**, vellykkede macOS- og iOS/iPadOS-bygg uten appkjøring, og bestått sikkerhets-/diffkontroll. Ny kompilering og sekvensiell syntetisk testkjøring bekreftet resultatene under samlet validering. Ingen nye testtilfeller eller kodeendringer ble gjort da eller ved godkjenningsoppdateringen.

Godkjenningen gjelder bare den isolerte relasjonsrapporten på uendret 242.1-modell. Rapporten er ikke koblet til UI, CloudKit-leser, import eller restore. Kalleren må fortsatt levere faktisk kontekst/dekning; historisk baselinebinding, underpostens egen identitet/versjon og atomisitet er ikke verifisert. Ingen skrivetillatelse, reparasjon, baselineendring eller generell tillatelse til nye datalesinger følger av dette. Test 242 samlet og senere deltester er ikke fullført eller startet. Tidligere delstatuser beholdes som historikk.

## 242.3 – isolert baselinebevis i minnet

**242.3 ✅ fullført og uttrykkelig brukergodkjent 2026-11-08; alle fem valideringspunkter ✅.** Utgangspunkt: publisert `b5d2598`; arbeidsgren `codex/test-242-3-baseline-evidence`. 242.1–242.2 beholdes ✅. Tidligere omtale av ikke-startede senere deltester er historikk; kun denne deltesten er nå implementert.

### Kontrakt og bevisgrenser

`BaselineEvidenceModel.evaluate(_:)` er en separat `nonisolated` verdimodell uten imports eller avhengigheter til eksisterende modeller, filer, UI, repositories eller CloudKit. Input er allerede strukturerte, innsendte påstander: valgt ZIP-hash, journal-/baselinekandidater, baselinens rå posttype/recordName/changeTag, historiske kontekstpåstander med kilde, og separat dagens kontekst. Modellen leser ingen faktiske kilder, beregner ikke ZIP-hash og dekoder ikke eksisterende formater.

Tre vurderinger holdes adskilt: `binding`, `observations` og `historicalContext`, hver med `documented`, `unresolved`, `conflicting` eller `ambiguous`. «Documented» betyr kun strukturmessig gyldig og konsistent innsendt grunnlag, ikke autentisert kilde eller komplett CloudKit-snapshot. Én entydig baseline og journal må samsvare eksakt om journal-ID og ZIP-hash, inkludert valgt ZIP-hash. UUID-/hashsyntaks kontrolleres uten trimming eller normalisering. Manglende kandidater stopper; flere kandidater beholdes uten å velge én. Alle konkrete avvik beholdes som sorterte årsakskoder.

Råfelt skiller manglende, streng og feil datatype. Alle fem posttyper støttes; ugyldige verdier og duplikater fjernes ikke. Rå recordName/changeTag er observerte baselinepåstander, ikke bekreftede nåværende serververdier. Gjentatt posttype/recordName i samme baseline gir tvetydighet; ulike tags i slike oppføringer gir motstrid. Dette er diagnostikk av baselinegrunnlaget, ikke bevis for dupliserte faktiske CloudKit-records. Historisk zone mangler i v1, så global recordadresse eller kollisjonsfrihet kan ikke utledes.

Historisk kontekst må leveres eksplisitt som en påstand knyttet til baselinen med ikke-tom kilde og alle seks råfelt: container, miljø, konto, database, zone og zoneOwner. Manglende/ugyldig påstand forblir uavklart; flere, også identiske, er tvetydige; ulike kontekster er motstridende. Kildens historiske ekthet eller tilknytning autentiseres ikke av modellen. `currentContexts` bevares bare i input og leses aldri i vurderingslogikken. Dagens kontekst kan derfor verken etablere, erstatte eller avkrefte historisk bevis.

Eksisterende `CloudKitVersionBaseline` v1 har bare schemaVersion, journalID, zipSHA256 og entries med posttype/recordName/changeTag. Den har ingen historisk kontekst. Et syntetisk v1-formet grunnlag med korrekt binding og observasjoner får derfor disse to vurderingene dokumentert, men historisk kontekst **uavklart/STOPP**, også når dagens kontekst er tilgjengelig. Ingen historisk tilbakebinding, migrering eller baselineendring er implementert.

Resultatet bevarer hele opprinnelige input med rekkefølge og duplikater, samt separat deterministisk sorterte poster innen hver baseline og unike, sorterte årsakskoder. Omordnet postinput gir samme vurderinger/sorterte observasjoner; originalinput gjenspeiler fortsatt innsendt rekkefølge. Tomt eller uavklart grunnlag gir `hasStop`. Selv komplett syntetisk grunnlag gir alltid `permitsImport == false` og `permitsCloudKitWriting == false`. Ingen garanti om eierskap, historisk sletting, atomisitet, idempotens eller trygg import.

### Sekvensiell validering – alle fem punkter ✅

1. **✅ Bygg og isolasjon.** Gjennomgå de to nye Swift-filene i Xcode GUI; bygg macOS/Debug, deretter iOS/iPadOS/Debug uten appstart. Codex kan utføre byggene. Forvent begge bygg bestått, modellen inkludert i begge mål og ingen IO-/CloudKit-kobling. **STOPP** ved byggefeil, endring av eksisterende modell/repository eller automatisk datatilgang.
2. **✅ Syntetisk kjøring.** Kompiler/kjør programmet nedenfor via Codex/Terminal etter bygg; bruk ingen faktiske ZIP-/journal-/baselinefiler. Forvent **23 PASS, 0 FAIL**, deretter eksisterende 242.1-/242.2-programmer **25 + 15 PASS, 0 FAIL** under samme isolasjon. **STOPP** ved første feil eller skrive-/nettverksbivirkning.
3. **✅ Binding og observerte poster.** Gjennomgå test 01, 04–15 og 20–23: eksakte vurderinger, årsakskoder, rå input og komplette postgrupper kontrolleres. Forvent alle fem typer, uavhengige journal-ID-/hashavvik, manglende/flere kandidater, ugyldige felt, duplikater og motstridende tags uten tap av data eller falsk godkjenning. **STOPP** ved normalisering, utelatte avvik eller vilkårlig valg.
4. **✅ Historisk kontekst.** Gjennomgå test 02–03 og 16–19: v1-formet grunnlag forblir historisk uavklart, hvert av seks kontekstfelter og kilde kreves separat, identiske påstander er tvetydige og forskjellige motstridende. Forvent ingen historisk slutning fra dagens kontekst, heller ikke ved samsvar. **STOPP** hvis dagens konto/miljø/zone brukes som historisk bevis eller innsendt kilde omtales som autentisert.
5. **✅ Etterkontroll og stopp.** Kontroller determinisme, uendret input, ubetinget import-/skrivetillatelse false, nye filers hele kallkjede og Git-diff. Forvent kun isolert modell/test og fire dokumenter, separat fra lokale Xcode-/scheme-endringer; eksisterende baseline, journal, ZIP, importbeslutninger og repositories urørt. **STOPP etter rapporten**, avvent brukergodkjenning. Ingen app, CloudKit, integrasjon eller neste deltest.

Isolert oppsett fra prosjektroten (tilpass brukermappestien i profilen):

```sh
mkdir -p /private/tmp/tekstilig-test242-3
xcrun swiftc -module-cache-path /private/tmp/tekstilig-test241-b1/module-cache Tekstilig/Diagnostics/BaselineEvidenceModel.swift Tests/BaselineEvidenceModelTests.swift -o /private/tmp/tekstilig-test242-3/baseline-tests
/usr/bin/sandbox-exec -p '(version 1) (allow default) (deny network*) (deny file-write*) (deny file-read* (subpath "/Users/persteinar"))' /private/tmp/tekstilig-test242-3/baseline-tests
```

### Faktiske tekniske resultater – 2026-11-08

Oppføringen nedenfor bevarer teknisk status før brukergodkjenningen; sluttstatus følger nederst.

- Først macOS/Debug, så generisk iOS/iPadOS/Debug med Xcode 27.2 og `CODE_SIGNING_ALLOWED=NO`: **BUILD SUCCEEDED**. Ny modell bekreftet i begge SwiftFileList. Kun kjent AppIntents-metadataadvarsel; ingen signert appkontroll eller appkjøring.
- Deretter isolert kompilering/kjøring: **23/23 baselinetester PASS**, etterfulgt av ny kompilering og sekvensiell kjøring av uendrede **25/25 relasjonsmodelltester og 15/15 rapporttester PASS**. Totalt **63 PASS, 0 FAIL**, exitkode 0. Nettverk, filskriving og lesing av brukermappen blokkert under kjøring. Ingen bygge-/testfeil eller rettingsforsøk.
- Sikkerhets-/diffkontroll bestått. Modellen bruker bare verdier og Swift-standardbibliotekets samlings-/strengoperasjoner; ingen URL-/kataloghjelpere eller eksterne kall. Ingen eksisterende importbeslutninger, repositories, UI, transport eller dataformater er endret. Ingen faktiske ZIP-er, journaler, baseline eller CloudKit-data er lest eller endret. Lokale Xcode-/scheme-endringer er bevart uten staging. **Alle fem punkter og 242.3 samlet forblir ❗️** frem til brukergodkjenning. Ingen commit, merge eller push.


### Sluttresultat og brukergodkjenning – 242.3 – 2026-11-08

**242.3 ✅ fullført og uttrykkelig brukergodkjent 2026-11-08, inkludert alle fem valideringspunkter.** Samlet validering bekrefter skillet mellom ZIP-/journalbinding, rå recordName/changeTag og historisk CloudKit-kontekst, eksplisitt STOPP ved manglende, motstridende eller tvetydig grunnlag, bevarte råverdier/duplikater og ubetinget import-/skrivetillatelse false. Dagens kontekst brukes aldri som historisk bevis.

Sluttgrunnlag: **23 baselinetester + 25 relasjonsmodelltester + 15 rapporttester = 63 PASS, 0 FAIL**, vellykkede macOS- og iOS/iPadOS-bygg uten appkjøring og bestått sikkerhets-/diffkontroll. Ny kompilering og sekvensiell syntetisk kjøring bekreftet resultatene under samlet validering; eksisterende byggresultater ble gjenbrukt på uendrede kilder.

Godkjenningen gjelder bare den isolerte baselinebevismodellen. Innsendte historiske kilder autentiseres ikke; faktisk historisk CloudKit-kontekst er fortsatt uavklart. Ingen faktisk baseline-/journal-/ZIP-endring, UI-/leserintegrasjon, import, restore, CloudKit-operasjon eller skrivetillatelse følger av godkjenningen. Test 242 samlet og senere deltester er ikke dermed fullført. Tidligere delstatuser beholdes som historikk.
