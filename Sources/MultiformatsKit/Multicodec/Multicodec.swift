//
//  Multicodec.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-21.
//

import Foundation

/// A data structure that represents a Multicodec entry, as defined in
/// the [Multicodec specification](https://github.com/multiformats/multicodec).
///
/// A Multicodec defines a self-describing format using a compact prefix (`code`) to identify the
/// content type of the associated binary data. Multicodecs are used heavily in protocols such as
/// IPFS, IPLD, libp2p, and others.
///
/// Each instance stores the codec's name, numeric code, usage tag, registration status, and an
/// optional description. The codec can be used to wrap raw binary data with a varint-encoded
/// prefix, and to unwrap that data later.
///
/// Use ``MulticodecRegistry/shared`` to register and retrieve codecs globally, or to validate
/// and organize codecs by tag or status.
///
/// ### Example
///
/// ```swift
/// do {
///     let rawData = Data([0xde, 0xad, 0xbe, 0xef])
///     let codec = try Multicodec(name: "example-codec", tag: "custom", code: 0x300001)
///
///     // Wrap data with varint-encoded codec prefix
///     let wrapped = try codec.wrap(rawData)
///
///     // Later: unwrap the prefix to get the original data
///     let unwrapped = try codec.unwrap(wrapped)
///     print(unwrapped == rawData) // true
/// } catch {
///     throw error
/// }
/// ```


/// A data structure that represents a Multicodec entry, as defined in
/// the [Multicodec specification](https://github.com/multiformats/multicodec).
///
/// A Multicodec defines a self-describing format using a compact prefix (`code`) to identify the
/// content type of the associated binary data. Multicodecs are used heavily in protocols such as
/// IPFS, IPLD, libp2p, and others.
///
/// Each instance stores the codec's name and numeric code. The codec can be used to wrap raw
/// binary data with a varint-encoded prefix, and to unwrap that data later.
///
/// ```swift
/// do {
///
/// } catch {
///     throw error
/// }
/// ```
public enum Multicodec: Sendable, Hashable, Equatable {

    /// CBOR.
    public static let cbor: Codec = {
        return Codec(name: "cbor", codePrefix: 0x51)
    }()

    /// Raw binary.
    public static let raw: Codec = {
        return Codec(name: "raw", codePrefix: 0x55)
    }()

    /// MerkleDAG protobuf.
    public static let dagPB: Codec = {
        return Codec(name: "dag-pb", codePrefix: 0x70)
    }()

    /// MerkleDAG-CBOR.
    public static let dagCBOR: Codec = {
        return Codec(name: "dag-cbor", codePrefix: 0x71)
    }()

    /// Libp2p Public Key.
    public static let libp2pKey: Codec = {
        return Codec(name: "libp2p-key", codePrefix: 0x72)
    }()

    public static let allCases: [Codec] = {
        return [
            Multicodec.cbor,
            Multicodec.raw,
            Multicodec.dagPB,
            Multicodec.dagCBOR,
            Multicodec.libp2pKey
        ]
    }()

    /// A codec supported by `Multicodec`.
    public struct Codec: Sendable, Hashable, Codable {

        /// The name of the codec.
        public let name: String

        /// The code prefix of the codec, encoded as a single byte.
        public let codePrefix: UInt8

        /// Wraps raw binary data with the varint-encoded multicodec prefix.
        ///
        /// - Parameter rawData: The raw binary data to wrap.
        /// - Returns: A `Data` object with the codec prefix prepended.
        public func wrap(_ rawData: Data) -> Data {
            // Encode the single-byte prefix using varint (always 1 byte for UInt8)
            let prefix = Data([codePrefix])
            return prefix + rawData
        }

        /// Unwraps a multicodec-encoded `Data` and verifies the prefix matches this codec.
        ///
        /// - Parameter multicodecData: The data to unwrap.
        /// - Returns: The unwrapped data without the prefix.
        /// 
        /// - Throws: `MulticodecError.mismatchedCode` if the prefix doesn't match.
        public func unwrap(_ multicodecData: Data) throws -> Data {
            guard let firstByte = multicodecData.first else {
                throw MulticodecError.emptyData
            }

            guard firstByte == codePrefix else {
                throw MulticodecError.mismatchedCode(expected: codePrefix, found: firstByte)
            }

            return multicodecData.dropFirst()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(codePrefix)
        }
    }

    /// Errors that may be thrown by `Multicodec`.
    public enum MulticodecError: Error, LocalizedError, Sendable {

        /// The provided data is empty.
        case emptyData

        /// There is a mismatch between the expected and found code.
        ///
        /// - Parameters:
        ///   - expected: The expected code.
        ///   - found: The code that was actually there.
        case mismatchedCode(expected: UInt8, found: UInt8)

        public var errorDescription: String? {
            switch self {
                case .emptyData:
                    return "The provided data is empty."
                case let .mismatchedCode(expected, found):
                    return "Mismatched multicodec code. Expected 0x\(String(format: "%02x", expected)), found 0x\(String(format: "%02x", found))."
            }
        }
    }
}
