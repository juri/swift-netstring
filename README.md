# Netstrings in Swift

[![Build Status](https://travis-ci.org/juri/swift-netstring.svg?branch=master)](https://travis-ci.org/juri/swift-netstring)
[![Documentation Status](https://juri.github.io/swift-netstring/badge.svg)](https://juri.github.io/swift-netstring/)

Implements [netstrings](https://cr.yp.to/proto/netstrings.txt) in Swift 3.1.

## Usage

To create a netstring:

```swift

let ns = Netstring(payload: [0x4f, 0x72, 0x61, 0x6e, 0x67, 0x65, 0x20, 0x4d, 0x65, 0x6e, 0x61, 0x63, 0x65])
let bytes = ns.export()
```

To parse:

```swift
let data: [UInt8] = [0x34, 0x3a, 0x73, 0x77, 0x61, 0x67, 0x2c]
if case let .success(ns) = Netstring.parse(array: data) {
    let payload = ns.payload
}
```

The array-based constructor delegates to a closure-based one. It takes in a closure of type `(Int) -> [UInt8]` that `Netstring` asks to provide bytes as necessary. You can use it to read input from a stream (socket, pipe, file etc.)

See also [the reference documentation](https://juri.github.io/swift-netstring/), `Usage.playground` and `NetstringTests`.
