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

/// A list of errors related to Multicodec operations.
public enum MulticodecError: Error, LocalizedError {

    /// The name provided is invalid.
    ///
    /// - Parameter name: The name provided.
    case invalidName(name: String)

    /// The code provided is invalid.
    ///
    /// - Parameter code: The code provided.
    case invalidCode(code: Int)

    /// The status provided is invalid.
    ///
    /// - Parameter status: The status provided.
    case invalidStatus(status: String)

    /// There is a mismatch with the code.
    ///
    /// - Parameters:
    ///   - expected: The code that was expected.
    ///   - found: The code that was found instead.
    case mismatchedCode(expected: Int, found: Int)

    /// The Multicode is not registered.
    ///
    /// - Parameter string: The Multicode's ID.
    case notRegistered(id: String)

    /// There is a duplicate name.
    ///
    /// - Parameter name: The provided name.
    case duplicateName(name: String)

    /// There is a duplicate code.
    ///
    /// - Parameter code: The provided code.
    case duplicateCode(code: Int)

    /// The query name or code is too ambiguous.
    case ambiguousQuery

    public var errorDescription: String? {
        switch self {
            case .invalidName(let name):
                return "Invalid multicodec name: \(name)"
            case .invalidCode(let code):
                return "Invalid multicodec code: \(code)"
            case .invalidStatus(let status):
                return "Invalid multicodec status: \(status)"
            case .mismatchedCode(let expected, let found):
                return "Expected code \(expected), but found \(found)."
            case .notRegistered(let id):
                return "Multicodec not registered: \(id)"
            case .duplicateName(let name):
                return "Multicodec name already exists: \(name)"
            case .duplicateCode(let code):
                return "Multicodec code already exists: \(code)"
            case .ambiguousQuery:
                return "You must specify exactly one of name or code."
        }
    }
}
