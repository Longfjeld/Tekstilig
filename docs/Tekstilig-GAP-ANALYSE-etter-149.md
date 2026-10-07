# Tekstilig – gap-analyse etter punkt 149

**Kodegrunnlag:** Tekstilig-SwiftUIActualApp0024  
**Status:** Test 141–149 validert OK  
**Formål:** Kartlegge gjenstående planlagt funksjonalitet, UX-forbedringer og tekniske steg fram mot versjon 1.0 og senere utvikling.

## 1. Sammendrag

Etter test 141–149 er kjernen i «Finn til prosjekt» i praksis godt utbygget. Appen har nå strukturerte prosjektkrav, Piece-basert tilgjengelig mengde, reservasjon, forklarbare treff og deterministisk best-fit-rangering på dimensjoner.

De viktigste gjenstående områdene før en versjon 1.0 er derfor ikke flere søkekriterier, men robusthet rundt iCloud/CloudKit, eksport/import, bildehåndtering, produksjonsklargjøring og en samlet validering på fysiske enheter.

Større funksjonelle utvidelser som flere samtidige reservasjoner per Piece, «Registrer bruk», full lokal cache/offline-modell og CloudKit-deling bør fortsatt behandles som egne senere utviklingsblokker.

## 2. Bør fullføres før versjon 1.0

|navn|verdi|
|:---|:---|
|iCloud-/offline-status|Appen bør oppdage og forklare når iCloud, iCloud Drive eller CloudKit ikke er tilgjengelig, i stedet for å kunne fremstå som om den bare fortsetter å laste.|
|Eksport / backup|Det bør finnes en lesbar eksport av tekstildata og tilhørende bilder slik at brukeren har en uavhengig sikkerhetskopi av samlingen.|
|Import / restore|Eksportformatet bør kunne brukes til å gjenopprette data. Dette kan implementeres etter at eksportformatet er definert og stabilisert.|
|Direkte kamera|Bildearbeidsflyten bør kunne bruke kamera direkte, ikke bare eksisterende bilder fra bildebiblioteket.|
|Bildeoptimalisering|Bilder bør vurderes nedskalert/optimalisert før lagring slik at unødvendig store originalfiler ikke belaster lokal lagring, nettverk og CloudKit.|
|Tomme tilstander og feiltilstander|Det bør gjøres en samlet gjennomgang av tomt bibliotek, ingen søkeresultater, nettverksfeil, CloudKit-feil og andre forventede feiltilstander.|
|Release-opprydding|Debug- og diagnostikkfunksjoner må gjennomgås slik at Release-versjonen ikke inneholder utviklerfunksjoner som ikke skal distribueres.|
|CloudKit Production|Development-schema må gjennomgås og deployes korrekt til Production før ordinær distribusjon.|
|Helhetlig fysisk enhet-test|CRUD, bilder, søk, reservasjon, synkronisering og feiltilstander bør sluttvalideres på relevante iPhone-, iPad- og Mac-enheter.|

### Vurdering

Den største tekniske gjenstående oppgaven før 1.0 er robust datatilgang og produksjonsklargjøring, ikke ytterligere utbygging av «Finn til prosjekt».

## 3. Flere bilder per tekstil

Datamodellen og arkitekturen er laget med tanke på rikere bildehåndtering, mens dagens brukergrensesnitt primært håndterer ett hovedbilde.

Planlagt videre funksjonalitet omfatter:

- flere bilder per tekstil
- bildetype, for eksempel stoffprøve, nærbilde, vaskelapp, hele stoffet eller annet
- valg av hovedbilde
- thumbnails
- sletting av enkeltbilder
- direkte kamera

Dette bør behandles som et eget vertikalsnitt slik at datamodell, CloudKit, bildebehandling og brukergrensesnitt kan testes samlet.

## 4. Rikere Piece-data

Dagens Piece-modell dekker de viktigste behovene for fysisk stoffstykke og reservasjon, men den langsiktige modellen kan utvides med mer informasjon.

Mulige senere felt omfatter:

- rikere mengdeinformasjon
- notat
- mer detaljert lagerinformasjon

Dette vil kunne kreve CloudKit-schemaendringer og bør derfor gjøres som en separat blokk.

## 5. Splitting av stoffrester

En nyttig videre Piece-funksjon er å kunne dele ett eksisterende stoffstykke i flere rester.

Eksempel:

```text
280 × 145 cm
    ↓ klippes
170 × 145 cm
55 × 60 cm
```

Aktuelle operasjoner blir da:

- velg eksisterende Piece
- registrer at stoffet er brukt eller klippet
- reduser eller avslutt det opprinnelige Piece
- opprett én eller flere nye rester med egne mål

Dette kan gi stor praktisk nytte uten at hele reservasjonsmodellen må bygges om samtidig.

