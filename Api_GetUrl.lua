local http = require("http")
local log = require("log")
local json = require("json")
function GetUrl(data)
    local index = GenRandInt(2, 5)
    if index == 2 then
        return GetBJHUrl(data)
    end
    if index == 3 then
        return GetNiuUrl(data)
    end
    if index == 4 then
        return GetVimCNUrl(data)
    end
    if index == 5 then
        return GetOPPOUrl(data)
    end
end

function GetNiuUrl(data)
    local response, error_message = http.request("GET", string.format("http://gocloudcoder.com:8081/upload"))

    jsonData = json.decode(response.body)

    if jsonData.token == nil then
        return nil
    end
    local file_name = string.format("%s%s.jpg", os.time(), GenRandInt(11111, 999999999))
    local response, error_message =
        http.request(
        "POST",
        "http://upload-z2.qiniup.com/",
        {
            multipart = {
                ["token"] = jsonData.token,
                ["key"] = file_name
            },
            file = {
                ["file"] = file_name,
                ["body"] = data
            }
        }
    )
    jsonData = json.decode(response.body)
    if jsonData.key == nil then
        return nil
    end
    return string.format("https://pic.gocloudcoder.com/%s", jsonData.key)
end
function GetVimCNUrl(data)
    local response, error_message =
        http.request(
        "POST",
        "https://img.vim-cn.com/",
        {
            multipart = {},
            file = {
                ["image"] = "a.jpg",
                ["body"] = data
            }
        }
    )
    return response.body
end
function GetOPPOUrl(data)
    local response, error_message =
        http.request(
        "POST",
        "https://api.open.oppomobile.com/api/utility/upload",
        {
            multipart = {
                ["type"] = "feedback"
            },
            file = {
                ["file"] = "file.jpg",
                ["body"] = data
            }
        }
    )
    --log.info("%s", response.body)
    jsonData = json.decode(response.body)
    if jsonData.errno ~= 0 then
        return nil
    end
    return jsonData.data.url
end
function GetUploadCCUrl(data)
    local response, error_message =
        http.request(
        "POST",
        "https://mp.yidianzixun.com/upload?action=uploadimage",
        {
            multipart = {},
            file = {
                ["upfile"] = "file.jpg",
                ["body"] = data
            }
        }
    )
    --log.info("%s", response.body)
    jsonData = json.decode(response.body)
    if jsonData.errno ~= 0 then
        return nil
    end
    return jsonData.data.url
end
function GetBJHUrl(data)
    response, error_message =
        http.request(
        "POST",
        "https://baijiahao.baidu.com/builderinner/api/content/file/upload",
        {
            multipart = {},
            file = {
                ["media"] = "22222.jpg",
                ["body"] = data
            }
        }
    )
    jsonData = json.decode(response.body)
    if jsonData.errno ~= 0 then
        return nil
    end
    return jsonData.ret.https_url
end
function UrlDecode(s)
    s =
        string.gsub(
        s,
        "%%(%x%x)",
        function(h)
            return string.char(tonumber(h, 16))
        end
    )
    return s
end
function GenRandInt(x, y)
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    num = math.random(x, y)
    return num
end
