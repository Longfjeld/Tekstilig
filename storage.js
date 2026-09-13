const DB_NAME = 'tekstilig-prototype';
const DB_STORE = 'handles';
const DB_KEY = 'data-directory';

function supportsDirectoryPicker() {
  return typeof window.showDirectoryPicker === 'function';
}

function supportsOPFS() {
  return !!navigator.storage?.getDirectory;
}

function openHandleDb() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onupgradeneeded = () => request.result.createObjectStore(DB_STORE);
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
}

async function saveDirectoryHandle(handle) {
  const db = await openHandleDb();
  await new Promise((resolve, reject) => {
    const tx = db.transaction(DB_STORE, 'readwrite');
    tx.objectStore(DB_STORE).put(handle, DB_KEY);
    tx.oncomplete = resolve;
    tx.onerror = () => reject(tx.error);
  });
  db.close();
}

async function getSavedDirectoryHandle() {
  try {
    const db = await openHandleDb();
    const value = await new Promise((resolve, reject) => {
      const tx = db.transaction(DB_STORE, 'readonly');
      const req = tx.objectStore(DB_STORE).get(DB_KEY);
      req.onsuccess = () => resolve(req.result || null);
      req.onerror = () => reject(req.error);
    });
    db.close();
    return value;
  } catch {
    return null;
  }
}

async function verifyPermission(handle, withWrite = true) {
  if (!handle) return false;
  const options = withWrite ? { mode: 'readwrite' } : {};
  if ((await handle.queryPermission?.(options)) === 'granted') return true;
  return (await handle.requestPermission?.(options)) === 'granted';
}

async function writeTextFile(directory, name, text) {
  const fileHandle = await directory.getFileHandle(name, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(text);
  await writable.close();
}

async function readTextFile(directory, name) {
  const fileHandle = await directory.getFileHandle(name);
  const file = await fileHandle.getFile();
  return file.text();
}

async function writeBlobFile(directory, name, blob) {
  const fileHandle = await directory.getFileHandle(name, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(blob);
  await writable.close();
}

export class FolderStorage {
  constructor() {
    this.kind = 'folder';
    this.directory = null;
  }

  async reconnect() {
    const saved = await getSavedDirectoryHandle();
    if (!saved) return false;
    if (!(await verifyPermission(saved))) return false;
    this.directory = saved;
    return true;
  }

  async connect() {
    this.directory = await window.showDirectoryPicker({ id: 'tekstilig-data', mode: 'readwrite' });
    await saveDirectoryHandle(this.directory);
    await this.ensureStructure();
    return this.directory.name;
  }

  async ensureStructure() {
    const images = await this.directory.getDirectoryHandle('bilder', { create: true });
    void images;
    try {
      await this.directory.getFileHandle('tekstiler.json');
    } catch {
      await this.writeData({ schemaVersion: 1, textiles: [] });
    }
  }

  async writeData(data) {
    await writeTextFile(this.directory, 'tekstiler.json', JSON.stringify(data, null, 2));
  }

  async readData() {
    return JSON.parse(await readTextFile(this.directory, 'tekstiler.json'));
  }

  async writeImage(name, blob) {
    const images = await this.directory.getDirectoryHandle('bilder', { create: true });
    await writeBlobFile(images, name, blob);
  }

  description() {
    return `Direkte katalog: ${this.directory?.name || 'ikke valgt'}`;
  }
}

export class OPFSStorage {
  constructor() {
    this.kind = 'opfs';
    this.directory = null;
  }

  async reconnect() {
    if (!supportsOPFS()) return false;
    this.directory = await navigator.storage.getDirectory();
    await this.ensureStructure();
    return true;
  }

  async connect() {
    this.directory = await navigator.storage.getDirectory();
    await this.ensureStructure();
    return 'Tekstilig privat app-lager';
  }

  async ensureStructure() {
    await this.directory.getDirectoryHandle('bilder', { create: true });
    try {
      await this.directory.getFileHandle('tekstiler.json');
    } catch {
      await this.writeData({ schemaVersion: 1, textiles: [] });
    }
  }

  async writeData(data) {
    await writeTextFile(this.directory, 'tekstiler.json', JSON.stringify(data, null, 2));
  }

  async readData() {
    return JSON.parse(await readTextFile(this.directory, 'tekstiler.json'));
  }

  async writeImage(name, blob) {
    const images = await this.directory.getDirectoryHandle('bilder', { create: true });
    await writeBlobFile(images, name, blob);
  }

  description() {
    return 'Privat nettleserlager (OPFS)';
  }
}

export function detectCapabilities() {
  return {
    directoryPicker: supportsDirectoryPicker(),
    opfs: supportsOPFS(),
    fileShare: !!navigator.share && !!navigator.canShare
  };
}

export function createBestStorage() {
  if (supportsDirectoryPicker()) return new FolderStorage();
  if (supportsOPFS()) return new OPFSStorage();
  return null;
}
