# Endringslogg

## Dokumentasjon 0001 – 2026-09-13

Første dokumentasjonspakke for Tekstilig.

### Opprettet

- `README.md`
- `ARKITEKTUR.md`
- `DATAMODELL.md`
- `BESLUTNINGSLOGG.md`
- `ENDRINGSLOGG.md`

### Fastlagt

- lokal-first PWA/webapp
- GitHub/GitHub Pages for programkode
- privat JSON- og bildelagring i lokal/iCloud-katalog
- datamodell v1
- separate fysiske stoffstykker
- strukturerte material-, farge-, vedlikeholds-, elastisitets- og krympdata
- valgfri prisinformasjon
- reservasjon per stoffstykke
- visuell retning og designprinsipper
- arbeidsdeling mellom mobil/iPad og Mac
- sekvensiell ZIP-basert leveransemodell

### Applikasjonskode

Ingen applikasjonskode er levert i denne versjonen.


## Dokumentasjon 0002 – 2026-09-13

UX-grunnlaget og hovedbrukerflytene er konkretisert.

### Ny fil

- `UX-FLYTER.md`

### Endret

- `README.md` – lagt til UX-dokumentasjon og oppdatert status
- `BESLUTNINGSLOGG.md` – lagt til beslutninger B-017 til B-021
- `ENDRINGSLOGG.md` – denne leveransen

### Fastlagt

- fire hovedområder i navigasjonen
- stoffbibliotek som primær startflate
- innhold og interaksjon i tekstilkort
- søk og filterstruktur
- tekstildetalj og håndtering av stoffstykker
- hurtigregistrering med progressiv detaljering
- mobil/iPad-flyt for fotografering
- prosjektsøk med forklarbare treff
- reservasjon og grunnleggende beholdningsredigering
- forskjeller mellom mobil/iPad og Mac
- tomme tilstander, feil og grunnleggende tilgjengelighet
- anbefalt implementeringsrekkefølge

### Applikasjonskode

Ingen applikasjonskode er levert i denne versjonen.

## Kodeleveranse 0001 – 2026-09-13

Første komplette kodeleveranse.

### Opprettet

- teknisk PWA-prototype
- nettleserdeteksjon for katalogtilgang og OPFS
- abstrahert lagringslag
- oppretting/lesing/skriving av `tekstiler.json`
- testdata basert på datamodell v1
- bildevalg/kamerainput og bildelagring
- Safari/iOS eksport/import av JSON
- service worker og manifest
- responsivt grensesnitt med valgt designretning

### Teknisk avklaring

Direkte bruker-valgt iCloud Drive-katalog kan ikke være eneste lagringsmekanisme for Safari/iPhone/iPad. Dette testes videre før endelig produksjonsarkitektur låses.
