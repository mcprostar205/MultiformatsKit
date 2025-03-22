//
//  Varint.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-21.
//

import Foundation

/// A utility struct for encoding and decoding unsigned varints.
public struct Varint {

    /// The maximum number of bytes a varint can have (from spec: at most 9 bytes).
    private static let maxBytes = 9

    /// Encodes a non-negative integer into varint format.
    ///
    /// - Parameter value: The integer to encode.
    /// - Returns: The encoded varint as `Data`.
    ///
    /// - Throws: `Varint.integerTooLarge` if the integer is too large.
    public static func encode(_ value: UInt64) throws -> Data {
        guard value < (1 << 63) else {
            throw VarintError.integerTooLarge
        }

        var x = value
        var result = Data()

        repeat {
            var byte = UInt8(x & 0b0111_1111)
            x >>= 7
            if x > 0 {
                byte |= 0b1000_0000 // set continuation bit
            }
            result.append(byte)
        } while x > 0

        if result.count > Self.maxBytes {
            throw VarintError.integerTooLarge
        }

        return result
    }

    /// Decodes a varint from data. All data must be used.
    ///
    /// - Parameter data: The encoded data.
    /// - Returns: The decoded integer.
    ///
    /// - Throws: `VarintError.notAllBytesUsed` if not all of the data has been used.
    public static func decode(_ data: Data) throws -> UInt64 {
        let (value, bytesRead) = try decodeRaw(from: data)
        guard bytesRead == data.count else {
            throw VarintError.notAllBytesUsed
        }
        return value
    }

    /// Decodes a varint from an `InputStream`.
    ///
    /// - Parameter stream: An open `InputStream`.
    /// - Returns: The decoded integer and the number of bytes read.
    public static func decode(from stream: InputStream) throws -> (UInt64, Int) {
        let (value, bytesRead) = try decodeRaw(from: stream)
        return (value, bytesRead)
    }

    /// Decodes a varint, returning the remaining unprocessed data or stream.
    ///
    /// - Parameter source: A `Data` object, containing the varint.
    /// - Returns: Tuple of decoded integer and number of bytes read.
    ///
    /// - Throws: `VarintError` if the continuation byte is missing, the integer is too large,
    /// or the value wasn't encoded properly.
    public static func decodeRaw(from data: Data) throws -> (UInt64, Int) {
        var x: UInt64 = 0
        var shift = 0
        var numBytesRead = 0

        for byte in data {
            let valuePart = UInt64(byte & 0b0111_1111)
            x |= valuePart << shift
            numBytesRead += 1

            if (byte & 0b1000_0000) == 0 {
                break
            }

            shift += 7
            guard shift < 64, numBytesRead <= maxBytes else {
                throw VarintError.integerTooLarge
            }
        }

        if numBytesRead == 0 {
            throw VarintError.emptyInput
        }

        if numBytesRead > 1 && x < (1 << (7 * (numBytesRead - 1))) {
            throw VarintError.overlongEncoding
        }

        return (x, numBytesRead)
    }

    /// Decodes a varint from an `InputStream`, returns value and number of bytes read.
    ///
    /// - Parameter source: An `InputStream` object, containing the varint.
    /// - Returns: Tuple of decoded integer and number of bytes read.
    ///
    /// - Throws: `VarintError` if the continuation byte is missing, the integer is too large,
    /// or the value wasn't encoded properly.
    public static func decodeRaw(from stream: InputStream) throws -> (UInt64, Int) {
        var x: UInt64 = 0
        var shift = 0
        var numBytesRead = 0

        while true {
            var buffer: UInt8 = 0
            let read = stream.read(&buffer, maxLength: 1)
            guard read == 1 else {
                throw VarintError.missingContinuationByte(byteIndex: numBytesRead)
            }

            let valuePart = UInt64(buffer & 0b0111_1111)
            x |= valuePart << shift
            numBytesRead += 1

            if (buffer & 0b1000_0000) == 0 {
                break
            }

            shift += 7
            guard shift < 64, numBytesRead <= maxBytes else {
                throw VarintError.integerTooLarge
            }
        }

        if numBytesRead > 1 && x < (1 << (7 * (numBytesRead - 1))) {
            throw VarintError.overlongEncoding
        }

        return (x, numBytesRead)
    }
}
