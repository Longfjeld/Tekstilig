# Tekstilig

Tekstilig er en lokal-first webapp/PWA for registrering, søk og filtrering av tekstiler til bruk i syprosjekter.

## Formål

Appen skal gjøre det enkelt å svare på spørsmål som:

- Hvilke tekstiler har vi?
- Hvor ligger et bestemt stoff?
- Har vi et stoff med riktig materiale, størrelse og egenskaper til et prosjekt?
- Hvor mye sammenhengende stoff er tilgjengelig?
- Er deler av beholdningen allerede reservert?

## Hovedprinsipper

- Programkoden kan publiseres via GitHub/GitHub Pages.
- Private tekstildata skal ikke publiseres i GitHub.
- Data og bilder lagres lokalt i en bruker-valgt katalog, primært i iCloud Drive.
- Appen skal fungere godt på mobil/iPad ved registrering og oppslag.
- Mac skal være godt egnet til administrasjon, redigering og mer omfattende søk.
- Stoffbildene skal være det viktigste visuelle elementet.

## Dokumentasjon

- `ARKITEKTUR.md` – teknisk arkitektur og lagringsprinsipper
- `DATAMODELL.md` – autoritativ datamodell
- `BESLUTNINGSLOGG.md` – beslutninger og begrunnelser
- `UX-FLYTER.md` – hovedskjermer, navigasjon og brukerflyter
- `ENDRINGSLOGG.md` – endringer mellom leveranser

## Status

Dokumentasjon 0002 etablerer også UX-grunnlaget og hovedflytene. Applikasjonskode er ikke opprettet ennå.


## CloudKit

CloudKit er nå valgt som primær produksjonslagring. Se:

- `CLOUDKIT-OPPSETT.md` – kontoer, tilganger, CloudKit Console, API-token, GitHub Pages og PoC-forberedelser
- `ARKITEKTUR.md` – oppdatert arkitektur for PWA + mulig SwiftUI-klient mot samme CloudKit-container

`tekstiler.json` er fortsatt del av datamodellens eksport-/backupformat, men er ikke lenger planlagt som primær produksjonsdatabase.
