import Foundation

/// Reads ZIP32 central directory and checks every stored payload and CRC against staging.
enum BackupZIPVerifier {
    enum VerifyError: LocalizedError {
        case invalid
        var errorDescription: String? { "ZIP-arkivet samsvarer ikke med backupfilene." }
    }
    static func verify(_ zip: Data, expected: [String: Data]) throws {
        let bytes = Array(zip)
        func u16(_ p: Int) throws -> Int {
            guard p >= 0, p + 2 <= bytes.count else { throw VerifyError.invalid }
            return Int(bytes[p]) | Int(bytes[p+1]) << 8
        }
        func u32(_ p: Int) throws -> Int {
            let lo = try u16(p); let hi = try u16(p+2)
            return lo | hi << 16
        }
        guard bytes.count >= 22 else { throw VerifyError.invalid }
        let end = bytes.count - 22
        guard try u32(end) == 0x06054b50 else { throw VerifyError.invalid }
        let count = try u16(end+10)
        var cursor = try u32(end+16)
        var seen = Set<String>()
        guard count == expected.count else { throw VerifyError.invalid }
        for _ in 0..<count {
            guard try u32(cursor) == 0x02014b50 else { throw VerifyError.invalid }
            let crc = try u32(cursor+16)
            let size = try u32(cursor+20)
            let nameLength = try u16(cursor+28)
            let extra = try u16(cursor+30)
            let comment = try u16(cursor+32)
            let localOffset = try u32(cursor+42)
            guard cursor+46+nameLength <= bytes.count else { throw VerifyError.invalid }
            guard let name = String(bytes: bytes[(cursor+46)..<(cursor+46+nameLength)], encoding: .utf8),
                  seen.insert(name).inserted, let reference = expected[name] else { throw VerifyError.invalid }
            guard try u32(localOffset) == 0x04034b50 else { throw VerifyError.invalid }
            let localName = try u16(localOffset+26)
            let localExtra = try u16(localOffset+28)
            let start = localOffset+30+localName+localExtra
            guard size == reference.count, start <= bytes.count, size <= bytes.count-start else { throw VerifyError.invalid }
            let payload = Data(bytes[start..<(start+size)])
            guard payload == reference, crc == Int(crc32(payload)) else { throw VerifyError.invalid }
            cursor += 46+nameLength+extra+comment
        }
        guard seen.count == expected.count else { throw VerifyError.invalid }
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
