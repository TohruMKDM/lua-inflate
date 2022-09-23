make sure you install coro http if u want the test to work
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

local stream = inflate:new(fs.readFileSync('file.zip'))

for name, offset, size, packed in stream:files() do
    -- You can identify sub directories by checking if it's name ends with "/"
    if name:sub(-1) == '/' then
        fs.mkdirSync(name)
    else
        local content
        if packed then
            content = stream:inflate(offset)
        else
            content = stream:extract(offset, size)
        end
        fs.writeFileSync(name, content)
    end
end
print('Done.')
```
## API Reference
### Bitstream
|  Fields  |   Type   | Default |            Description            |
| -------- | -------- | ------- | --------------------------------- |
|  buffer  |  string  |   nil   | Character buffer                  |
| position | integer  |    0    | Position in the character buffer  |
|   bits   | integer  |    0    | Bits buffer                       |
|  count   | integer  |    0    | Number of bits in the buffer      |
|   dir    | string   |   nil   | DIR NAME                          |

### inflate:new(buffer, DIR)
| Parameter |   Type   |
| --------- | -------- |
|  buffer   | string   |
|    dir    | string   |

Creates a new bitstream object with the specified buffer string.</br>
**Returns:** [Bitstream](https://github.com/TohruMKDM/lua-inflate#bitstream)
### Bitstream:files()
Returns an iterator that will span the list of files in the ZIP archive.
|  Name  |   Type   |          Description          |
| ------ | -------- | ----------------------------- |
|  name  |  string  | The name of the file          |
| offset | integer  | The position of the files     |
|  size  | integer  | The size of the file          |
| packed | boolean  | If the file is packed or not  |

**Returns:** function
### Bitstream:inflate(offset)
| Parameter |   Type   |
| --------- | -------- |
|  offset   | integer  |

Inflates the bitstream at the specified position offset and returns the unpacked contents.</br>
**Returns:** string
### Bitstream:unzip(filepath)
| Parameter |   Type   |
| --------- | -------- |
| filepath  |  string  |

Unpacks a specific file from the ZIP archive.</br>
**Returns:** string
### Bitstream:extract(offset, size)
| Parameter |   Type   | 
| --------- | -------- |
|  offset   | integer  |
|   size    | integer  |

Extracts content from the ZIP archive with the specified offset and size. Used for extracting unpacked content.</br>
**Returns:** string
## Performance
I was able to reach speeds of ~30MB/s under LuaJIT which is pretty fast when you keep in mind that this is written in pure Lua.</br>
I was also able to inflate a relatively large ZIP archive (162MB) a little over 4 seconds faster than the original source.
![image](https://user-images.githubusercontent.com/100388505/190425983-8fe35511-1bb7-4e54-bfec-f972b65b0837.png)
