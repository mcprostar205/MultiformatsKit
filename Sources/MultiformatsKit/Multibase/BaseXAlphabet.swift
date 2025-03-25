//
//  BaseXAlphabet.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A structure representing a base-x encoding alphabet for use with ``BaseX``.
///
/// This `struct` defines the character set and prefix for custom base encodings such as Base58,
/// Base36, and other user-defined alphabets. It precomputes lookup tables to optimize encoding
/// and decoding.
///
/// Use ``BaseXAlphabet/create(alphabet:prefix:)`` to safely create a valid alphabet instance.
public struct BaseXAlphabet: Sendable {

    /// The encoding character set.
    public let encode: [UInt8]

    /// The decoding lookup table.
    public let decode: [UInt8]

    /// The base of this alphabet (number of characters).
    public let base: Int

    /// A prefix character for the base. Optional.
    public let prefix: Character?

    /// Initializes a `BaseXAlphabet` with a given character set.
    ///
    /// Since the `create(alphabet:)` method is the only way to invoke the initializer,
    /// the resulting alphabet is guaranteed to have a unique ASCII alphabet.
    ///
    /// - Parameters:
    ///   - alphabet: A string containing unique ASCII characters.
    ///   - prefix: A prefix character for the base. Optional. Defaults to `nil`.
    internal init(_ alphabet: String, prefix: Character? = nil) {
        self.base = alphabet.count
        self.prefix = prefix
        self.encode = alphabet.utf8.map { UInt8($0) }

        var decodeTable = [UInt8](repeating: 0xFF, count: 256)
        for (i, byte) in self.encode.enumerated() {
            decodeTable[Int(byte)] = UInt8(i)
        }
        self.decode = decodeTable
    }

    /// Creates a custom Base-X alphabet.
    ///
    /// - Note: The alphabet must contain unique ASCII characters and be between 2 and 255 characters.
    ///
    /// - Parameters:
    ///   - alphabet: A string representing the custom alphabet.
    ///   - prefix: A prefix character for the base. Optional. Defaults to `nil`.
    /// - Returns: A `BaseXAlphabet` instance.
    /// - Throws: `BaseXError.invalidNumberOfCharacters` if the length is not valid.
    ///           `BaseXError.invalidCharacter` if a non-ASCII character is present.
    ///           `BaseXError.duplicateCharacter` if duplicate characters exist.
    public static func create(alphabet: String, prefix: Character? = nil) throws -> BaseXAlphabet {
        guard (2...255).contains(alphabet.count) else {
            throw BaseXError.invalidNumberOfCharacters
        }

        var seenCharacters = Set<Character>()
        for character in alphabet {
            guard character.isASCII else {
                throw BaseXError.invalidCharacter(character: character)
            }
            guard seenCharacters.insert(character).inserted else {
                throw BaseXError.duplicateCharacter(character: character)
            }
        }

        return BaseXAlphabet(alphabet, prefix: prefix)
    }
}
