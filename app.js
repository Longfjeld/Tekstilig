'use strict';

import { CLOUDKIT_CONFIG } from './cloudkit-config.js';

const $ = (id) => document.getElementById(id);
const els = {
  statusPill: $('statusPill'), authPill: $('authPill'), cloudKitSupport: $('cloudKitSupport'), containerId: $('containerId'),
  environment: $('environment'), origin: $('origin'), configNotice: $('configNotice'), identityInfo: $('identityInfo'),
  textileName: $('textileName'), textileCategory: $('textileCategory'), textileId: $('textileId'), createTextileButton: $('createTextileButton'),
  fetchTextileButton: $('fetchTextileButton'), updateTextileButton: $('updateTextileButton'), textileRecordInfo: $('textileRecordInfo'),
  recordPreview: $('recordPreview'), pieceId: $('pieceId'), pieceWidth: $('pieceWidth'), pieceLength: $('pieceLength'),
  createPieceButton: $('createPieceButton'), pieceRecordInfo: $('pieceRecordInfo'), imageInput: $('imageInput'), imagePreviewWrap: $('imagePreviewWrap'),
  imagePreview: $('imagePreview'), imageMeta: $('imageMeta'), saveImageButton: $('saveImageButton'), fetchImageButton: $('fetchImageButton'),
  imageRecordInfo: $('imageRecordInfo'), cloudImageWrap: $('cloudImageWrap'), cloudImage: $('cloudImage'), clearLogButton: $('clearLogButton'), log: $('log')
};

let container = null;
let database = null;
let userIdentity = null;
let textileRecord = null;
let pieceRecord = null;
let imageRecord = null;
let selectedImage = null;
let selectedImageUrl = null;

const KEYS = {
  textileRecordName: 'tekstilig.poc.textileRecordName',
  pieceRecordName: 'tekstilig.poc.pieceRecordName',
  imageRecordName: 'tekstilig.poc.imageRecordName'
};

function log(message, type = '') {
  const li = document.createElement('li');
  li.textContent = `${new Date().toLocaleTimeString('nb-NO')} – ${message}`;
  if (type) li.className = type;
  els.log.prepend(li);
}

function formatError(error) {
  if (!error) return 'Ukjent feil';
  const parts = [error.message || error.reason || error.toString?.() || 'Ukjent feil'];
  if (error.ckErrorCode) parts.push(`CloudKit: ${error.ckErrorCode}`);
  if (error.serverErrorCode) parts.push(`Server: ${error.serverErrorCode}`);
  return parts.filter(Boolean).join(' · ');
}

function assertResponse(response, operation) {
  if (response?.hasErrors) {
    const error = response.errors?.[0] || new Error(`${operation} returnerte feil.`);
    throw error;
  }
  if (!response?.records?.length) throw new Error(`${operation} returnerte ingen record.`);
  return response.records[0];
}

function fieldValue(record, name) {
  return record?.fields?.[name]?.value ?? null;
}

function compactRecord(record) {
  if (!record) return null;
  const fields = {};
  for (const [key, field] of Object.entries(record.fields || {})) {
    const value = field?.value;
    fields[key] = value instanceof Blob
      ? `[Blob ${value.type || 'ukjent'} · ${value.size} byte]`
      : (value?.downloadURL ? { downloadURL: value.downloadURL, size: value.size } : value);
  }
  return {
    recordType: record.recordType,
    recordName: record.recordName,
    recordChangeTag: record.recordChangeTag,
    fields
  };
}

function renderRecord(record) {
  els.recordPreview.textContent = JSON.stringify(compactRecord(record), null, 2);
}

function setAuthState(identity) {
  userIdentity = identity || null;
  const signedIn = !!userIdentity;
  els.authPill.textContent = signedIn ? 'Innlogget' : 'Ikke innlogget';
  els.authPill.className = `pill ${signedIn ? 'good' : 'warn'}`;
  els.statusPill.textContent = signedIn ? 'CloudKit klar' : 'Venter på innlogging';
  els.statusPill.className = `pill ${signedIn ? 'good' : 'warn'}`;
  els.identityInfo.textContent = signedIn
    ? `CloudKit-session aktiv. userRecordName: ${userIdentity.userRecordName || 'ikke oppgitt'}`
    : 'Ingen aktiv CloudKit-session.';
  updateButtons();
}

