//
//  Multihash.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A data structure representing a self-describing multihash, as defined by
/// the [Multihash spec](https://github.com/multiformats/multihash).
///
/// A multihash combines:
/// - A `Multicodec` indicating the hashing algorithm used.
/// - The digest bytes.
/// - A varint-encoded prefix indicating the hash function and length.
///
/// This struct is used in protocols like IPFS, IPLD, libp2p, and CID for verifying
/// data integrity.
public struct Multihash: Hashable, Codable, Sendable {

    /// The multicodec indicating which hash function was used.
    public let codec: Multicodec

    /// The raw digest output from the hash function.
    public let digest: Data

    /// Returns the multihash in its encoded form:
    /// `[varint(codec code)] + [varint(digest length)] + [digest bytes]`.
    public var encoded: Data {
        let code = try? Varint.encode(UInt64(codec.code))
        let length = try? Varint.encode(UInt64(digest.count))
        return (code ?? Data()) + (length ?? Data()) + digest
    }

    /// Initializes a multihash using a codec and digest.
    ///
    /// - Parameters:
    ///   - codec: The multicodec describing the hash function.
    ///   - digest: The raw digest data.
    public init(codec: Multicodec, digest: Data) {
        self.codec = codec
        self.digest = digest
    }

    /// Decodes a multihash from its binary representation.
    ///
    /// - Parameter data: The encoded multihash.
    /// - Returns: A `Multihash` instance.
    ///
    /// - Throws: If the multicodec is not registered, or decoding fails.
    public static func decode(_ data: Data) async throws -> Multihash {
        let (codec, digest) = try await MulticodecRegistry.shared.unwrap(data)
        return Multihash(codec: codec, digest: digest)
    }
}
