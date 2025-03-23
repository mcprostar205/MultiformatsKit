//
//  Hashers.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation
import Crypto

public struct SHA256Multihash: MultihashAlgorithm {
    public let codec: Multicodec

    public init() throws {
        self.codec = try Multicodec(name: "sha2-256", tag: "sha2", code: 0x12)
    }

    public func hash(_ data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }
}
