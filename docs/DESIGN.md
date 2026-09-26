# Design

**Status:** Autoritativ designretning v1  
**Fase:** Tidlig utvikling / native PoC

Dette dokumentet er den samlede kilden for visuell design og typografiske prinsipper i Tekstilig. `UX-FLYTER.md` beskriver brukerflyter og skjermstruktur; dette dokumentet beskriver hvordan grensesnittet skal oppleves og utformes.

## 1. Designmål

Tekstilig skal være:

- enkel og rolig
- visuelt tydelig uten unødvendig dekor
- rask å forstå på iPhone og iPad
- effektiv på Mac når mer administrasjon og avansert søk senere innføres
- bygget rundt tekstilbildene som viktigste visuelle innhold

Appen er fortsatt i en tidlig utviklingsfase. SwiftUI-grensesnittet i CloudKit-PoC-en er diagnostikk, ikke ferdig produktdesign.

## 2. Visuell retning

- Nøytral og dempet grunnflate.
- Stoffbilder og farger i selve tekstilene skal få dominere.
- Systemtypografi brukes som utgangspunkt.
- God luft mellom innholdselementer prioriteres fremfor høy informasjonstetthet på mobil.
- Primære handlinger skal være få, store og tydelige.
- Sekundære og destruktive handlinger skal være mindre fremtredende.
- Både lys og mørk systemmodus skal støttes.

## 3. Typografi

Native klient bruker Apples systemtypografi og Dynamic Type som utgangspunkt. Egne skrifttyper innføres ikke uten en konkret designmessig grunn.

Retningslinjer:

- navigasjonstitler følger plattformens standardnivåer
- brødtekst skal være lesbar uten manuell zoom
- metadata kan være mindre, men skal fortsatt følge Dynamic Type
- fet skrift brukes for hierarki, ikke som dekor

## 4. Kontroller og symboler

- Bruk standard SwiftUI-kontroller når de dekker behovet.
- Bruk SF Symbols for generelle handlinger og status der symbolene er entydige.
- Vedlikeholdssymboler skal vises sammen med forståelig tekst der det er relevant.
- Ikoner skal ikke være eneste forklaring på en viktig eller uvanlig handling.

## 5. Bilder

Bilder er en kjernekomponent i Tekstilig.

- hovedbildet skal få høy visuell prioritet
- flere bildetyper støttes, blant annet stoffprøve, nærbilde, vaskelapp og oversiktsbilde
- bilder skal beskjæres/presenteres konsekvent uten å ødelegge originalfilen
- thumbnail/forhåndsvisning kan optimaliseres separat fra originalen

## 6. Plattformtilpasning

### iPhone

Prioriter fotografering, hurtigregistrering, oppslag og enkel redigering. Vanlige handlinger skal være tilgjengelige med få steg.

### iPad

Samme grunnflyt som iPhone, men større flate kan brukes til bedre oversikt, samtidige paneler og mer effektiv redigering.

### Mac

Mac er sekundær i første native fase. Senere skal plassen utnyttes til administrasjon, avansert søk, filtre og oversikt fremfor å kopiere mobil-layout direkte.

## 7. Forholdet til PWA-design

PWA-en er en teknisk PoC og referanse. Farge- og layoutvalg derfra kan inspirere native klient, men skal ikke kopieres mekanisk. SwiftUI-versjonen skal følge Apple-plattformenes native mønstre der dette gir bedre tilgjengelighet, respons og vedlikeholdbarhet.

## 8. Endringsregel

Nye overordnede beslutninger om visuell stil eller typografi skal dokumenteres her. Brukerflyt og informasjonsarkitektur dokumenteres fortsatt i `UX-FLYTER.md`.
