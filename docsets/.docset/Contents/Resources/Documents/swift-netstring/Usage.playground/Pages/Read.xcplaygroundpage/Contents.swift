import Foundation
import Netstring

// Read data from an array, extract result.
let data: [UInt8] = [0x34, 0x3a, 0x73, 0x77, 0x61, 0x67, 0x2c]
if case let .success(ns) = Netstring.parse(array: data) {
    let payload = ns.payload
}

// Read data from a file (see Usage.playground/Resources)
let path = Bundle.main.path(forResource: "Data", ofType: "txt")!
let fh = FileHandle(forReadingAtPath: path)!

func fileReader(handle: FileHandle) -> Netstring.Reader {
    return { (length: Int) -> [UInt8] in
        let data = handle.readData(ofLength: length)
        let arr = [UInt8](data)
        return arr
    }
}

let result = Netstring.parse(reader: fileReader(handle: fh))
if case let .success(ns2) = result,
   let json = try? JSONSerialization.jsonObject(with: Data(bytes: ns2.payload), options: [])
{
    let dict = json as! [String: String]
}
