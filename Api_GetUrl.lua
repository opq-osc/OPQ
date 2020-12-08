local http = require("http")
local json = require("json")

function GetUrl(data)
    response, error_message =
        http.request(
        "POST",
        string.format("https://yzf.qq.com/fsna/kf-file/upload_wx_media?_t=%d", os.time()),
        {
            multipart = {
                ["userid"] = "kfh53e531627f2ee4c_h552fdfc072182654f163f5f0f9a621d72",
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
    return json.decode(response.body)
end

function GenRandInt(x, y)
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    num = math.random(x, y)
    return num
end
