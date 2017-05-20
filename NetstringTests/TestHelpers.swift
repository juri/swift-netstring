//
//  TestHelpers.swift
//  Netstring
//
//  Created by Juri Pakaste on 18/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
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
