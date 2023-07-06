# lua-inflate
lua-inflate is a refactored release of [zzlib](https://github.com/zerkman/zzlib) by [zerkman](https://github.com/zerkman) which is a pure Lua implementation of a depacker for the  zlib DEFLATE([RFC1951](https://www.rfc-editor.org/info/rfc1951)) file format.</br>
The purpose of this refactor is to optimize the source where possible and allow *limited* support for ZIP archives with comments which the orginal does not support.</br>
The performance gains over the original was made possible by skipping some validation checks (this library assumes you're working with a valid ZIP file) and reusing tables when possible.
## Installation
You can get this module from [lit](https://luvit.io/lit.html) with the following command. 
```
lit install TohruMKDM/inflate
```
## Usage
Using this module is extremely simple. The following is an example of how you'd use this module to unpack and write a ZIP archive's contents to disk. 
```lua
local inflate = require('inflate')
local fs = require('fs')

local stream = inflate.new(assert(fs.readFileSync('file.zip')))

for name, offset, size, packed, crc in stream:files() do
    -- You can identify sub directories by checking if it's name ends with "/"
    if name:sub(-1) == '/' then
        fs.mkdirSync(name)
    else
        local content
        if packed then
            -- perform checksum verification
            content = stream:inflate(offset, crc)
        else
            content = stream:extract(offset, size)
        end
        fs.writeFileSync(name, content)
    end
end
print('Done.')
```
## API Reference

### inflate.new(buffer)
| Parameter | Type | Description |
| - | - | - |
| buffer | string | The data to be used in the BitStream |

Creates a new bitstream object with the specified buffer string.</br>
**Returns:** [BitStream](https://github.com/TohruMKDM/lua-inflate#bitstream)

### inflate.setChunkSize(size)
| Parameter | Type | Description
| - | - | - |
| size | integer | The new chunk size. Preferrably a value with a power of 2 |

Sets the size at which to divide chunks by during byte to string conversion. The default value is `4096`. </br>
If you encounter any issues with the lua stack it is advised you use this function to lower the chunk size to something like `2048` or even `1024`.
**Returns:** nothing

### BitStream
| Fields | Type | Default | Description |
| - | - | - | - |
| buffer | string | nil | Character buffer |
| position | integer | 0 | Position in the character buffer |
| bits | integer | 0 | Bits buffer |
| count | integer | 0 | Number of bits in the buffer |

### BitStream:files()
Returns an iterator that will span the list of files in the ZIP archive.
| Name | Type | Description |
| - | - | - |
| name | string | The name of the file |
| offset | integer | The position of the files |
| size | integer | The size of the file |
| packed | boolean | If the file is packed or not |
| crc | integer | A value to be used for checksum verification |

**Returns:** function
### BitStream:inflate(offset, crc)
| Parameter | Type | Description | Optional |
| - | - | - | - |
| offset | integer | The offset at which to begin inflating | ✘ |
| crc | integer | The value to use in checksum verification | ✓ |

Inflates the bitstream at the specified position offset and optionally perform checksum verification. Returns the inflated contents.</br>
**Returns:** string
### Bitstream:unzip(filepath, verify)
| Parameter | Type | Description | Optional |
| - | - | - | - |
| filepath | string | The name of the file within the zip archive | ✘ |
| verify | boolean | Whether or not to perform checksum verification on the unzipped file | ✓ |

Unpacks a specific file from the ZIP archive and optionally perform checksum verification.</br>
**Returns:** string
### Bitstream:extract(offset, size)
| Parameter | Type | 
| - | - |
| offset | integer |
| size | integer |

Extracts content directly from the ZIP archive with the specified offset and size. Used for extracting unpacked content.</br>
**Returns:** string
## Performance
I was able to reach speeds of ~30MB/s under LuaJIT which is pretty fast when you keep in mind that this is written in pure Lua.</br>
I was also able to inflate a relatively large ZIP archive (162MB) a little over 4 seconds faster than the original source.
![image](https://user-images.githubusercontent.com/100388505/190425983-8fe35511-1bb7-4e54-bfec-f972b65b0837.png)</br>
My results from `bench.lua`
```
'inflate'       8.1698002800003 0.81698002800003
'inflateCrc'    8.6834577949994 0.86834577949994
'zzlib' 18.384467002999 1.8384467002999
'zzlibCrc'      19.173533376001 1.9173533376001
'miniz' 1.1439774689989 0.11439774689989
```
**Note:** While there is a noticable improvement in speed from the original source, ZIP inflation in pure Lua is still considerably slower than it's C/C++ counterparts and if you're working in a Lua environment where C modules such as `miniz` are present or available then I highly reccommend you use those opposed to this one. This was mostly made for use in environments where using modules such as `miniz` was not possible.

