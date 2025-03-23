//
//  RFC4648Codec.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// An encoder and decoder, based on the RFC 4648 specification.
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
                throw DecodingError.invalidCharacter(name: name)
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

/// General encoder that supports both base encoding and multibase encoding.
public struct Encoder: MultibaseEncoder, BaseEncoder, Sendable {

    /// The name of the
    public let name: String

    ///
    public let prefix: Character

    ///
    private let encodeFunction: @Sendable (Data) -> String

    public init(name: String, prefix: Character, encodeFunction: @Sendable @escaping (Data) -> String) {
        self.name = name
        self.prefix = prefix
        self.encodeFunction = encodeFunction
    }

    public func baseEncode(_ bytes: Data) -> String {
        return encodeFunction(bytes)
    }

    public func encode(_ bytes: Data) -> String {
        return encodeFunction(bytes)
    }
}

/// General decoder that supports both base decoding and multibase decoding.
public struct Decoder: MultibaseDecoder, UnibaseDecoder, BaseDecoder, Sendable {

    public let name: String
    public let prefix: Character
    private let decodeFunction: @Sendable (String) throws -> Data

    public init(name: String, prefix: Character, decodeFunction: @Sendable @escaping (String) throws -> Data) {
        self.name = name
        self.prefix = prefix
        self.decodeFunction = decodeFunction
    }

    public func baseDecode(_ text: String) throws -> Data {
        return try decodeFunction(text)
    }

    public func decode(_ text: String) throws -> Data {
        guard let firstCharacter = text.first, firstCharacter == prefix else {
            throw PrefixError.invalidPrefix
        }

        return try decodeFunction(String(text.dropFirst()))
    }

    public func or<Other: UnibaseDecoder>(_ other: Other) -> ComposedDecoder {
        return ComposedDecoder(decoders: [self.prefix: self, other.prefix: other])
    }
}

public struct ComposedDecoder: MultibaseDecoder, CombobaseDecoder {

    public let decoders: [Character: UnibaseDecoder]

    public init(decoders: [Character: UnibaseDecoder]) {
        self.decoders = decoders
    }

    public func decode(_ input: String) throws -> Data {
        guard let firstCharacter = input.first, let decoder = decoders[firstCharacter] else {
            throw PrefixError.unsupportedMultibasePrefix
        }
        return try decoder.decode(input)
    }

    func or<Other: UnibaseDecoder>(_ other: Other) -> ComposedDecoder {
        var combinedDecoders = self.decoders
        combinedDecoders[other.prefix] = other
        return ComposedDecoder(decoders: combinedDecoders)
    }
}

/// Codec class implementing both encoder and decoder.
public struct Codec: BaseProtocol, Sendable {

    public let name: String

    public let prefix: Character

    public var baseEncoder: BaseEncoder { encoderInstance }
    public var baseDecoder: BaseDecoder { decoderInstance }

    private let encoderInstance: Encoder
    private let decoderInstance: Decoder

    public init(
        name: String,
        prefix: Character,
        encodeFunction: @Sendable @escaping (Data) -> String,
        decodeFunction: @Sendable @escaping (String) throws -> Data
    ) {
        self.name = name
        self.prefix = prefix
        self.encoderInstance = Encoder(name: name, prefix: prefix, encodeFunction: encodeFunction)
        self.decoderInstance = Decoder(name: name, prefix: prefix, decodeFunction: decodeFunction)
    }

    public func encode(_ bytes: Data) -> String {
        return encoderInstance.encode(bytes)
    }

    public func decode(_ text: String) throws -> Data {
        return try decoderInstance.decode(String(text.dropFirst()))
    }
}

/// Factory function to create a Codec instance.
public func from(name: String, prefix: Character, encode: @Sendable @escaping (Data) -> String, decode: @Sendable @escaping (String) throws -> Data) -> Codec {
    return Codec(name: name, prefix: prefix, encodeFunction: encode, decodeFunction: decode)
}
