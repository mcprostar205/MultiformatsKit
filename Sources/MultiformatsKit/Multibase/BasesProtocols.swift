//
//  BasesProtocols.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// Base encoder protocol that encodes bytes into a base-encoded string.
public protocol BaseEncoder {
    func baseEncode(_ bytes: Data) -> String
}

extension BaseEncoder {
    public func baseEncode(_ bytes: Data) -> String {
        return String(data: bytes, encoding: .utf8) ?? ""
    }
}

/// Base decoder decodes encoded strings into bytes.
public protocol BaseDecoder {
    func baseDecode(_ text: String) throws -> Data
}

extension BaseDecoder {
    public func baseDecode(_ text: String) throws -> Data {
        return text.data(using: .utf8) ?? Data()
    }
}

/// Base codec is a combination of an encoder and a decoder.
public protocol BaseProtocol: Sendable {
    var baseEncoder: BaseEncoder { get }
    var baseDecoder: BaseDecoder { get }
}

/// Represents base-encoded strings with a prefix character describing its encoding.
public struct Multibase: Sendable {
    public let prefix: Character
    public let value: String

    public var fullString: String {
        return "\(prefix)\(value)"
    }
}

/// Multibase encoder protocol that encodes data into a multibase string.
public protocol MultibaseEncoder: Sendable {

    /// The name of the encoding.
    var name: String { get }

    /// The prefix character for the base encoding.
    var prefix: Character { get }

    func encode(_ bytes: Data) -> Multibase
}

/// Multibase decoder protocol that decodes multibase strings into bytes.
public protocol MultibaseDecoder: Sendable {
    func decode(_ multibase: Multibase) throws -> Data
}

/// Combined multibase codec for encoding and decoding.
public protocol MultibaseCodec {
    var name: String { get }
    var prefix: Character { get }
    var multibaseEncoder: MultibaseEncoder { get }
    var multibaseDecoder: MultibaseDecoder { get }
}

/// A unibase decoder responsible for decoding a specific base encoding.
public protocol UnibaseDecoder: MultibaseDecoder {
    var prefix: Character { get }
    func or<Other: UnibaseDecoder>(_ other: Other) -> ComposedDecoder
}

/// A combobase decoder that can decode multiple base encodings.
public protocol CombobaseDecoder: MultibaseDecoder {
    var decoders: [Character: UnibaseDecoder] { get }
}