function updateButtons() {
  const signedIn = !!userIdentity && !!database;
  const textileKnown = !!(textileRecord || localStorage.getItem(KEYS.textileRecordName));
  const imageKnown = !!(imageRecord || localStorage.getItem(KEYS.imageRecordName));
  els.createTextileButton.disabled = !signedIn;
  els.fetchTextileButton.disabled = !signedIn || !textileKnown;
  els.updateTextileButton.disabled = !signedIn || !textileKnown;
  els.createPieceButton.disabled = !signedIn || !textileKnown;
  els.saveImageButton.disabled = !signedIn || !textileKnown || !selectedImage;
  els.fetchImageButton.disabled = !signedIn || !imageKnown;
}

function renderConfig() {
  const cloudKitAvailable = !!window.CloudKit;
  els.cloudKitSupport.textContent = cloudKitAvailable ? 'Lastet' : 'Ikke tilgjengelig';
  els.containerId.textContent = CLOUDKIT_CONFIG.containerIdentifier;
  els.environment.textContent = CLOUDKIT_CONFIG.environment;
  els.origin.textContent = window.location.origin;

  if (!cloudKitAvailable) {
    els.configNotice.textContent = 'CloudKit JS kunne ikke lastes fra Apple. Kontroller nettverk/Content Blocker og prøv en full reload.';
    els.statusPill.textContent = 'CloudKit JS mangler';
    els.statusPill.className = 'pill warn';
    return false;
  }

  if (window.location.origin !== CLOUDKIT_CONFIG.allowedOrigin) {
    els.configNotice.textContent = `Denne siden kjører fra ${window.location.origin}. Tokenet er konfigurert for ${CLOUDKIT_CONFIG.allowedOrigin}. CloudKit-kall kan derfor bli avvist. Publiser/test fra GitHub Pages-adressen.`;
  } else {
    els.configNotice.textContent = `Konfigurasjonen samsvarer med forventet GitHub Pages-origin ${CLOUDKIT_CONFIG.allowedOrigin}.`;
  }
  return true;
}

async function initializeCloudKit() {
  if (!renderConfig()) return;

  try {
    window.CloudKit.configure({
      locale: 'nb-no',
      containers: [{
        containerIdentifier: CLOUDKIT_CONFIG.containerIdentifier,
        environment: CLOUDKIT_CONFIG.environment,
        apiTokenAuth: {
          apiToken: CLOUDKIT_CONFIG.apiToken,
          persist: true,
          signInButton: { id: 'apple-sign-in-button', theme: 'black' },
          signOutButton: { id: 'apple-sign-out-button', theme: 'black' }
        }
      }]
    });

    container = window.CloudKit.getDefaultContainer();
    database = container.privateCloudDatabase;
    log(`CloudKit konfigurert mot ${CLOUDKIT_CONFIG.containerIdentifier} (${CLOUDKIT_CONFIG.environment}).`, 'success');

    const identity = await container.setUpAuth();
    setAuthState(identity);
    if (identity) log('Eksisterende iCloud-session funnet.', 'success');
    else log('CloudKit er klart. Logg inn med iCloud for å fortsette.');

    container.whenUserSignsIn().then((signedInIdentity) => {
      setAuthState(signedInIdentity);
      log('iCloud-innlogging fullført.', 'success');
    }).catch((error) => log(`Innlogging feilet: ${formatError(error)}`, 'error'));

    container.whenUserSignsOut().then(() => {
      textileRecord = null;
      pieceRecord = null;
      imageRecord = null;
      setAuthState(null);
      log('iCloud-session avsluttet.');
    }).catch((error) => log(`Utlogging feilet: ${formatError(error)}`, 'error'));
  } catch (error) {
    setAuthState(null);
    els.configNotice.textContent = `CloudKit-konfigurasjon feilet: ${formatError(error)}`;
    log(`CloudKit-konfigurasjon feilet: ${formatError(error)}`, 'error');
  }
}

