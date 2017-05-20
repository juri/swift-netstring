//
//  Netstring.swift
//  Netstring
//
//  Created by Juri Pakaste on 12/05/2017.
//  Copyright © 2017 Juri Pakaste. All rights reserved.
//

import Foundation

private let colon: UInt8 = 0x3a
private let comma: UInt8 = 0x2c
private let zero: UInt8 = 0x30
private let nine: UInt8 = zero + 9
private let maxLengthLength = 9

public struct Netstring {
    public enum Failure: Error {
        case formattingError
    }

    typealias Bytes = [UInt8]
    typealias Reader = (Int) -> Bytes

    let payload: Bytes

    init(payload: Bytes) {
        self.payload = payload
    }

    init?(reader: @escaping (Int) -> Bytes) {
        var next: [UInt8] = reader(1)
        var lengthBytes: [UInt8] = []
        while next.count == 1 && next[0] >= zero && next[0] <= nine {
            lengthBytes.append(next[0])
            next = reader(1)
        }
        guard next.count == 1, next.first == colon else { return nil }
        guard lengthBytes.count > 0,
            let lengthString = String(bytes: lengthBytes, encoding: .ascii),
            let length = formatter.number(from: lengthString) as? Int
            else {
                return nil
        }
        let data = reader(length)
        guard data.count == length else { return nil }
        let endDelimiter = reader(1)
        guard endDelimiter.count == 1, endDelimiter.first == comma else { return nil }
        self.payload = data
    }

    init?(array: [UInt8]) {
        self.init(reader: ArrayReader(array: array).read)
    }

    func export() throws -> Bytes {
        let length = self.payload.count
        guard let lengthString = formatter.string(from: length as NSNumber),
              let lengthData = lengthString.data(using: .ascii)
        else {
            throw Failure.formattingError
        }
        var output: Bytes = []
        output.append(contentsOf: lengthData)
        output.append(colon)
        output.append(contentsOf: self.payload)
        output.append(comma)
        return output
    }
}


private let formatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.minimumIntegerDigits = 1
    nf.maximumFractionDigits = 0
    nf.locale = Locale(identifier: "en_US_POSIX")
    return nf
}()
