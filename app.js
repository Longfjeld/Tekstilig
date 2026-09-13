import { createBestStorage, detectCapabilities } from './storage.js';

const $ = (id) => document.getElementById(id);
const els = {
  statusPill: $('statusPill'), directorySupport: $('directorySupport'), opfsSupport: $('opfsSupport'), shareSupport: $('shareSupport'),
  storageMode: $('storageMode'), modeExplanation: $('modeExplanation'), connectButton: $('connectButton'), reloadButton: $('reloadButton'),
  connectionInfo: $('connectionInfo'), writeButton: $('writeButton'), testName: $('testName'), testWidth: $('testWidth'), testLength: $('testLength'),
  jsonPreview: $('jsonPreview'), imageInput: $('imageInput'), imagePreviewWrap: $('imagePreviewWrap'), imagePreview: $('imagePreview'), imageMeta: $('imageMeta'),
  saveImageButton: $('saveImageButton'), portableSection: $('portableSection'), exportButton: $('exportButton'), importInput: $('importInput'),
  clearLogButton: $('clearLogButton'), log: $('log')
};

const caps = detectCapabilities();
const storage = createBestStorage();
let selectedImage = null;
let selectedImageUrl = null;

function log(message, type = '') {
  const li = document.createElement('li');
  li.textContent = `${new Date().toLocaleTimeString('nb-NO')} – ${message}`;
  if (type) li.className = type;
  els.log.prepend(li);
}

function setConnected(connected) {
  els.reloadButton.disabled = !connected;
  els.writeButton.disabled = !connected;
  els.exportButton.disabled = !connected;
  els.saveImageButton.disabled = !connected || !selectedImage;
  els.statusPill.textContent = connected ? 'Lagring klar' : 'Ikke tilkoblet';
  els.statusPill.className = `pill ${connected ? 'good' : 'warn'}`;
}

function renderCapabilities() {
  els.directorySupport.textContent = caps.directoryPicker ? 'Ja' : 'Nei';
  els.opfsSupport.textContent = caps.opfs ? 'Ja' : 'Nei';
  els.shareSupport.textContent = caps.fileShare ? 'Ja' : 'Nei / ukjent';

  if (!storage) {
    els.storageMode.textContent = 'Ikke støttet';
    els.modeExplanation.textContent = 'Denne nettleseren mangler både direkte katalogtilgang og OPFS. Prototypen kan ikke utføre lagringstesten.';
    els.connectButton.disabled = true;
    return;
  }

  if (storage.kind === 'folder') {
    els.storageMode.textContent = 'Direkte katalog';
    els.modeExplanation.textContent = 'Nettleseren støtter katalogtilgang. Velg en Tekstilig-katalog; den kan ligge i en lokalt synkronisert iCloud Drive-katalog dersom operativsystemet tilbyr den i filvelgeren.';
  } else {
    els.storageMode.textContent = 'Privat app-lager';
    els.modeExplanation.textContent = 'Safari/iOS gir ikke webappen direkte vedvarende tilgang til en valgfri iCloud Drive-katalog. Prototypen bruker derfor nettleserens private app-lager og tilbyr eksplisitt eksport/import.';
    els.portableSection.hidden = false;
  }
}

async function connect() {
  try {
    const label = await storage.connect();
    els.connectionInfo.textContent = storage.description();
    setConnected(true);
    log(`Lagring klargjort: ${label}`, 'success');
    await readData();
  } catch (error) {
    if (error?.name === 'AbortError') {
      log('Valg av lagring ble avbrutt.');
      return;
    }
    log(`Kunne ikke klargjøre lagring: ${error.message}`, 'error');
  }
}

function makeTestData() {
  const now = new Date().toISOString();
  return {
    schemaVersion: 1,
    textiles: [{
      id: 'T0001',
      name: els.testName.value.trim() || 'Testtekstil',
      category: 'Vevd',
      description: 'Opprettet av lagringsprototypen.',
      tags: ['prototype'],
      colors: [{ group: 'Blå', name: 'Marineblå', hex: '#273448' }],
      pattern: 'Ensfarget',
      materials: [{ material: 'Ull', percent: 80 }, { material: 'Polyester', percent: 20 }],
      pieces: [{
        id: 'P001',
        lengthCm: Number(els.testLength.value) || 0,
        widthCm: Number(els.testWidth.value) || 0,
        quantity: 1,
        reservation: null,
        note: ''
      }],
      weightGsm: 320,
      stretch: { level: 'low', direction: 'width', percent: null },
      shrinkage: { lengthPercent: 3, widthPercent: 1, note: '' },
      properties: ['Mykt', 'Kraftig', 'Godt fall'],
      care: { wash: { allowed: true, temperatureC: 40, cycle: 'normal' }, bleach: 'notAllowed', tumbleDry: 'notAllowed', drying: 'hang', iron: 'medium', dryClean: 'P', notes: '' },
      images: [],
      location: { area: '', shelf: '', container: '' },
      purchase: { supplier: '', purchaseDate: '', pricePerMeter: null, totalPrice: null, currency: 'NOK' },
      notes: '',
      createdAt: now,
      updatedAt: now
    }]
  };
}

