# Tekstilig – roadmap frem mot versjon 1.0

**Utgangspunkt:** Tekstilig-SwiftUIActualApp0024  
**Mål:** Ferdigstille, kvalitetssikre og publisere Tekstilig 1.0.  
**Arbeidsprinsipp:** Vi arbeider sekvensielt fra punkt 1 til punkt 12. Et hovedpunkt avsluttes og valideres før vi går videre til neste.

## Overordnet mål for Tekstilig 1.0

Tekstilig 1.0 skal være en stabil, forståelig og visuelt helhetlig app for registrering, administrasjon og gjenfinning av tekstiler.

Den foreløpige plattformretningen er:

- **iPhone:** rask og enkel registrering av tekstiler, med særlig vekt på bilde, navn og eventuelt lagringssted.
- **iPad:** både rask registrering og mer komplett registrering/redigering av tekstilinformasjon.
- **Mac:** primært komplettering, administrasjon, søk og arbeid med mer omfattende tekstilinformasjon.
- **CloudKit/iCloud:** samme private tekstilsamling skal være tilgjengelig på brukerens enheter.

Den endelige plattform- og UX-strategien fastsettes i punkt 1 før større UI-endringer gjøres.

## Roadmap

|navn|verdi|
|:---|:---|
|1. Plattform- og UX-strategi|Definer konkret hvordan Tekstilig 1.0 skal fungere på iPhone, iPad og Mac. Test samtidig eksisterende app på iPad og Apple Silicon Mac. Avklar om 1.0 skal bruke iPhone/iPad-versjonen direkte på Mac eller om en egen macOS-/multiplattformtilpasning er nødvendig. Fastsett hovedarbeidsflytene før videre UI-arbeid.|
|2. Visuell retning|Fastsett grunnleggende design for 1.0: bildebruk, bibliotekpresentasjon, navigasjon, typografi, spacing, knapper, ikoner, tomtilstander og visuell identitet. Vurder spesielt en mer bildeorientert presentasjon av tekstiler.|
|3. Rask registrering|Optimaliser registrering på iPhone slik at et nytt tekstil kan registreres svært raskt, primært med bilde, navn og eventuelt lagringssted. Øvrige egenskaper skal kunne kompletteres senere uten å gjøre førstegangsregistreringen tung.|
|4. Ufullstendige registreringer|Gjør det enkelt å identifisere og komplettere tekstiler som bare er hurtigregistrert eller mangler viktige data, spesielt på iPad og Mac. Avklar hvilke opplysninger som skal regnes som manglende uten å gjøre alle metadata obligatoriske.|
|5. iCloud-/CloudKit-robusthet|Implementer tydelig status og forståelige feiltilstander når iCloud, iCloud Drive, nettverk eller CloudKit ikke er tilgjengelig. Appen skal ikke fremstå som om den laster uten forklaring når datatilgangen faktisk har feilet.|
|6. Eksport og backup|Definer og implementer et stabilt og lesbart eksportformat for brukerens tekstildata og bilder. Eksporten skal være egnet som uavhengig sikkerhetskopi og utformes med tanke på senere gjenoppretting/import.|
|7. Import og restore|Implementer kontrollert import av det definerte eksportformatet. Avklar håndtering av eksisterende data, duplikater, bilder og feil under import, og test en komplett eksport→import/gjenoppretting-flyt.|
|8. Bilder|Implementer direkte kamera der det gir mening og optimaliser bildebehandlingen for lagring, synkronisering og ytelse. Før implementeringen avsluttes skal det også tas en eksplisitt beslutning om flere bilder per tekstil skal inngå i 1.0 eller utsettes.|
|9. Plattformpolering|Gjennomgå og tilpass appen for de plattformene som inngår i 1.0. Kontroller blant annet navigasjon, vindus-/skjermstørrelser, tastatur og fokus, trykkflater, Dynamic Type, tilgjengelighet, iPad-layout og Mac-bruk.|
|10. Release- og CloudKit Production-klargjøring|Gjennomgå debug-/diagnostikkfunksjoner, Release-konfigurasjon, signing/capabilities og CloudKit-schema. Klargjør og deploy nødvendige CloudKit-endringer til Production på kontrollert tidspunkt.|
|11. Full 1.0-validering|Gjennomfør ende-til-ende-testing av den ferdige 1.0-kandidaten på relevante fysiske enheter og med realistisk datamengde. Test registrering, redigering, sletting, Piece, reservasjon, søk, Finn til prosjekt, bilder, eksport/import, synkronisering, feiltilstander og ytelse. Kritiske feil skal rettes og retestes før publisering.|
|12. Publisering av Tekstilig 1.0|Klargjør App Store-leveransen: versjon/build, appikon, metadata, beskrivelser, skjermbilder, personvernopplysninger og øvrige nødvendige App Store Connect-opplysninger. Distribuer først egnet release candidate via TestFlight ved behov, gjennomfør siste kontroll og send Tekstilig 1.0 til publisering.|

