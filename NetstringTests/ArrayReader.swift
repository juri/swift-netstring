//
//  ArrayReader.swift
//  Netstring
//
//  Created by Juri Pakaste on 14/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
//

import Foundation
import XCTest

class ArrayReader {
    private let array: [UInt8]
    private var position: Int

    init(array: [UInt8]) {
        self.array = array
        self.position = 0
    }

    func read(_ n: Int) -> [UInt8] {
        let size = max(min(n, self.array.count-self.position), 0)
        let result = Array(self.array[self.position ..< self.position + size])
        self.position += size
        return result
    }
}

class ArrayReaderTests: XCTestCase {
    func testEmpty_read_zero_should_return_empty() {
        let reader = ArrayReader(array: [])
        XCTAssertEqual(reader.read(0), [])
    }

    func testEmpty_read_nonzero_should_return_empty() {
        let reader = ArrayReader(array: [])
        XCTAssertEqual(reader.read(0), [])
    }

    func testNonEmpty_read_zero_should_return_empty() {
        let reader = ArrayReader(array: [1, 2, 3])
        XCTAssertEqual(reader.read(0), [])
    }

    func testNonEmpty_read_one_should_return_consecutive() {
        let reader = ArrayReader(array: [1, 2, 3])
        XCTAssertEqual(reader.read(1), [1])
        XCTAssertEqual(reader.read(1), [2])
        XCTAssertEqual(reader.read(1), [3])
        XCTAssertEqual(reader.read(1), [])
    }

    func testNonEmpty_read_two_should_return_consecutive() {
        let reader = ArrayReader(array: [1, 2, 3])
        XCTAssertEqual(reader.read(2), [1, 2])
        XCTAssertEqual(reader.read(2), [3])
        XCTAssertEqual(reader.read(2), [])
    }

    func testNonEmpty_read_length_should_all_then_none() {
        let reader = ArrayReader(array: [1, 2, 3])
        XCTAssertEqual(reader.read(3), [1, 2, 3])
        XCTAssertEqual(reader.read(3), [])
    }

    func testNonEmpty_read_more_than_length_should_all_then_none() {
        let reader = ArrayReader(array: [1, 2, 3])
        XCTAssertEqual(reader.read(4), [1, 2, 3])
        XCTAssertEqual(reader.read(4), [])
    }
}
