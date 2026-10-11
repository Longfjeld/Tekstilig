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
|3. Rask registrering|✅ Fullført og validert etter devpatch 0063 på autoritativ kilde 0035. Hurtigregistrering, hovedbilde og kamera på eksisterende tekstil er validert OK.|
|4. Ufullstendige registreringer|✅ Fullført og validert på iPhone, iPad og native macOS etter devpatch 0068. «Kan kompletteres», filter og detaljforklaring fungerer på alle tre plattformer.|
|5. iCloud-/CloudKit-robusthet|❗️ Pågår. Punkt 187–189 er validert. Neste blokk (punkt 190/devpatch 0070) sikrer at «Kan kompletteres»-metadata lastes på nytt sammen med biblioteket etter «Prøv igjen».|
|6–12|❗️ Ikke startet.|

### Statusnotat – roadmap punkt 3

Devpatch 0060 ble build-blokkert i Xcode 27 av en SwiftUI-typecheck-feil i `TextileDetailView`. Devpatch 0061 deler view-uttrykket opp uten å endre kamerafunksjonen. Roadmap-punkt 3 står derfor fortsatt åpent til test 176 er validert.

### Korrigering etter devpatch 0061

Gjennomgang av `Tekstilig-SwiftUIActualApp0032.zip` viste at `TextileDetailView.swift` fra devpatch 0060/0061 var pakket under feil relativ path utenfor Xcode-targetets `Tekstilig/`-rot. Devpatch 0062 legger samme strukturelle kamerafiks i korrekt target-path. Roadmap-punkt 3 står fortsatt åpent til test 177 er validert.


### Roadmap punkt 4 – Ufullstendige registreringer

**178. Kriterier og UX-beslutning – ✅**

Et tekstil regnes som **Kan kompletteres** dersom minst ett av følgende mangler:

- hovedbilde
- materiale
- kategori
- lagringssted

Farge, Piece/dimensjoner, vekt, elastisitet, krymp, vask/vedlikehold og notat gjør ikke i seg selv registreringen ufullstendig. Statusen skal være en diskret hjelp, ikke en feil/advarsel. Biblioteket skal kunne filtreres på **Kan kompletteres**, og detaljvisningen skal forklare hvilke av de fire feltene som mangler.

**179. ❗️ Bygg og åpne biblioteket**

Appen skal bygge uten nye feil. Bibliotek og eksisterende tekstiler skal åpnes normalt.

**180. ❗️ Status i full tekstilliste**

Et tekstil som mangler minst ett av hovedbilde, materiale, kategori eller lagringssted skal vise den diskrete statusen **Kan kompletteres**. Et tekstil som har alle fire skal ikke vise statusen.

**181. ❗️ Filter «Kan kompletteres»**

Aktiver filteret **Kan kompletteres**. Bare tekstiler som mangler minst ett av de fire kriteriene skal vises. Nullstilling av filteret skal gjenopprette vanlig liste.

**182. ❗️ Detaljvisning forklarer mangler**

Åpne et ufullstendig tekstil. Under **Registrering** skal detaljvisningen vise **Kan kompletteres** og en konkret liste over manglende felt, for eksempel `Mangler: materiale, kategori.`

**183. ❗️ Status oppdateres etter komplettering**

Legg til eller rediger manglende hovedbilde, materiale, kategori og/eller lagringssted. Detaljstatusen skal oppdateres direkte når data lagres. Når du går tilbake til biblioteket, skal status/filtergrunnlaget oppdateres uten app-omstart.

**Observasjon – iOS/iPadOS 27 statusbar-API**

Xcode kan logge `-[UIApplication setStatusBarHidden:animationParameters:] API has been deprecated and is a no-op on 27.0 and later.` Det finnes ikke noe direkte kall til dette deprecated API-et i Tekstilig-koden. Ingen funksjonell feil er observert, og det gjøres derfor ingen spekulativ kodeendring nå. Revurderes dersom meldingen kan knyttes til en faktisk UI-feil.


### Roadmap punkt 5 – iCloud-/CloudKit-robusthet

Første implementeringsblokk avgrenses til selve tekstilbibliotekets første last. Målet er at appen ikke skal bli stående med en uforklart lasteindikator når CloudKit bruker lang tid eller returnerer en kjent tilgjengelighetsfeil.

Devpatch 0069:

- gir forståelige meldinger for manglende iCloud-pålogging, nettverksfeil, midlertidig CloudKit-feil, full iCloud-lagring og tilgangsfeil
- beholder eksplisitt **Prøv igjen** ved faktisk lastefeil
- viser **Venter på iCloud** med konkret veiledning dersom første biblioteklast varer mer enn omtrent åtte sekunder
- endrer ikke CloudKit-schema, Textile-data eller eksisterende funksjonslogikk

Etter validering av denne blokken skal neste blokk eksplisitt dekke iCloud/iCloud Drive-tilgjengelighet og deretter gjenbruke samme feilpresentasjon for øvrige CloudKit-avhengige deler av appen.

**Observasjon etter test 189:** Selve biblioteket kom tilbake etter gjenopprettet tilgang, men materiale-/farge- og bildemetadata for **Kan kompletteres** krevde manuell refresh. Devpatch 0070 gjør derfor **Prøv igjen** til en samlet gjenlasting av bibliotek og kompletteringsmetadata før neste robusthetsblokk.
