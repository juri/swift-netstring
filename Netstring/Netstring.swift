//
//  Netstring.swift
//  Netstring
//
//  Created by Juri Pakaste on 12/05/2017.
//  Copyright © 2017 Juri Pakaste. See LICENSE for licensing info.
//

import Foundation

let colon: UInt8 = 0x3a
let comma: UInt8 = 0x2c
let zero: UInt8 = 0x30
let nine: UInt8 = zero + 9

private let maxLengthLength = 9

/// Netstring reads and writes [netstrings](https://cr.yp.to/proto/netstrings.txt).
/// A netstring is a self-delimiting encoding of a string of bytes that declares
/// its length at its beginning.
///
/// The predeclared length makes it easy to limit the the size of accepted data
/// and to find the end of message without imposing escaping on the sender.
public struct Netstring {
    public typealias Bytes = [UInt8]
    public typealias Reader = (Int) -> Bytes

    public let payload: Bytes

    public init(payload: Bytes) {
        self.payload = payload
    }

    public init?(reader: @escaping (Int) -> Bytes) {
        var next: [UInt8] = reader(1)
        var lengthBytes: [UInt8] = []
        while next.count == 1 && next[0] >= zero && next[0] <= nine {
            lengthBytes.append(next[0])
            next = reader(1)
        }
        guard next.count == 1, next.first == colon else { return nil }
        guard lengthBytes.count > 0,
              let length = IntegerASCIIConversion.number(from: lengthBytes)
        else {
            return nil
        }
        let data = reader(length)
        guard data.count == length else { return nil }
        let endDelimiter = reader(1)
        guard endDelimiter.count == 1, endDelimiter.first == comma else { return nil }
        self.payload = data
    }

    public init?(array: [UInt8]) {
        self.init(reader: ArrayReader(array: array).read)
    }

    public func export() -> Bytes {
        let length = self.payload.count
        let lengthBytes = IntegerASCIIConversion.asciiArray(from: length)
        var output: Bytes = []
        output.append(contentsOf: lengthBytes)
        output.append(colon)
        output.append(contentsOf: self.payload)
        output.append(comma)
        return output
    }
}
