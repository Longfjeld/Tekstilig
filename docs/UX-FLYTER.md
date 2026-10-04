# UX og brukerflyter

**Status:** UX-grunnlag v1  
**Dato:** 2026-09-13

Dette dokumentet beskriver hovedskjermer og sentrale brukerflyter i Tekstilig før implementering. Det beskriver struktur og prioritering, ikke endelig grafisk detaljutforming.

## 1. Overordnede prinsipper

Tekstilig skal være enkel, vakker og oversiktlig, med høy ytelse og minst mulig unødvendig friksjon.

Stoffbildene er det viktigste visuelle elementet. Appens øvrige grafikk skal være rolig og nøytral.

Vanlige oppgaver skal kreve få steg. Avanserte opplysninger og filtre skal være tilgjengelige uten å dominere standardvisningen.

## 2. Hovednavigasjon

Første versjon skal ha fire tydelige hovedområder:

1. **Tekstiler** – bibliotek, søk og filtrering
2. **Finn til prosjekt** – kriteriebasert søk etter egnet stoff
3. **Nytt tekstil** – rask registrering, spesielt på mobil/iPad
4. **Innstillinger** – datakatalog, visning og senere appinnstillinger

På mobil kan navigasjonen ligge nederst. På større skjermer kan den ligge i toppfelt eller sidefelt dersom det gir bedre utnyttelse av plassen.

## 3. Startside / stoffbibliotek

Stoffbiblioteket er appens primære startflate.

### Innhold

- appnavn og enkel toppnavigasjon
- tydelig fritekstsøk
- knapp for filtre
- knapp/lenke til «Finn til prosjekt»
- knapp for «Nytt tekstil»
- antall treff
- relativt store tekstilkort

### Kortvisning

Hvert kort viser som standard:

- hovedbilde
- navn
- viktigste materialinnhold
- tilgjengelig størrelse eller største tilgjengelige sammenhengende stykke
- eventuell diskret markering dersom noe er reservert

Eksempel:

```text
┌──────────────────────────┐
│                          │
│       STOFFBILDE         │
│                          │
├──────────────────────────┤
│ Marineblå ull            │
│ 80 % ull / 20 % poly.    │
│ 145 cm × 2,80 m          │
│ Delvis reservert         │
└──────────────────────────┘
```

### Søk

Fritekstsøket skal kunne søke i minst:

- navn
- beskrivelse
- materiale
- farge
- mønster
- tags
- egenskaper
- plassering
- notater

Resultatlisten oppdateres fortløpende så lenge ytelsen er god.

### Filtre

Filtre åpnes som et eget panel/sheet og skal minst kunne omfatte:

- materiale
- farge/fargegruppe
- kategori
- mønster
- egenskaper
- minimumsbredde
- minimumslengde på ett sammenhengende tilgjengelig stykke
- vektintervall
- elastisitet
- vedlikehold
- plassering
- tilgjengelig / helt eller delvis reservert

Aktive filtre skal være tydelige og enkle å nullstille.

## 4. Tekstildetalj

Når et tekstil åpnes, skal detaljsiden prioritere bildet først og deretter informasjon i tydelige grupper.

### Foreslått rekkefølge

1. hovedbilde og eventuelle øvrige bilder
2. navn, kategori, farge og materiale
3. tilgjengelige stoffstykker
4. egenskaper
5. elastisitet, vekt og krymp
6. vedlikehold
7. plassering
8. kjøpsinformasjon
9. notater
10. metadata ved behov

### Stoffstykker

Hvert stykke vises separat, for eksempel:

```text
Stykke 1
2,80 m × 145 cm
Tilgjengelig: 2,80 m

Stykke 2
1,80 m × 110 cm
Reservert 1,50 m til «Jakke til Kari»
Tilgjengelig: 0,30 m
```

Det skal være lett å:

- redigere et stykke
- legge til et nytt stykke
- registrere at deler er brukt
- reservere eller fjerne reservasjon

### Handlinger

Primære handlinger:

- Rediger
- Legg til stoffstykke
- Reserver

Sekundære handlinger, eksempelvis sletting, skal ligge mindre fremtredende for å redusere risikoen for feil.

## 5. Nytt tekstil

Registrering skal være optimalisert for telefon/iPad og direkte fotografering.

### Prinsipp

Brukeren skal kunne lagre et nytt tekstil raskt og komplettere informasjon senere.

### Første del – hurtigregistrering

Foreslått første skjerm:

