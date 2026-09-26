# CloudKit PoC – sekvensiell test

**Status:** Klar for test  
**Miljø:** Development

Denne veiledningen skal følges strengt i nummerrekkefølge. Fullfør hvert punkt før du går videre.

Statusmarkeringer:

- ❗️ gjenstår
- ✅ utført

## 1. Publiser kodeendringen

**❗️ AKSJON – DU**

1. Kopier filene fra endringspakken over tilsvarende filer i repositoryet.
2. Kontroller `git diff`.
3. Commit endringen.
4. Push til GitHub.
5. Vent til GitHub Pages-deploy er ferdig.

Ikke gå videre før Pages viser den nye overskriften **CloudKit PoC 0002**.

## 2. Åpne PoC-en fra korrekt adresse

**❗️ AKSJON – DU**

Åpne:

```text
https://longfjeld.github.io/Tekstilig/
```

Kontroller at seksjonen **CloudKit-miljø** viser:

```text
CloudKit JS:  Lastet
Container:    iCloud.com.longfjeld.tekstilig
Miljø:        development
Web-origin:   https://longfjeld.github.io
```

Hvis origin avviker, stopp testen.

## 3. Logg inn med iCloud

**❗️ AKSJON – DU**

1. Bruk Apple-knappen under **Logg inn med iCloud**.
2. Fullfør Apples innlogging.
3. Kontroller at status blir **Innlogget**.
4. Kontroller at `userRecordName` vises.

Hvis innloggingen feiler, stopp og kopier feilen fra PoC-loggen.

## 4. Opprett Textile

**❗️ AKSJON – DU**

1. Behold testverdiene eller skriv egne.
2. Trykk **Opprett Textile** én gang.
3. Kontroller at PoC-loggen sier at `Textile` ble opprettet.
4. Noter `recordName` som vises.

Development kan opprette første schema just-in-time når den første recorden lagres. Hvis CloudKit avviser schema/felter, stopp og send hele feilmeldingen.

## 5. Les Textile tilbake

**❗️ AKSJON – DU**

1. Trykk **Les Textile**.
2. Kontroller at samme `recordName` returneres.
3. Kontroller at `textileId`, `name`, `category`, `createdAt`, `updatedAt` og `schemaVersion` vises i JSON-panelet.

## 6. Endre Textile

**❗️ AKSJON – DU**

1. Trykk **Endre navn og lagre**.
2. Kontroller at navnet får suffikset `· oppdatert`.
3. Kontroller at lagringen lykkes uten konfliktfeil.

Dette validerer oppdatering med CloudKit sin `recordChangeTag`.

## 7. Opprett Piece

**❗️ AKSJON – DU**

1. Kontroller Piece-ID, bredde og lengde.
2. Trykk **Opprett Piece**.
3. Kontroller at en `Piece`-record opprettes og får et `recordName`.

## 8. Velg eller fotografer et bilde

**❗️ AKSJON – DU**

1. Trykk **Velg bilde / åpne kamera**.
2. På iPhone/iPad: ta gjerne et nytt bilde.
3. Kontroller at forhåndsvisning, filstørrelse og MIME-type vises.

For denne PoC-en bør du bruke et vanlig bilde med moderat størrelse.

## 9. Lagre TextileImage som CloudKit Asset

**❗️ AKSJON – DU**

1. Trykk **Lagre TextileImage**.
2. Vent til operasjonen er ferdig.
3. Kontroller at `TextileImage` får et `recordName`.
4. Kontroller at PoC-loggen rapporterer vellykket Asset-lagring.

Hvis denne operasjonen feiler, stopp og kopier hele feilmeldingen.

## 10. Les bildet tilbake

**❗️ AKSJON – DU**

1. Trykk **Les bilde tilbake**.
2. Kontroller at bildet vises i seksjonen som bilde hentet fra CloudKit.
3. Kontroller at loggen sier at Asset-URL ble lest tilbake.

## 11. Test på en annen Apple-enhet

**❗️ AKSJON – DU**

1. Åpne samme Pages-adresse på en annen Apple-enhet.
2. Logg inn med **samme iCloud-konto**.
3. PoC-en lagrer test-recordenes CloudKit `recordName` lokalt i nettleseren, så knappene for direkte oppslag kjenner ikke automatisk ID-ene fra den første enheten.
4. For denne første PoC-runden er derfor selve kryssenhetstesten godkjent når innloggingen fungerer på enhet 2. Server-side søk/synk for å finne eksisterende records blir neste implementering etter at steg 1–10 er validert.

## 12. Rapporter resultatet

**❗️ AKSJON – DU**

Send tilbake status i denne formen:

```text
1 Publisering:       OK / FEIL
2 CloudKit config:   OK / FEIL
3 iCloud login:      OK / FEIL
4 Create Textile:    OK / FEIL
5 Fetch Textile:     OK / FEIL
6 Update Textile:    OK / FEIL
7 Create Piece:      OK / FEIL
8 Velg bilde:        OK / FEIL
9 Save Asset:        OK / FEIL
10 Fetch Asset:      OK / FEIL
11 Enhet 2 login:    OK / FEIL
```

Ved feil: ta med teksten fra PoC-loggen og hvilket nummer testen stoppet på. Ikke fortsett forbi første feil.