function textileRecordName() {
  return textileRecord?.recordName || localStorage.getItem(KEYS.textileRecordName);
}

async function createTextile() {
  try {
    const now = Date.now();
    const record = {
      recordType: 'Textile',
      fields: {
        textileId: { value: els.textileId.value.trim() || 'T0001', type: 'STRING' },
        name: { value: els.textileName.value.trim() || 'Testtekstil', type: 'STRING' },
        category: { value: els.textileCategory.value.trim() || 'Vevd', type: 'STRING' },
        createdAt: { value: now, type: 'TIMESTAMP' },
        updatedAt: { value: now, type: 'TIMESTAMP' },
        schemaVersion: { value: 1, type: 'INT64' }
      }
    };
    const response = await database.saveRecords(record);
    textileRecord = assertResponse(response, 'Opprett Textile');
    localStorage.setItem(KEYS.textileRecordName, textileRecord.recordName);
    els.textileRecordInfo.textContent = `Textile lagret. recordName: ${textileRecord.recordName}`;
    renderRecord(textileRecord);
    updateButtons();
    log(`Textile opprettet: ${textileRecord.recordName}.`, 'success');
  } catch (error) {
    log(`Opprett Textile feilet: ${formatError(error)}`, 'error');
  }
}

async function fetchTextile() {
  try {
    const recordName = textileRecordName();
    if (!recordName) throw new Error('Ingen Textile recordName er kjent. Opprett en Textile først.');
    const response = await database.fetchRecords(recordName);
    textileRecord = assertResponse(response, 'Les Textile');
    els.textileRecordInfo.textContent = `Textile lest fra CloudKit. recordName: ${textileRecord.recordName}`;
    renderRecord(textileRecord);
    updateButtons();
    log(`Textile lest tilbake: ${textileRecord.recordName}.`, 'success');
  } catch (error) {
    log(`Les Textile feilet: ${formatError(error)}`, 'error');
  }
}

async function updateTextile() {
  try {
    if (!textileRecord) await fetchTextile();
    if (!textileRecord) throw new Error('Kunne ikke hente Textile før oppdatering.');

    const newName = `${fieldValue(textileRecord, 'name') || 'Tekstil'} · oppdatert`;
    textileRecord.fields.name = { value: newName, type: 'STRING' };
    textileRecord.fields.updatedAt = { value: Date.now(), type: 'TIMESTAMP' };
    const response = await database.saveRecords(textileRecord);
    textileRecord = assertResponse(response, 'Oppdater Textile');
    els.textileName.value = newName;
    els.textileRecordInfo.textContent = `Textile oppdatert. recordName: ${textileRecord.recordName}`;
    renderRecord(textileRecord);
    log('Textile ble endret og lagret med gjeldende recordChangeTag.', 'success');
  } catch (error) {
    log(`Oppdater Textile feilet: ${formatError(error)}`, 'error');
  }
}

async function createPiece() {
  try {
    const parentTextileId = fieldValue(textileRecord, 'textileId') || els.textileId.value.trim() || 'T0001';
    const record = {
      recordType: 'Piece',
      fields: {
        pieceId: { value: els.pieceId.value.trim() || 'P001', type: 'STRING' },
        textileId: { value: parentTextileId, type: 'STRING' },
        lengthCm: { value: Number(els.pieceLength.value) || 0, type: 'INT64' },
        widthCm: { value: Number(els.pieceWidth.value) || 0, type: 'INT64' },
        reservedLengthCm: { value: 0, type: 'INT64' },
        project: { value: '', type: 'STRING' }
      }
    };
    const response = await database.saveRecords(record);
    pieceRecord = assertResponse(response, 'Opprett Piece');
    localStorage.setItem(KEYS.pieceRecordName, pieceRecord.recordName);
    els.pieceRecordInfo.textContent = `Piece lagret. recordName: ${pieceRecord.recordName}`;
    renderRecord(pieceRecord);
    log(`Piece opprettet: ${pieceRecord.recordName}.`, 'success');
  } catch (error) {
    log(`Opprett Piece feilet: ${formatError(error)}`, 'error');
  }
}

