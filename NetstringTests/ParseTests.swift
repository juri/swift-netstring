//
//  ParseTests.swift
//  Netstring
//
//  Created by Juri Pakaste on 16/05/2017.
//  Copyright © 2017 Juri Pakaste.  See LICENSE for licensing info.
//

import XCTest

class ParseTests: XCTestCase {
    func testValidEmpty() throws {
        let result = Netstring.parse(array: "0:,".byteArray)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, [])
    }

    func testSuccessfulRead() throws {
        let result = Netstring.parse(array: "3:abc,".byteArray)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, "abc".byteArray)
    }

    func testOnlyNumber() {
        let result = Netstring.parse(array: "4".byteArray)
        XCTAssertEqual(result, .failure)
    }

    func testNumberColon() {
        let result = Netstring.parse(array: "2:".byteArray)
        XCTAssertEqual(result, .failure)
    }

    func testMissingColon() {
        let result = Netstring.parse(array: "1a".byteArray)
        XCTAssertEqual(result, .failure)
    }

    func testEndBeforeComma() {
        let result = Netstring.parse(array: "1:a".byteArray)
        XCTAssertEqual(result, .failure)
    }

    func testMissingComma() {
        let result = Netstring.parse(array: "1:ab".byteArray)
        XCTAssertEqual(result, .failure)
    }

    func testNoExtraRead_with_zero() throws {
        let ar = ArrayReader(array: "0:,Z".byteArray)
        let result = Netstring.parse(reader: ar.read)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, [])
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }

    func testNoExtraRead_with_nonzero() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, "Hello world".byteArray)
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }

    func testMaxLength_over_length() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read, maxLength: 20)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, "Hello world".byteArray)
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }

    func testMaxLength_equal_to_length() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read, maxLength: 11)
        let ns = try result.successValue()
        XCTAssertEqual(ns.payload, "Hello world".byteArray)
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }

    func testMaxLength_under_length_no_skip() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read, maxLength: 10, skipTooLong: false)
        XCTAssertEqual(result, .rejected(length: 11))
        XCTAssertEqual(ar.read(20), "Hello world,Z".byteArray)
    }

    func testMaxLength_under_length_skip() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read, maxLength: 10)
        XCTAssertEqual(result, .rejected(length: 11))
        XCTAssertEqual(ar.read(20), "Z".byteArray)
    }

    func testMaxLength_under_length_skip_bad_content() throws {
        let ar = ArrayReader(array: "5:Hello world,Z".byteArray)
        let result = Netstring.parse(reader: ar.read, maxLength: 3)
        XCTAssertEqual(result, .failure)
        XCTAssertEqual(ar.read(20), "world,Z".byteArray)
    }

    func testTooLongLength() {
        let ar = ArrayReader(array: "1000000000:Hello world,Z".byteArray)
        var hasReadColon = false
        var position = 0
        func reader(_ i: Int) -> [UInt8] {
            position += i
            if position > 9 { hasReadColon = true }
            return ar.read(i)
        }

        let result = Netstring.parse(reader: reader, maxLength: nil)
        XCTAssertEqual(result, .failure)
        XCTAssertFalse(hasReadColon)
    }
}
