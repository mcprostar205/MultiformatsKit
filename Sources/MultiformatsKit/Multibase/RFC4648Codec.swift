//
//  RFC4648Codec.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// An encoder and decoder conforming to the
/// [RFC 4648](https://datatracker.ietf.org/doc/html/rfc4648) specification.
///
/// This struct supports encoding and decoding of base-n formats such as Base2, Base8, Base16, and
/// Base32, using a fixed number of bits per character.
///
/// `RFC4648Codec` is typically used in multibase encoding schemes where padding and bit-wise
/// character representations are standardized.
///
/// - Note: While `RFC4648Codec`can take Base64 encoding and decoding, Swift’s `Foundation`
/// framework already includes native support for Base64 via:\
/// \- `Data.base64EncodedString()`\
/// \- `Data(base64Encoded:)`\
/// \
/// These native methods are more efficient and should be preferred over a manual
/// Base64 implementation.
public struct RFC4648Codec: MultibaseSendable {

    /// The name of the base.
    public let name: String

    /// The base's prefix.
    public let prefix: String

    /// The number of bits per character for the base.
    public let bitsPerCharacter: Int

    /// The base's alphabet.
    public let alphabet: [Character]

    /// The base's lookup table.
    private let lookupTable: [Character: Int]

    /// Creates an instance of `RFC4648Codec`.
    ///
    /// - Parameters:
    ///   - name: The name of the base.
    ///   - prefix: The base's prefix.
    ///   - bitsPerCharacter: The number of bits per character for the base.
    ///   - alphabet: The base's alphabet.
    public init(name: String, prefix: String, bitsPerCharacter: Int, alphabet: String) {
        self.name = name
        self.prefix = prefix
        self.bitsPerCharacter = bitsPerCharacter
        self.alphabet = Array(alphabet)

        var table: [Character: Int] = [:]
        for (index, character) in self.alphabet.enumerated() {
            table[character] = index
        }

        self.lookupTable = table
    }

    /// Encodes the base based on the algorithm set by RFC 4648.
    ///
    /// - Parameter data: The data to encode.
    /// - Returns: The encoded `String` object.
    public func encode(_ data: Data) -> String {
        var output = ""
        let pad = alphabet.last == "="
        let mask = (1 << bitsPerCharacter) - 1
        var bits = 0
        var buffer = 0

        for byte in data {
            buffer = (buffer << 8) | Int(byte)
            bits += 8

            while bits > bitsPerCharacter {
                bits -= bitsPerCharacter
                output.append(alphabet[(buffer >> bits) & mask])
            }
        }

        if bits != 0 {
            output.append(alphabet[(buffer << (bitsPerCharacter - bits)) & mask])
        }

        if pad {
            while ((output.count * bitsPerCharacter) & 7) != 0 {
                output.append("=")
            }
        }

        return output
    }

    /// Decodes the base based on the algorithm set by RFC 4648.
    ///
    /// - Parameter input: The `String` object to decode.
    /// - Returns: The decoded `Data` object.
    ///
    /// - Throws: An error if there are invalid characters or when the end of data is unexpected.
    public func decode(_ input: String) throws -> Data {
        var end = input.count
        while end > 0, input[input.index(input.startIndex, offsetBy: end - 1)] == "=" {
            end -= 1
        }

        var output = Data(capacity: (end * bitsPerCharacter / 8))
        var bits = 0
        var buffer = 0

        for i in 0..<end {
            let character = input[input.index(input.startIndex, offsetBy: i)]
            guard let value = lookupTable[character] else {
                throw DecodingError.invalidCharacter(character: character)
            }

            buffer = (buffer << bitsPerCharacter) | value
            bits += bitsPerCharacter

            if bits >= 8 {
                bits -= 8
                output.append(UInt8((buffer >> bits) & 0xFF))
            }
        }

        if bits >= bitsPerCharacter || ((buffer << (8 - bits)) & 0xFF) != 0 {
            throw DecodingError.unexpectedEndOfData
        }

        return output
    }
}
