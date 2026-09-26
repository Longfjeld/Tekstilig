# Tekstilig

Tekstilig er i en tidlig utviklingsfase. Målet er en privat tekstiloversikt for registrering, søk og filtrering av tekstiler til syprosjekter.

## Nåværende utviklingsspor

CloudKit er valgt som primærlager. Den tidligere PWA-en beholdes som teknisk PoC/referanse for CloudKit JS og datamodellen, men videre klientutvikling skjer nå som **SwiftUI med native CloudKit** mot samme container:

```text
iCloud.com.longfjeld.tekstilig
```

App Store-distribusjon er et mål for en senere full native versjon, men prosjektet er ikke på distribusjonsstadiet ennå.

## Validert så langt

CloudKit JS/PWA-PoC-en validerte i privat Development-database:

- iCloud-autentisering
- `Textile`: oppretting, lesing og endring
- `Piece`: oppretting
- eksisterende CloudKit-container og schema

Bildevalg fungerte i webklienten, men opplasting av `TextileImage.imageAsset` stoppet på CORS/preflight mot Apples separate `singleFileUpload`-endepunkt. Native SwiftUI/CloudKit brukes derfor til videre validering, særlig `CKAsset`.

## Neste steg

Punkt 1–5 i `docs/SWIFTUI-OPPSTART.md` er fullført. Kodeleveransen inneholder nå punkt 6: minimal native CloudKit-diagnostikk for å validere container, iCloud-status, privat database og `Textile` før `CKAsset` introduseres.

Production skal ikke deployes ennå.
