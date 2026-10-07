# Datamodell

**Status:** Datamodell v1  
**Schema:** 1

Dette dokumentet er den autoritative beskrivelsen av den **logiske datamodellen** for Tekstilig.

Produksjonslagring er fra beslutning B-023 planlagt i CloudKit. Strukturene i dette dokumentet beskriver derfor domenemodellen og eksportformatet; de trenger ikke lagres som ett fysisk JSON-dokument i CloudKit. `tekstiler.json` beholdes som portabelt eksport-/backupformat. Se `ARKITEKTUR.md` for CloudKit-mapping.

## 1. Toppnivå

`tekstiler.json` skal ha en versjonert toppstruktur.

```json
{
  "schemaVersion": 1,
  "textiles": []
}
```

## 2. Tekstil

| Felt | Type | Påkrevd | Beskrivelse |
|---|---|---:|---|
| `id` | tekst | Ja | Permanent automatisk ID, f.eks. `T0042` |
| `name` | tekst | Ja | Brukerdefinert navn |
| `category` | tekst | Nei | Grunnkonstruksjon/type |
| `description` | tekst | Nei | Kort beskrivelse |
| `tags` | liste | Nei | Frie søkeord |
| `colors` | liste | Nei | Strukturerte farger |
| `pattern` | tekst | Nei | Mønstertype |
| `patternNote` | tekst | Nei | Detaljert mønsterbeskrivelse |
| `materials` | liste | Nei | Fibersammensetning |
| `pieces` | liste | Nei* | Fysiske stoffstykker/beholdning |
| `weightGsm` | tall | Nei | Gram per kvadratmeter |
| `stretch` | objekt | Nei | Elastisitet |
| `shrinkage` | objekt | Nei | Krymp |
| `properties` | liste | Nei | Søkbare egenskaper |
| `care` | objekt | Nei | Vedlikehold |
| `images` | liste | Nei | Bilder |
| `location` | objekt | Nei | Fysisk plassering |
| `purchase` | objekt | Nei | Innkjøpsinformasjon |
| `notes` | tekst | Nei | Fritekst |
| `createdAt` | dato/tid | Ja | Automatisk |
| `updatedAt` | dato/tid | Ja | Automatisk |

`pieces` kan mangle dersom beholdningen er ukjent, men registrering av kjent beholdning skal skje som ett eller flere stoffstykker.

## 3. Kategori

Første standardsett:

- Vevd
- Strikket
- Filt/non-woven
- Kunstskinn/skinn
- Annet
- Ukjent

## 4. Materialer

Materialer lagres strukturert.

```json
"materials": [
  { "material": "Ull", "percent": 80 },
  { "material": "Polyester", "percent": 20 }
]
```

Første standardsett:

- Bomull
- Ull
- Lin
- Silke
- Viskose
- Modal
- Lyocell
- Polyester
- Polyamid
- Akryl
- Elastan
- Acetat
- Annet
- Ukjent

Nye materialnavn skal kunne registreres. Prosentandel er valgfri, og summen trenger ikke være 100 %.

## 5. Farger

Et tekstil kan ha flere farger.

```json
"colors": [
  {
    "group": "Blå",
    "name": "Marineblå",
    "hex": "#273448"
  }
]
```

Fargegruppe brukes til filtrering. `name` og `hex` gir mer presis beskrivelse.

Standardgrupper:

- Hvit
- Beige/natur
- Gul
- Oransje
- Rød
- Rosa
- Lilla
- Blå
- Grønn
- Brun
- Grå
- Sort
- Flerfarget

## 6. Mønster

Første standardsett:

- Ensfarget
- Melert
- Stripet
- Rutet
- Prikket
- Blomstret
- Geometrisk
- Abstrakt
- Motiv/print
- Annet

`patternNote` kan brukes til detaljer, eksempelvis «smale hvite striper, ca. 4 mm».

## 7. Stoffstykker og beholdning

Dimensjoner registreres per fysisk stoffstykke. Intern lengdeenhet er centimeter.

```json
"pieces": [
  {
    "id": "P001",
    "lengthCm": 280,
    "widthCm": 145,
    "quantity": 1,
    "reservation": null,
    "note": ""
  }
]
```

Dette gjør det mulig å skille mellom eksempelvis 4,8 meter totalt og to separate stykker på 2,8 og 2,0 meter.

