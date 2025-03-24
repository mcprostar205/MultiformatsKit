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
        let code = try? Varint.encode(UInt64(codec.code))
        let length = try? Varint.encode(UInt64(digest.count))
        return (code ?? Data()) + (length ?? Data()) + digest
    }

    public static func decode(_ data: Data) async throws -> Multihash {
        let (codec, digest) = try await MulticodecRegistry.shared.unwrap(data)
        return Multihash(codec: codec, digest: digest)
    }
}
