//
//  TestHelpers.swift
//  Netstring
//
//  Created by Juri Pakaste on 18/05/2017.
//  Copyright © 2017 Juri Pakaste.  See LICENSE for licensing info.
//

import Foundation
import XCTest

struct UnexpectedNilError: Error {}
func AssertNotNilAndUnwrap<T>(_ variable: T?, message: String = "Unexpected nil value", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let variable = variable else {
        XCTFail(message, file: file, line: line)
        throw UnexpectedNilError()
    }
    return variable
}

extension Sequence where Iterator.Element == Character {
    var byteArray : [UInt8] {
        return String(self).utf8.map{ UInt8($0) }
    }
}

extension String {
    var byteArray : [UInt8] {
        return self.characters.byteArray
    }
}

// Result handling

struct BadResultError: Error {
    let result: Netstring.ParseResult
}

extension Netstring.ParseResult {
    func successValue(file: StaticString = #file, line: UInt = #line) throws -> Netstring {
        guard case let .success(ns) = self else {
            XCTFail("Expected success result, got \(self)", file: file, line: line)
            throw BadResultError(result: self)
        }
        return ns
    }
}
