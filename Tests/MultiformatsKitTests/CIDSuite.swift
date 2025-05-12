//
//  CIDSuite.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-25.
//

import Foundation
import Testing
@testable import MultiformatsKit

@Suite("CID Suite") struct CIDSuite {
    @Test("Generates, then round trips between encoding and decoding a CIDv1.") func cidRoundtrip() async throws {
        let text = "I'm feeling great today!"

        let cid = try await CID(content: text)

        let encodedCID = try cid.encode()
        try #require(encodedCID == "bafybeifhhzii2au6jnkhjr3ng3r5s7pn3td7xzbos547rlqonpgc76fde4", "The encoded string should match the original text.")

        let decoded = try CID.decode(from: cid.encode())

        #expect(decoded == cid, "The decoded CID should match the original CID.")
    }
}
