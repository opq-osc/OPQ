local http = require("http")
local json = require("json")
function GetUrl(data)
    local index = GenRandInt(2, 3)
    if index == 2 then
        return GetBJHUrl(data)
    end
    if index == 3 then
        return GetOPPOUrl(data)
    end
end

function GetYZFUrl(data)
    local userid = string.format("kfh53e531627f2ee4c_h58708d8145940cae8269e42%d", os.time())
    local response, error_message =
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
                ["file"] = "22.jpg",
                ["body"] = data
            }
        }
    )
    --log.info("%s ", response.body)
    jsonData = json.decode(response.body)
    if jsonData["code"] ~= 0 then
        return nil
    end

    return UrlDecode(jsonData["KfPicUrl"])
end
function GetNiuUrl(data)
    local response, error_message = http.request("GET", string.format("https://gocloudcoder.com:8081/upload"))

    jsonData = json.decode(response.body)

    if jsonData.token == nil then
        return nil
    end
    local file_name = string.format("%s%s.jpg", os.time(), GenRandInt(11111, 999999999))
    local response, error_message =
        http.request(
        "POST",
        "https://upload-z2.qiniup.com/",
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
