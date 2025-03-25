//
//  MultibaseSuite.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-25.
//

import Foundation
import Testing
@testable import MultiformatsKit

@Suite("Multibase Suite") struct MultibaseSuite {

    @Suite("BaseX Tests") struct BaseXTests {
        @Test("Roundtrips between decoding and encoding base58btc.")
        func base32RoundTrip() async throws {
            let baseEncoder = BaseCodec.base32Lower
            let encodedResult = try baseEncoder.decode("I'm feeling great today!")

            try #require(encodedResult == Data([0x4a, 0x45, 0x54, 0x57, 0x32, 0x49, 0x44, 0x47, 0x4d, 0x56, 0x53, 0x57, 0x59, 0x32, 0x4c, 0x4f, 0x4d, 0x34, 0x51, 0x47, 0x4f, 0x34, 0x54, 0x46, 0x4d, 0x46, 0x32, 0x43, 0x41, 0x35, 0x44, 0x50, 0x4d, 0x52, 0x51, 0x58, 0x53, 0x49, 0x49]), "The result should be equal to the original data.")

            let decodedResult = baseEncoder.encode(encodedResult)
            #expect(decodedResult == "I'm feeling great today!", "The encoded string should be equal to the original decoded string.")
        }
    }
}
