<p align="center">
  <img src="https://github.com/ATProtoKit/MultiformatsKit/blob/main/Sources/MultiformatsKit/MultiformatsKit.docc/Resources/multiformatskit_icon.png" height="128" alt="A icon for MultiformatsKit, which contains three stacks of rounded rectangles in an isometric top view. At the top stack, the Multiformats logo is displayed. The three stacks are in various shades of blue.">
</p>

<h1 align="center">MultiformatsKit</h1>

<div align="center">

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FATProtoKit%2FMultiformatsKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ATProtoKit/MultiformatsKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FATProtoKit%2FMultiformatsKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ATProtoKit/MultiformatsKit)
[![GitHub Repo stars](https://img.shields.io/github/stars/ATProtoKit/MultiformatsKit?style=flat&logo=github)](https://github.com/ATProtoKit/MultiformatsKit)

</div>
<div align="center">

[![Static Badge](https://img.shields.io/badge/Follow-%40cjrriley.com-0073fa?style=flat&logo=bluesky&labelColor=%23151e27&link=https%3A%2F%2Fbsky.app%2Fprofile%2Fcjrriley.com)](https://bsky.app/profile/cjrriley.com)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/masterj93?color=%23cb5f96&link=https%3A%2F%2Fgithub.com%2Fsponsors%2FMasterJ93)](https://github.com/sponsors/MasterJ93)

</div>

**MultiformatsKit** is a native Swift implementation of the [Multiformats](https://multiformats.io) protocol suite — including [Multibase](https://github.com/multiformats/multibase), [Multicodec](https://github.com/multiformats/multicodec), [Multihash](https://github.com/multiformats/multihash), and [CID](https://github.com/multiformats/cid).

This package enables content-addressing, self-describing data structures, and CID generation — all with `Sendable`-safe Swift code.

## Quick Examples

### CID
```swift
import MultiformatsKit

Task {
    do {
        let cid = try await CID(content: "Hello, World!")

        // CIDv1 encoded with base32
        print("CIDv1:", try cid.encode())

        // Decode back into a CID
        let decoded = try await CID.decode(from: cid.encode())
        print("Decoded multihash:", decoded.multihash)
    } catch {
        print("Error:", error)
    }
}
```

### Multibase
```swift
import MultiformatsKit

do {
    let base58 = Multibase.base58btc
    let result = multibase.encode("Hello from Multibase!")
    
    print(result) // Will return as "4QBebtZN9VvWV59DoFiqFLTfq2CJp".
} catch {
    throw error
}
```

### Multicodec

```swift
do {
    let dagPB = try Multicodec(name: "dag-pb", tag: "dag-pb", code: 0x70, status: .permanent)
    try await MulticodecRegistry.shared.register(dagPB)
    
    let dagPBEntry = MulticodecRegistry.shared.get(name: "dag-pb")
    let data = Data("Hello from Multicodec!".utf8)
    let wrapped = try await Multicodec.shared.wrap(dagPBEntry, rawData: data)
    
    let (unwrappedCodec, unwrappedData) = try await MulticodecRegistry.shared.unwrap(wrapped)
    print(unwrappedCodec.name) // "dag-pb"
    
    if let string = String(data: unwrappedData, encoding: .utf8) {
        print(string) // Will return as "dag-pb".
    } else {
        print("Failed to decode UTF-8 string")
    }
    
} catch {
    throw error
}
```

### Multihash

```swift
Task {
    do {
        let data = Data("hello".utf8)
        let algorithm = try SHA256Multihash()
        try await MultihashFactory.shared.register(algorithm)

        let multihash = try await MultihashFactory.shared.hash(using: "sha2-256", data: data)
        // Prints as [0xdd, 0x7d, 0x93, 0xb5, 0xcc, 0xe6, 0x1c, 0x9e, 0xf6, 0x36, 0x5b, 0xf0, 0x9b, 0x41, 0xa8, 0xb0, 0x6f, 0xce, 0x69, 0x9a, 0xf4, 0x58, 0x76, 0xe3, 0x27, 0x0c, 0xb4, 0x65, 0xa1, 0x7a, 0xec, 0xb4]
        print(multihash.encoded.map { String(format: "%02x", $0) }.joined())
    } catch {
        throw error
    }
}
```

## Features

- Fully `Sendable`-safe and concurrency-ready.
- Supports CIDv0 and CIDv1 (including `dag-pb` with `sha2-256`).
- Multibase encoding/decoding with support for:
  - Base2, Base8, Base10, Base16
  - Base58 (BTC, Flickr)
  - Base32 (lower/upper, padded/unpadded, hex variants)
- Multicodec registration.
- Multihash support with plug-and-play hashing algorithms.
- RFC 4648 compliance for fixed-bit encoding.
- Varint encoding/decoding.
- Written entirely in Swift — no C or unsafe code.

## Installation

You can use the Swift Package Manager to download and import the library into your project:
```swift
dependencies: [
    .package(url: "https://github.com/ATProtoKit/MultiformatsKit.git", from: "0.3.0")
]
```

Then under `targets`:
```swift
targets: [
    .target(
        // name: "[name of target]",
        dependencies: [
            .product(name: "MultiformatsKit", package: "multiformatskit")
        ]
    )
]
```

## Requirements
To use MultiformatsKit in your apps, your app should target the specific version numbers:
- **iOS** and **iPadOS** 14 or later.
- **macOS** 12 or later.
- **tvOS** 14 or later.
- **visionOS** 1 or later.
- **watchOS** 9 or later.

For Linux, you need to use Swift 6.0 or later. On Linux, the minimum requirements include:
- **Amazon Linux** 2
- **Debian** 12
- **Fedora** 39
- **Red Hat UBI** 9
- **Ubuntu** 20.04

You can also use this project for any programs you make using Swift and running on **Docker**.

> [!WARNING]
> As of right now, Windows support is theoretically possible, but not has not been tested to work. Contributions and feedback on making it fully compatible for Windows and Windows Server are welcomed.

## Submitting Contributions and Feedback
While this project will change significantly, feedback, issues, and contributions are highly welcomed and encouraged. If you'd like to contribute to this project, please be sure to read both the [API Guidelines](https://github.com/ATProtoKit/MultiformatsKit/blob/main/API_GUIDELINES.md) as well as the [Contributor Guidelines](https://github.com/MasterJ93/ATProtoKit/blob/main/CONTRIBUTING.md) before submitting a pull request. Any issues (such as bug reports or feedback) can be submitted in the [Issues](https://github.com/ATProtoKit/MultiformatsKit/issues) tab. Finally, if there are any security vulnerabilities, please read [SECURITY.md](https://github.com/ATProtoKit/MultiformatsKit/blob/main/SECURITY.md) for how to report it.

If you have any questions, you can ask me on Bluesky ([@cjrriley.com](https://bsky.app/profile/cjrriley.com)). And while you're at it, give me a follow! I'm also active on the [Bluesky API Touchers](https://discord.gg/3srmDsHSZJ) Discord server.

## License
This Swift package is using the Apache 2.0 License. Please view [LICENSE.md](https://github.com/ATProtoKit/MultiformatsKit/blob/main/LICENSE.md) for more details.
