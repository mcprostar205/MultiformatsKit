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
        @Test("Roundtrips between decoding and encoding base32.")
        func base32RoundTrip() async throws {
            guard let text = "I'm feeling great today!".data(using: .utf8) else { return }
            let baseEncoder = BaseCodec.base32Lower
            let encodedResult = baseEncoder.encode(text)

            try #require(encodedResult == "jetw2idgmvswy2lom4qgo4tfmf2ca5dpmrqxsii", "The result should be equal to the original data.")

            let decodedResult = try baseEncoder.decode(encodedResult)
            guard let decodedString = String(data: decodedResult, encoding: .utf8) else {
                return
            }
            #expect(decodedString == "I'm feeling great today!", "The result should be equal to the original text.")
        }
    }
}
