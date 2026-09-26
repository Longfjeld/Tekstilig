# Tekstilig – dokumentasjon

Tekstilig er et tekstilregister i tidlig utvikling. CloudKit er valgt som primærlager, og aktivt klientspor er nå SwiftUI med native CloudKit. Den tidligere PWA-en beholdes som teknisk PoC/referanse.

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

Punkt 1–5 i `SWIFTUI-OPPSTART.md` er fullført. Neste handling er punkt 6: kjør den leverte native CloudKit-diagnostikken og bekreft både resultatet i appen og testrecorden i privat Development-database.

Full produkt-UI og Production-deploy skal ikke startes før den native CloudKit-valideringen, inkludert `CKAsset`, er ferdig.