async function saveImage() {
  if (!selectedImage) return;
  try {
    const parentTextileId = fieldValue(textileRecord, 'textileId') || els.textileId.value.trim() || 'T0001';
    const imageId = `IMG-${Date.now()}`;
    const record = {
      recordType: 'TextileImage',
      fields: {
        imageId: { value: imageId, type: 'STRING' },
        textileId: { value: parentTextileId, type: 'STRING' },
        type: { value: 'fabric', type: 'STRING' },
        primary: { value: 1, type: 'INT64' },
        fileName: { value: selectedImage.name || `${imageId}.jpg`, type: 'STRING' },
        contentType: { value: selectedImage.type || 'application/octet-stream', type: 'STRING' },
        imageAsset: { value: selectedImage, type: 'ASSET' }
      }
    };
    const response = await database.saveRecords(record);
    imageRecord = assertResponse(response, 'Lagre TextileImage');
    localStorage.setItem(KEYS.imageRecordName, imageRecord.recordName);
    els.imageRecordInfo.textContent = `TextileImage lagret. recordName: ${imageRecord.recordName}`;
    renderRecord(imageRecord);
    updateButtons();
    log(`Bilde lagret som CloudKit Asset: ${imageRecord.recordName}.`, 'success');
  } catch (error) {
    log(`Lagre bilde feilet: ${formatError(error)}`, 'error');
  }
}

async function fetchImage() {
  try {
    const recordName = imageRecord?.recordName || localStorage.getItem(KEYS.imageRecordName);
    if (!recordName) throw new Error('Ingen TextileImage recordName er kjent.');
    const response = await database.fetchRecords(recordName);
    imageRecord = assertResponse(response, 'Les TextileImage');
    const asset = fieldValue(imageRecord, 'imageAsset');
    if (!asset?.downloadURL) throw new Error('Recorden inneholder ikke en downloadURL for imageAsset.');
    const filename = encodeURIComponent(fieldValue(imageRecord, 'fileName') || 'tekstilig-bilde');
    els.cloudImage.src = asset.downloadURL.replace('${f}', filename);
    els.cloudImageWrap.hidden = false;
    els.imageRecordInfo.textContent = `TextileImage lest tilbake. recordName: ${imageRecord.recordName}`;
    renderRecord(imageRecord);
    log('TextileImage og Asset-URL lest tilbake fra CloudKit.', 'success');
  } catch (error) {
    log(`Les bilde feilet: ${formatError(error)}`, 'error');
  }
}

els.createTextileButton.addEventListener('click', createTextile);
els.fetchTextileButton.addEventListener('click', fetchTextile);
els.updateTextileButton.addEventListener('click', updateTextile);
els.createPieceButton.addEventListener('click', createPiece);
els.saveImageButton.addEventListener('click', saveImage);
els.fetchImageButton.addEventListener('click', fetchImage);
els.clearLogButton.addEventListener('click', () => { els.log.innerHTML = ''; });
els.imageInput.addEventListener('change', () => {
  selectedImage = els.imageInput.files?.[0] || null;
  if (!selectedImage) return;
  if (selectedImageUrl) URL.revokeObjectURL(selectedImageUrl);
  selectedImageUrl = URL.createObjectURL(selectedImage);
  els.imagePreview.src = selectedImageUrl;
  els.imagePreviewWrap.hidden = false;
  els.imageMeta.textContent = `${selectedImage.name || 'Kamerabilde'} · ${(selectedImage.size / 1024 / 1024).toFixed(2)} MB · ${selectedImage.type || 'ukjent format'}`;
  updateButtons();
  log('Bilde valgt for CloudKit Asset-test.');
});

renderConfig();
updateButtons();
initializeCloudKit();

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch((error) => log(`Service worker: ${error.message}`, 'error')));
}
