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

Kodeleveranse 0006 starter den faktiske appimplementeringen. Første vertikale produktstykke er:

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

Første reelle brukerflyt er:

```text
Tekstilbibliotek → Tekstildetalj → Nytt/rediger tekstil
```

Denne første produktflyten lagrer foreløpig bare den validerte kjernen av `Textile`: navn, kategori, permanente ID-er og metadata. Den fulle logiske datamodellen i `docs/DATAMODELL.md` endres ikke og kobles på trinnvis.

## Videre test

Følg `docs/SWIFTUI-IMPLEMENTERING.md` i nummerrekkefølge.

Production skal ikke deployes ennå.
