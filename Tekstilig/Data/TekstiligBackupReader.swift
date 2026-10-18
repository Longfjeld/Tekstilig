import Foundation

/// Read-only reader for the ZIP32/stored backup format written by TekstiligBackupZIP.
/// No CloudKit operations or filesystem extraction are performed.
@MainActor
struct TekstiligBackupReader {
    enum ImportError: LocalizedError {
        case invalid(String)
        var errorDescription: String? {
            switch self { case .invalid(let reason): return "Ugyldig backup: \(reason)" }
        }
    }

    struct Result {
        let document: TekstiligBackupDocument
        let imageCount: Int
        let pieceCount: Int
    }

    func read(_ data: Data) throws -> Result {
        let b = Array(data)
        func u16(_ p: Int) throws -> Int {
            guard p >= 0, p <= b.count - 2 else { throw ImportError.invalid("Avkortet ZIP") }
            return Int(b[p]) | (Int(b[p + 1]) << 8)
        }
        func u32(_ p: Int) throws -> Int {
            let low = try u16(p), high = try u16(p + 2)
            return low | (high << 16)
        }
        guard b.count >= 22 else { throw ImportError.invalid("ZIP mangler sluttregister") }
        let end = b.count - 22
        guard try u32(end) == 0x06054b50, try u16(end + 20) == 0,
              try u16(end + 4) == 0, try u16(end + 6) == 0,
              try u16(end + 8) == u16(end + 10) else {
            throw ImportError.invalid("Ustøttet ZIP-struktur")
        }
        let count = try u16(end + 10)
        let centralSize = try u32(end + 12)
        let centralStart = try u32(end + 16)
        guard centralStart <= end, centralSize == end - centralStart else {
            throw ImportError.invalid("Ugyldig ZIP-indeks")
        }
        var cursor = centralStart
        var files: [String: Data] = [:]
        for _ in 0..<count {
            guard try u32(cursor) == 0x02014b50,
                  try u16(cursor + 10) == 0, // stored, not compressed
                  try u16(cursor + 8) & 0x0008 == 0, // no data descriptors
                  try u32(cursor + 20) == u32(cursor + 24) else {
                throw ImportError.invalid("Ustøttet ZIP-oppføring")
            }
            let crc = try u32(cursor + 16)
            let size = try u32(cursor + 20)
            let nameSize = try u16(cursor + 28)
            let extraSize = try u16(cursor + 30)
            let commentSize = try u16(cursor + 32)
            let offset = try u32(cursor + 42)
            guard cursor <= end - 46, nameSize <= end - cursor - 46,
                  let name = String(bytes: b[(cursor + 46)..<(cursor + 46 + nameSize)], encoding: .utf8),
                  name == "backup.json" || (name.hasPrefix("images/") && name.count > 7 && !name.dropFirst(7).contains("/")),
                  !name.contains(".."), !name.contains("\\"), files[name] == nil else {
                throw ImportError.invalid("Ugyldig eller duplisert filsti")
            }
            guard try u32(offset) == 0x04034b50,
                  try u16(offset + 8) == 0,
                  try u32(offset + 14) == crc,
                  try u32(offset + 18) == size,
                  try u32(offset + 22) == size else {
                throw ImportError.invalid("ZIP-header samsvarer ikke")
            }
            let localNameSize = try u16(offset + 26)
            let localExtraSize = try u16(offset + 28)
            let payloadStart = offset + 30 + localNameSize + localExtraSize
            guard offset <= centralStart - 30, localNameSize <= centralStart - offset - 30,
                  String(bytes: b[(offset + 30)..<(offset + 30 + localNameSize)], encoding: .utf8) == name,
                  payloadStart <= centralStart, size <= centralStart - payloadStart else {
                throw ImportError.invalid("Ugyldig filinnhold")
            }
            let payload = Data(b[payloadStart..<(payloadStart + size)])
            guard Self.crc32(payload) == UInt32(crc) else {
                throw ImportError.invalid("CRC32-feil i \(name)")
            }
            files[name] = payload
            let advance = 46 + nameSize + extraSize + commentSize
            guard advance <= end - cursor else { throw ImportError.invalid("Avkortet ZIP-indeks") }
            cursor += advance
        }
        guard cursor == end, let json = files["backup.json"] else {
            throw ImportError.invalid("Mangler backup.json")
        }
        let document = try TekstiligBackupBuilder().decodeDocument(json)
        guard document.format == TekstiligBackupDocument.currentFormat,
              document.formatVersion == TekstiligBackupDocument.currentFormatVersion else {
            throw ImportError.invalid("Ukjent backupformat eller formatversjon")
        }
        try validateDocument(document, filePaths: Set(files.keys.filter { $0 != "backup.json" }))
        return Result(document: document, imageCount: imagePaths.count,
                      pieceCount: document.textiles.reduce(0) { $0 + $1.pieces.count })
    }

    /// Shared semantic validation for ZIP reading and read-only diagnostic tests.
    func validateDocument(_ document: TekstiligBackupDocument, filePaths: Set<String>) throws {
        guard document.format == TekstiligBackupDocument.currentFormat,
              document.formatVersion == TekstiligBackupDocument.currentFormatVersion else {
            throw ImportError.invalid("Ukjent backupformat eller formatversjon")
        }
        let ids = document.textiles.map(\.textileID)
        guard ids.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }),
              Set(ids).count == ids.count else {
            throw ImportError.invalid("Tomme eller dupliserte tekstil-ID-er")
        }
        let pieces = document.textiles.flatMap(\.pieces).map(\.pieceID)
        guard pieces.allSatisfy({ !$0.isEmpty }), Set(pieces).count == pieces.count else {
            throw ImportError.invalid("Tomme eller dupliserte stoffstykke-ID-er")
        }
        let imagePaths = document.textiles.flatMap(\.images).map(\.backupPath)
        guard Set(imagePaths).count == imagePaths.count,
              Set(imagePaths) == filePaths else {
            throw ImportError.invalid("Bildefilene samsvarer ikke med backup.json")
        }
    }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 { crc = (crc >> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0) }
        }
        return ~crc
    }
}
