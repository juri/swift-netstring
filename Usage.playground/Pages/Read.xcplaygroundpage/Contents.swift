import Foundation
import Netstring

// Read data from an array, extract result.
let data: [UInt8] = [0x34, 0x3a, 0x73, 0x77, 0x61, 0x67, 0x2c]
if let ns = Netstring(array: data) {
    let payload = ns.payload
}
