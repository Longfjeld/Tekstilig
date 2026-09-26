# Tekstilig

Tekstilig er et tekstilregister for registrering, søk og filtrering av tekstiler til syprosjekter.

## Arkitekturstatus

CloudKit er valgt som primær produksjonslagring. GitHub Pages/PWA brukes nå som PoC-klient. En senere SwiftUI-app kan kobles til samme CloudKit-container, schema og data.

`tekstiler.json` beholdes som planlagt eksport-/backupformat, ikke som primær database.

## Dokumentasjon

- `ARKITEKTUR.md` – teknisk arkitektur og lagringsprinsipper
- `DATAMODELL.md` – autoritativ logisk datamodell
- `BESLUTNINGSLOGG.md` – beslutninger og begrunnelser
- `UX-FLYTER.md` – hovedskjermer, navigasjon og brukerflyter
- `CLOUDKIT-OPPSETT.md` – kontoer, container, token og GitHub Pages-forberedelser
- `CLOUDKIT-POC-TEST.md` – sekvensiell test av CloudKit-PoC-en
- `ENDRINGSLOGG.md` – endringer mellom leveranser

## Status

CloudKit-forhåndsoppsettet er ferdig. Neste milepæl er å publisere kodeleveranse 0002 og validere CloudKit-PoC-en i Development.
