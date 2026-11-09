# Tekstilig – roadmap frem mot versjon 1.0

**Statuspresisering 2026-11-09 – 242.6 ✅:** 239–240, 241 A/B.1/B.2/B.3 og 242.1–242.5 er ✅ innen dokumenterte omfang. 242.6.1–6 og samlet 242.6 er ✅ etter eksplisitt brukergodkjenning på dokumentert, avgrenset grunnlag. Trygg faktisk import/restore er fortsatt ikke validert; dokumentasjonsendringene er lokale og ikke publisert ved denne oppdateringen. [Beslutningsgrunnlaget og restlisten](SWIFTUI-IMPLEMENTERING.md#24266--avsluttende-gjennomgang-og-beslutningsgrunnlag) konkretiserer åpne utførelsesbehov; ingen gap eller skrivesperre lukkes. Neste minste anbefaling er et særskilt bestilt beslutningsnotat/testspesifikasjon for produksjonsidentitet og unikhetskrav for nye familier, ikke oppstart av implementering. T0001 og historisk CloudKit-kontekst er fortsatt uavklart; ikke-atomisitet og øvrige bevisbegrensninger består. Ingen import/restore, skriveautorisasjon eller ny datalesing. Eldre daterte statuser nedenfor er historikk; se [gjeldende prosjektstatus](PROSJEKTSTATUS.md). Stopp etter punkt 6.


**Sluttstatus 2026-11-08 – 242.5 ✅ på avgrenset grunnlag, punkt 1–6 ✅:** Brukeren har godkjent etterkontrollen og testen samlet med dokumenterte begrensninger. 129 syntetiske tester PASS, begge bygg, signeringskontroll, brukervalidert lesing (43 poster per passering, 15 Textile + 28 underposter) og avbrudd (`Operation Cancelled (20)`, ufullstendig dekning, STOPP) inngår. Oppstartens GUI-observasjoner er ikke uavhengig verifisert; parallellsperren gjenbruker B.3-praktikk og 242.5-syntetikk. Application Support-data kunne ikke kontrolleres; appdata og faktiske CloudKit-data er ikke uavhengig verifisert uendret. T0001 er fortsatt uavklart og gir relasjons-STOPP. Ingen import-/skrivetillatelse, ny datalesing eller fullføring av test 242 samlet. Tidligere delstatuser nedenfor er historikk.

**Brukerbekreftelse 2026-11-08 – 242.5.5 ✅:** Tilgjengelig Avbryt-knapp under lesing, synlig avbruddsforespørsel og ingen automatisk ny lesing er uttrykkelig bekreftet. Verifisert Development, `Operation Cancelled (20)`, ufullstendig typedekning og korrekt STOPP beholdes som resultat. Parallellsperre gjenbruker tidligere praktisk B.3-validering og syntetiske 242.5-tester; ikke praktisk gjentatt her. Punkt 6 og samlet test forblir ❗️. Etterkontrollen gir ingen uavhengig bekreftelse på uendrede beskyttede appdata eller CloudKit-data. Tidligere delstatuser nedenfor er historikk.

**Etterkontroll 2026-11-08 – 242.5 ❗️:** Praktisk kansellering er rapportert med verifisert Development, `Operation Cancelled (20)`, 0 observasjoner, ufullstendig typedekning og STOPP. Øvrige praktiske avbruddskriterier er ikke uttrykkelig bekreftet. Åtte oppgavefiler og skrivefri kallkjede kontrollert; ZIP-hasher samsvarer med tidligere grunnlag. Journal/baseline og øvrige appdata er ikke verifisert grunnet lokal tilgangsnekt. Punkt 5–6 og samlet test beholdes ❗️, punkt 3–4 ✅. Ingen nye CloudKit-operasjoner eller reparasjon; T0001 forblir uavklart.

**Delvalidering 2026-11-08 – 242.5 ❗️ samlet, punkt 3–4 ✅:** Brukeren har validert to fullførte Development-passeringer med 43 råobservasjoner hver (15 Textile + 28 underposter), korrekte normale/PoC-relasjoner og forventet STOPP for ett historisk TextileImage med eier T0001 uten observert forelder. T0001 er fortsatt uavklart, ikke bekreftet foreldreløs. Ingen skriving utført. Punkt 1, 2, 5 og 6 avventer uttrykkelig validering; ingen nye oppslag eller logikkendringer i dokumentasjonsoppgaven.

**Tillegg 2026-11-08 – 242.5 ❗️:** Isolert macOS/DEBUG-relasjonsvisning gjenbruker B.3-session og 242.4-adapter uten automatisk lesing. Development-port og eksplisitt handling beholdes; komplett lesegrunnlag skilles fra relasjons-STOPP, også for PoC/T0001. 129 syntetiske tester PASS, begge plattformbygg og sikkerhets-/diffkontroll bestått. Seks valideringspunkter, inkludert senere praktisk kjøring, avventer godkjenning. Ingen faktisk CloudKit-/appkjøring, import eller skrivetillatelse. 242.1–242.4 er ✅ og publisert.

**Tillegg 2026-11-08 – 242.4 ✅ fullført og samlet brukergodkjent, alle fem punkter ✅.** 102 syntetiske tester PASS, begge plattformbygg og etterkontroll bestått. Godkjenningen gjelder bare isolert adapter fra innsendt ReadResult til relasjonsrapport. Ingen ny datalesing, importbeslutning eller skrivetillatelse; test 242 samlet er ikke dermed fullført.

**Historisk teknisk fortsettelse før brukergodkjenning – 242.4 ❗️:** Testhjelpernes actor-feil er rettet uten produksjonsendring. 21 adaptertester + 41 leser-/miljøtester + 25 modelltester + 15 rapporttester = 102 PASS, 0 FAIL. Begge tidligere plattformbygg gjenbrukes på uendrede kilder; sikkerhets-/diffkontroll bestått. Alle fem punkter avventer fortsatt brukergodkjenning. Ingen app-/CloudKit-kjøring eller skrivetillatelse.

**Historisk oppstart 2026-11-08 – 242.4 ❗️:** Isolert adapter fra allerede innlest ReadResult til relasjonsmodell/-rapport er påbegynt. Begge plattformbygg består, men testkompilering stopper på actor-isolerte fixturestandardargumenter. Ingen nye syntetiske tester eller regresjonstester er kjørt. Alle fem punkter avventer videre teknisk kontroll og brukergodkjenning. 242.1–242.3 er ✅ og publisert; ingen CloudKit-/appkjøring eller import-/skrivetillatelse.

**Tillegg 2026-11-08 – 242.3 ✅ fullført og samlet brukergodkjent, alle fem punkter ✅.** 63 syntetiske tester PASS, begge plattformbygg og etterkontroll bestått. Godkjenningen gjelder bare isolert baselinebevismodell; faktisk historisk kontekst forblir uavklart og import-/skrivetillatelse false. Ingen integrasjon eller fullføring av test 242 samlet følger av dette.

**Historisk implementeringsstatus før brukergodkjenningen – 242.3 ❗️:** Isolert baselinebevismodell er implementert med separate vurderinger av ZIP-/journalbinding, rå recordName/changeTag og eksplisitt historisk kontekst. Dagens CloudKit-kontekst brukes aldri til å fylle historiske hull; eksisterende v1-baseline forblir historisk uavklart. 23 nye tester og 40 relasjonsregresjonstester PASS, begge plattformbygg bestått; fem valideringspunkter avventer brukergodkjenning. Ingen faktisk datalesing, baselineendring, UI-/importintegrasjon eller skrivetillatelse. 242.1–242.2 er ✅ og publisert; test 242 samlet er ikke fullført.

**Utgangspunkt:** Tekstilig-SwiftUIActualApp0024  
**Mål:** Ferdigstille, kvalitetssikre og publisere Tekstilig 1.0.  
**Arbeidsprinsipp:** Vi arbeider sekvensielt fra punkt 1 til punkt 12. Et hovedpunkt avsluttes og valideres før vi går videre til neste.

**Gjeldende status 2026-11-07:** Se [PROSJEKTSTATUS.md](PROSJEKTSTATUS.md). Kodegrunnlag `SwiftUIActualApp0086` / `d3a0a62`; test 237 og 238 ✅. Hele test 230 er ✅ etter brukervalidering av ZIP-negativtest og uendret journalbinding 2026-11-06. Test 230 og 238 er publisert på GitHub. Identitetsstrategien er godkjent i B-050; test 239 ✅ og alle elleve punkter er brukervalidert 2026-11-07. Sluttresultat: 38 syntetiske tester bestått, vellykkede macOS-/iOS-/iPadOS-bygg og gjennomført etterkontroll. Godkjenningen gjelder isolert beslutningsmodell; ingen faktisk import, idempotens eller skrivetillatelse er godkjent. Test 239 er committet i `ae16a30`, integrert i `main` og publisert på GitHub. Test 240 ✅ er samlet brukervalidert: 38/38 modelltester og 23/23 adaptertester bestått, begge plattformbygg vellykket og praktisk UI-test gjennomført etter én særskilt godkjent test 238-lesing. Rapporten viste forventet STOPP ved uverifisert CloudKit-kontekst og manglende recordkontekst. Godkjenningen gjelder bare isolert adapter og beslutningsrapport; ingen produksjonsgodkjenning av kandidatidentiteter. Test 240 er integrert/publisert i `671c339`. Test 241 fase A ✅ er samlet brukergodkjent: 26 lesertester, 38 modelltester og 23 adaptertester, totalt 87 PASS/0 FAIL, begge appbygg og sikkerhetsetterkontroll bestått. Ingen faktisk transport eller appkjøring. Test 241 B.1 ✅ er samlet brukergodkjent for syntetisk miljøverifikasjon (102 PASS/0 FAIL, begge bygg og sikkerhetskontroll bestått); B.2 ✅ er brukervalidert for lokal miljøkontroll på macOS etter signeringsrettelsen; senere CloudKit-lesetester er fortsatt ❗️; uverifisert iOS/iPadOS-miljø, uavklart historisk baselinebinding og manglende atomisitetsgaranti består. Import/restore-skriving til CloudKit er fortsatt sperret. Miljø: Xcode 27.2 · iOS/iPadOS/macOS 27.2. Innledende plan og eldre statusnotater nedenfor beholdes som historikk; løpende status er oppdatert separat.

**Tillegg 2026-11-08 – test 241 B.3 ✅ fullført og endelig brukergodkjent:** Isolert Development-lesing er implementert med eksplisitt start, lokal miljøport før transportopprettelse, to metadata-/identitetspasseringer og minnerapport. Begge appbygg og 113 syntetiske tester bestått. Etterfølgende brukervalidering bekrefter isolert oppstart og to samsvarende Development-passeringer med 43 poster i hver og alle fem posttyper: alle seks praktiske punkter og B.3 samlet er ✅ etter også godkjent bygg/signering, avbrudd/parallellsperre og avsluttende etterkontroll uten konkrete avvik. Den kjente TextileImage-posten med eier T0001 er bare observert, uten reparasjon. Ingen import-/restore- eller skrivetillatelse. B.2 beholdes ✅.

**Tillegg 2026-11-08 – test 242.1 ✅ fullført og brukergodkjent:** Isolert relasjonsmodell er implementert med fem utfall for alle fire undertyper, bevart rågrunnlag/kontekst og ingen historisk slettingskonklusjon. Begge appbygg og 25 syntetiske tester bestått uten app-/CloudKit-kjøring. Alle fem valideringspunkter er brukergodkjent. Bare 242.1 er implementert; test 242 samlet og senere deltester er ikke fullført eller startet. Ingen endring av importbeslutninger, repositories eller baseline. B.3 er publisert i f11881f og beholdes ✅.

**Tillegg 2026-11-08 – test 242.2 ✅ fullført og brukergodkjent:** Isolert deterministisk relasjonsrapport er implementert på uendret 242.1-modell, med alle underpostrader, rågrunnlag/kontekst/foreldretreff og konkrete STOPP-begrunnelser uten skrivetillatelse. Begge appbygg og 15 rapporttester + 25 modelltester bestått uten app-/CloudKit-kjøring. Alle fem valideringspunkter er brukergodkjent. Bare den isolerte rapporten er godkjent; test 242 samlet og senere deltester er ikke fullført eller startet. 242.1 beholdes ✅ og er publisert i 1c9ab60. Ingen integrasjon, importbeslutninger, repository- eller baselineendring.

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
|5. iCloud-/CloudKit-robusthet|Implementer tydelig status og forståelige feiltilstander når iCloud-konto, nettverk eller CloudKit ikke er tilgjengelig. Avklar eksplisitt forholdet til iCloud Drive, men ikke anta at iCloud Drive-filsynkronisering er en forutsetning for CloudKit. Appen skal ikke fremstå som om den laster uten forklaring når datatilgangen faktisk har feilet.|
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
|5. iCloud-/CloudKit-robusthet|✅ Fullført. Punkt 187–197 er validert. Nettverksfeil, manglende iCloud-konto, detaljlasting og gjenoppretting har forståelige tilstander; avslått iCloud Drive-synk alene blokkerer ikke CloudKit.|
|6. Eksport og backup|✅ Validert. Test 198–204 er validert på iPhone, iPad og macOS; ZIP med `backup.json` og `images/` kan eksporteres.|
|7. Import og restore|❗️ Pågår som diagnostikk og sikkerhetsavklaring. Test 237 og 238 er validert; hele test 230 er ✅, inkludert negativtest med alternativ gyldig ZIP og etterkontroll av uendret journalbinding. Faktisk restore er ikke klar, og CloudKit-skriving er sperret. Ingen faktisk import eller restore er utført. Identitetsstrategi og testomfang er godkjent i B-050. Test 239 ✅ og alle elleve delpunkter er brukervalidert for isolert beslutningsmodell: 38 syntetiske tester, begge plattformbygg og etterkontroll bestått. Dette godkjenner ikke faktisk CloudKit-import, idempotens eller skriving. Test 239 er committet/publisert i `ae16a30`; test 240 ✅ er samlet brukervalidert for isolert adapter og skrivebeskyttet beslutningsrapport: 38/38 modelltester, 23/23 adaptertester og begge plattformbygg bestått. Praktisk UI-test etter én særskilt godkjent test 238-lesing bekreftet forventet STOPP ved uverifisert CloudKit-kontekst og manglende recordkontekst. Ingen import/restore, skrivetillatelse eller produksjonsgodkjenning av kandidatidentiteter. Test 240 er integrert/publisert i `671c339`; test 241 fase A ✅ er samlet brukergodkjent for isolert diagnostisk leser og syntetisk transport: 87 PASS/0 FAIL, begge appbygg og sikkerhetsetterkontroll bestått, uten faktisk transport eller appkjøring. Test 241 B.1 ✅ er samlet brukergodkjent for syntetisk miljøverifikasjon (102 PASS/0 FAIL, begge bygg og sikkerhetskontroll bestått), uten faktisk transport. B.2 ✅ er brukervalidert for lokal miljøkontroll på macOS: forventet Development samsvarer med verifisert Development, mens forventet Production gir STOPP ved miljøavvik. B.3 ✅ og 242.1–242.5 ✅ er senere fullført innen dokumenterte modell-/diagnostikkomfang, jf. sluttoppføringene ovenfor og [prosjektstatus](PROSJEKTSTATUS.md). 242.6 ✅ er avsluttet og brukergodkjent som avgrenset gjennomgang og beslutningsgrunnlag; faktisk import/restore er fortsatt ikke validert. Uverifisert iOS/iPadOS-miljø, uavklart historisk CloudKit-kontekst for baseline og manglende atomisitetsgaranti er fortsatt begrensninger.|
|8–12|❗️ Ikke startet som egne hovedblokker. Kamera og grunnleggende JPEG-optimalisering er allerede implementert under rask registrering; dette lukker ikke hele bildeblokken.|

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

Etter validering av denne blokken skal neste blokk eksplisitt dekke reell iCloud-/CloudKit-tilgjengelighet og deretter gjenbruke samme feilpresentasjon for øvrige CloudKit-avhengige deler av appen. Punkt 194 viste senere at iCloud Drive-filsynkronisering kan være slått av uten at privat CloudKit-database blir utilgjengelig; dette skal derfor ikke behandles som en feiltilstand i seg selv.

**Observasjon etter test 189:** Selve biblioteket kom tilbake etter gjenopprettet tilgang, men materiale-/farge- og bildemetadata for **Kan kompletteres** krevde manuell refresh. Devpatch 0070 gjør derfor **Prøv igjen** til en samlet gjenlasting av bibliotek og kompletteringsmetadata før neste robusthetsblokk.


### Roadmap punkt 6 – Eksport og backup

**Statuskorrigering 2026-11-01:** Test 198–204 er validert på alle tre plattformer. Avsnittet nedenfor beskriver oppstarten av punkt 6, ikke gjeldende eksportstatus.

Punkt 198 starter med å fastsette backupkontrakten før kode implementeres. Foreslått v1-format er én komplett snapshot-ZIP med `backup.json` og en `images/`-mappe. JSON-filen er versjonert og inneholder Textile med alle tilhørende Piece-, Material-, Color- og Image-metadata. Bilder lagres som egne filer. Tekstilig-ID-er brukes som applikasjonens restore-identitet; CloudKit record names skal ikke være nødvendig for gjenoppretting. Beslutningen må godkjennes før eksportimplementasjonen starter.


### Eksport og backup – devpatch 0085

**Historisk delstatus ved devpatch 0085:** Senere avløst av validert ZIP-eksport i test 203–204.

198–201 er validert. 202 ❗️ tester kun midlertidig filskriving og verifisering av `backup.json` og bilder. ZIP og brukerinitiert eksport kommer i neste blokk etter validering.
