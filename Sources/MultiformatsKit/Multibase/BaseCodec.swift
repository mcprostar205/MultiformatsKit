//
//  BaseCodec.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

public struct BaseCodec: Sendable {

    /// The Base2 Alphabet.
    public lazy var base2: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base2",
            prefix: "0",
            bitsPerCharacter: 1,
            alphabet: "01"
        )
    }()

    /// The Base8 Alphabet.
    public lazy var base8: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base8",
            prefix: "7",
            bitsPerCharacter: 3,
            alphabet: "01234567"
        )
    }()

    /// The Base10 Alphabet.
    public lazy var base10: BaseXAlphabet? = {
        return BaseXAlphabet(
            "0123456789",
            prefix: "9"
        )
    }()

    /// The Base16 Alphabet (lower).
    public lazy var base16Lower: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base16",
            prefix: "f",
            bitsPerCharacter: 4,
            alphabet: "0123456789abcdef"
        )
    }()

    /// The Base16 Alphabet (upper).
    public lazy var base16Upper: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base16",
            prefix: "F",
            bitsPerCharacter: 4,
            alphabet: "0123456789ABCDEF"
        )
    }()

    /// The Base32 Alphabet (lower).
    public lazy var base32Lower: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32",
            prefix: "b",
            bitsPerCharacter: 5,
            alphabet: "abcdefghijklmnopqrstuvwxyz234567"
        )
    }()
    
    /// The Base32 Alphabet (upper).
    public lazy var base32Upper: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32upper",
            prefix: "B",
            bitsPerCharacter: 5,
            alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        )
    }()

    /// The Base32 Alphabet (padded).
    public lazy var base32Pad: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32pad",
            prefix: "c",
            bitsPerCharacter: 5,
            alphabet: "abcdefghijklmnopqrstuvwxyz234567="
        )
    }()

    /// The Base32 Alphabet (padded, upper).
    public lazy var base32PadUpper: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32padupper",
            prefix: "C",
            bitsPerCharacter: 5,
            alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567="
        )
    }()

    /// The Base32hex Alphabet (lower).
    public lazy var base32Hex: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32hex",
            prefix: "v",
            bitsPerCharacter: 5,
            alphabet: "0123456789abcdefghijklmnopqrstuv"
        )
    }()

    /// The Base32hex Alphabet (upper).
    public lazy var base32HexUpper: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32hexupper",
            prefix: "V",
            bitsPerCharacter: 5,
            alphabet: "0123456789ABCDEFGHIJKLMNOPQRSTUV"
        )
    }()

    /// The Base32hex Alphabet (padded, lower).
    public lazy var base32HexPad: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32hexpad",
            prefix: "t",
            bitsPerCharacter: 5,
            alphabet: "0123456789abcdefghijklmnopqrstuv="
        )
    }()

    /// The Base32hex Alphabet (padded, upper).
    public lazy var base32HexPadUpper: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32hexpadupper",
            prefix: "T",
            bitsPerCharacter: 5,
            alphabet: "0123456789ABCDEFGHIJKLMNOPQRSTUV="
        )
    }()

    /// The Base32z Alphabet.
    public lazy var base32z: RFC4648Codec? = {
        return RFC4648Codec(
            name: "base32z",
            prefix: "h",
            bitsPerCharacter: 5,
            alphabet: "ybndrfg8ejkmcpqxot1uwisza345h769"
        )
    }()

    /// The Base36 Alphabet (lower).
    public lazy var base36: BaseXAlphabet? = {
        return BaseXAlphabet(
            "0123456789abcdefghijklmnopqrstuvwxyz",
            prefix: "k"
        )
    }()

    /// The Base36 Alphabet (upper).
    public lazy var base36Upper: BaseXAlphabet? = {
        return BaseXAlphabet(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            prefix: "K"
        )
    }()

    /// The Base58 Alphabet (BTC).
    public lazy var base58btc: BaseXAlphabet? = {
        return BaseXAlphabet(
            "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz",
            prefix: "z"
        )
    }()

    /// The Base58 Alphabet (Flickr).
    public lazy var base58flickr: BaseXAlphabet? = {
        return BaseXAlphabet(
            "123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ",
            prefix: "Z"
        )
    }()
}
