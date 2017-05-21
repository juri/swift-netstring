//
//  ArrayReader.swift
//  Netstring
//
//  Created by Juri Pakaste on 20/05/2017.
//  Copyright © 2017 Juri Pakaste.  See LICENSE for licensing info.
//

import Foundation

/// ArrayReader is a wrapper for a byte array whose `read(_:)` method can be used as `Netstring.Reader`.
/// - SeeAlso: `Netstring.Reader`
public class ArrayReader {
    private let array: [UInt8]
    private var position: Int

    public init(array: [UInt8]) {
        self.array = array
        self.position = 0
    }

    public func read(_ n: Int) -> [UInt8] {
        let size = max(min(n, self.array.count-self.position), 0)
        let result = Array(self.array[self.position ..< self.position + size])
        self.position += size
        return result
    }
}

