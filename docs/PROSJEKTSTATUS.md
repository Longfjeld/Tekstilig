# Gjeldende prosjektstatus – Tekstilig

**Oppdatert:** 2026-11-01. Status og testbekreftelser nedenfor er oppgitt av prosjekteieren; commit er kontrollert i lokal Git-historikk. Dette er inngangen til gjeldende progresjon, ikke en ny funksjonsvalidering.

## Gjeldende status

- Autoritativ kilde for kode og versjonert dokumentasjon: Git-repositoriet, jf. [AGENTS.md](../AGENTS.md).
- Siste bekreftede kodegrunnlag: `SwiftUIActualApp0086`, commit `d3a0a62` (commitmelding kontrollert).
- Aktiv klient: native SwiftUI for iOS, iPadOS og macOS. Miljø: Xcode 27.2 og OS 27.2; CloudKit Development.
- Roadmap-punkt 1–5 er dokumentert fullført. Eksport/backup, test 198–204, er validert på iPhone, iPad og macOS. Roadmap-punkt 7, import/restore, pågår som diagnostikk og sikkerhetsavklaring; faktisk restore er ikke klar.
- Xcode-prosjektet angir fortsatt minimumsversjon 27.0 for iOS og macOS. Dette er en annen innstilling enn gjeldende miljø 27.2; prosjektinnstillingene er ikke endret i denne dokumentasjonsoppdateringen.

## Siste validerte test

**237 ✅ – validert OK av prosjekteieren.** Devpatch 0128 tester create-only-identitet og duplikatvern i en minnesimulering. Godkjenningen dokumenterer testresultatet, ikke faktisk CloudKit-skriveatferd eller ferdig import.

## Neste test

**238 ❗️ – neste test, ikke gjennomført.** Videre avklaring av identitetsstrategi ved import, særlig duplikatvern og bevaring av eksisterende automatisk genererte CloudKit-recordnavn (omtalt som servergenererte i implementeringsloggen).

Grunnlaget er test 222 og 237 i [implementeringsloggen](SWIFTUI-IMPLEMENTERING.md): logiske ID-er er egne felt; normale save-metoder bruker eksisterende `cloudRecordName` ved oppdatering og `CKRecord(recordType:)` ved ny post. Test 237 viser risiko for to ulike recordnavn med samme logiske ID. Ingen konkret ny identitetsstrategi eller detaljert testprosedyre for 238 er vedtatt her.

## Åpne problemer og uavklarte tester

- **Test 230 ❗️, avgrenset restpunkt:** negativtest med en annen gyldig ZIP med ulikt innhold/hash er fortsatt uavklart. Tidligere validerte kontroller beholdes som validert; restpunktet lukkes ikke gjennom test 237.
- Duplikatvern, samtidighet og bevaring av eksisterende recordnavn må avklares før reell import. Ikke-atomiske CloudKit-lesinger og lokale simuleringer gir ingen garanti mot endringer før en eventuell skriving.
- Eldre dokumenter har statusetterslep: rotens `README.md` beskriver devpatch 0051, `docs/README.md` beskriver devpatch 0009, og `CLOUDKIT-OPPSETT.md` har en gammel PoC-status. Bruk dem for relevant kontekst, ikke dagens neste steg.
- Eldre metodikk og beslutning B-016 omtaler opplastet ZIP som autoritativ kilde og viser commit/push som normal arbeidsflyt. For Codex-arbeid her gjelder Git som autoritativ kilde og eksplisitt tillatelse før commit/push, jf. `AGENTS.md`.
- Eldre eksporteksempler i `ARKITEKTUR.md` og `DATAMODELL.md` bruker `tekstiler.json`/`bilder/`. Gjeldende backupkontrakt er ZIP med `backup.json` og `images/`, jf. test 198–204 og eksisterende backupkode. En full lokal database/cache er behovsdrevet arbeid etter 1.0 ifølge roadmapet, ikke dokumentert ferdig funksjonalitet.

## Aktive sikkerhetssperrer

- **CloudKit-skriving og -sletting under import/restore er fortsatt sperret.** Bare prosjekteierens uttrykkelige godkjenning av sikkerheten kan åpne for dette.
- Simuleringer og «FORELØPIG OK» / «IKKE SKRIVEKLAR» gir ingen tillatelse til import. Eksisterende CloudKit-identiteter, journaler, baseline, backupbindinger og ZIP-grunnlag skal bevares.
- Ingen automatisk overskriving eller sletting av eksisterende bibliotek som restore-strategi.

## Neste planlagte arbeid

Fortsett fra test 238 når videre arbeid er bestilt: avklar identitetsstrategien mot eksisterende repositories og dokumenterte funn før eventuell implementering og sekvensiell validering. Følg opp restpunktet fra test 230 eksplisitt. Denne dokumentasjonsoppdateringen starter ingen tester og åpner ingen skrivesperrer.

## Historiske referansedokumenter

- [Gap-analyse etter 149](Tekstilig-GAP-ANALYSE-etter-149.md): historisk vurdering, ikke gjeldende status eller arbeidsrekkefølge.
- [SwiftUI-oppstart](SWIFTUI-OPPSTART.md) og [CloudKit-PoC-test](CLOUDKIT-POC-TEST.md): tidligere teknisk validering.
- [CloudKit-oppsett](CLOUDKIT-OPPSETT.md): historisk oppstart og tekniske oppsettsreferanser; eldre PoC-stoppunkter er ikke dagens arbeidsplan.
- [Beslutningslogg](BESLUTNINGSLOGG.md): beslutningshistorikk; vurder eldre beslutninger mot senere vedtak og gjeldende prosjektinstruksjoner.

[Roadmapet](Tekstilig-ROADMAP-1.0.md) styrer hovedrekkefølgen og [implementeringsloggen](SWIFTUI-IMPLEMENTERING.md) bevarer testhistorikken. Historiske ❗️-oppføringer som senere er eksplisitt godkjent, skal ikke tolkes som nye åpne tester.
