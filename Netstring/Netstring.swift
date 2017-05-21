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

/// The maximum number of bytes read when parsing length of incoming netstring.
let maxLengthLength = 9

/// `Netstring` reads and writes [netstrings](https://cr.yp.to/proto/netstrings.txt).
/// A netstring is a self-delimiting encoding of a string of bytes that declares
/// its length at its beginning.
///
/// The predeclared length makes it easy to limit the the size of accepted data
/// and to find the end of message without imposing escaping on the sender.
public struct Netstring {
    /// Result of parsing.
    public enum ParseResult {
        /// A successfully parsed netstring.
        case success(Netstring)
        /// Parse failure caused by invalid format or missing data.
        case failure
        /// Parse failure caused by netstring length exceeding the specified maximum.
        /// `length` is the declared length of the netstring. When this value is
        /// returned, the reader has read the prefix number and the colon after it.
        case rejected(length: Int)
    }

    public typealias Bytes = [UInt8]
    /// A `Reader` should return as many bytes as specified in the parameter, or less
    /// if end of stream has been reached.
    public typealias Reader = (Int) -> Bytes

    /// The undecorated (no length, no delimiters) content of the netstring.
    public let payload: Bytes

    /// Initialize Netstring with the given bytes. This initializer doesn't parse the content.
    public init(payload: Bytes) {
        self.payload = payload
    }

    /// Parse a netstring from `reader`.
    ///
    /// This function will read as little data from `reader` as possible. The read position after
    /// this function can be determined based on the return value.
    ///
    /// If the return value is `success`, the reader will be left at the position after the final comma.
    ///
    /// If the return value is `rejected`, the position depends on the value of `skipTooLong`:
    /// - `true`: the reader will be left at the position after the final comma.
    /// - `false`: the reader will be left at the position after the colon.
    ///
    /// If the return value is `failure`, the position is undefined.
    ///
    /// - Parameter reader: Source of data.
    /// - Parameter maxLength: Maximum length of netstring to accept. If nil, Netstring will attempt to
    ///                        read all the data.
    /// - Parameter skipTooLong: Read in chunks and discard the input netstring if it's too long.
    /// - Warning: a nil value for `maxLength` means unbounded memory usage if you don't control the data source
    ///            for `reader`.
    ///
    /// - Returns: ParseResult
    public static func parse(reader: @escaping ((Int) -> Bytes), maxLength: Int? = 10240, skipTooLong: Bool = true) -> ParseResult {
        var next: [UInt8] = reader(1)
        var lengthBytes: [UInt8] = []
        while next.count == 1 && next[0] >= zero && next[0] <= nine {
            lengthBytes.append(next[0])
            guard lengthBytes.count < maxLengthLength else { return .failure }
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

    /// Parse a netstring from `array`.
    ///
    /// This is a convenience function that creates an `ArrayReader` for `array` and calls 
    /// `parse(reader:maxLength:skipTooLong:)`.
    ///
    /// - SeeAlso: `ArrayReader`
    /// - SeeAlso: `parse(reader:maxLength:skipTooLong:)`
    public static func parse(array: [UInt8]) -> ParseResult {
        return parse(reader: ArrayReader(array: array).read, maxLength: nil)
    }

    /// Create a netstring based on `payload`.
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
