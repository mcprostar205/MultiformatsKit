//
//  MultihashFactory.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

public actor MultihashFactory {
    public static let shared = MultihashFactory()

    private var algorithms: [String: MultihashAlgorithm] = [:]

    public func register(_ algorithm: MultihashAlgorithm) async throws {
        try await MulticodecRegistry.shared.register(algorithm.codec)
        algorithms[algorithm.codec.name] = algorithm
    }

    public func hash(using name: String, data: Data) throws -> Multihash {
        guard let algorithm = algorithms[name] else {
            throw MulticodecError.notRegistered(id: name)
        }
        return Multihash(codec: algorithm.codec, digest: algorithm.hash(data))
    }
}
