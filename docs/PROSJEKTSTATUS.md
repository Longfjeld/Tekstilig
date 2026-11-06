# Gjeldende prosjektstatus – Tekstilig

**Oppdatert:** 2026-11-06. Status og testbekreftelser nedenfor er oppgitt av prosjekteieren; commit er kontrollert i lokal Git-historikk. Dette er inngangen til gjeldende progresjon, ikke en ny funksjonsvalidering.

## Gjeldende status

- Autoritativ kilde for kode og versjonert dokumentasjon: Git-repositoriet, jf. [AGENTS.md](../AGENTS.md).
- Siste bekreftede kodegrunnlag: `SwiftUIActualApp0086`, commit `d3a0a62` (commitmelding kontrollert).
- Aktiv klient: native SwiftUI for iOS, iPadOS og macOS. Miljø: Xcode 27.2 og OS 27.2; CloudKit Development.
- Roadmap-punkt 1–5 er dokumentert fullført. Eksport/backup, test 198–204, er validert på iPhone, iPad og macOS. Roadmap-punkt 7, import/restore, pågår som diagnostikk og sikkerhetsavklaring; faktisk restore er ikke klar.
- Xcode-prosjektet angir fortsatt minimumsversjon 27.0 for iOS og macOS. Dette er en annen innstilling enn gjeldende miljø 27.2; prosjektinnstillingene er ikke endret i denne dokumentasjonsoppdateringen.

## Siste valideringer

**238 ✅ fullført – eksplisitt godkjent av prosjekteieren 2026-11-01 på macOS 27.2.** Testen omfatter skrivebeskyttet identitetsavstemming mellom valgt ZIP, v2-journal, baseline og CloudKit, samt verifisering av diagnostikkens filtrering. Alle fire bindinger/avstemminger er OK.

Versjonslesingen viser 43 unike poster, identitetslesingen 40. Differansen er nøyaktig `Textile:swiftui-poc-textile-v1`, `Piece:swiftui-poc-piece-v1` og `TextileImage:swiftui-poc-textile-image-v1`: alle finnes i verifisert baseline og treffer eksakte eksisterende PoC-filtre. Motsatt differanse er 0; ingen uventede mengdedifferanser er observert. Fire backup-poster svarer til fire planlagte journaloperasjoner; ingen operasjoner er utført.

Bildepost `IMG-204AB741-6904-42E7-85C9-5A0AD15F44DC` med eier `T0001` beholdes uendret som sannsynlig historisk rest. Faktisk foreldreløshet er ikke fullstendig verifisert.

Godkjenningen omfatter ikke faktisk import/restore, CloudKit-skriving eller -sletting, endelig valg eller implementering av identitetsstrategi, atomisk konsistens mellom separate lesinger eller fullstendig verifikasjon av historisk eierskap og bildeinnhold. Ingen brukervalidering på iOS/iPadOS er dokumentert for test 238.

**230 ✅ fullstendig brukervalidert 2026-11-06.** Prosjekteieren har bekreftet den nye skrivebeskyttede diagnostikkfunksjonen i appen, korrekt avvisning av `Tekstilig-backup2.zip` ved avvikende SHA-256 og korrekt godkjenning av `Tekstilig-backup.zip` ved samsvar. Etterkontrollen viste uendret journal-ID, ZIP-binding og operasjonstall:

- Journal-ID: `3EC77AF2-223E-4556-AAFB-98376557CE47`.
- Lagret ZIP SHA-256: `004ced842dd8da950c7d3552d149bb1ca9af02e72d2491219e2ad376374bf963`.
- Planlagte operasjoner: 4. Fullførte operasjoner: 0.
- Alternativ ZIP SHA-256: `f34f8804d9ce1789e28eb71d5d476653add318a7ca30a13eebeb98249bd860b9`.

Ingen faktisk import, restore eller CloudKit-skriving ble utført. Godkjenningen gjelder journalbinding og skrivebeskyttet diagnostikk; CloudKit-skriving/-sletting under import/restore er fortsatt sperret. Test 238 er fortsatt ✅ fullført. Tidligere ❗️-statuser for test 230 nedenfor og i senere testbeskrivelser er historikk fra før denne godkjenningen.