`quantity` er normalt `1`, men beholdes for identiske separate stykker dersom dette er praktisk.

### Reservasjon

Reservasjon knyttes til stoffstykket, ikke hele tekstilet.

```json
"reservation": {
  "project": "Jakke til Kari",
  "reservedLengthCm": 150,
  "note": ""
}
```

Et stykke kan dermed være delvis reservert. Tilgjengelig sammenhengende mengde må beregnes med hensyn til reservasjonen.

## 8. Vekt

```json
"weightGsm": 320
```

Enhet: g/m².

## 9. Elastisitet

```json
"stretch": {
  "level": "medium",
  "direction": "width",
  "percent": 25
}
```

Grad:

- ingen
- lav
- middels
- høy

Retning:

- lengde
- bredde
- begge
- ikke relevant

`percent` er valgfritt.

## 10. Krymp

```json
"shrinkage": {
  "lengthPercent": 3,
  "widthPercent": 1,
  "note": "Etter vask på 40 °C"
}
```

Lengde og bredde kan registreres separat.

## 11. Egenskaper

Første sett med søkbare egenskaper:

- Tynt
- Middels
- Kraftig
- Mykt
- Stivt
- Godt fall
- Strukturert
- Glatt
- Lodden
- Gjennomsiktig
- Delvis gjennomsiktig
- Ugjennomsiktig
- Vannavvisende
- Vindtett
- Stretch
- Stabilt

Listen kan videreutvikles etter faktisk bruk.

## 12. Vedlikehold

```json
"care": {
  "wash": {
    "allowed": true,
    "temperatureC": 40,
    "cycle": "normal"
  },
  "bleach": "notAllowed",
  "tumbleDry": "notAllowed",
  "drying": "hang",
  "iron": "medium",
  "dryClean": "P",
  "notes": ""
}
```

Vedlikehold skal vises med både symboler og forklarende tekst.

Områder:

- vasketemperatur/program
- bleking
- tørketrommel
- annen tørking, inkludert hengetørk
- stryking
- rens
- merknad

Bilde av vaskelapp kan lagres som supplement, men erstatter ikke strukturerte data.

## 13. Bilder

```json
"images": [
  {
    "id": "IMG001",
    "file": "T0042-main.webp",
    "type": "fabric",
    "primary": true
  }
]
```

Planlagte typer:

- `fabric`
- `closeup`
- `careLabel`
- `full`
- `other`

Ett bilde kan være `primary: true`.

## 14. Plassering

```json
"location": {
  "area": "Arbeidsrom",
  "shelf": "Hylle 3",
  "container": "Kasse B"
}
```

Alle delene er valgfrie og skal kunne brukes til filtrering.

## 15. Innkjøp og pris

Pris er valgfritt.

```json
"purchase": {
  "supplier": "Stoffbutikk",
  "purchaseDate": "2026-09-10",
  "pricePerMeter": 249.00,
  "totalPrice": 697.20,
  "currency": "NOK"
}
```

Meterpris, totalpris eller begge kan registreres.

## 16. Metadata

```json
"createdAt": "2026-09-13T22:45:00+02:00",
"updatedAt": "2026-09-13T22:45:00+02:00"
```

Tidsstempler oppdateres av appen.

## 17. Registreringsnivå

Datamodellen skal ikke føre til et tungt registreringsskjema.

### Minimum

- navn
- kjent dimensjon/beholdning når tilgjengelig

### Sterkt anbefalt

- hovedbilde
- materiale
- farge
- plassering

### Kan kompletteres senere

- vekt
- elastisitet
- krymp
- vedlikehold
- egenskaper
- innkjøp/pris
- øvrige bilder
- notater

## 18. Eksempel