1. **Ta bilde / velg bilde**
2. **Navn**
3. **Lengde og bredde** for første stoffstykke
4. **Materiale**
5. **Farge**
6. **Plassering**
   - Devpatch 0005 implementerer område/rom, hylle og beholder/kasse som valgfrie felt på Textile.

Bare navn må alltid være obligatorisk. Stoffstykke kreves når beholdningen er kjent.

### Andre del – flere detaljer

Et område «Flere detaljer» inneholder:

- kategori
- mønster
- flere stoffstykker
- vekt
- elastisitet
- krymp
- egenskaper
- vedlikehold
- pris/leverandør
- ekstra bilder
- tags
- beskrivelse/notater

### Lagre og fortsette

Brukeren skal kunne:

- lagre umiddelbart
- lagre og fortsette å redigere

Appen bør unngå tap av utfylt informasjon dersom brukeren navigerer bort ved et uhell. En usendt registrering bør derfor kunne beholdes midlertidig så langt nettlesermiljøet tillater det.

## 6. Fotografering

Fotografering er en kjerneflyt på mobil/iPad.

Når brukeren velger bilde, bør appen prioritere:

- direkte kamera som enkelt valg
- eksisterende bilde som alternativ
- automatisk nedskalering/optimalisering
- enkel forhåndsvisning før lagring

Det skal være mulig å legge til flere bilder senere og angi bildetype, eksempelvis stoffprøve eller vaskelapp.

### Implementeringsstatus 2026-09-27

Devpatch 0003 implementerer første produktversjon av hovedbilde på tekstildetaljen. Brukeren kan velge eller erstatte hovedbildet fra Bilder. Direkte kamera, flere bilder, thumbnails og lokal bildeoptimalisering er bevisst utsatt til senere bildesteg.

## 7. Finn stoff til prosjekt

Dette er en egen arbeidsflyt for når brukeren kjenner kravene til et prosjekt, men ikke hvilket stoff som skal brukes.

### Grunnskjema

Første versjon bør støtte:

- nødvendig sammenhengende lengde
- minimumsbredde
- materialer
- ønsket/akseptabel farge
- kategori
- vektintervall
- elastisitet og retning
- egenskaper
- vedlikeholdskrav

Alle kriterier skal være valgfrie.

Eksempel:

```text
Finn stoff til prosjekt

Lengde minst       [ 2,50 m ]
Bredde minst       [ 140 cm ]

Materiale          [ Ull      v ]
Elastisitet        [ Ingen    v ]
Vekt               [ 200 ] – [ 400 ] g/m²

[ Flere kriterier ]

[ Finn tekstiler ]
```

### Resultater

Resultatene bruker samme kortkomponenter som stoffbiblioteket.

De bør sorteres slik at tekstiler som best oppfyller kriteriene vises først. I første versjon kan dette være en enkel deterministisk sortering, ikke en «smart» anbefalingsmotor.

Et resultat skal tydelig vise hvorfor det passer, eksempelvis:

- «Stykke på 2,80 m × 145 cm»
- «80 % ull»
- «320 g/m²»

Tekstiler som ikke oppfyller absolutte krav skal normalt ikke vises.

## 8. Reservasjon til prosjekt

Fra tekstildetalj eller søkeresultat skal et tilgjengelig stykke kunne reserveres.

Foreslått flyt:

1. velg stoffstykke
2. angi prosjekt
3. angi reservert lengde
4. valgfri merknad
5. bekreft

Et delvis reservert stykke skal fortsatt kunne brukes i søk basert på gjenværende sammenhengende tilgjengelig lengde.

## 9. Redigering av beholdning etter bruk

Det må være enkelt å oppdatere lageret etter at stoff er klippet.

Første versjon bør minst støtte:

- endre lengde og bredde på eksisterende stykke
- slette et oppbrukt stykke
- dele et stykke i flere rester dersom det er nødvendig

En senere versjon kan tilby en egen «Registrer bruk»-flyt som automatiserer dette ytterligere.

## 10. Mobil/iPad

På mindre skjermer prioriteres:

- kamera
- store trykkflater
- én hovedoppgave om gangen
- bunnnavigasjon eller tilsvarende lett tilgjengelig navigasjon
- filterpanel som sheet/fullskjerm
- enkle kort i én eller få kolonner avhengig av skjermbredde

Registrering skal kunne gjennomføres uten presis musepeker eller små kontroller.

## 11. Mac / større skjerm

På større skjerm prioriteres:

