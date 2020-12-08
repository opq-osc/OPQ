local http = require("http")
local json = require("json")

function GetUrl(data)
    local index = GenRandInt(1, 4)
    if index == 1 then
        return GetYZFUrl(data)
    end
    if index == 2 then
        return GetTTUrl(data)
    end
    if index == 3 then
        return GetDPUrl(data)
    end
    if index == 4 then
        return GetBJHUrl(data)
    end
end
function GetYZFUrl(data)
    local userid = string.format("kfh53e531627f2ee4c_h552fdfc072182654f163f5f%d", os.time())
    response, error_message =
        http.request(
        "POST",
        string.format("https://yzf.qq.com/fsna/kf-file/upload_wx_media?_t=%d", os.time()),
        {
            multipart = {
                ["userid"] = userid,
                ["agentid"] = "",
                ["media_type"] = "image",
                ["mid"] = "fsna"
            },
            file = {
                ["file"] = "./22.jpg",
                ["body"] = data
            }
        }
    )
    jsonData = json.decode(response.body)
    if jsonData["code"] ~= 0 then
        return nil
    end

    return UrlDecode(jsonData["KfPicUrl"])
end
--ok
function GetTTUrl(data)
    response, error_message =
        http.request(
        "POST",
        "https://mp.toutiao.com/upload_photo/?type=json",
        {
            multipart = {},
            file = {
                ["photo"] = "./22.jpg",
                ["body"] = data
            }
        }
    )
    jsonData = json.decode(response.body)
    if jsonData.message ~= "success" then
        return nil
    end
    return jsonData.web_url
end

function GetDPUrl(data)
    response, error_message =
        http.request(
        "POST",
        "https://kfupload.alibaba.com/mupload",
        {
            multipart = {
                ["scene"] = "productImageRule",
                ["name"] = "22222.jpg"
            },
            file = {
                ["file"] = "22222.jpg",
                ["body"] = data
            }
        }
    )
    jsonData = json.decode(response.body)
    if jsonData.code ~= "0" then
        return nil
    end
    return jsonData.url
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
