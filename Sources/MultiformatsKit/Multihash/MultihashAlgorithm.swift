//
//  MultihashAlgorithm.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A protocol representing a hashing algorithm supported by the multihash specification.
///
/// Implementers of this protocol provide both the underlying digest algorithm (e.g., SHA-256),
/// and the associated `Multicodec` identifier for that algorithm.
///
/// Conforming types must be `Sendable`.
///
/// This protocol is used by `MultihashFactory` to compute multihashes dynamically.
public protocol MultihashAlgorithm: Sendable {

    /// The `Multicodec` that identifies this hash algorithm.
    var codec: Multicodec { get }

    /// Hashes the input data and returns the resulting digest.
    ///
    /// - Parameter data: The input data to hash.
    /// - Returns: The raw digest (not yet wrapped as a multihash).
    func hash(_ data: Data) -> Data
}
