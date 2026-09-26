# Tekstilig

Tekstilig er et tekstilregister for registrering, søk og filtrering av tekstiler til syprosjekter.

## Arkitekturstatus

CloudKit er valgt som primær produksjonslagring. CloudKit JS/PWA-PoC-en har validert autentisering og strukturerte records i privat Development-database, men Asset-opplasting stoppet på CORS/preflight i nettleseren.

Neste klientspor er derfor **SwiftUI med native CloudKit**, mot samme container og schema. PWA-en beholdes som PoC/referanse.

`tekstiler.json` beholdes som planlagt eksport-/backupformat, ikke som primær database.

## Dokumentasjon

- `ARKITEKTUR.md` – teknisk arkitektur og lagringsprinsipper
- `DATAMODELL.md` – autoritativ logisk datamodell
- `BESLUTNINGSLOGG.md` – beslutninger og begrunnelser
- `UX-FLYTER.md` – hovedskjermer, navigasjon og brukerflyter
- `CLOUDKIT-OPPSETT.md` – kontoer, container, token og GitHub Pages-forberedelser
- `CLOUDKIT-POC-TEST.md` – resultatlogg fra avsluttet CloudKit JS/PWA-PoC
- `SWIFTUI-OPPSTART.md` – sekvensiell oppstart av native SwiftUI/CloudKit-PoC
- `ENDRINGSLOGG.md` – endringer mellom leveranser

## Status

CloudKit JS/PWA-PoC-en er avsluttet. Neste handling er punkt 1 i `SWIFTUI-OPPSTART.md`. Første SwiftUI-kodeleveranse lages etter at punktene 1–5 er bekreftet.
