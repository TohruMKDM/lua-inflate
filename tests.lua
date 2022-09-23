local f = {["zip_10MB/"]=false,["zip_10MB/file_example_JPG_1MB.jpg"]=false,["zip_10MB/file-example_PDF_1MB.pdf"]=false,["zip_10MB/file_example_ODS_5000.ods"]=false,["zip_10MB/file_example_TIFF_10MB.tiff"]=false,["zip_10MB/file_example_PNG_2500kB.jpg"]=false,["zip_10MB/file_example_PPT_1MB.ppt"]=false,["zip_10MB/file-sample_1MB.doc"]=false}
local r,b=require("coro-http").request("GET", "https://files-example-com.github.io/uploads/zip_10MB.zip")
if r.code ~= 200 then print("Failed to get the sample ZIP archive.") return end
local s=require("inflate"):new(b)
local p,e=pcall(function()
    local t=os.clock()
    for n,o in s.files(s) do
        f[n] = true
        s.inflate(s, o)
    end
    t=os.clock()-t
    print("Took "..t.."ms to traverse and inflate the ZIP archive")
    s.unzip(s, "zip_10MB/file_example_JPG_1MB.jpg")
end)
if p==false then
    print("error during inflate:"..e)
    local _=process and process.exit(process, 0) or os.exit(0)
end
for n,w in pairs(f) do
    if w==false then
        print("File '"..n.."' not seen in ZIP file.")
        local _=process and process.exit(process, 0) or os.exit(0)
        return
    end
end
print("Test pass.")
