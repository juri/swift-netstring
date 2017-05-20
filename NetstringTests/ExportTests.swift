//
//  ExportTests.swift
//  Netstring
//
//  Created by Juri Pakaste on 18/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
//

import Foundation
import XCTest

class ExportTests: XCTestCase {
    func testExportEmpty() throws {
        let ns = Netstring(payload: [])
        XCTAssertEqual(ns.export(), "0:,".byteArray)
    }

    func testExportOne() throws {
        let ns = Netstring(payload: ["A"].byteArray)
        XCTAssertEqual(ns.export(), "1:A,".byteArray)
    }

    func testExportMore() throws {
        let ns = Netstring(payload: "Orange Menace".characters.byteArray)
        XCTAssertEqual(ns.export(), "13:Orange Menace,".byteArray)
    }
}
