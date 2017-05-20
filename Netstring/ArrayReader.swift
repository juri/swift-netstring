//
//  ArrayReader.swift
//  Netstring
//
//  Created by Juri Pakaste on 20/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
//

import Foundation

public class ArrayReader {
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