- flere tekstilkort samtidig, men fortsatt relativt store bilder
- filterpanel som kan være permanent synlig når det er nyttig
- rask veksling mellom bibliotek og detalj
- effektiv redigering av mange felt
- tastaturvennlig søk

Appen skal fortsatt oppleves som den samme løsningen på alle enheter.

## 12. Tomme tilstander og førstegangsbruk

Appen må ha gode tomme tilstander.

Når ingen tekstiler finnes:

```text
Ingen tekstiler ennå

Registrer det første stoffet for å bygge biblioteket ditt.

[ + Nytt tekstil ]
```

Når et søk ikke gir treff:

- vis at ingen tekstiler passer
- vis aktive filtre/kriterier
- tilby «Nullstill filtre»

## 13. Feil og bekreftelser

Appen skal unngå unødvendige modalvinduer.

Bekreftelse kreves spesielt ved irreversible handlinger, for eksempel:

- sletting av tekstil
- sletting av bilde
- overskriving eller nullstilling av data

Vanlig lagring skal bekreftes diskret, ikke med en blokkerende dialog.

## 14. Tilgjengelighet

Selv om appen primært er privat, skal grunnleggende tilgjengelighetsprinsipper følges:

- tydelig kontrast
- ikke bruke farge alene som betydningsbærer
- store nok trykkflater
- synlig tastaturfokus
- semantiske kontroller og etiketter
- symboler ledsages av tekst der betydningen ellers kan være uklar

## 15. Første implementeringsomfang

Første fungerende versjon bør implementere følgende flyter i denne rekkefølgen:

1. velge/opprette datakatalog
2. lese og skrive `tekstiler.json`
3. vise stoffbibliotek
4. registrere nytt tekstil med hovedbilde og første stoffstykke
5. vise tekstildetalj
6. redigere tekstil og beholdning
7. fritekstsøk og grunnfiltre
8. prosjektsøk
9. reservasjon
10. videre vedlikeholds- og administrasjonsfunksjoner

Dette prioriterer teknisk risiko rundt lokal/iCloud-lagring tidlig, før resten av brukergrensesnittet blir omfattende.

## Implementeringsstatus – native produktfase 1

Kodeleveranse 0006 etablerer første fungerende del av de planlagte flytene:

```text
Tekstiler
  -> tekstilbibliotek
  -> tekstildetalj
  -> nytt tekstil
  -> rediger tekstil
```

Denne første UI-en er funksjonell struktur, ikke ferdig visuell implementering av kort, bilder, søk eller filtre. Den skal først validere apparkitektur og grunnleggende lagring. `DESIGN.md` og resten av dette dokumentet er fortsatt målbildet for den videre produktutviklingen.



## 17. Implementert Piece-flyt – devpatch 0002

Første native produktversjon av stoffstykker implementerer nå denne flyten fra tekstildetaljen:

```text
Tekstildetalj
    -> se stoffstykker
    -> legg til stoffstykke
    -> rediger stoffstykke
    -> valgfri reservasjon til prosjekt
    -> slett stoffstykke med bekreftelse
```

Visningen viser total lengde og bredde, og ved reservasjon både reservert og gjenværende tilgjengelig lengde. Dette er første funksjonelle beholdningssteg; senere UX for «registrer bruk», splitting av rester og rikere Piece-data beholdes som planlagt videreutvikling.


## 18. Implementert materiale- og fargeflyt – devpatch 0004

Tekstildetaljen får egne seksjoner for strukturerte materialer og farger.

Materialflyt:

```text
Tekstildetalj
    → Materialer
       → legg til standardmateriale eller eget materialenavn
       → valgfri prosentandel
       → rediger / slett
```

Fargeflyt:

```text
Tekstildetalj
    → Farger
       → velg fargegruppe
       → valgfritt beskrivende navn
       → valgfri #RRGGBB-verdi
       → rediger / slett
```

UI viser en liten fargeprøve når gyldig hex-verdi finnes, men tekstlig fargegruppe/navn beholdes alltid slik at farge ikke er eneste betydningsbærer.

## 19. Implementert vedlikeholdsflyt – devpatch 0008

Tekstildetaljen får en egen seksjon **Vedlikehold** mellom materiale/farge og plassering. Flyten er:

```text
Tekstildetalj
    → Vedlikehold
       → vask / temperatur / program
       → bleking
       → tørketrommel
       → annen tørking
       → stryking
       → rens
       → valgfri merknad
       → lagre / rediger
```

