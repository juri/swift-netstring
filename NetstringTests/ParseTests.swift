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
}