## Neste test

Neste nummererte test er ikke fastlagt. Test 238 er avsluttet; videre arbeid må avgrenses og godkjennes før oppstart. Test 230 er nå fullstendig godkjent, og test 238 er fortsatt fullført.

Grunnlaget er test 222 og 237 i [implementeringsloggen](SWIFTUI-IMPLEMENTERING.md): logiske ID-er er egne felt; normale save-metoder bruker eksisterende `cloudRecordName` ved oppdatering og `CKRecord(recordType:)` ved ny post. Test 237 viser risiko for to ulike recordnavn med samme logiske ID. Rapporten bruker bare den allerede eksisterende diagnostikkformelen for hypotetiske kandidatnavn; ingen ny identitetsstrategi er vedtatt.

## Åpne problemer og uavklarte tester

- Duplikatvern, samtidighet og bevaring av eksisterende recordnavn må avklares før reell import. Ikke-atomiske CloudKit-lesinger og lokale simuleringer gir ingen garanti mot endringer før en eventuell skriving.
- Eldre dokumenter har statusetterslep: rotens `README.md` beskriver devpatch 0051, `docs/README.md` beskriver devpatch 0009, og `CLOUDKIT-OPPSETT.md` har en gammel PoC-status. Bruk dem for relevant kontekst, ikke dagens neste steg.
- Eldre metodikk og beslutning B-016 omtaler opplastet ZIP som autoritativ kilde og viser commit/push som normal arbeidsflyt. For Codex-arbeid her gjelder Git som autoritativ kilde og eksplisitt tillatelse før commit/push, jf. `AGENTS.md`.
- Eldre eksporteksempler i `ARKITEKTUR.md` og `DATAMODELL.md` bruker `tekstiler.json`/`bilder/`. Gjeldende backupkontrakt er ZIP med `backup.json` og `images/`, jf. test 198–204 og eksisterende backupkode. En full lokal database/cache er behovsdrevet arbeid etter 1.0 ifølge roadmapet, ikke dokumentert ferdig funksjonalitet.

## Aktive sikkerhetssperrer

- **CloudKit-skriving og -sletting under import/restore er fortsatt sperret.** Bare prosjekteierens uttrykkelige godkjenning av sikkerheten kan åpne for dette.
- Simuleringer og «FORELØPIG OK» / «IKKE SKRIVEKLAR» gir ingen tillatelse til import. Eksisterende CloudKit-identiteter, journaler, baseline, backupbindinger og ZIP-grunnlag skal bevares.
- Ingen automatisk overskriving eller sletting av eksisterende bibliotek som restore-strategi.

## Neste planlagte arbeid

Etter godkjent test 238 er neste steg å avklare omfanget av videre identitetsstrategi mot eksisterende repositories og rapporterte funn, før eventuell implementering. Test 230-restpunktet er avsluttet etter uttrykkelig brukergodkjenning. Rapporten åpner ingen skrivesperrer.

## Historiske referansedokumenter

- [Gap-analyse etter 149](Tekstilig-GAP-ANALYSE-etter-149.md): historisk vurdering, ikke gjeldende status eller arbeidsrekkefølge.
- [SwiftUI-oppstart](SWIFTUI-OPPSTART.md) og [CloudKit-PoC-test](CLOUDKIT-POC-TEST.md): tidligere teknisk validering.
- [CloudKit-oppsett](CLOUDKIT-OPPSETT.md): historisk oppstart og tekniske oppsettsreferanser; eldre PoC-stoppunkter er ikke dagens arbeidsplan.
- [Beslutningslogg](BESLUTNINGSLOGG.md): beslutningshistorikk; vurder eldre beslutninger mot senere vedtak og gjeldende prosjektinstruksjoner.

[Roadmapet](Tekstilig-ROADMAP-1.0.md) styrer hovedrekkefølgen og [implementeringsloggen](SWIFTUI-IMPLEMENTERING.md) bevarer testhistorikken. Historiske ❗️-oppføringer som senere er eksplisitt godkjent, skal ikke tolkes som nye åpne tester.
