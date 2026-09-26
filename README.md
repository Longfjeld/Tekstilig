# Tekstilig – overgang til SwiftUI/native CloudKit

CloudKit JS/PWA-PoC-en er nå avsluttet som teknisk validering.

## PoC-resultat

Følgende ble validert i privat CloudKit Development-database:

- iCloud-autentisering
- `Textile`: oppretting, lesing og endring
- `Piece`: oppretting
- eksisterende CloudKit-container og schema

Bildevalg fungerte i webklienten, men opplasting av `TextileImage.imageAsset` stoppet på CORS/preflight mot Apples separate `singleFileUpload`-endepunkt i både Safari og Chrome. Samme feil besto i en diagnostisk test med Development-tokenet midlertidig satt til `Any Domain`.

## Beslutning

CloudKit beholdes som primærlager. Neste klientspor er **SwiftUI med native CloudKit** mot samme container:

```text
iCloud.com.longfjeld.tekstilig
```

PWA-koden beholdes som PoC/referanse, men videre funksjonsutvikling skjer ikke der nå.

## Neste steg

Følg `docs/SWIFTUI-OPPSTART.md` strengt fra punkt 1. Første native kodeleveranse lages etter at punktene 1–5 er utført og kontrollert.

Production skal ikke deployes ennå.
