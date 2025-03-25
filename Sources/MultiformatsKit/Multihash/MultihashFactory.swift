//
//  MultihashFactory.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A global factory for registering and using multihash algorithms.
///
/// The `MultihashFactory` lets you:
/// - Register hashing algorithms conforming to `MultihashAlgorithm`.
/// - Compute multihashes on-demand using the algorithm’s name.
///
/// This is useful when working with dynamic multihash creation across different hash functions.
///
/// ```swift
/// Task {
///     do {
///         let data = Data("hello".utf8)
///         let algorithm = try SHA256Multihash()
///         try await MultihashFactory.shared.register(algorithm)
///
///         let multihash = try await MultihashFactory.shared.hash(using: "sha2-256", data: data)
///         print(multihash.encoded.map { String(format: "%02x", $0) }.joined())
///     } catch {
///         throw error
///     }
/// }
/// ```
public actor MultihashFactory {

    /// A shared instance of `MultihashFactory`
    public static let shared = MultihashFactory()

    /// A registry of registered algorithms by name.
    private var algorithms: [String: MultihashAlgorithm] = [:]

    /// Registers a multihash algorithm for later use.
    ///
    /// - Parameter algorithm: The algorithm to register.
    ///
    /// - Throws: If the codec associated with the algorithm is already registered and conflicts.
    public func register(_ algorithm: MultihashAlgorithm) async throws {
        try await MulticodecRegistry.shared.register(algorithm.codec)
        algorithms[algorithm.codec.name] = algorithm
    }

    /// Computes a multihash for the given data using a registered algorithm name.
    ///
    /// - Parameters:
    ///   - name: The name of the algorithm (e.g., `"sha2-256"`).
    ///   - data: The data to hash.
    /// - Returns: A `Multihash` value.
    ///
    /// - Throws: If the algorithm name is not registered.
    public func hash(using name: String, data: Data) throws -> Multihash {
        guard let algorithm = algorithms[name] else {
            throw MulticodecError.notRegistered(id: name)
        }

        return Multihash(codec: algorithm.codec, digest: algorithm.hash(data))
    }
}