Alle delområder kan stå uregistrert. UI skal tydelig skille «ikke registrert» fra eksplisitt «ikke tillatt». Detaljvisningen viser semantisk symbolmarkør og forklarende tekst slik at symbol alene aldri er eneste betydningsbærer.

Første native implementering bruker system-/tekstmarkører som funksjonell representasjon. Endelig grafikk for standardiserte vaskesymboler og eventuelt bilde av vaskelapp kommer senere.

### UX-observasjoner etter første prosjektsøk

Følgende skal tas med i senere UX-/ytelsesopprydding:

- lokale Textile-/materiale-/farge-/Piece-indekser må vurderes samlet fordi appstart er observert som tregere
- numeriske felt i prosjektsøk har hatt merkbar forsinkelse ved første fokus
- prosjektsøk skal automatisk få ferske Piece-data etter endringer; manuell pull-to-refresh skal ikke være nødvendig for korrekt resultat
- når en visuell rad representerer én handling eller ett valg, skal hele raden være trykkbar, også for Piece-rader og tilsvarende editorrader

### UX-/ytelsesopprydding – devpatch 0051

Før videre utvidelse av prosjektsøket gjennomføres en mobilrettet opprydding basert på observasjonene fra test 104–122:

- **Finn til prosjekt** skal ikke gjøre tunge child-record-kall før fanen faktisk åpnes.
- Når brukeren kommer tilbake til **Finn til prosjekt**, skal relevant datagrunnlag oppdateres uten krav om manuell pull-to-refresh.
- En Piece-endring eller reservasjon som allerede er lagret lokalt skal reflekteres direkte i aktive søkeresultater.
- Numeriske søkefelt skal reagere raskt på første trykk og fortsatt ha tydelig **Ferdig**-handling for talltastaturet.
- Når en rad representerer én handling, er hele raden trykkbar. Dette gjelder blant annet Piece-rader og dimensjonsrader i Piece-editoren.

### Utvidede prosjektkriterier – devpatch 0052

Etter validert UX-/ytelsesopprydding utvides **Finn til prosjekt** med flere allerede strukturerte tekstilegenskaper uten å endre CloudKit-modellen:

- farge velges som **fargegruppe**, ikke fritekst, slik at kravet er deterministisk
- elastisitet kan kreve både nivå og retning; **Ingen** elastisitet kan ikke kombineres med en retning
- maksimumskrav til krymp vurderer både lengde- og breddekrymp, og manglende data regnes ikke som dokumentert oppfyllelse
- første vedlikeholdskrav begrenses til vaskbarhet og minimum tillatt vasketemperatur
- ved aktivt vasketemperaturkrav må tekstilet eksplisitt være vaskbart og ha registrert temperatur
- alle aktive prosjektkrav kombineres som AND-kriterier
- resultatraden skal forklare relevante egenskaper som gjorde at et stoff traff
- eksisterende deterministiske sortering beholdes; «best fit»/egnethetsrangering behandles som en senere separat blokk

I Piece-editoren skal fokus på et eksisterende lengde- eller breddefelt plassere markøren etter eksisterende tall, slik at brukeren kan fortsette å skrive uten først å flytte innsettingspunktet manuelt.


### Søkefeedback og første egnethetsrangering – devpatch 0053

Etter validering av test 132–140 forbedres **Finn til prosjekt** uten å endre datamodellen:

- **Finn tekstiler** skal gi umiddelbar visuell feedback ved hvert trykk; første implementering bruker søkeikon med kort systemanimasjon
- når prosjektet har minimumslengde, prioriteres det passende stoffstykket som har minst overskytende tilgjengelig lengde
- når både lengde og bredde er krav, brukes minst breddeoverskudd som sekundært kriterium
- når bare bredde er dimensjonskrav, prioriteres minst breddeoverskudd
- samme forståelige best-fit-prinsipp brukes i rekkefølgen mellom tekstiltreff
- resultatraden viser hvor mye ekstra lengde/bredde treffet har mot prosjektkravet
- uten dimensjonskrav beholdes eksisterende stabile, deterministiske rekkefølge
- dette er ikke en generell poengscore eller smart anbefalingsmotor; filtrering er fortsatt absolutte AND-krav og rangeringen kan forklares direkte fra dimensjonene

### Finn tekstiler – trykkfeedback

Knappen **Finn tekstiler** skal beholde sin etablerte tekst/layout og gi en kort, tydelig visuell puls ved hvert trykk. Feedbacken skal ikke flytte innhold eller påvirke skillelinjer i skjemaet.
