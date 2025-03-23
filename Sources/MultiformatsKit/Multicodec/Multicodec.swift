//
//  Multicodec.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-21.
//

import Foundation

/// 
public struct Multicodec: Hashable, Codable, Sendable {

    /// The name of the codec.
    public let name: String

    /// The tag of the codec.
    public let tag: String

    /// The code of the codec.
    public let code: Int

    /// The status of the codec.
    public let status: MulticodecStatus

    /// A description of the codec. Optional.
    public let description: String?

    /// Converts the Multicodec code into a hexadecimal `String`.
    ///
    /// Ensures the hex digits are zero-padded to an even length.
    public var hexcode: String {
        String(format: "0x%02x", code)
    }

    /// Specifies whether the multicodec code is reserved for private use.
    public var isPrivateUse: Bool {
        (0x300000..<0x400000).contains(code)
    }

    /// Initializes an instance of `Multicodec`.
    ///
    /// - Parameters:
    ///   - name: The name of the codec.
    ///   - tag: The tag of the codec.
    ///   - code: The code of the codec.
    ///   - status: The status of the codec. Defaults to `.default`.
    ///   - description: A description of the codec. Optional. Defaults to `nil`,
    ///
    ///   - Throws: `MulticodecError` if the name or code is invalid.
    public init(name: String, tag: String, code: Int, status: MulticodecStatus = .draft, description: String? = nil) throws {
        guard name.range(of: #"^[a-z][a-z0-9_-]+$"#, options: .regularExpression) != nil else {
            throw MulticodecError.invalidName(name: name)
        }

        guard code >= 0 else {
            throw MulticodecError.invalidCode(code: code)
        }

        self.name = name
        self.tag = tag
        self.code = code
        self.status = status
        self.description = description
    }

    /// Wraps raw binary data with the varint-encoded multicodec code.
    ///
    /// - Parameter rawData: The raw binary data to be inputted.
    /// - Returns: A `Data` object, wrapped with the varint-encoded multicodec code.
    ///
    /// - Throws: `VarintError` if the integer is too large.
    public func wrap(_ rawData: Data) throws -> Data {
        return try Varint.encode(UInt64(code)) + rawData
    }

    /// Unwraps multicodec-encoded data and verifies the code matches.
    ///
    /// - Parameter multicodecData: The multicodec data to unwrap.
    /// - Returns: An unwrapped `Data` object.
    public func unwrap(_ multicodecData: Data) throws -> Data {
        // Decode the varint prefix from the Data
        let (decodedCode, bytesRead) = try Varint.decodeRaw(from: multicodecData)

        // Ensure it matches the expected multicodec code
        guard decodedCode == UInt64(code) else {
            throw MulticodecError.mismatchedCode(expected: code, found: Int(decodedCode))
        }

        // Return the remaining data after the varint prefix
        let remaining = multicodecData.dropFirst(bytesRead)
        return Data(remaining)
    }

    /// Converts the multicode into a JSON object.
    ///
    /// - Returns: A `[String: String]` object.
    public func toJSON() -> [String: String] {
        [
            "name": name,
            "tag": tag,
            "code": hexcode,
            "status": status.rawValue,
            "description": description ?? ""
        ]
    }

    public static func == (lhs: Multicodec, rhs: Multicodec) -> Bool {
        lhs.name == rhs.name && lhs.code == rhs.code
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(code)
    }
}

/// The Multicodec status.
public enum MulticodecStatus: String, Codable, Sendable {

    /// The Multicodec is in the draft status.
    case draft

    /// The Multicodec is permanent.
    case permanent

    /// The Multicodec is deprecated.
    case deprecated
}