```json
{
  "schemaVersion": 1,
  "textiles": [
    {
      "id": "T0042",
      "name": "Marineblå ull",
      "category": "Vevd",
      "description": "Mykt, relativt kraftig ullstoff med fint fall.",
      "tags": ["jakke", "bukse", "vinter"],
      "colors": [
        { "group": "Blå", "name": "Marineblå", "hex": "#273448" }
      ],
      "pattern": "Ensfarget",
      "materials": [
        { "material": "Ull", "percent": 80 },
        { "material": "Polyester", "percent": 20 }
      ],
      "pieces": [
        {
          "id": "P001",
          "lengthCm": 280,
          "widthCm": 145,
          "quantity": 1,
          "reservation": null,
          "note": ""
        },
        {
          "id": "P002",
          "lengthCm": 180,
          "widthCm": 110,
          "quantity": 1,
          "reservation": {
            "project": "Jakke til Kari",
            "reservedLengthCm": 150,
            "note": ""
          },
          "note": "Rest etter tidligere prosjekt"
        }
      ],
      "weightGsm": 320,
      "stretch": {
        "level": "low",
        "direction": "width",
        "percent": null
      },
      "shrinkage": {
        "lengthPercent": 3,
        "widthPercent": 1,
        "note": "Etter vask på 40 °C"
      },
      "properties": ["Mykt", "Kraftig", "Godt fall", "Ugjennomsiktig"],
      "care": {
        "wash": {
          "allowed": true,
          "temperatureC": 40,
          "cycle": "normal"
        },
        "bleach": "notAllowed",
        "tumbleDry": "notAllowed",
        "drying": "hang",
        "iron": "medium",
        "dryClean": "P",
        "notes": ""
      },
      "images": [
        {
          "id": "IMG001",
          "file": "T0042-main.webp",
          "type": "fabric",
          "primary": true
        }
      ],
      "location": {
        "area": "Arbeidsrom",
        "shelf": "Hylle 3",
        "container": "Kasse B"
      },
      "purchase": {
        "supplier": "Stoffbutikk",
        "purchaseDate": "2026-09-10",
        "pricePerMeter": 249.00,
        "totalPrice": 697.20,
        "currency": "NOK"
      },
      "notes": "",
      "createdAt": "2026-09-13T22:45:00+02:00",
      "updatedAt": "2026-09-13T22:45:00+02:00"
    }
  ]
}
```

## 19. Native implementeringsstatus

Fra kodeleveranse 0006 er `Textile` introdusert som faktisk Swift-domenetype. Dette endrer ikke den logiske modellen over.

Første implementerte persistensutsnitt startet bevisst begrenset til:

- `id` / `textileId`
- `name`
- `category`
- `createdAt`
- `updatedAt`
- `schemaVersion`

Fra devpatch 0005 er den avtalte plasseringen også mappet direkte på `Textile` som valgfrie felt:

- `locationArea`
- `locationShelf`
- `locationContainer`

Fra devpatch 0055 er det generelle fritekstfeltet `notes` også implementert direkte på `Textile`. Feltet er valgfritt, synkroniseres via CloudKit og inngår i klientens fritekstsøk.

Permanent ID for nye native records genereres som `T-<UUID>`. Eksempelet `T0042` i datamodellen beskriver fortsatt en mulig lesbar ID-form, men er ikke et krav til formatet. Viktigste krav er stabil og unik permanent Tekstilig-ID som er uavhengig av CloudKit Record Name.

Fra devpatch 0002 er `Piece` også introdusert som faktisk Swift-domenetype. Første native persistensutsnitt for `Piece` bruker eksisterende CloudKit-schema:

- `pieceId`
- `textileId`
- `lengthCm`
- `widthCm`
- `reservedLengthCm`
- `project`

`quantity`, notat og eventuell rikere reservasjonsmodell fra den logiske modellen over er **ikke fjernet som krav**, men utsettes til en senere eksplisitt schemautvidelse.

Fra devpatch 0003 er `TextileImage` introdusert som faktisk Swift-domenetype. Første produktutsnitt bruker det allerede validerte Development-schemaet:

- `imageId`
- `textileId`
- `type`
- `primary`
- `fileName`
- `contentType`
- `imageAsset`

Første produktimplementering håndterer ett hovedbilde per tekstil og lagrer det som `CKAsset`. Fra devpatch 0055 kan et hovedbilde tas direkte med kamera under hurtigregistrering eller velges fra Bilder. Nye bilder fra hurtigregistreringen normaliseres til JPEG med maksimal lengste side på 2048 piksler og kompresjonskvalitet 0,82 før lagring. Flere bilder, bildetyper og thumbnails kommer senere. Materialer, farger og øvrige tekstilegenskaper kobles på i senere vertikale implementeringssteg.



### Devpatch 0004 – native materiale og farge

