# Datamodell

**Status:** Datamodell v1  
**Schema:** 1

Dette dokumentet er den autoritative beskrivelsen av datamodellen for Tekstilig.

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
