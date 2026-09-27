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

Textile-produktflyten er validert gjennom test 1–9, Piece gjennom test 10–18, hovedbilde gjennom test 20–29 og materialer/farger gjennom test 30–39. Devpatch 0006 har stabilisert sheet-presentasjonen for materiale/farge. Devpatch 0007 anvender samme presentasjonsmønster på plassering før lagring av plasseringsdata testes mot CloudKit. Arkitekturen er nå:

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
     → Materialer / farger
     → Plassering
     → Stoffstykker → Nytt/rediger/slett Piece
```

Materialer og farger lagres strukturert som egne child-records (`TextileMaterial` og `TextileColor`) knyttet til `textileId`. Plassering lagres som tre valgfrie felt direkte på `Textile`: område/rom, hylle og beholder/kasse. Kamera, thumbnails og bildeoptimalisering er fortsatt utsatt. Den fulle logiske datamodellen i `docs/DATAMODELL.md` endres ikke og kobles på trinnvis.

## Videre test

Følg `docs/SWIFTUI-IMPLEMENTERING.md` i nummerrekkefølge.

Production skal ikke deployes ennå.
