//
//  ParseTests.swift
//  Netstring
//
//  Created by Juri Pakaste on 16/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
//

import XCTest

class ParseTests: XCTestCase {
    func testValidEmpty() throws {
        let ns = try AssertNotNilAndUnwrap(Netstring(array: "0:,".byteArray))
        XCTAssertEqual(ns.payload, [])
    }

    func testSuccessfulRead() throws {
        let ns = try AssertNotNilAndUnwrap(Netstring(array: "3:abc,".byteArray))
        XCTAssertEqual(ns.payload, "abc".byteArray)
    }

    func testOnlyNumber() {
        let ns = Netstring(array: "4".byteArray)
        XCTAssertNil(ns)
    }

    func testNumberColon() {
        let ns = Netstring(array: "2:".byteArray)
        XCTAssertNil(ns)
    }

    func testMissingColon() {
        let ns = Netstring(array: "1a".byteArray)
        XCTAssertNil(ns)
    }

    func testEndBeforeComma() {
        let ns = Netstring(array: "1:a".byteArray)
        XCTAssertNil(ns)
    }

    func testMissingComma() {
        let ns = Netstring(array: "1:ab".byteArray)
        XCTAssertNil(ns)
    }

    func testNoExtraRead_with_zero() throws {
        let ar = ArrayReader(array: "0:,Z".byteArray)
        let ns = try AssertNotNilAndUnwrap(Netstring(reader: ar.read))
        XCTAssertEqual(ns.payload, [])
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }

    func testNoExtraRead_with_nonzero() throws {
        let ar = ArrayReader(array: "11:Hello world,Z".byteArray)
        let ns = try AssertNotNilAndUnwrap(Netstring(reader: ar.read))
        XCTAssertEqual(ns.payload, "Hello world".byteArray)
        XCTAssertEqual(ar.read(10), "Z".byteArray)
    }
}
