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
    public static func decode(_ data: Data) throws -> UInt64 {
        let (value, bytesRead, _) = try decodeRaw(data)
        guard bytesRead == data.count else {
            throw VarintError.notAllBytesUsed
        }
        return value
    }

    /// Decodes a varint from a stream (or any `InputStream`).
    ///
    /// - Parameter stream: An open `InputStream`.
    /// - Returns: The decoded integer and the number of bytes read.
    public static func decode(from stream: InputStream) throws -> (UInt64, Int) {
        let (value, bytesRead, _) = try decodeRaw(stream)
        return (value, bytesRead)
    }

    /// Decodes a varint from a Data or InputStream, returning remaining unprocessed data or stream.
    ///
    /// - Parameter source: Either `Data` or `InputStream`.
    /// - Returns: Tuple of decoded integer, number of bytes read, and remaining source.
    public static func decodeRaw(_ source: Any) throws -> (UInt64, Int, Any) {
        var x: UInt64 = 0
        var shift = 0
        var numBytesRead = 0

        var readByte: () throws -> UInt8 = {
            throw VarintError.emptyInput
        }

        var remaining: Any = source

        if let data = source as? Data {
            readByte = {
                guard numBytesRead < data.count else {
                    throw VarintError.missingContinuationByte(byteIndex: numBytesRead)
                }
                let byte = data[numBytesRead]
                numBytesRead += 1
                return byte
            }
        } else if let stream = source as? InputStream {
            readByte = {
                var buffer: UInt8 = 0
                let read = stream.read(&buffer, maxLength: 1)
                guard read == 1 else {
                    throw VarintError.missingContinuationByte(byteIndex: numBytesRead)
                }
                numBytesRead += 1
                return buffer
            }
        } else {
            fatalError("Unsupported type passed to decodeRaw.")
        }

        while true {
            let byte = try readByte()

            // Append 7 bits from the byte into result
            x |= UInt64(byte & 0b0111_1111) << shift

            // If high bit is 0, this is the last byte
            if (byte & 0b1000_0000) == 0 {
                break
            }

            shift += 7

            // Guard against overflow (max 9 bytes = 63 bits of data)
            guard shift < 64, numBytesRead <= Self.maxBytes else {
                throw VarintError.integerTooLarge
            }
        }

        if numBytesRead > 1 && x < (1 << (7 * (numBytesRead - 1))) {
            throw VarintError.overlongEncoding
        }

        if let data = source as? Data {
            let remainingData = data.dropFirst(numBytesRead)
            remaining = Data(remainingData)
        }

        return (x, numBytesRead, remaining)
    }
}
