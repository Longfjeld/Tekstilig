# Prosjektinstruksjoner for Tekstilig

## Kildegrunnlag og oppstart

- Git-repositoriet er autoritativ kilde for kode og versjonert dokumentasjon. Eldre regler om opplastet ZIP som autoritativ kilde gjelder ikke for arbeid her; ZIP-er er leveranse-/referansesnapshots.
- Arbeid i egen oppgavegren, aldri direkte på `main`. Kontroller arbeidsmappe, gren og lokale endringer før endringer; bevar brukerens arbeid.
- Når oppgaven angir forventet gren, commit eller lokale endringer, kontroller dette før arbeidet. Stopp og rapporter uventede avvik; ikke korriger arbeidsmiljøet automatisk.
- Les [gjeldende prosjektstatus](docs/PROSJEKTSTATUS.md), relevant del av [implementeringsloggen](docs/SWIFTUI-IMPLEMENTERING.md), [arbeidsmetodikken](docs/ARBEIDSMETODIKK.md) og [leveranse- og testmetodikken](docs/LEVERANSE-OG-TESTMETODIKK.md) før endringer. Disse instruksjonene erstatter eldre, motstridende kilde- og Git-arbeidsflytregler for Codex-arbeid i repositoriet.
- Les relevante krav i `docs/ARKITEKTUR.md`, `docs/DATAMODELL.md`, `docs/BESLUTNINGSLOGG.md`, `docs/Tekstilig-ROADMAP-1.0.md` og ved behov `docs/UX-FLYTER.md`, `docs/DESIGN.md` og `docs/CLOUDKIT-OPPSETT.md`. Skill planlagt modell fra implementert funksjonalitet; kontroller tekniske opplysninger mot kode ved behov.
- Gjeldende status føres i `docs/PROSJEKTSTATUS.md`; implementeringsloggen styrer konkrete testpunkter og roadmapet styrer hovedrekkefølgen. Stopp avhengig arbeid og avklar vesentlige motstridigheter som ikke kan løses fra dokumentert grunnlag.

## Endringer og Git

- Identifiser og dokumenter rotårsaken før feilretting. Ingen spekulative patcher eller kompenserende lag som skjuler feilen.
- Gjør minimale, målrettede endringer. Ikke refaktorer eller endre annen funksjonalitet uten eksplisitt godkjenning.
- Etter maksimalt to mislykkede rettingsforsøk på samme feil: stopp videre rettingsforsøk og utfør ny, målrettet diagnostikk før neste rettelse.
- Ikke utfør destruktive Git-operasjoner. Ikke utfør commit, push, merge eller sletting av filer, grener eller data uten eksplisitt tillatelse. Historiske arbeidsflyteksempler gir ikke slik tillatelse.
- Hold eksisterende lokale brukerendringer utenfor oppgavens staging og commits. Xcode-brukerfiler, inkludert `UserInterfaceState.xcuserstate`, BBEdit-kataloger og lokale bygge-/testartefakter skal ikke tas med med mindre oppgaven uttrykkelig gjelder dem. Ikke bruk stash, reset, clean eller tvungen checkout uten eksplisitt tillatelse.
- Ved godkjent commit: stage bare godkjente filer med eksplisitte filstier, kontroller staged diff og bekreft filutvalget før commit. Godkjenning av commit omfatter ikke merge eller push.
- Dokumenter hvilke filer som endres og hvorfor. Oppdater relevant dokumentasjon ved funksjonelle endringer, inkludert prosjektstatus og implementeringslogg når progresjon endres.

## Testing og validering

- Nye og ikke-validerte testpunkter markeres ❗️. Marker først ✅ når brukeren uttrykkelig har validert resultatet OK; bygg, kodeinspeksjon eller simulering alene lukker ikke testen.
- Utfør testpunkter strengt sekvensielt. Nødvendige forberedelser og handlinger skal stå før tilhørende kontroll og stoppbetingelse. Stopp ved feil eller uttrykkelig stoppunkt.
- Ikke endre tidligere validerte testresultater uten dokumentert grunnlag. Bevar historiske testbeskrivelser og observasjoner, og skill daterte statuskorrigeringer fra historikken.
- Ved kodeendringer: bygg først, utfør deretter relevante tester på angitt målplattform. Oppgi begrensninger dersom bygg eller tester ikke kan kjøres.
- Rapporter separat hva som er implementert, hvilke kontroller som faktisk er kjørt, og hva som gjenstår for brukerens validering. Ikke marker en funksjon ferdig bare fordi den er implementert eller simulert.
- Avslutt endringsoppgaver med `git diff --check`, Git-status og en oversikt over endrede og nye filer. Ved godkjente Git-operasjoner kontrolleres også resulterende gren-/commitstatus. Rapporter avvik og stopp ved oppgavens avtalte sluttpunkt; ikke start neste test eller utviklingsfase automatisk.

## SwiftUI og CloudKit

- Aktiv implementering er native SwiftUI for iOS, iPadOS og macOS. Gjeldende utviklingsmiljø er Xcode 27.2 og OS 27.2. PWA-sporet er frosset referanse og endres ikke uten ny eksplisitt beslutning.
- CloudKit er primærlager for brukerdata; Git er kilde for kode og dokumentasjon. Bevar skillet mellom logiske Tekstilig-ID-er og CloudKit-recordidentiteter.
- CloudKit-skriving og -sletting under import/restore er sperret til sikkerheten er uttrykkelig godkjent av prosjekteieren. Et godkjent diagnostikkresultat gir ikke skrivetillatelse.
- Ikke anta at en simulering dokumenterer faktisk CloudKit-atferd, atomisitet, idempotens eller unikhet for logiske ID-er.
- Bevar eksisterende CloudKit-identiteter, inkludert eksisterende automatisk genererte recordnavn og systemmetadata. Unngå duplikater og utilsiktet overskriving; ikke bytt identitetsstrategi eller normale save-metoder uten avklart grunnlag og godkjenning.
- Bevar eksisterende importjournaler, backupbindinger, baseline og ZIP-grunnlag. Ikke slett, overskriv eller endre dem for å få en kontroll godkjent.
- Ved skrivebeskyttet diagnostikk skal hele kallkjeden kontrolleres, også URL- og kataloghjelpere. Lesestier skal ikke opprette kataloger, lagre filer eller oppdatere journal/baseline. Faktisk import eller restore krever egen uttrykkelig godkjenning.
