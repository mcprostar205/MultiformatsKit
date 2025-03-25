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
    /// - Parameter bytes: The data to encode.
    /// - Returns: A base-x encoded `String`.
    func encode(_ bytes: Data) -> String
}

/// Multibase decoder protocol that decodes multibase strings into bytes.
public protocol MultibaseDecoder: Sendable {

    /// Decodes a base-x encoded string into a `Data` object.
    ///
    /// - Parameter text: The encoded string.
    /// - Returns: The decoded `Data` object.
    func decode(_ text: String) throws -> Data
}
