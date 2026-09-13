# Beslutningslogg

Beslutningsloggen dokumenterer **hvorfor** Tekstilig bygges slik den gjør. Endringsloggen dokumenterer hva som endres mellom leveranser.

---

## B-001 – Programkode og brukerdata skilles

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Programkoden kan publiseres via GitHub/GitHub Pages. Tekstildata og brukerbilder skal ikke publiseres i GitHub.

### Begrunnelse

Dataene er private og skal eies og kunne håndteres direkte av brukeren.

### Konsekvens

Appen må ha et separat lagringslag.

---

## B-002 – JSON og separate bilder i lokal/iCloud-katalog

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Primær lagringsmodell er en lokal katalog, primært plassert i iCloud Drive, med `tekstiler.json` og en egen bildekatalog.

### Begrunnelse

Løsningen er transparent, enkel å sikkerhetskopiere og gir direkte tilgang til data uten å være avhengig av en sentral tjeneste.

---

## B-003 – Lagringslaget abstraheres

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Filtilgang skal kapsles inn slik at resten av appen ikke avhenger direkte av den konkrete nettleser-API-en.

### Begrunnelse

Dette reduserer konsekvensen av forskjeller mellom nettlesere og gjør senere endring av lagringsmekanisme enklere.

---

## B-004 – Stoffstykker modelleres separat

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Et tekstil kan bestå av flere fysiske stoffstykker. Lengde og bredde registreres per stykke.

### Begrunnelse

Total meterlengde sier ikke om det finnes et stort nok sammenhengende stykke til et syprosjekt. Rester kan også ha ulik bredde.

---

## B-005 – Materialinnhold lagres strukturert

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Fibertype og prosentandel lagres som separate strukturerte verdier, ikke bare som fritekst.

### Begrunnelse

Dette muliggjør presist søk og filtrering på materiale og andel.

---

## B-006 – Vedlikehold lagres strukturert

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Vask, bleking, tørking, stryking og rens registreres som strukturerte verdier. Bilde av vaskelapp kan lagres i tillegg.

### Begrunnelse

Strukturerte data kan søkes og filtreres. Bildet fungerer som dokumentasjon og supplement.

---

## B-007 – Visuell retning: varm minimalisme

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Tekstilig skal ha et varmt, rolig og stilrent uttrykk med dempet, hovedsakelig nøytral palett. Stoffbildene skal stå for mesteparten av fargen og det visuelle uttrykket.

Appen følger systemets lys/mørk-modus.

### Designprinsipper

1. Stoffet er hovedpersonen.
2. Enkel før komplett.
3. Visuelt, men informativt.
4. Mobil ved lageret, Mac ved skrivebordet.
5. Rolig og varmt, ikke dekorativt.
6. Ytelse er en del av designet.

### Begrunnelse

Grensesnittet skal være enkelt, vakkert og oversiktlig uten å konkurrere med tekstilbildene eller bli sterilt.

---

## B-008 – Responsiv arbeidsdeling mellom enheter

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Mobil/iPad prioriteres for fotografering, registrering og oppslag ved lageret. Mac prioriteres for administrasjon, redigering og omfattende søk.

### Konsekvens

Mobilgrensesnittet skal ikke bare være en nedskalert desktop-visning.

---

## B-009 – Søk og visuelt bibliotek er hovedinngangen

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Forsiden kombinerer fritekstsøk med et visuelt stoffbibliotek. Vanlig søk, filtrering, prosjektsøk og fri blaing skal støttes.

Kortvisning skal prioritere relativt store stoffbilder og vise navn, materiale og tilgjengelig størrelse.

---

## B-010 – Rask registrering med progressiv detaljering

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Et nytt tekstil skal kunne registreres raskt med få grunnopplysninger. Flere detaljer kan fylles ut umiddelbart eller senere.

Fotografering direkte fra telefon/iPad skal være en sentral arbeidsflyt.

---

## B-011 – Symboler kombineres med tekst

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Vedlikehold og andre egnede egenskaper skal presenteres med både grafiske symboler og forklarende tekst.

### Begrunnelse

Symboler gir rask visuell lesing, mens tekst reduserer tvetydighet.

---

## B-012 – Farge lagres på flere nivåer

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Farge kan bestå av søkbar fargegruppe, beskrivende navn og en konkret fargeverdi.

### Begrunnelse

Fargegruppe gir robust filtrering, mens navn og fargeverdi gir mer presis beskrivelse.

---

## B-013 – Pris er valgfritt

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Innkjøpspris kan registreres, men er ikke obligatorisk. Meterpris og/eller totalpris kan lagres sammen med valuta, leverandør og innkjøpsdato.

---

## B-014 – Reservasjon knyttes til stoffstykke

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Hele eller deler av et stoffstykke kan reserveres til et prosjekt.

### Begrunnelse

Andre stykker av samme tekstil kan fortsatt være tilgjengelige, og et stykke kan være delvis reservert.

---

## B-015 – Permanente ID-er og versjonert schema

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Tekstiler får permanente automatiske ID-er. Datafilen inneholder `schemaVersion`.

### Begrunnelse

Dette gjør migrering av datamodellen mulig og legger grunnlag for senere funksjoner som QR-koder.

---

## B-016 – Leveransemodell for kode

**Dato:** 2026-09-13  
**Status:** Besluttet

### Beslutning

Første kodeleveranse skal være en komplett ZIP.

Ved senere endringer laster brukeren opp ZIP med gjeldende kode. Denne regnes som autoritativ kilde. Ny leveranse skal da være en ZIP som bare inneholder endrede eller nye filer, med korrekt katalogstruktur.

Leveranser nummereres sekvensielt, eksempelvis `0001`, `0002`, `0003`.

### Begrunnelse

Dette reduserer risikoen for å gjeninnføre gammel eller eksperimentell kode fra tidligere samtaler.
