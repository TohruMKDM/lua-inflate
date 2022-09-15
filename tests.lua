local inflate = require('inflate')
local http = require('https')

local start, finish

local files = {
    ['zip_10MB/'] = false,
    ['zip_10MB/file_example_JPG_1MB.jpg'] = false,
    ['zip_10MB/file-example_PDF_1MB.pdf'] = false,
    ['zip_10MB/file_example_ODS_5000.ods'] = false,
    ['zip_10MB/file_example_TIFF_10MB.tiff'] = false,
    ['zip_10MB/file_example_PNG_2500kB.jpg'] = false,
    ['zip_10MB/file_example_PPT_1MB.ppt'] = false,
    ['zip_10MB/file-sample_1MB.doc'] = false
}

http.get('https://files-example-com.github.io/uploads/zip_10MB.zip', function(response)
    if response.statusCode ~= 200 then
        print('Failed to get the sample ZIP archive.')
        return
    end
    local buffer = {}
    response:on('data', function(chunk)
        buffer[#buffer + 1] = chunk
    end)
    response:on('end', function()
        local stream = inflate:new(table.concat(buffer))
        local success, err = pcall(function()
            start = os.clock()
            for name, offset in stream:files() do
                files[name] = true
                stream:inflate(offset)
            end
            finish = os.clock()
            print('Took '..(finish - start)..'ms to traverse and inflate the ZIP archive')
            stream:unzip('zip_10MB/file_example_JPG_1MB.jpg')
        end)
        if not success then
            print('Exception during inlation: '..err)
            if process then
                process:exit(0)
            else
                os.exit(0)
            end
        end
        for name, seen in pairs(files) do
            if not seen then
                print('File "'..name..'" not seen in ZIP archive.')
                return
            end
        end
        print('Test passed.')
    end)
end)