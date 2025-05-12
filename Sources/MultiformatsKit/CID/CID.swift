//
//  CID.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-24.
//

import Foundation

/// A self-describing content-addressed identifier.
///
/// A CID wraps a content type (``Multicodec``), a content-addressing hash (``Multihash``), and
/// a version number. CIDs are the foundation of IPFS, IPLD, and other distributed systems built
/// on content addressing.
///
/// This implementation supports:
/// - CIDv0: Strictly SHA2-256 multihash, Base58BTC-encoded (used in legacy IPFS).
/// - CIDv1: Flexible version supporting multibase, multicodec, and any valid multihash.
///
/// - Note: CIDv0 can only use `sha2-256` as the multihash, must be exactly 34 bytes,
/// and is always base58btc-encoded.
///
/// ### Example (CIDv1)
/// ```swift
/// Task {
///     do {
///         let text = "Hello, World!"
///
///         let cid = CID(version: .v1, content: content)
///
///         // Encode the CID.
///         let encodedCID = try cid.encode()
///         print(encodedCID) // Encoded as: bafybeiadp6jhqmgdkmf7tlyimehev3wog2ghn6n6ojdqtfzmja3a7ky6rm
///
///         // Decode the CID.
///         let decodedCID = try await CID.decode(from: "bafybeiadp6jhqmgdkmf7tlyimehev3wog2ghn6n6ojdqtfzmja3a7ky6rm")
///         // Decoded as: [0x01, 0x70, 0x12, 0x20, 0x03, 0x7f, 0x92, 0x78, 0x30, 0xc3, 0x53, 0x0b, 0xf9, 0xaf, 0x08, 0x61, 0x0e, 0x4a, 0xee, 0xce, 0x36, 0x8c, 0x76, 0xf9, 0xbe, 0x72, 0x47, 0x09, 0x97, 0x2c, 0x48, 0x36, 0x0f, 0xab, 0x1e, 0x8b]
///         print(decodedCID)
///     } catch {
///         throw error
///     }
/// }
/// ```
///
/// ### Example (CIDv0)
/// ```swift
/// Task {
///     do {
///         let text = "Hello, World!"
///
///         let cid = CID(version: .v0, content: content)
///
///         // Encode the CID.
///         let encodedCID = try cid.encode()
///         print(encodedCID) // Encoded as: QmNaJkvSxpCskJLtDajChFFQGsNDu9HCNc6XeWxep5Nf7p
///
///         // Decode the CID.
///         let decodedCID = try await CID.decode(from: "QmNaJkvSxpCskJLtDajChFFQGsNDu9HCNc6XeWxep5Nf7p")
///         // Decoded as: [0x12, 0x20, 0xdf, 0xfd, 0x60, 0x21, 0xbb, 0x2b, 0xd5, 0xb0, 0xaf, 0x67, 0x62, 0x90, 0x80, 0x9e, 0xc3, 0xa5, 0x31, 0x91, 0xdd, 0x81, 0xc7, 0xf7, 0x0a, 0x4b, 0x28, 0x68, 0x8a, 0x36, 0x21, 0x82, 0x98, 0x6f]
///         print(decodedCID)
///     } catch {
///         throw error
///     }
/// }
/// ```
public struct CID: Sendable, Hashable {

    /// The version of the CID.
    public enum CIDVersion: UInt8, Sendable, Hashable {

        /// Version 0.
        case v0 = 0

        /// Version 1.
        case v1 = 1
    }

    /// The CID version.
    public let version: CIDVersion

    /// The content-type multicodec.
    public let codec: Multicodec.Codec

    /// The multihash of the addressed content.
    public let multihash: Data

    /// The raw binary representation of the CID.
    public var rawData: Data {
        get throws {
            switch version {
                case .v0:
                    return multihash
                case .v1:
                    let versionEncoded = try Varint.encode(UInt64(version.rawValue))
                    let codecEncoded = try Varint.encode(UInt64(codec.codePrefix))

                    var data = Data()
                    data.append(versionEncoded)
                    data.append(codecEncoded)
                    data.append(multihash)
                    return data
            }
        }
    }

    /// Returns the canonical string representation of the CID.
    ///
    /// For CIDv0, this is the base58btc-encoded multihash.
    /// For CIDv1, this is the multibase (base32-lowercase) encoded string.
    ///
    /// - Throws: A `CIDError` if encoding fails.
    /// - Returns: The string representation.
    public var canonicalString: String {
        get throws {
            switch version {
                case .v0:
                    return Multibase.base58btc.encode(try rawData)
                case .v1:
                    return Multibase.base32Lower.prefix + Multibase.base32Lower.encode(try rawData)
            }
        }
    }

    /// Creates a new `CID`.
    ///
    /// For CIDv0:
    /// - Only `.v0` is allowed.
    /// - The multicodec must be `dag-pb` (code `0x70`).
    /// - The multihash must be a `sha2-256` hash.
    ///
    /// - Parameters:
    ///   - version: The CID version.
    ///   - codec: The content-type multicodec.
    ///   - multihash: The multihash data.
    ///
    /// - Throws: A `CIDError` if the provided parameters do not form a valid CID.
    public init(version: CIDVersion, codec: Multicodec.Codec, multihash: Data) throws {
        if version == .v0 {
            // For CIDv0, validate the multihash:
            guard multihash.count == 34,
                  multihash.first == 0x12,
                  multihash[multihash.index(multihash.startIndex, offsetBy: 1)] == 0x20 else {
                throw CIDError.invalidMultihashForCIDv0
            }
            // Also, for CIDv0 the codec must be dag-pb (code 0x70).
            guard codec.codePrefix == 0x70 else {
                throw CIDError.invalidCID(message: "For CIDv0, codec must be dag-pb (code 0x70)")
            }
        }

        self.version = version
        self.codec = codec
        self.multihash = multihash
    }