## Funksjonalitet som i utgangspunktet ikke blokkerer 1.0

Følgende funksjoner flyttes til behovsdrevet arbeid etter 1.0 med mindre arbeidet i roadmapet avdekker en konkret teknisk grunn til å gjøre dem tidligere:

- Piece-splitting
- Reservation v2 med flere reservasjoner per Piece
- «Registrer bruk»
- rikere Piece-data utover behovene i 1.0
- mer avansert poengbasert rangering i «Finn til prosjekt»
- flere avanserte vedlikeholdskriterier i prosjektsøk
- full lokal database/cache og omfattende offline-synkronisering
- CloudKit-deling mellom brukere
- avansert Mac-spesifikt administrasjonsgrensesnitt utover det som kreves for en god 1.0-opplevelse

## Beslutning som tas under roadmapet

**Flere bilder per tekstil** er foreløpig ikke endelig plassert innenfor eller etter 1.0.

Dette avgjøres senest i punkt 8 basert på:

- faktisk brukerbehov
- ønsket bildearbeidsflyt
- eksisterende datamodell og CloudKit-støtte
- konsekvens for eksport/import
- kompleksitet og risiko før første publisering

Aktuelle bildebehov kan blant annet være:

- hovedbilde / oversiktsbilde
- nærbilde av struktur eller mønster
- vaskelapp
- annet relevant detaljbilde

## Arbeidsmetode

Roadmapet behandles som den styrende rekkefølgen frem mot 1.0.

Vi starter med **punkt 1 – Plattform- og UX-strategi** og går deretter videre i nummerert rekkefølge.

Innenfor hvert hovedpunkt kan vi opprette egne implementerings- og testpunkter. Nye tester markeres med **❗️** frem til de er gjennomført og bekreftet OK. Først da markeres de med **✅**.

Et hovedpunkt skal ikke regnes som ferdig bare fordi koden er implementert. Relevant funksjon skal også være testet og validert før vi går videre når punktet krever dette.

Hvis arbeidet avdekker et problem som teknisk bør løses tidligere enn roadmapet tilsier, vurderer vi dette eksplisitt før rekkefølgen endres. Nye funksjonsønsker skal normalt ikke utvide 1.0-scope dersom de kan gjennomføres forsvarlig etter første publisering.

## Neste steg

Start med:

**1. Plattform- og UX-strategi**

Første mål er å fastsette hva Tekstilig 1.0 konkret skal være på:

- iPhone
- iPad
- Mac

Deretter fastsetter vi de viktigste arbeidsflytene på hver plattform før vi går videre til punkt 2.


## Løpende status etter plattform- og designavklaring

|navn|verdi|
|:---|:---|
|1. Plattform- og UX-strategi|✅ Fullført. Native iPhone, iPad og macOS 27 fra samme SwiftUI-kodebase er låst retning.|
|2. Visuell retning|✅ Fullført. Liquid Glass/native SwiftUI, konteksttilpassede bilder, rolig iPhone-hovedside og stor-skjerm split-view er låst retning.|
|3. Rask registrering|❗️ Pågår. Devpatch 0055–0057 er funksjonelt validert, men praktisk test avdekket fire avsluttende UX-/bildepunkter. Devpatch 0058 retter umiddelbar thumbnail, kamera på eksisterende tekstil, duplisert hovedside-navigasjon og plassering av Nullstill i filterarket. Test 170–173 gjenstår før punkt 3 lukkes.|
|4–12|❗️ Ikke startet.|
