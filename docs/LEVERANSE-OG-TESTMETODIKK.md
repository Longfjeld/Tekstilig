# Tekstilig – fast leveranse- og testmetodikk

**Status:** Fast arbeidsflyt for videre SwiftUI-utvikling  
**Gjelder:** Alle nye kodeleveranser, feilrettinger, tester, Git-snapshots og komplette kildeopplastinger  
**Miljø:** Xcode 27 · iOS/iPadOS/macOS 27

Dette dokumentet beskriver den faste arbeidsformen for Tekstilig. Hensikten er å sikre at kode, dokumentasjon, testing og komplette snapshots alltid følger samme mønster og at det ikke oppstår tvil om hvilken versjon som er autoritativ.

## 1. Styrende dokumenter

Arbeidet følger disse dokumentene:

1. `SWIFTUI-IMPLEMENTERING.md` er **hovedsporet for implementering og test**.
2. Nye eller ikke-validerte testpunkter markeres **❗️**.
3. Et punkt endres først til **✅** etter at brukeren eksplisitt har bekreftet testen som OK.
4. Tester utføres **strengt sekvensielt i nummerrekkefølge**.
5. Et stoppunkt skal respekteres. Neste punkt startes ikke før foregående stoppbetingelse er oppfylt.
6. Roadmapet styrer hovedrekkefølgen frem mot 1.0, mens `SWIFTUI-IMPLEMENTERING.md` styrer de konkrete kode- og testiterasjonene.

## 2. Autoritativ kilde før ny hovedleveranse

Som hovedregel er den siste komplette filen:

```text
Tekstilig-SwiftUIActualApp00##.zip
```

den autoritative kildekoden for neste hovedleveranse.

Før kode endres skal det kontrolleres hvilken komplett ZIP som sist er lastet opp. En ny devpatch skal baseres på denne, med mindre det eksplisitt er avtalt at en mindre korrigering bygges direkte oppå en allerede levert devpatch.

Hvis det er uklart om siste komplette kode er tilgjengelig, skal ny funksjonell kode ikke lages før dette er avklart.

## 3. Format for kodeleveranser

Normale inkrementelle leveranser heter:

```text
Tekstilig-devpatch-00##.zip
```

Patchen skal:

1. bevare samme relative mappestruktur som prosjektroten
2. bare inneholde filer som faktisk skal legges til eller erstattes
3. ikke flytte filer unødvendig
4. ikke inkludere tilfeldige Xcode-brukerfiler eller andre lokale artefakter
5. ikke endre annen logikk enn det aktuelle steget krever
6. inneholde oppdatert `docs/SWIFTUI-IMPLEMENTERING.md` når leveransen introduserer eller endrer implementerings-/testpunkter

Eksempel på korrekt relativ filplassering:

```text
Tekstilig-devpatch-00##/
├── docs/
│   └── SWIFTUI-IMPLEMENTERING.md
└── Tekstilig/
    └── Features/
        └── ...
```

Filer skal aldri legges under en alternativ rot bare fordi filnavnet er riktig.

## 4. Brukerens faste rsync-prosess

Brukeren laster ned ZIP-filen og pakker den ut i `Downloads`.

Først kjøres alltid en dry-run:

```bash
rsync -av --dry-run --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-00##/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

Deretter kjøres faktisk synkronisering:

```bash
rsync -av --itemize-changes \
"/Users/persteinar/Downloads/Tekstilig-devpatch-00##/" \
"/Users/persteinar/Library/Mobile Documents/com~apple~CloudDocs/Koding/GitHub/Tekstilig/"
```

Konsekvens for alle leveranser: patchen må være laget slik at denne operasjonen er trygg. Brukeren skal ikke måtte gjette hvilke filer som skal flyttes, slettes eller plasseres manuelt, med mindre et eksplisitt nummerert test-/oppryddingspunkt sier det.

## 5. Build og test

Etter rsync:

1. åpner brukeren prosjektet i Xcode 27
2. bygger appen
3. kjører appen på testenheten som er angitt i `SWIFTUI-IMPLEMENTERING.md`
4. gjennomfører testene **i nøyaktig nummerrekkefølge**
5. stopper ved første test som feiler eller ved uttrykkelig stoppunkt
6. rapporterer resultatet

Hvis et tidlig punkt feiler, skal senere testpunkter ikke antas validert.

## 6. Feilrettinger mellom komplette snapshots

Ved en avgrenset feil kan en mindre korrigering leveres uten at brukeren først laster opp en ny komplett kode-ZIP.

Da gjelder:

1. korrigeringen skal være minimal
2. den skal bygges på den klart identifiserte koden + eventuelle allerede implementerte devpatcher
3. nødvendige testpunkter i `SWIFTUI-IMPLEMENTERING.md` skal oppdateres
4. eksisterende funksjonslogikk utenfor feilen skal ikke omskrives
5. når feilen er validert fortsetter hovedsporet fra neste ufullførte testpunkt

## 7. Etter validert leveranse

Som hovedregel lager brukeren et nytt komplett snapshot etter vellykket implementasjon og test:

```bash
git status
git add .
git diff --cached
git commit -m "SwiftUIActualApp00##"
git push
```

Deretter:

```bash
git archive --format=zip --output=../Tekstilig-SwiftUIActualApp00##.zip HEAD
```

Den komplette ZIP-filen lastes så opp i prosjektet. Denne blir normalt autoritativ kilde for neste hovediterasjon.

## 8. Dokumentasjon av progresjon

`SWIFTUI-IMPLEMENTERING.md` skal alltid gjøre det tydelig:

1. hva som sist er validert
2. hvilken devpatch som hører til testene
3. hvilke punkter som er ✅
4. hvilke punkter som er ❗️
5. hvilket eksakt punkt arbeidet skal fortsette fra
6. eventuelle observasjoner som ikke blokkerer videre arbeid
7. eventuelle stoppbetingelser før neste punkt

Det skal ikke være nødvendig å rekonstruere gjeldende progresjon fra chatloggen alene.

## 9. Endringer i arbeidsmetodikken

Arbeidsmetodikken skal ikke endres implisitt.

Hvis en annen leveranseform, filstruktur, testmåte eller dokumentasjonsmåte foreslås, skal dette forklares og avtales **før** leveransen lages.

Inntil en slik endring er eksplisitt godkjent, gjelder dette dokumentet og den etablerte devpatch/rsync/SWIFTUI-IMPLEMENTERING/Git-snapshot-flyten.

## 10. Fast sjekkliste før en devpatch leveres

Før en ny `Tekstilig-devpatch-00##.zip` leveres skal følgende være kontrollert:

- [ ] korrekt autoritativ kilde er brukt
- [ ] patchnummeret er nytt og sekvensielt
- [ ] bare nødvendige filer er med
- [ ] relative paths er kontrollert mot prosjektroten
- [ ] `SWIFTUI-IMPLEMENTERING.md` er oppdatert når test/progresjon endres
- [ ] nye tester er merket ❗️
- [ ] tidligere tester er bare merket ✅ når brukeren faktisk har validert dem
- [ ] testene står i faktisk utførelsesrekkefølge
- [ ] handling kommer før kontroll/stoppbetingelse
- [ ] stoppunktet peker tydelig på neste tillatte steg
- [ ] patchen kan legges inn med brukerens faste rsync-kommando uten manuell omstrukturering