    /// Creates a new `CID` with the pre-defined ``Multicodec`` and ``Multihash`` entries.
    ///
    /// This initializer will automatically add a "dag-pb" multicodec and "sha-256" hash, if it
    /// hasn't been added yet.
    ///
    /// - Parameters:
    ///   - version: The CID version. Defaults to `.v1`.
    ///   - content: The `String` object containing the text.
    ///
    /// - Throws: An error if the `String` fails to be converted to a `Data` object, or if the
    /// provided parameters do not form a valid CID.
    public init(version: CIDVersion = .v1, content: String) async throws {

        // Auto-create the `String` into a `Data` object.
        guard let text = content.data(using: .utf8) else {
            throw CIDError.invalidDataConversion(content: content)
        }

        // Register the multihash algorithm.
        try await MultihashFactory.shared.register(SHA256Multihash())

        // Create multihash with the content, then create the CID.
        let multihash = try await MultihashFactory.shared.hash(using: "sha2-256", data: text)
        try self.init(version: version, codec: Multicodec.dagPB, multihash: multihash.encoded)
    }

    /// Creates a new `CID` using raw `Data` as the content source.
    ///
    /// This initializer will automatically add a "dag-pb" multicodec and "sha-256" hash, if it
    /// hasn't been added yet.
    ///
    /// - Parameters:
    ///   - version: The CID version. Defaults to `.v1`.
    ///   - data: The `Data` object to be hashed and embedded in the CID.
    ///
    /// - Throws: An error if the `String` fails to be converted to a `Data` object, or if the
    /// provided parameters do not form a valid CID.
    public init(version: CIDVersion = .v1, data: Data) async throws {

        // Register the multihash algorithm.
        try await MultihashFactory.shared.register(SHA256Multihash())

        let multihash = try await MultihashFactory.shared.hash(using: "sha2-256", data: data)
        try self.init(version: version, codec: Multicodec.dagPB, multihash: multihash.encoded)
    }

    /// Initializes a `CID` from its raw binary representation.
    ///
    /// This initializer automatically detects and decodes one of the following:
    /// - **CIDv0**: If the data is exactly 34 bytes and starts with a valid `sha2-256`
    /// multihash `(0x12, 0x20`), the CID is treated as version 0 with the `dag-pb` codec.
    /// - **CIDv1**: Otherwise, it parses a CIDv1 with varint-encoded fields:
    /// [version] + [codec] + [multihash].
    ///
    /// The raw data must match the format produced by a prior `.rawData` encoding of a CID.
    ///
    /// - Parameter rawData: A binary representation of a CID (either v0 or v1).
    ///
    /// - Throws: A `CIDError` if the binary data does not represent a valid CID.
    public init(rawData: Data) throws {
        // Check for CIDv0: exactly 34 bytes, starting with 0x12, 0x20.
        if rawData.count == 34,
           rawData.first == 0x12,
           rawData[rawData.index(rawData.startIndex, offsetBy: 1)] == 0x20 {
            let dagPB = Multicodec.dagCBOR
            self.version = .v0
            self.codec = dagPB
            self.multihash = rawData
        } else {
            // Otherwise, decode as a CIDv1 with varint‑encoded fields.
            let (versionValue, versionByteCount) = try Varint.decodeRaw(from: rawData)
            guard versionValue == 1 else {
                throw CIDError.invalidVersion(versionNumber: versionValue)
            }

            let remainderAfterVersion = rawData.dropFirst(versionByteCount)
            let (_, codecByteCount) = try Varint.decodeRaw(from: remainderAfterVersion)

            let remaining = remainderAfterVersion.dropFirst(codecByteCount)
            self.version = .v1
            self.codec = Multicodec.dagPB
            self.multihash = Data(remaining)
        }
    }

    /// Creates a new CID from its string representation.
    ///
    /// - Parameter string: The string representation of the CID.
    ///
    /// - Throws: A `CIDError` if the string cannot be decoded as a valid CID.
    public init(string: String) throws {
        // Heuristic for CIDv0: 46-character strings starting with "Qm".
        if string.count == 46 && string.hasPrefix("Qm") {
            let alphabet = BaseNAlphabet("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
            let base58 = BaseN(alphabet: alphabet)
            let data = try base58.decode(string)

            try self.init(rawData: data)
        } else {
            // Otherwise, assume a multibase-encoded CIDv1.
            guard let mbPrefix = string.first else {
                throw CIDError.invalidCID(message: "Empty CID string")
            }
            // In this example, we only support base32-lowercase (prefix "b") for CIDv1.
            if Character(extendedGraphemeClusterLiteral: mbPrefix) == Character(Multibase.base32Lower.prefix) {
                let encodedPart = String(string.dropFirst())
                let rawData = try Multibase.base32Lower.decode(encodedPart)

                try self.init(rawData: rawData)
            } else {
                throw CIDError.invalidCID(message: "Unsupported multibase prefix: \(mbPrefix)")
            }
        }
    }

    /// Encodes the CID into its canonical string representation.
    ///
    /// - Returns: A string representing the CID.
    ///
    /// - Throws: A `CIDError` if encoding fails.
    public func encode() throws -> String {
        return try canonicalString
    }

    /// Decodes a CID from its string representation.
    ///
    /// - Parameter string: The string representation of the CID.
    /// - Returns: A valid `CID` instance.
    ///
    /// - Throws: A `CIDError` if decoding fails.
    public static func decode(from string: String) throws -> CID {
        return try CID(string: string)
}