**Anbefaling:** Piece-splitting bør vurderes før Reservation v2.

## 6. Reservation v2 – flere reservasjoner per Piece

Dagens modell representerer i praksis én reservasjon direkte på et Piece:

```text
Piece
 ├─ reservedLengthCm
 └─ project
```

En rikere modell bør sannsynligvis skille reservasjoner ut som egne objekter:

```text
Piece
 ├─ Reservation
 ├─ Reservation
 └─ Reservation
```

Dette kan støtte:

- flere prosjekter på samme Piece
- separat lengde per reservasjon
- merknad per reservasjon
- endring og sletting av individuelle reservasjoner
- historikk
- bedre prosjektoversikt
- eksplisitt frigjøring av reservasjoner
- korrekt summering av total, reservert og tilgjengelig mengde

Dette er en reell datamodell- og CloudKit-endring og bør ikke blandes sammen med mindre UX-forbedringer.

## 7. «Registrer bruk»

En senere arbeidsflyt kan gjøre faktisk bruk av stoff enklere å registrere.

I stedet for manuelt å:

1. endre Piece-lengde
2. endre eller fjerne reservasjon
3. opprette rester
4. eventuelt slette et oppbrukt Piece

kan appen tilby en samlet funksjon som «Registrer bruk».

Eksempel:

```text
Brukt til: Sommerkjole
Brukt: 185 cm
Rester:
- 75 × 145 cm
- 30 × 40 cm
```

Denne funksjonen henger naturlig sammen med Piece-splitting og en eventuell Reservation v2, men trenger ikke implementeres samtidig med begge.

## 8. Lokal cache og offline-støtte

Arkitekturen åpner for at CloudKit fortsatt er autoritativ kilde samtidig som klienten senere får mer omfattende lokal persistens/cache.

En slik arkitektur kan se slik ut:

```text
SwiftUI
   ↓
lokal database/cache
   ↕ synkronisering
CloudKit
```

Mulige fordeler:

- raskere oppstart
- mindre CloudKit-lesing
- bedre offline-bruk
- mer robust scrolling og søk
- mulighet for å køe endringer mens nettverket er utilgjengelig

Samtidig introduserer dette betydelig kompleksitet:

- synkroniseringslogikk
- konflikthåndtering
- endringssporing
- lokale og eksterne versjoner av samme data
- feilretting ved delvis synkronisering

**Anbefaling:** Ikke innfør en full lokal database bare fordi arkitekturen åpner for det. Mål først ytelse og brukeropplevelse med realistisk datamengde. Implementer dette dersom faktisk bruk viser behov.

## 9. Status for «Finn til prosjekt»

Etter utviklingsblokkene fram til 149 har «Finn til prosjekt» allerede omfattende funksjonalitet.

|navn|verdi|
|:---|:---|
|Minimum tilgjengelig lengde|Implementert|
|Minimum bredde|Implementert|
|Kategori|Implementert|
|Materiale|Implementert|
|Fargegruppe|Implementert|
|Minimum/maksimum vekt|Implementert|
|Elastisitetsgrad|Implementert|
|Elastisitetsretning|Implementert|
|Maksimum krymp|Implementert|
|Vaskbarhet|Implementert|
|Minimum vasketemperatur|Implementert|
|Kombinerte AND-krav|Implementert|
|Piece-basert tilgjengelig mengde|Implementert|
|Reservasjon|Implementert|
|Forklaring av hvorfor tekstilet passer|Implementert|
|Automatisk resultatoppdatering etter relevante endringer|Implementert|
|Best-fit på dimensjoner|Implementert|
|Visuell feedback på «Finn tekstiler»|Implementert og validert|

### Vurdering

Det er ikke nødvendig å prioritere en mer avansert poengbasert anbefalingsmotor nå.

Dagens modell er deterministisk og forståelig. Mer avansert rangering bør først vurderes dersom faktisk bruk viser behov for å skille mellom flere tekstiler som alle tilfredsstiller de absolutte kravene.

## 10. Flere vedlikeholdskriterier i prosjektsøk

Datamodellen inneholder mer vedlikeholdsinformasjon enn prosjektfilteret bruker i dag.

Mulige senere kriterier er:

- vaskesyklus
- bleking
- tørketrommel
- annen tørking
- stryking
- rens

Dette kan senere gi prosjektkrav som:

```text
Må tåle tørketrommel
Må kunne strykes varmt
Skal ikke kreve rens
```

### Vurdering

Dette bør være behovsdrevet. Vaskbarhet og temperatur dekker allerede de mest åpenbare prosjektkravene.

Standardiserte grafiske vaskesymboler kan fortsatt behandles som en separat senere forbedring.

## 11. Mac- og iPad-spesifikk optimalisering

Appen fungerer på flere skjermstørrelser, men større skjermer kan etter hvert utnyttes bedre.

