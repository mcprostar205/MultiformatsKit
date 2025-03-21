//
//  Errors.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-21.
//

import Foundation

/// A list of errors related to varint encoding and decoding.
public enum VarintError: Error, LocalizedError {

    /// The integer is not an unsigned integer.
    case negativeInteger

    /// The integer is larger than 9 bytes.
    case integerTooLarge

    /// The integer is empty.
    case emptyInput

    /// The last byte was a continuation byte, but the input ended.
    case continuationByteAtEnd

    /// The value wasn't minimally encoded.
    case overlongEncoding

    /// Not all bytes were used by the variant encoding.
    case notAllBytesUsed

    /// The continuation byte was missing.
    ///
    /// - Parameter byteIndex: The index of the byte.
    case missingContinuationByte(byteIndex: Int)

    public var errorDescription: String? {
        switch self {
            case .negativeInteger:
                return "Integer is negative. Varint only supports unsigned integers."
            case .integerTooLarge:
                return "Integer is too large to be encoded as varint (more than 9 bytes)."
            case .emptyInput:
                return "Input is empty. Varints must be at least 1 byte long."
            case .continuationByteAtEnd:
                return "Last byte was a continuation byte but input ended."
            case .overlongEncoding:
                return "Value was not minimally encoded."
            case .notAllBytesUsed:
                return "Not all bytes were used by the varint encoding."
            case .missingContinuationByte(let byteIndex):
                return "Expected continuation byte at index \(byteIndex), but none was available."
        }
    }
}
