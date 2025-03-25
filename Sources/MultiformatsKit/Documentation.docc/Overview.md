# ``MultiformatsKit``

Create cryptographic hashes, base encodings, serialized serialization codecs, and more.

@Metadata {
    @PageImage(
        purpose: icon, 
        source: "multiformatskit_icon", 
        alt: "A technology icon representing the MultiformatsKit framework.")
    @PageColor(blue)
}

## Overview

`MultiformatsKit` is a Swift implementation of the [Multiformats](https://multiformats.io) suite of specifications. It enables content addressing and self-describing data formats in Swift using consistent and standardized building blocks.

This package includes support for the core Multiformats technologies:

- **Multibase**: Encodes/decodes data using self-describing base prefixes.
- **Multicodec**: Tags data with compact, varint-prefixed type identifiers.
- **Multihash**: Represents content hashes alongside metadata (e.g. hash type, length).
- **CID** (Content Identifier): A universal, versioned format for referencing content by hash.
- **Varint**: Implements efficient variable-length integer encoding, used extensively in Multiformats.

### Use Cases

- Creating and parsing [CIDs](https://github.com/multiformats/cid) (v0 or v1) for use in IPFS, IPLD, libp2p, or any distributed system.
- Encoding data using [Multibase](https://github.com/multiformats/multibase)-compatible formats such as base58btc, base32, base16, or custom base-x alphabets.
- Registering and resolving [Multicodec](https://github.com/multiformats/multicodec) identifiers.
- Computing [Multihash](https://github.com/multiformats/multihash)-compliant digests using plug-and-play hashing algorithms.
- Working with varint-prefixed data formats or building protocol parsers that follow Multiformats conventions.



## Topics

### CID

- ``CID``

### Multibase

- ``BaseCodec``
- ``BaseXAlphabet``
- ``BaseX``
- ``RFC4648Codec``

### Multicodec

- ``Multicodec``
- ``MulticodecRegistry``
- ``MultibaseSendable``

### Multihash

- ``Multihash``
- ``MultihashFactory``
- ``MultihashAlgorithm``
- ``SHA256Multihash``

### Varint

- ``Varint``

### Errors

- ``CIDError``
- ``BaseXError``
- ``MulticodecError``
- ``DecodingError``
- ``PrefixError``
- ``VarintError``