Mulige forbedringer:

- flere tekstiler synlige samtidig
- permanent eller mer tilgjengelig filterpanel
- raskere administrativ redigering
- bedre tastaturnavigasjon
- mer effektiv bruk av sidepanel og detaljvisning
- bedre arbeidsflate for større tekstilsamlinger

Dette bør behandles som plattformpolering og ikke som en forutsetning for grunnfunksjonaliteten.

## 12. Deling mellom brukere

CloudKit-arkitekturen gjør det mulig å vurdere `CKShare` senere.

Eksempel:

```text
Del tekstilsamlingen med Kari
```

Dette kan gi:

- delt tilgang til tekstiler
- samarbeid om samme samling
- deling med familie eller andre brukere

### Vurdering

Dette er eksplisitt ikke nødvendig for første versjon. Privat CloudKit-database passer nåværende bruksmodell og bør beholdes fram til et reelt behov for deling oppstår.

## 13. UX- og robusthetsgjennomgang

Før versjon 1.0 bør appen gjennomgås systematisk som et ferdig produkt, ikke bare som enkeltfunksjoner.

|navn|verdi|
|:---|:---|
|Tastatur og fokus|Kontroller numeriske felt, markørplassering, åpning/lukking av tastatur og navigasjon mellom felt.|
|Trykkflater|Kontroller at naturlige rader kan trykkes over hele forventet område.|
|Navigasjon|Kontroller tilbake-navigasjon, sheets, editorer og lagring/avbryt.|
|Tomme tilstander|Kontroller bibliotek uten tekstiler, tekstil uten Piece, tomme filtre og ingen søkeresultater.|
|Feiltilstander|Kontroller CloudKit-feil, nettverksfeil, manglende iCloud og feil ved bildeoperasjoner.|
|Loading|Kontroller at brukeren alltid kan forstå når data faktisk lastes.|
|Sletting|Kontroller varsling og konsekvenser ved sletting av tekstil, Piece og bilder.|
|Ytelse|Test med vesentlig større datamengde enn utviklingsdatasettet.|
|Synkronisering|Test endringer mellom iPhone, iPad og Mac.|
|Tilgjengelighet|Kontroller Dynamic Type, lesbarhet, VoiceOver-relevante labels og trykkflater.|

## 14. Prioritert vei mot versjon 1.0

Anbefalt rekkefølge:

1. robust iCloud-/CloudKit-status og forståelige feiltilstander
2. eksport / backup
3. import / restore
4. direkte kamera og bildeoptimalisering
5. Piece-splitting
6. samlet UX- og robusthetsgjennomgang
7. Release-opprydding
8. CloudKit Production-klargjøring
9. helhetlig test på fysiske enheter
10. versjon 1.0

Denne rekkefølgen prioriterer datasikkerhet, forståelige feiltilstander og produksjonskvalitet framfor nye avanserte funksjoner.

## 15. Prioritert arbeid etter versjon 1.0

|navn|verdi|
|:---|:---|
|1|Flere bilder og rikere bildeadministrasjon dersom dette ikke tas før 1.0|
|2|Rikere Piece-data|
|3|Reservation v2 med flere reservasjoner per Piece|
|4|«Registrer bruk» og bedre håndtering av rester|
|5|Flere vedlikeholdskriterier og eventuelt mer avansert best-fit-rangering|
|6|Lokal database/cache og mer omfattende offline-støtte dersom målinger viser behov|
|7|Mac-/iPad-spesifikk administrativ UX|
|8|Deling via CloudKit/CKShare dersom behovet oppstår|

## 16. Konklusjon

Etter punkt 149 er den sentrale registrerings-, søke-, Piece- og prosjektfunksjonaliteten kommet langt nok til at videre utvikling bør dreies fra funksjonsvekst mot robusthet og produksjonskvalitet.

Den viktigste neste utviklingsblokken bør være **iCloud-/CloudKit-status og forståelige feiltilstander**. Tidligere testing har vist at deaktivert iCloud Drive kan gi en dårlig og lite forklarende brukeropplevelse. Dette er et større 1.0-problem enn manglende avanserte søkefunksjoner.

Deretter bør eksport/backup prioriteres. Brukeren bør kunne hente ut egne tekstildata og bilder i et lesbart og senere importerbart format før appen betraktes som ferdig for ordinær bruk.

Reservation v2 bør fortsatt utsettes. Den krever en reell endring av datamodellen og CloudKit-strukturen, mens Piece-splitting kan gi mye av den praktiske nytten rundt stoffrester med lavere kompleksitet.

### Anbefalt neste steg

**Punkt 150:** Gap-analysen er gjennomført.

**Neste implementeringsblokk:** Start med punkt 151 og implementer robust iCloud-/CloudKit-status med en tydelig og forståelig feiltilstand før videre funksjonsutvidelser.
