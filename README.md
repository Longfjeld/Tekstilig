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

Den tidligere CloudKit JS/PWA-PoC-en validerte også vanlige record-operasjoner, men Asset-opplasting stoppet på CORS/preflight mot Apples web-endepunkt. Dette er grunnen til at `CKAsset` nå valideres native.

## Neste steg

Punkt 1–6 i `docs/SWIFTUI-OPPSTART.md` er fullført. Kodeleveranse 0004 implementerer punkt 7: velg ett bilde med systemets Photos Picker, lagre det som `TextileImage.imageAsset`, hent det tilbake fra privat CloudKit-database og vis den nedlastede Asset-filen.

Production skal ikke deployes ennå.
