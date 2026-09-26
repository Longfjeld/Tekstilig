# Tekstilig – dokumentasjon

Tekstilig er et tekstilregister i tidlig utvikling. CloudKit er valgt som primærlager, og aktivt klientspor er SwiftUI med native CloudKit. Den tidligere PWA-en er frosset og beholdes kun som teknisk PoC/referanse.

## Autoritative dokumenter

- `ARKITEKTUR.md` – teknisk arkitektur, lagringsprinsipper og klientspor
- `DATAMODELL.md` – autoritativ logisk datamodell
- `DESIGN.md` – autoritativ visuell design- og typografiretning
- `UX-FLYTER.md` – hovedskjermer, navigasjon og brukerflyter
- `BESLUTNINGSLOGG.md` – beslutninger og begrunnelser

## Oppsett og test

- `CLOUDKIT-OPPSETT.md` – kontoer, container, token og tidligere GitHub Pages-forberedelser
- `CLOUDKIT-POC-TEST.md` – resultatlogg fra avsluttet CloudKit JS/PWA-PoC
- `SWIFTUI-OPPSTART.md` – strengt sekvensiell oppstart og validering av native SwiftUI/CloudKit-PoC

## Historikk

- `ENDRINGSLOGG.md` – endringer mellom dokumentasjons- og kodeleveranser

## Status

Punkt 1–6 i `SWIFTUI-OPPSTART.md` er fullført. Punkt 7 er neste handling: valider `TextileImage` + `CKAsset` på fysisk iPhone/iPad ved å lagre, hente og vise samme bildefil fra privat Development-database.

PWA-koden skal ikke videreutvikles i denne fasen. Full produkt-UI og Production-deploy starter ikke før den native CloudKit-valideringen er ferdig.
