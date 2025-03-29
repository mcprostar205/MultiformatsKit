# ``MultiformatsKit/CID``

## Topics

### Creating a CID from Content

- ``init(version:codec:multihash:)
- ``init(version:content:)

### Decoding an Existing CID

- ``init(rawData:)``
- ``init(string:)``

### Encoding and Decoding

- ``encode()``
- ``decode(from:)``

### CID Properties

- ``version``
- ``codec``
- ``multihash``
- ``rawData``
- ``canonicalString``

### Supporting Types

- ``CIDVersion``
