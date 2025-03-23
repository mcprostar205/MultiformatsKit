//
//  Multihash.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

public struct Multihash: Hashable, Codable, Sendable {
    public let codec: Multicodec
    public let digest: Data

    public init(codec: Multicodec, digest: Data) {
        self.codec = codec
        self.digest = digest
    }

    public var encoded: Data {
        (try? codec.wrap(digest)) ?? Data()
    }

    public static func decode(_ data: Data) async throws -> Multihash {
        let (codec, digest) = try await MulticodecRegistry.shared.unwrap(data)
        return Multihash(codec: codec, digest: digest)
    }
}
