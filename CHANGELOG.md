## Version 2.0.0
### Major Changes
- Added the ability to optionally perform checksum verification during operations.
    - `BitStream:files()` now returns a value to be used for checksum verification.
    - `BitStream:inflate(offset, crc)` now accepts a crc value for checksum verification.
    - `BitStream:unzip(filepath, verify)` can now perform checksum verification on the unzipped output.
- Improved performance and flexibility:
    - Introduced `inflate.setChunkSize(size)` to modify the size at which inflated data is divided during byte to string conversion. The default is `4096`.
    - Patched a potential oversight during archive comment stripping.
    - Replaced `BitStream` object usage: `inflate:new(data)` is now `inflate.new(data)`.

### Bug Fixes
- Fixed a bug in `BitStream:inflate` that caused incorrect data output in certain cases. ([#3](https://github.com/TohruMKDM/lua-inflate/issues/3))

### Documentation Updates
- Updated some of the EmmyLua doc comments.

## Version 1.0.0
- Initial module release.
