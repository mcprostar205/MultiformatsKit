//
//  CID.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-24.
//

import Foundation

/// A self-describing, content-addressed identifier.
///
/// This implementation supports both CIDv0 and CIDv1. It provides regular encoding and decoding methods
/// instead of conforming to Codable.
public struct CID: Sendable, Hashable {

    /// The version of the CID.
    public enum CIDVersion: UInt8, Sendable, Hashable {
        case v0 = 0
        case v1 = 1
    }

    /// The CID version.
    public let version: CIDVersion

    /// The content-type multicodec.
    public let codec: Multicodec

    /// The multihash of the addressed content.
    public let multihash: Data

    /// The raw binary representation of the CID.
    public var rawData: Data {
        switch version {
            case .v0:
                // For CIDv0, the raw data is simply the multihash.
                return multihash
            case .v1:
                // For CIDv1, encode as [varint(version)] + [varint(codec code)] + [multihash].
                var data = Data()
                data.append((try! Varint.encode(UInt64(version.rawValue))))

                let codecVarint = try! Varint.encode(UInt64(codec.code))
                data.append(codecVarint)
                data.append(multihash)
                return data
        }
    }

    /// Returns the canonical string representation of the CID.
    ///
    /// For CIDv0, this is the base58btc-encoded multihash.
    /// For CIDv1, this is the multibase (base32-lowercase) encoded string.
    public var canonicalString: String {
        switch version {
            case .v0:
                let base58 = BaseX(alphabet: BaseCodec.base58btc)
                return base58.encode(rawData)
            case .v1:
                return BaseCodec.base32Lower.prefix + BaseCodec.base32Lower.encode(rawData)
        }
    }

    /// Creates a new CID from its components.
    ///
    /// - Parameters:
    ///   - version: The CID version. For CIDv0, only `.v0` is allowed.
    ///   - codec: The content-type multicodec. For CIDv0, this must be dag-pb (code 0x70).
    ///   - multihash: The multihash data. For CIDv0 it must be exactly 34 bytes long with a SHA2‑256 prefix.
    ///
    /// - Throws: A `CIDError` if the provided parameters do not form a valid CID.
    public init(version: CIDVersion, codec: Multicodec, multihash: Data) throws {
        if version == .v0 {
            // For CIDv0, validate the multihash:
            guard multihash.count == 34,
                  multihash.first == 0x12,
                  multihash[multihash.index(multihash.startIndex, offsetBy: 1)] == 0x20 else {
                throw CIDError.invalidMultihashForCIDv0
            }
            // Also, for CIDv0 the codec must be dag-pb (code 0x70).
            guard codec.code == 0x70 else {
                throw CIDError.invalidCID("For CIDv0, codec must be dag-pb (code 0x70)")
            }
        }
        self.version = version
        self.codec = codec
        self.multihash = multihash
    }

    /// Creates a new CID from its raw binary representation.
    ///
    /// - Parameter rawData: The binary CID.
    ///
    /// - Throws: A `CIDError` if the binary data does not represent a valid CID.
    public init(rawData: Data) async throws {
        // Check for CIDv0: exactly 34 bytes, starting with 0x12, 0x20.
        if rawData.count == 34,
           rawData.first == 0x12,
           rawData[rawData.index(rawData.startIndex, offsetBy: 1)] == 0x20 {
            let dagPB = try Multicodec(name: "dag-pb", tag: "dag-pb", code: 0x70, status: .permanent)
            self.version = .v0
            self.codec = dagPB
            self.multihash = rawData
        } else {
            // Otherwise, decode as a CIDv1 with varint‑encoded fields.
            let (versionValue, versionByteCount) = try Varint.decodeRaw(from: rawData)
            guard versionValue == 1 else {
                throw CIDError.invalidVersion(versionValue)
            }
            let remainderAfterVersion = rawData.dropFirst(versionByteCount)
            let (codecValue, codecByteCount) = try Varint.decodeRaw(from: remainderAfterVersion)
            let codecCode = Int(codecValue)
            // For simplicity, if the codec code is dag-pb (0x70) we use it; otherwise, create a placeholder.
            let codec: Multicodec
            codec = try await MulticodecRegistry.shared.get(code: codecCode)

            let remaining = remainderAfterVersion.dropFirst(codecByteCount)
            self.version = .v1
            self.codec = codec
            self.multihash = Data(remaining)
        }
    }

    /// Creates a new CID from its string representation.
    ///
    /// - Parameter string: The string representation of the CID.
    ///
    /// - Throws: A `CIDError` if the string cannot be decoded as a valid CID.
    public init(string: String) async throws {
        // Heuristic for CIDv0: 46-character strings starting with "Qm".
        if string.count == 46 && string.hasPrefix("Qm") {
            let base58 = BaseX(alphabet: BaseCodec.base58btc)
            let data = try base58.decode(string)
            try await self.init(rawData: data)
        } else {
            // Otherwise, assume a multibase-encoded CIDv1.
            guard let mbPrefix = string.first else {
                throw CIDError.invalidCID("Empty string")
            }
            // In this example, we only support base32-lowercase (prefix "b") for CIDv1.
            if Character(extendedGraphemeClusterLiteral: mbPrefix) == Character(BaseCodec.base32Lower.prefix) {
                let encodedPart = String(string.dropFirst())
                let rawData = try BaseCodec.base32Lower.decode(encodedPart)
                try await self.init(rawData: rawData)
            } else {
                throw CIDError.invalidCID("Unsupported multibase prefix: \(mbPrefix)")
            }
        }
    }

    /// Encodes the CID into its canonical string representation.
    ///
    /// - Returns: A string representing the CID.
    public func encode() -> String {
        return canonicalString
    }

    /// Decodes a CID from its string representation.
    ///
    /// - Parameter string: The string representation of the CID.
    /// - Returns: A valid `CID` instance.
    ///
    /// - Throws: A `CIDError` if decoding fails.
    public static func decode(from string: String) async throws -> CID {
        return try await CID(string: string)
    }
}