Fra devpatch 0004 er strukturerte materialer og farger introdusert som egne Swift-domenetyper og egne CloudKit child-records. Den logiske modellen over er uendret.

`TextileMaterial` bruker:

- `materialId` – permanent ID (`MAT-<UUID>`)
- `textileId` – relasjon til Textile
- `material` – fibertype/materialnavn
- `percent` – valgfri prosentandel 0–100

`TextileColor` bruker:

- `colorId` – permanent ID (`COL-<UUID>`)
- `textileId` – relasjon til Textile
- `group` – søkbar fargegruppe
- `name` – valgfritt beskrivende navn
- `hex` – valgfri `#RRGGBB`-verdi

Denne fysiske CloudKit-mappingen bevarer struktureringen fra seksjon 4 og 5 uten å låse de sammensatte verdiene til ett fritekstfelt. Flere materialer og flere farger kan knyttes til samme tekstil.


### Devpatch 0005 – plassering

Plassering er en 1:1-egenskap ved et tekstil og lagres derfor direkte på `Textile` i CloudKit i stedet for som en egen child-record. Mappingen følger det logiske `location`-objektet:

| Logisk felt | CloudKit-felt | Type |
|:---|:---|:---|
| `location.area` | `locationArea` | String, valgfri |
| `location.shelf` | `locationShelf` | String, valgfri |
| `location.container` | `locationContainer` | String, valgfri |

Alle tre verdiene kan lagres uavhengig av hverandre. Tomme verdier fjernes fra recorden ved lagring. Query-/search-indekser på disse feltene opprettes først når søk og filtre implementeres.

### Devpatch 0055 – generelt notatfelt

Det logiske `notes`-feltet er nå implementert direkte på `Textile` og mappes slik:

| Logisk felt | CloudKit-felt | Type |
|:---|:---|:---|
| `notes` | `notes` | String, valgfri |

Tom verdi fjernes fra recorden ved lagring. Feltet brukes i klientens fritekstsøk uten server-side query-indeks og skal tas med i senere eksport/import.

### Devpatch 0008 – vedlikehold

Fra devpatch 0008 er den logiske `care`-modellen representert native som `TextileCare` og lagret som valgfrie felt på samme CloudKit `Textile`-record. Mappingen er:

| Logisk felt | CloudKit-felt | Type |
|:---|:---|:---|
| `care.wash.allowed` | `careWashAllowed` | Int64, valgfri (`1`/`0`) |
| `care.wash.temperatureC` | `careWashTemperatureC` | Int64, valgfri |
| `care.wash.cycle` | `careWashCycle` | String, valgfri |
| `care.bleach` | `careBleach` | String, valgfri |
| `care.tumbleDry` | `careTumbleDry` | String, valgfri |
| `care.drying` | `careDrying` | String, valgfri |
| `care.iron` | `careIron` | String, valgfri |
| `care.dryClean` | `careDryClean` | String, valgfri |
| `care.notes` | `careNotes` | String, valgfri |

Manglende felt betyr «ikke registrert». Dette er bevisst forskjellig fra kodeverdien `notAllowed`. Vaskens temperatur og program brukes bare når `careWashAllowed = 1`. Første native UI støtter strukturerte valg og forklarende tekst; bilde av vaskelapp forblir et senere supplement.

### Devpatch 0010 – vekt, elastisitet og krymp

Fra devpatch 0010 er de logiske feltene `weightGsm`, `stretch` og `shrinkage` representert native på `Textile` og lagret som valgfrie felt på samme CloudKit-record:

| Logisk felt | CloudKit-felt | Type |
|:---|:---|:---|
| `weightGsm` | `weightGsm` | Int64, valgfri |
| `stretch.level` | `stretchLevel` | String, valgfri |
| `stretch.direction` | `stretchDirection` | String, valgfri |
| `stretch.percent` | `stretchPercent` | Int64, valgfri |
| `shrinkage.lengthPercent` | `shrinkageLengthPercent` | Int64, valgfri |
| `shrinkage.widthPercent` | `shrinkageWidthPercent` | Int64, valgfri |
| `shrinkage.note` | `shrinkageNote` | String, valgfri |

Manglende felt betyr «ikke registrert» og eldre records trenger derfor ingen migrering. Første native versjon lagrer prosentverdier som heltall. Søk-/filterindekser opprettes først sammen med søkefunksjonen.
