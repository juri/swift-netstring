//
//  IntegerASCIIConversion.swift
//  Netstring
//
//  Created by Juri Pakaste on 20/05/2017.
//  Copyright © 2017 Juri Pakaste.  See LICENSE for licensing info.
//

import Foundation

private let asciiNumbers: [UInt8] = Array(zero ... nine)

enum IntegerASCIIConversion {
    static func pow10(_ n: Int) -> Int {
        var v: Int = 1
        for _ in 0 ..< n {
            v *= 10
        }
        return v
    }

    static func numeral(at magnitude: Int, from number: Int) -> Int {
        return number % (pow10(magnitude)) / pow10(magnitude - 1)
    }

    static func magnitude(of number: Int) -> Int {
        var m: Int = 1
        var comp: Int = 1

        while comp * 10 <= number {
            comp *= 10
            m += 1
        }

        return m
    }

    static func asciiArray(from number: Int) -> [UInt8] {
        guard number >= 0 else { return [] }
        let m = magnitude(of: number)
        let ascii: [UInt8] = stride(from: m, to: 0, by: -1).map { m in
            let num = numeral(at: m, from: number)
            return asciiNumbers[num]
        }
        return ascii
    }

    static func number(from asciiArray: [UInt8]) -> Int? {
        var num: Int = 0
        for char in asciiArray {
            guard let index = asciiNumbers.index(of: char) else {
                return nil
            }
            num *= 10
            num += index
        }
        return num
    }
}
