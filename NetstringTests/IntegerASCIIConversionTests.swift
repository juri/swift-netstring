//
//  IntegerASCIIConversionTests.swift
//  Netstring
//
//  Created by Juri Pakaste on 20/05/2017.
//  Copyright © 2017 Juri Pakaste.  See LICENSE for licensing info.
//

import Foundation
import XCTest

class IntegerToASCIITests: XCTestCase {
    struct ExpectedResult {
        let input: Int
        let output: String
    }

    func test() {
        let values = [
            ExpectedResult(input: -1, output: ""),
            ExpectedResult(input: 0, output: "0"),
            ExpectedResult(input: 1, output: "1"),
            ExpectedResult(input: 9, output: "9"),
            ExpectedResult(input: 10, output: "10"),
            ExpectedResult(input: 11, output: "11"),
            ExpectedResult(input: 56, output: "56"),
            ExpectedResult(input: 99, output: "99"),
            ExpectedResult(input: 100, output: "100"),
            ExpectedResult(input: 101, output: "101"),
            ExpectedResult(input: 654, output: "654"),
            ExpectedResult(input: 1234, output: "1234"),
        ]
        for value in values {
            XCTAssertEqual(value.output.byteArray, IntegerASCIIConversion.asciiArray(from: value.input), "Bad result for \(value)")
        }
    }
}


class ASCIIToIntegerTests: XCTestCase {
    struct ExpectedResult {
        let input: String
        let output: Int?
    }

    func test() {
        let values = [
            ExpectedResult(input: "abcd", output: nil),
            ExpectedResult(input: "-1", output: nil),
            ExpectedResult(input: "0", output: 0),
            ExpectedResult(input: "1", output: 1),
            ExpectedResult(input: "9", output: 9),
            ExpectedResult(input: "10", output: 10),
            ExpectedResult(input: "11", output: 11),
            ExpectedResult(input: "56", output: 56),
            ExpectedResult(input: "99", output: 99),
            ExpectedResult(input: "100", output: 100),
            ExpectedResult(input: "101", output: 101),
            ExpectedResult(input: "654", output: 654),
            ExpectedResult(input: "1234", output: 1234),
            ]
        for value in values {
            XCTAssertEqual(value.output, IntegerASCIIConversion.number(from: value.input.byteArray), "Bad result for \(value)")
        }
    }
}
