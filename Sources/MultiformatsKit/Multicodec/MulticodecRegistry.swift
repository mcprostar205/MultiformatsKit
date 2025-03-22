//
//  MulticodecRegistry.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-21.
//

import Foundation

///
public actor MulticodecRegistry {

    /// A singleton property for all instances.
    public static let shared = MulticodecRegistry()

    /// A table of multicodecs.
    private var codeTable: [Int: Multicodec] = [:]

    /// A table of multicodec names.
    private var nameTable: [String: Multicodec] = [:]

    /// Registers a multicodec.
    ///
    /// - Parameters:
    ///   - codec: The Multicodec to register.
    ///   - canOverwrite: Determines whether the multicodec can be overwritten.
    ///   Defaults to `false`.
    public func register(_ codec: Multicodec, canOverwrite: Bool = false) throws {
        if !canOverwrite {
            if codeTable[codec.code] != nil {
                throw MulticodecError.duplicateCode(code: codec.code)
            }
            if let existing = nameTable[codec.name], existing.code != codec.code {
                throw MulticodecError.duplicateName(name: codec.name)
            }
        }
        codeTable[codec.code] = codec
        nameTable[codec.name] = codec
    }

    /// Unregisters a multicodec.
    ///
    /// - Parameters:
    ///   - name: The name of the multicodec. Optional. Defaults to `nil`.
    ///   - code: The multicodec's code. Optional. Defaults to `nil`.
    public func unregister(name: String? = nil, code: Int? = nil) throws {
        guard (name != nil) != (code != nil) else {
            throw MulticodecError.ambiguousQuery
        }
        let codec = try get(name: name, code: code)
        codeTable.removeValue(forKey: codec.code)
        nameTable.removeValue(forKey: codec.name)
    }

    /// Gets a specific multicodec.
    ///
    /// - Parameters:
    ///   - name: The name of the multicodec. Optional. Defaults to `nil`.
    ///   - code: The multicodec's code. Optional. Defaults to `nil`.
    /// - Returns: The `Mutlticodec` object that contaisn information for the multicodec.
    public func get(name: String? = nil, code: Int? = nil) throws -> Multicodec {
        guard (name != nil) != (code != nil) else {
            throw MulticodecError.ambiguousQuery
        }

        if let name = name, let codec = nameTable[name] {
            return codec
        } else if let code = code, let codec = codeTable[code] {
            return codec
        }

        throw MulticodecError.notRegistered(id: name ?? "\(String(describing: code))")
    }

    /// Checks if a multicodec exists.
    ///
    /// - Parameters:
    ///   - name: The name of the multicodec. Optional. Defaults to `nil`.
    ///   - code: The multicodec's code. Optional. Defaults to `nil`.
    /// - Returns: `true` if exists, or `false` if it doesn't.
    public func exists(name: String? = nil, code: Int? = nil) -> Bool {
        if let name = name {
            return nameTable[name] != nil
        } else if let code = code {
            return codeTable[code] != nil
        }

        return false
    }

    /// Wraps a multicodec with raw data.
    ///
    /// - Parameters:
    ///   - codec: The `Multicodec` object.
    ///   - rawData: The raw data to wrap.
    /// - Returns: The `Data` object that contains the wrapped multicodec information.
    public func wrap(_ codec: Multicodec, rawData: Data) throws -> Data {
        try codec.wrap(rawData)
    }

    /// Unwraps the multicodec information from the raw data.
    ///
    /// - Parameter data: The `Data` object to unwrap.
    /// - Returns: A tuple, containing the `Multicodec` information and the `Data` object.
    public func unwrap(_ data: Data) throws -> (Multicodec, Data) {
        let (code, bytesRead) = try Varint.decodeRaw(from: data)
        let codec = try get(code: Int(code))
        let remaining = data.dropFirst(bytesRead)
        return (codec, Data(remaining))
    }

    /// Displays a list of `Multicodec` objects by their tags and statuses.
    ///
    /// - Parameters:
    ///   - tag: An array of tags. Optional. Defaults to `nil`.
    ///   - status: An array of statuses. Optional. Defaults to `nil`.
    /// - Returns: An array of `Multicodec` objects that fits the parameters.
    public func table(tag: Set<String>? = nil, status: Set<MulticodecStatus>? = nil) -> [Multicodec] {
        return codeTable.values.sorted(by: {
            $0.code < $1.code
        }).filter { codec in
            let tagMatches = tag?.contains(codec.tag) ?? true
            let statusMatches = status?.contains(codec.status) ?? true
            return tagMatches && statusMatches
        }
    }

    /// Validates a `Multicodec` instance.
    ///
    /// - Parameter codec: The multicodec to validate.
    public func validate(_ codec: Multicodec) throws {
        let registered = try get(name: codec.name)
        guard registered == codec else {
            throw MulticodecError.mismatchedCode(expected: registered.code, found: codec.code)
        }
    }
}
