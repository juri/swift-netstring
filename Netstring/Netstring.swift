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
    public enum ParseResult {
        case success(Netstring)
        case failure
        case rejected(length: Int)
    }

    public typealias Bytes = [UInt8]
    public typealias Reader = (Int) -> Bytes

    public let payload: Bytes

    public init(payload: Bytes) {
        self.payload = payload
    }

    public static func parse(reader: @escaping ((Int) -> Bytes), maxLength: Int? = nil, skipTooLong: Bool = true) -> ParseResult {
        var next: [UInt8] = reader(1)
        var lengthBytes: [UInt8] = []
        while next.count == 1 && next[0] >= zero && next[0] <= nine {
            lengthBytes.append(next[0])
            next = reader(1)
        }
        guard next.count == 1, next.first == colon else { return .failure }
        guard lengthBytes.count > 0,
            let length = IntegerASCIIConversion.number(from: lengthBytes)
            else {
                return .failure
        }
        if let maxLength = maxLength {
            guard maxLength >= length else {
                if skipTooLong && !skip(length: length, reader: reader) {
                    return .failure
                }
                return .rejected(length: length)
            }
        }
        let data = reader(length)
        guard data.count == length else { return .failure }
        let endDelimiter = reader(1)
        guard endDelimiter.count == 1, endDelimiter.first == comma else { return .failure }
        return .success(Netstring(payload: data))
    }

    public static func parse(array: [UInt8]) -> ParseResult {
        return parse(reader: ArrayReader(array: array).read)
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

    private static func skip(length: Int, reader: ((Int) -> Bytes)) -> Bool {
        var i = 0
        while i < length {
            let chunkSize = min(length - i, 1024)
            let chunk = reader(chunkSize)
            if chunk.count < chunkSize {
                return false
            }
            i += chunkSize
        }
        let endDelimiter = reader(1)
        guard endDelimiter.count == 1, endDelimiter.first == comma else { return false }
        return true
    }
}

extension Netstring: Equatable {
    public static func ==(lhs: Netstring, rhs: Netstring) -> Bool {
        return lhs.payload == rhs.payload
    }
}

extension Netstring.ParseResult: Equatable {
    public static func ==(lhs: Netstring.ParseResult, rhs: Netstring.ParseResult) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lv), .success(let rv)): return lv == rv
        case (.failure, .failure): return true
        case (.rejected(let lv), .rejected(let rv)): return lv == rv
        case (.success, _),
             (.failure, _),
             (.rejected, _): return false
        }
    }
}
