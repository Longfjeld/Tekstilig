# Arbeidsmetodikk for Tekstilig

Dette dokumentet er den faste arbeidsmetodikken for videre utvikling av Tekstilig. Les dette dokumentet sammen med `SWIFTUI-IMPLEMENTERING.md` før en ny kodeendring eller funksjonsblokk startes.

## 1. Autoritativt kodegrunnlag

1. Før kode endres skal siste komplette kodeversjon som er lastet opp i prosjektet identifiseres og kontrolleres.
2. Nye devpatcher skal bygges på denne versjonen, ikke på en eldre lokal kopi eller en tidligere patchserie.
3. Hvis det er uklart hvilken komplette kodeversjon som er nyest, skal arbeidet stoppe til dette er avklart.

## 2. Hovedspor for implementasjon og testing

1. `SWIFTUI-IMPLEMENTERING.md` er den sekvensielle arbeids- og testplanen.
2. Arbeidet utføres i stigende punktrekkefølge. Et senere punkt skal ikke brukes som erstatning for et ufullført tidligere punkt.
3. Nye eller ikke-validerte punkter markeres med **❗️**.
4. Et punkt endres til **✅** først når testen/handlingen er gjennomført og brukeren har bekreftet resultatet som OK.
5. Instruksjonen som gjør en kontroll mulig skal alltid komme før kontrollen eller stoppbetingelsen.
6. En funksjonsblokk avsluttes med et eksplisitt stoppunkt før neste produktområde startes.

## 3. Avvik ved konkret feil

Hvis et nummerert testpunkt avdekker en konkret feil:

1. Hovedsporet stoppes på det aktuelle punktet.
2. Feilen isoleres med målrettede, små ad-hoc endringer og tester.
3. Det endres minst mulig om gangen slik at årsak og virkning kan skilles.
4. Eksisterende stabil funksjonalitet skal ikke bygges om uten at feilisoleringen krever det.
5. Når problemet er løst og validert, avsluttes ad-hoc-sporet.
6. Arbeidet går tilbake til det samme eller neste ufullførte nummererte punktet i `SWIFTUI-IMPLEMENTERING.md`.
7. Relevante funn og permanente arkitektur-/kodeendringer dokumenteres før hovedsporet fortsetter.

Ad-hoc testing i chat er dermed et midlertidig feilsøkingsverktøy, ikke den normale testplanen.

## 4. Devpatcher

1. Endringer leveres normalt som `Tekstilig-devpatch-00xx.zip`.
2. ZIP-filen skal pakke ut til en toppmappe med samme navn, for eksempel `Tekstilig-devpatch-0042/`.
3. Under toppmappen skal filene ha samme relative plassering som i prosjektet, for eksempel `Tekstilig/Features/...` og `docs/...`.
4. Patchen skal bare inneholde filer som faktisk må legges til eller erstattes.
5. ZIP-strukturen kontrolleres før levering.
6. Endrede Swift-filer syntakskontrolleres når dette er praktisk mulig. En slik kontroll erstatter ikke Xcode-build og testing på målplattformen.

## 5. Validering

1. Xcode-build er første tekniske kontroll etter en kodepatch.
2. Funksjonstester følger deretter nøyaktig rekkefølgen i `SWIFTUI-IMPLEMENTERING.md`.
3. Fysisk iPhone/iPad brukes når enhetsspesifikk SwiftUI-, CloudKit-, foto- eller livsløpsadferd er relevant.
4. Simulator kan brukes når den gir tilstrekkelig validering og fysisk enhet ikke er nødvendig.
5. Tidligere validerte funksjoner regresjonstestes når en ny blokk kan påvirke dem.
6. Et punkt regnes ikke som fullført bare fordi koden bygger; brukerens eksplisitte testbekreftelse lukker punktet.

## 6. Dokumentasjon

Ved hver funksjonsblokk vurderes minst:

- `SWIFTUI-IMPLEMENTERING.md` – teststatus og neste sekvens
- `ENDRINGSLOGG.md` – hva patchen endrer
- relevante arkitektur-, data- eller UX-dokumenter dersom beslutninger eller modell endres

Dokumentasjonen skal beskrive faktisk implementert tilstand. Planlagte funksjoner skal ikke fremstilles som ferdige.

## 7. Bevaring av eksisterende funksjonalitet

1. En ny funksjonsblokk skal være så avgrenset som mulig.
2. Tidligere validerte Textile-, Piece-, bilde-, materiale/farge-, plassering-, vedlikeholds-, fysiske egenskaps- og søkefunksjoner skal bevares med mindre blokken eksplisitt endrer dem.
3. Nye CloudKit-felt eller indekser opprettes bare når den aktuelle funksjonen faktisk trenger dem.
4. Ved tvil velges den minste reversible endringen først.

## 8. Fast startprosedyre for videre arbeid

Før neste utviklingssteg:

1. Finn og kontroller siste komplette opplastede kodeversjon.
2. Les dette dokumentet.
3. Les status og neste ufullførte punkt i `SWIFTUI-IMPLEMENTERING.md`.
4. Kontroller relevante produktkrav i `UX-FLYTER.md`, `DATAMODELL.md` og/eller `ARKITEKTUR.md`.
5. Implementer bare den avgrensede blokken som følger av planen.
6. Lever patch og la testpunktene stå **❗️** frem til brukeren har validert dem.
