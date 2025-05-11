//
//  Hashers.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation
import Crypto

/// A concrete implementation of `MultihashAlgorithm` for SHA-256.
///
/// This struct registers the `"sha2-256"` multicodec (code `0x12`) and hashes input data
/// using `SwiftCrypto`'s `SHA256` algorithm.
public struct SHA256Multihash: MultihashAlgorithm {

    /// The `Multicodec` definition for `sha2-256`.
    public let codec: Multicodec.Codec

    /// Initializes the SHA-256 multihash algorithm.
    public init() {
        self.codec = Multicodec.Codec(name: "sha2-256", codePrefix: 0x12)
    }

    /// Hashes the given data using SHA-256.
    ///
    /// - Parameter data: The input data to hash.
    /// - Returns: The SHA-256 digest of the data.
    public func hash(_ data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }
}
