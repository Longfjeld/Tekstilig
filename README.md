# Tekstilig – kodeleveranse 0001

Dette er første komplette kodeleveranse og en teknisk lagringsprototype.

## Formål

Før resten av appen bygges, skal denne versjonen verifisere hva som faktisk fungerer på Mac, iPhone og iPad:

- opprette/åpne `tekstiler.json`
- skrive og lese datamodell v1
- velge/fotografere og lagre et testbilde
- oppdage nettleserens lagringsmuligheter
- teste PWA/offline-grunnlag

## Viktig om Safari og iCloud

Safari støtter ikke `showDirectoryPicker()`. En ren webapp kan derfor ikke få permanent direkte tilgang til en vilkårlig valgt iCloud Drive-katalog på samme måte som Chromium på desktop.

Prototypen har derfor to lagringsmodi:

1. **Direkte katalogmodus** der `showDirectoryPicker()` finnes.
2. **OPFS-modus** i Safari/iOS, med eksplisitt eksport/import av `tekstiler.json`.

Dette er med hensikt en prototype for å avgjøre endelig lagringsstrategi før resten av appen bygges.

## Kjøring

Appen må serveres over HTTPS eller localhost for PWA/service worker og flere fil-API-er.

For GitHub Pages kan innholdet i denne ZIP-en legges i repositoryet og publiseres direkte.

## Testrekkefølge

1. Åpne appen.
2. Kontroller hvilken lagringsmodus som vises.
3. Trykk **Klargjør lagring**.
4. Trykk **Skriv testdata**.
5. Trykk **Les tekstiler.json**.
6. Velg eller fotografer et bilde og trykk **Lagre testbilde**.
7. På Safari/iOS: test **Eksporter tekstiler.json** og lagre den i iCloud Drive via systemets delings-/filgrensesnitt.
8. Test import av samme fil.

Noter resultatene separat for Mac, iPhone og iPad.
