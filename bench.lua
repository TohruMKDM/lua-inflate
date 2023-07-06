local inflate = require('inflate')
local zzlib = require('zzlib')
local miniz = require('miniz')
local http = require('https')
local fs = require("fs")
local uv = require("uv")

if not fs.existsSync("sample.zip") then
    local running = coroutine.running()
    http.get("https://files-example-com.github.io/uploads/zip_10MB.zip", function(response)
        if response.statusCode ~= 200 then
            return error("Failed to retrieve sample ZIP archive.")
        end
        local buffer = {}
        response:on("data", function(chunk)
            buffer[#buffer + 1] = chunk
        end)
        response:on("end", function()
            fs.writeFileSync("sample.zip", table.concat(buffer))
            coroutine.resume(running)
        end)
    end):done()
    coroutine.yield()
end

local function benchmark(fn, n)
    local start = (uv.hrtime() * 1e-06) / 1000
    for _ = 1, n do
        fn()
    end
    local finish = (uv.hrtime() * 1e-06) / 1000
    local result = finish - start
    return result, result / n
end


local base = 10
local sampleData = assert(fs.readFileSync("./sample.zip"))
-- Reusing reader object to avoid reading a file multiple times
local reader = assert(miniz.new_reader("./sample.zip"))

local function inflateTest()
    local stream = inflate.new(sampleData)
    for _, offset, size, packed in stream:files() do
        if packed then
            stream:inflate(offset)
        else
            stream:extract(offset, size)
        end
    end
end
local function inflateCrcTest()
    local stream = inflate.new(sampleData)
    for name, offset, size, packed, crc in stream:files() do
        if packed then
            stream:inflate(offset, crc)
        else
            stream:extract(offset, size)
        end
    end
end
local function zzlibTest()
    for name, name, offset, size, packed in zzlib.files(sampleData) do
        if packed then
            zzlib.unzip(sampleData, offset)
        else
            sampleData:sub(offset, offset + size - 1)
        end
    end
end
local function zzlibCrcTest()
    for _, _, offset, size, packed, crc in zzlib.files(sampleData) do
        if packed then
            zzlib.unzip(sampleData, offset, crc)
        else
            sampleData:sub(offset, offset + size - 1)
        end
    end
end
local function minizTest()
    for i = 1, reader:get_num_files() do
        reader:extract(i)
    end
end

p("inflate", benchmark(inflateTest, base))
p("inflateCrc", benchmark(inflateCrcTest, base))
p("zzlib", benchmark(zzlibTest, base))
p("zzlibCrc", benchmark(zzlibCrcTest, base))
p("miniz", benchmark(miniz, base))
