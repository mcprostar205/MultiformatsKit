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

    /// A codec representing CBOR data (code prefix `0x51`).
    public static let cbor: Codec = {
        return Codec(name: "cbor", codePrefix: 0x51)
    }()

    /// A codec representing raw binary data (code prefix `0x55`).
    public static let raw: Codec = {
        return Codec(name: "raw", codePrefix: 0x55)
    }()

    /// A codec representing MerkleDAG Protobuf nodes (code prefix `0x70`).
    public static let dagPB: Codec = {
        return Codec(name: "dag-pb", codePrefix: 0x70)
    }()

    /// A codec representing "MerkleDAG-CBOR" (code prefix `0x71`).
    public static let dagCBOR: Codec = {
        return Codec(name: "dag-cbor", codePrefix: 0x71)
    }()

    /// A codec representing a Libp2p Public Key (code prefix `0x72`).
    public static let libp2pKey: Codec = {
        return Codec(name: "libp2p-key", codePrefix: 0x72)
    }()

    /// Returns all predefined codec cases.
    ///
    /// Useful for lookup, debugging, and validation against known multicodecs.
    public static let allCases: [Codec] = {
        return [
            Multicodec.cbor,
            Multicodec.raw,
            Multicodec.dagPB,
            Multicodec.dagCBOR,
            Multicodec.libp2pKey
        ]
    }()

    /// A struct representing a single codec entry with a name and numeric code prefix.
    ///
    /// This is used to wrap and unwrap data with a multicodec prefix, allowing for type identification in
    /// content-addressed systems.
    ///
    /// The `wrap(_:)` method prepends the codec’s prefix to raw data.
    /// The `unwrap(_:)` method verifies the prefix and returns the original data.
    ///
    /// - Note: The prefix is always a single byte (`UInt8`) in this implementation.
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
}