async function writeData() {
  try {
    const data = makeTestData();
    await storage.writeData(data);
    els.jsonPreview.textContent = JSON.stringify(data, null, 2);
    log('tekstiler.json ble skrevet.', 'success');
  } catch (error) {
    log(`Skriving feilet: ${error.message}`, 'error');
  }
}

async function readData() {
  try {
    const data = await storage.readData();
    els.jsonPreview.textContent = JSON.stringify(data, null, 2);
    log(`tekstiler.json lest: ${data.textiles?.length ?? 0} tekstil(er).`, 'success');
    return data;
  } catch (error) {
    log(`Lesing feilet: ${error.message}`, 'error');
    throw error;
  }
}

function safeImageName(file) {
  const ext = (file.type.split('/')[1] || 'jpg').replace('jpeg', 'jpg').replace(/[^a-z0-9]/gi, '');
  return `T0001-test-${Date.now()}.${ext}`;
}

async function saveImage() {
  if (!selectedImage) return;
  try {
    const name = safeImageName(selectedImage);
    await storage.writeImage(name, selectedImage);
    log(`Testbilde lagret som bilder/${name}.`, 'success');
  } catch (error) {
    log(`Bildelagring feilet: ${error.message}`, 'error');
  }
}

async function exportData() {
  try {
    const data = await storage.readData();
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const file = new File([blob], 'tekstiler.json', { type: 'application/json' });

    if (navigator.share && navigator.canShare?.({ files: [file] })) {
      await navigator.share({ files: [file], title: 'Tekstilig – tekstiler.json' });
      log('Eksport sendt til systemets delingsdialog.', 'success');
      return;
    }

    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'tekstiler.json';
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
    log('tekstiler.json eksportert som nedlasting.', 'success');
  } catch (error) {
    if (error?.name === 'AbortError') return;
    log(`Eksport feilet: ${error.message}`, 'error');
  }
}

async function importData(file) {
  try {
    const data = JSON.parse(await file.text());
    if (data.schemaVersion !== 1 || !Array.isArray(data.textiles)) throw new Error('Filen ser ikke ut som Tekstilig schemaVersion 1.');
    await storage.writeData(data);
    els.jsonPreview.textContent = JSON.stringify(data, null, 2);
    log(`Importerte ${data.textiles.length} tekstil(er).`, 'success');
  } catch (error) {
    log(`Import feilet: ${error.message}`, 'error');
  }
}

els.connectButton.addEventListener('click', connect);
els.reloadButton.addEventListener('click', readData);
els.writeButton.addEventListener('click', writeData);
els.saveImageButton.addEventListener('click', saveImage);
els.exportButton.addEventListener('click', exportData);
els.importInput.addEventListener('change', () => els.importInput.files?.[0] && importData(els.importInput.files[0]));
els.clearLogButton.addEventListener('click', () => { els.log.innerHTML = ''; });
els.imageInput.addEventListener('change', () => {
  selectedImage = els.imageInput.files?.[0] || null;
  if (!selectedImage) return;
  if (selectedImageUrl) URL.revokeObjectURL(selectedImageUrl);
  selectedImageUrl = URL.createObjectURL(selectedImage);
  els.imagePreview.src = selectedImageUrl;
  els.imagePreviewWrap.hidden = false;
  els.imageMeta.textContent = `${selectedImage.name || 'Kamerabilde'} · ${(selectedImage.size / 1024 / 1024).toFixed(2)} MB · ${selectedImage.type || 'ukjent format'}`;
  els.saveImageButton.disabled = !storage?.directory;
  log('Bilde valgt for test.');
});

renderCapabilities();
setConnected(false);

(async () => {
  if (!storage) return;
  try {
    const ok = await storage.reconnect();
    if (ok) {
      els.connectionInfo.textContent = storage.description();
      setConnected(true);
      log('Eksisterende lagring ble funnet og åpnet.', 'success');
      await readData();
    }
  } catch (error) {
    log(`Automatisk gjenåpning var ikke mulig: ${error.message}`);
  }
})();

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(err => log(`Service worker: ${err.message}`)));
}
