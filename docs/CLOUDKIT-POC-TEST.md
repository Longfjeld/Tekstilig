# CloudKit JS PoC – testresultat

**Status:** Avsluttet 2026-09-26  
**Miljø:** Development  
**Resultat:** Records validert; Asset-opplasting stoppet av CORS/preflight

Dette dokumentet er nå en resultatlogg. Det skal ikke brukes som videre testprosedyre. Neste arbeidsveiledning er `SWIFTUI-OPPSTART.md`.

## 1. Publisering

**✅ UTFØRT**

CloudKit PoC 0002 ble publisert på GitHub Pages og riktig versjon ble bekreftet i nettleseren.

## 2. CloudKit-konfigurasjon

**✅ UTFØRT**

Bekreftet:

```text
Container:      iCloud.com.longfjeld.tekstilig
Environment:    development
Pages URL:      https://longfjeld.github.io/Tekstilig/
Allowed Origin: https://longfjeld.github.io
```

## 3. iCloud-innlogging

**✅ UTFØRT**

CloudKit JS autentiserte mot iCloud og privat database kunne brukes.

## 4. Textile

**✅ UTFØRT**

`Textile` måtte først opprettes eksplisitt i Development-schemaet. Deretter fungerte:

1. oppretting
2. lesing
3. endring og ny lagring

Dette korrigerer den opprinnelige antakelsen om at PoC-en kunne basere seg på just-in-time opprettelse av record type.

## 5. Piece

**✅ UTFØRT**

`Piece` måtte først opprettes eksplisitt i Development-schemaet. Deretter fungerte oppretting av `Piece`.

## 6. TextileImage-schema

**✅ UTFØRT**

`TextileImage` ble opprettet eksplisitt med feltene:

| Felt | Type |
|:---|:---|
| `contentType` | String |
| `fileName` | String |
| `imageAsset` | Asset |
| `imageId` | String |
| `primary` | Int(64) |
| `textileId` | String |
| `type` | String |

## 7. Valg av bilde

**✅ UTFØRT**

Webklienten kunne velge bilde og sende filen inn i Asset-flyten.

## 8. Lagre TextileImage som Asset

**❌ IKKE VALIDERT**

CloudKit JS rapporterte:

```text
UNEXPECTED_SERVER_RESPONSE
CKError: NETWORK_ERROR
```

Nettverksanalyse viste at Asset-flyten gikk til:

```text
https://cws.icloud-content.com/.../singleFileUpload
```

Nettleseren rapporterte CORS/preflight-feil:

```text
PreflightMissingAllowOriginHeader
```

og at origin:

```text
https://longfjeld.github.io
```

ikke var tillatt av responsens `Access-Control-Allow-Origin`.

Feilen ble observert i både Safari og Chrome. Development-tokenets Allowed Origin ble kontrollert til `https://longfjeld.github.io`. Som diagnostisk kontroll ble tokenet midlertidig satt til `Any Domain`; samme feil besto.

**Sluttstatus:** PWA-PoC-en stoppes her. Dette dokumenterer det observerte testresultatet; det hevdes ikke at CloudKit JS Assets generelt er umulig, bare at denne løsningen ikke ga en fungerende Asset-flyt i vårt testoppsett.

## 9. Les Asset tilbake

**⏭️ IKKE UTFØRT**

Kan ikke testes meningsfullt før punkt 8 fungerer.

## 10. Kryssenhetstest av bilde

**⏭️ IKKE UTFØRT**

Kan ikke testes meningsfullt før Asset-lagring fungerer.

## 11. Konklusjon

PoC-en har validert CloudKit som backend for strukturerte Tekstilig-records, men ikke bildeopplasting via CloudKit JS/PWA. Videre validering flyttes derfor til SwiftUI/native CloudKit mot samme Development-container.
