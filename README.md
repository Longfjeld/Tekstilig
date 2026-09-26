# Tekstilig

Tekstilig er i en tidlig utviklingsfase. Målet er en privat tekstiloversikt for registrering, søk og filtrering av tekstiler til syprosjekter.

## Aktivt utviklingsspor

CloudKit er valgt som primærlager. Videre klientutvikling skjer nå **utelukkende i SwiftUI med native CloudKit** mot containeren:

```text
iCloud.com.longfjeld.tekstilig
```

Den tidligere PWA-en er frosset som teknisk PoC/referanse. PWA-filene beholdes foreløpig i repositoryet, men skal ikke videreutvikles mens SwiftUI-sporet bygges ut.

App Store-distribusjon er et mål for en senere full native versjon, men prosjektet er ikke på distribusjonsstadiet ennå.

## Validert så langt

Native SwiftUI/CloudKit er nå validert på fysisk Apple-enhet for:

- signering og CloudKit-entitlements
- iCloud account status
- privat Development-database
- oppretting/lesing av fast `Textile`-testrecord
- `TextileImage` med native `CKAsset`, inkludert byte-for-byte tur/retur av bildefilen

Kryssenhetstesten i punkt 8 er utsatt til en annen fysisk Apple-enhet er tilgjengelig. Den blokkerer ikke den videre valideringen av `Piece`.

## Neste steg

Punkt 1–7 i `docs/SWIFTUI-OPPSTART.md` er fullført. Punkt 8 er utsatt. Kodeleveranse 0005 implementerer punkt 9: valider `Piece` native mot samme private Development-database, inkludert kobling til `Textile`, dimensjoner og reservasjon.

Production skal ikke deployes ennå.
