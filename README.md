# Tekstilig

Tekstilig er i aktiv native utvikling. Målet er en privat tekstiloversikt for registrering, søk og filtrering av tekstiler til syprosjekter.

## Aktivt utviklingsspor

CloudKit er primærlager. Videre klientutvikling skjer **utelukkende i SwiftUI med native CloudKit** mot containeren:

```text
iCloud.com.longfjeld.tekstilig
```

Den tidligere PWA-en er frosset som teknisk PoC/referanse. PWA-filene beholdes foreløpig i repositoryet, men skal ikke videreutvikles mens SwiftUI-sporet bygges ut.

## Teknisk PoC er fullført

Følgende er validert native i Development:

- signering og CloudKit-entitlements
- iCloud account status
- privat CloudKit-database
- `Textile`
- `TextileImage` med native `CKAsset`
- byte-for-byte tur/retur av bildefil
- tilgang fra separat Apple-klientinstans via iOS-simulator med samme iCloud-konto
- `Piece`, inkludert dimensjoner og reservasjon

PoC-resultatene er dokumentert i `docs/SWIFTUI-OPPSTART.md`.

## Nåværende appfase

Textile-produktflyten er validert gjennom test 1–9, og Piece-produktflyten er validert gjennom test 10–18. Devpatch 0003 starter neste produktsteg: hovedbilde med `TextileImage` + `CKAsset` i ordinær app-UI. Arkitekturen er nå:

```text
SwiftUI-visning
    ↓
TextileLibraryModel
    ↓
TextileRepository
    ↓
CloudKitTextileRepository
    ↓
Private CloudKit / Development
```

Aktiv produktflyt er nå:

```text
Tekstilbibliotek
  → Tekstildetalj
     → Hovedbilde (TextileImage + CKAsset)
     → Stoffstykker → Nytt/rediger/slett Piece
```

`TextileImage` bruker eksisterende Development-schema fra PoC-en. Denne leveransen legger til valg/erstatning av hovedbilde fra Bilder, men ikke kamera, thumbnails eller bildeoptimalisering ennå. Den fulle logiske datamodellen i `docs/DATAMODELL.md` endres ikke og kobles på trinnvis.

## Videre test

Følg `docs/SWIFTUI-IMPLEMENTERING.md` i nummerrekkefølge.

Production skal ikke deployes ennå.
