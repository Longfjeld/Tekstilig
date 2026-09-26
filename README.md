# Tekstilig – CloudKit PoC 0002

Denne leveransen erstatter den første lokale lagringsprototypen som aktiv testflate. Målet nå er å validere CloudKit som primær lagring for Tekstilig.

## Denne PoC-en tester

1. lasting og konfigurering av CloudKit JS
2. innlogging med iCloud
3. privat CloudKit-database
4. opprettelse av en `Textile`-record
5. lesing av samme record
6. endring og lagring med `recordChangeTag`
7. opprettelse av en `Piece`-record
8. valg/fotografering av bilde
9. lagring av bildet som `TextileImage` med CloudKit Asset
10. lesing av bildet tilbake fra CloudKit

Konfigurasjonen ligger i `cloudkit-config.js`. Web API-tokenet er et CloudKit JS-token og kan ligge i den publiserte klientkoden; tilgang begrenses med Allowed Origin i CloudKit. Private servernøkler skal aldri legges i repositoryet.

## Publisering og test

Publiser de endrede filene til GitHub Pages og følg `docs/CLOUDKIT-POC-TEST.md` strengt fra punkt 1 og videre.

## Miljø

```text
Container:      iCloud.com.longfjeld.tekstilig
Environment:    development
Pages:          https://longfjeld.github.io/Tekstilig/
Allowed Origin: https://longfjeld.github.io
```

Production skal ikke konfigureres eller deployes ennå.
