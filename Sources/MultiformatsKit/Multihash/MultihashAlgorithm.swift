//
//  MultihashAlgorithm.swift
//  MultiformatsKit
//
//  Created by Christopher Jr Riley on 2025-03-22.
//

import Foundation

public protocol MultihashAlgorithm: Sendable {
    var codec: Multicodec { get }

    func hash(_ data: Data) -> Data
}
