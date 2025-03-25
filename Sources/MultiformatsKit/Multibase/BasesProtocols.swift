//
//  BasesProtocols.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

/// A convenience `typealias` for a multibase encoder/decoder that is also `Sendable`.
///
/// Use this typealias to represent types that support both encoding and decoding of
/// multibase `String` objects.
///
/// Conforming types must implement:
/// - ``MultibaseEncoder/encode(_:)``
/// - ``MultibaseDecoder/decode(_:)``
public typealias MultibaseSendable = MultibaseEncoder & MultibaseDecoder & Sendable

/// Multibase encoder protocol that encodes data into a multibase string.
public protocol MultibaseEncoder: Sendable {

    /// Encodes the given byte array into a base-x string.
    ///
    /// - Parameter data: The data to encode.
    /// - Returns: A base-x encoded `String`.
    func encode(_ bytes: Data) -> String
}

/// Multibase decoder protocol that decodes multibase strings into bytes.
public protocol MultibaseDecoder: Sendable {

    /// Decodes a base-x encoded string into a `Data` object.
    ///
    /// - Parameter string: The encoded string.
    /// - Returns: The decoded `Data` object.
    func decode(_ text: String) throws -> Data
}

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
