import Foundation

/// ZIP32 (stored entries). JPEG/HEIC data is already compressed; no third-party dependency.
/// Input is the private staging directory produced by TekstiligBackupStager.
@MainActor
final class TekstiligBackupZIP {
    enum ZIPError: LocalizedError {
        case tooLarge
        case invalidFile(String)
        var errorDescription: String? {
            switch self {
            case .tooLarge: return "Backupen er for stor for ZIP32-formatet."
            case .invalidFile(let name): return "Ugyldig backupfil: \(name)"
            }
        }
    }

    private struct Entry {
        let name: String
        let size: UInt32
        let crc: UInt32
        let offset: UInt32
    }

    func create(from directory: URL) throws -> URL {
        let fm = FileManager.default
        let output = fm.temporaryDirectory.appendingPathComponent("Tekstilig-backup-\(UUID().uuidString).zip")
        let imageDirectory = directory.appendingPathComponent("images", isDirectory: true)
        let images = try fm.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil)
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        let sources = [directory.appendingPathComponent("backup.json")] + images
        guard sources.count <= Int(UInt16.max) else { throw ZIPError.tooLarge }
        fm.createFile(atPath: output.path, contents: nil)
        do {
            let handle = try FileHandle(forWritingTo: output)
            defer { try? handle.close() }
            var entries: [Entry] = []
            var offset: UInt64 = 0
            func append(_ bytes: Data) throws {
                try handle.write(contentsOf: bytes)
                offset += UInt64(bytes.count)
                guard offset <= UInt64(UInt32.max) else { throw ZIPError.tooLarge }
            }
            for source in sources {
                let name = source.lastPathComponent == "backup.json" ? "backup.json" : "images/" + source.lastPathComponent
                guard !source.hasDirectoryPath, !name.contains(".."), !name.contains("\\") else {
                    throw ZIPError.invalidFile(name)
                }
                let data = try Data(contentsOf: source)
                guard data.count <= Int(UInt32.max) else { throw ZIPError.tooLarge }
                let nameBytes = Data(name.utf8)
                guard nameBytes.count <= Int(UInt16.max) else { throw ZIPError.tooLarge }
                let size = UInt32(data.count)
                let crc = Self.crc32(data)
                let start = UInt32(offset)
                var header = Data()
                header.u32(0x04034b50); header.u16(20); header.u16(0x0800)
                header.u16(0); header.u16(0); header.u16(0)
                header.u32(crc); header.u32(size); header.u32(size)
                header.u16(UInt16(nameBytes.count)); header.u16(0)
                try append(header); try append(nameBytes); try append(data)
                entries.append(Entry(name: name, size: size, crc: crc, offset: start))
            }
            let centralOffset = UInt32(offset)
            for entry in entries {
                let nameBytes = Data(entry.name.utf8)
                var header = Data()
                header.u32(0x02014b50); header.u16(20); header.u16(20)
                header.u16(0x0800); header.u16(0); header.u16(0); header.u16(0)
                header.u32(entry.crc); header.u32(entry.size); header.u32(entry.size)
                header.u16(UInt16(nameBytes.count)); header.u16(0); header.u16(0)
                header.u16(0); header.u16(0); header.u32(0); header.u32(entry.offset)
                try append(header); try append(nameBytes)
            }
            let centralSize = UInt32(offset) - centralOffset
            var end = Data()
            end.u32(0x06054b50); end.u16(0); end.u16(0)
            end.u16(UInt16(entries.count)); end.u16(UInt16(entries.count))
            end.u32(centralSize); end.u32(centralOffset); end.u16(0)
            try append(end)
            return output
        } catch {
            try? fm.removeItem(at: output)
            throw error
        }
    }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                crc = (crc >> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0)
            }
        }
        return ~crc
    }
}

private extension Data {
    mutating func u16(_ value: UInt16) {
        append(UInt8(truncatingIfNeeded: value))
        append(UInt8(truncatingIfNeeded: value >> 8))
    }
    mutating func u32(_ value: UInt32) {
        u16(UInt16(truncatingIfNeeded: value))
        u16(UInt16(truncatingIfNeeded: value >> 16))
    }
}
