//
//  BaseX.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A struct for encoding and decoding base-x representations of data.
public struct BaseX: Sendable {
    private let alphabet: BaseXAlphabet
    private let base: Int
    private let prefix: Character?
    private let leader: UInt8
    private let factor: Double
    private let inverseFactor: Double

    /// Initializes a new BaseX encoder/decoder with the specified `BaseXAlphabet`.
    ///
    /// - Parameter alphabet: A `BaseXAlphabet` defining the character set used for encoding.
    public init(alphabet: BaseXAlphabet) {
        self.alphabet = alphabet
        self.base = alphabet.base
        self.prefix = alphabet.prefix
        self.leader = alphabet.encode[0]
        self.factor = log(Double(base)) / log(256)
        self.inverseFactor = log(256) / log(Double(base))
    }

    /// Encodes the given byte array into a base-x string.
    ///
    /// - Parameter data: The data to encode.
    /// - Returns: A base-x encoded string.
    public func encode(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }

        let source = Array(data)

        var zeroes = 0
        while zeroes < source.count && source[zeroes] == 0 {
            zeroes += 1
        }

        let size = max(1, Int(Double(source.count - zeroes) * inverseFactor) + 1)
        var encoded = [UInt8](repeating: 0, count: size)

        var length = 0
        for byte in source[zeroes...] {
            var carry = Int(byte)
            var newLength = 0

            for index in (0..<size).reversed() where carry != 0 || index >= size - length {
                carry += (Int(encoded[index]) << 8)
                encoded[index] = UInt8(carry % base)
                carry /= base
                newLength += 1
            }

            length = newLength
        }

        var output = String(repeating: Character(UnicodeScalar(leader)), count: zeroes)
        output.append(contentsOf: encoded.suffix(length).map { Character(UnicodeScalar(alphabet.encode[Int($0)])) })

        // Add a prefix if it exists.
        if let prefix = prefix {
            output.insert(prefix, at: output.startIndex)
        }

        return output
    }

    /// Decodes a base-x encoded string into a `Data` object.
    ///
    /// - Parameter string: The encoded string.
    /// - Throws: `BaseXError.invalidCharacter` if the string contains non-alphabet characters.
    /// - Returns: The decoded `Data`.
    public func decode(_ string: String) throws -> Data {
        guard !string.isEmpty else { return Data() }

        var input = Array(string.utf8)

        if let prefix = prefix?.asciiValue, !input.isEmpty {
            guard input[0] == prefix else {
                throw BaseXError.invalidCharacter(character: Character(UnicodeScalar(input[0])))
            }
            input.removeFirst()
        }

        var zeroes = 0
        while zeroes < input.count && input[zeroes] == leader {
            zeroes += 1
        }

        let size = max(1, Int(Double(input.count - zeroes) * factor) + 1)
        var decoded = [UInt8](repeating: 0, count: size)

        var length = 0
        for byte in input[zeroes...] {
            let carry = alphabet.decode[Int(byte)]
            guard carry != 255 else {
                throw BaseXError.invalidCharacter(character: Character(UnicodeScalar(byte)))
            }

            var carryInt = Int(carry)
            for index in (0..<size).reversed() where carryInt != 0 || index >= size - length {
                carryInt += base * Int(decoded[index])
                decoded[index] = UInt8(carryInt % 256)
                carryInt /= 256
            }

            length += 1
        }

        let startIndex = max(0, size - length)
        var output = [UInt8](repeating: 0, count: zeroes + (size - startIndex))
        output.replaceSubrange(zeroes..<output.count, with: decoded[startIndex...])

        return Data(output)
    }
}
