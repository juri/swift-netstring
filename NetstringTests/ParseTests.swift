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
        let ar = ArrayReader(array: "0:,".byteArray)
        let ns = try AssertNotNilAndUnwrap(Netstring(reader: ar.read))
        XCTAssertEqual(ns.payload, [])
    }

    func testSuccessfulRead() throws {
        let ar = ArrayReader(array: "3:abc,".byteArray)
        let ns = try AssertNotNilAndUnwrap(Netstring(reader: ar.read))
        XCTAssertEqual(ns.payload, "abc".byteArray)
    }

    func testOnlyNumber() {
        let ar = ArrayReader(array: "4".byteArray)
        let ns = Netstring(reader: ar.read)
        XCTAssertNil(ns)
    }

    func testNumberColon() {
        let ar = ArrayReader(array: "2:".byteArray)
        let ns = Netstring(reader: ar.read)
        XCTAssertNil(ns)
    }

    func testMissingColon() {
        let ar = ArrayReader(array: "1a".byteArray)
        let ns = Netstring(reader: ar.read)
        XCTAssertNil(ns)
    }

    func testEndBeforeComma() {
        let ar = ArrayReader(array: "1:a".byteArray)
        let ns = Netstring(reader: ar.read)
        XCTAssertNil(ns)
    }

    func testMissingComma() {
        let ar = ArrayReader(array: "1:ab".byteArray)
        let ns = Netstring(reader: ar.read)
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
