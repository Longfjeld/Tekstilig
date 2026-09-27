# SwiftUI – videre implementering

**Status:** Produktfase 1 validert (test 1–9) · Produktfase 2 `Piece` klar til test via devpatch 0002  
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

Devpatch 0002 er godkjent når alle disse er bekreftet:

- appen bygger i Xcode 27
- `Piece.textileId` er QUERYABLE i Development
- tom Piece-tilstand fungerer
- et stoffstykke kan opprettes og vises på riktig tekstil
- samme Piece kan redigeres uten å opprette en ekstra record
- delvis reservasjon viser korrekt gjenværende tilgjengelig lengde
- flere separate Piece-records kan tilhøre samme tekstil
- ett Piece kan slettes med bekreftelse uten å påvirke Textile eller andre Piece-records

**Ikke gå videre til bilder i produkt-UI før punkt 10–18 er validert.**

## 20. Neste planlagte implementering

**⏭️ SENERE**

Når Piece-steget er validert, fortsetter produktutviklingen i denne rekkefølgen:

1. hovedbilde med `TextileImage` + `CKAsset`
2. materiale og farge
3. plassering
4. deretter øvrige tekstilegenskaper og vedlikehold

`quantity`, Piece-notat, splitting av rester og egen «registrer bruk»-flyt vurderes som senere utvidelser av Piece-modellen. Production deployes ikke før produksjonsmodellen og schemaet er gjennomgått samlet.

## Feilretting: eldre PoC-records med samme `textileId`

Under første produktvalidering ble det avdekket at eldre PWA-PoC-data kan inneholde flere separate CloudKit-records med samme logiske `textileId` (for eksempel `T0001`). PWA-PoC-en brukte `T0001` som standardverdi og opprettet en ny CloudKit-record hver gang **Opprett Textile** ble kjørt.

Dette er to separate forhold:

1. CloudKit-recordene er reelt forskjellige fordi de har ulike `recordName`.
2. Første SwiftUI-produktversjon brukte `textileId` som SwiftUI-identitet og detaljoppslagsnøkkel. Når flere eldre records hadde samme `textileId`, kunne flere rader derfor peke til samme detaljrecord.

Fra devpatch 0001 brukes CloudKit `recordName` som SwiftUI/storage-identitet for lagrede records. `textileId` beholdes som permanent logisk Tekstilig-ID og endres ikke av denne rettingen.

### Rydding av gamle testdata

Etter at devpatch 0001 er installert:

1. Åpne hver av de tilsynelatende like radene i appen.
2. Kontroller feltet **Record name**. Radene skal nå vise sin faktiske CloudKit-record.
3. Åpne **CloudKit Database → Development → Private Database → Textile**.
4. Identifiser gamle PoC-records du ikke vil beholde.
5. Slett bare de gamle testrecordene du har bekreftet som overflødige.
6. Oppdater tekstilbiblioteket i appen.

Nye native tekstiler får `textileId` i formatet `T-<UUID>` og skal derfor ikke få samme logiske ID.
