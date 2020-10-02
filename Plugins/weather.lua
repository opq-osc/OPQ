---数据来源自和风天气®,需要请自行获取APIKey
local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
function ReceiveFriendMsg(CurrentQQ, data)
    log.notice("From Lua Log ReceiveFriendMsg %s", CurrentQQ)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    log.notice("From Lua Log tianqi ReceiveGroupMsg %s", CurrentQQ)
    if string.find(data.Content, "天气i") then
        keyWord = data.Content:gsub("天气i", "")
            if keyWord == "" then
                    return 1
            end
        response, error_message = 
            http.request(
                "GET",
                "https://geoapi.heweather.net/v2/city/lookup?location=" ..keyWord.. "&key=95f5b0cfd4184ee2bfebdb3492ebb293"
        )
        local html1 = response.body 
        local c = json.decode(html1)  
        ---air start     
        response, error_message = 
        http.request(
                "GET",
                "https://devapi.heweather.net/v7/air/now?location=" ..c.location[1].id.. "&key=95f5b0cfd4184ee2bfebdb3492ebb293" 
        )
        local html3 = response.body
        local air = json.decode(html3)
        ---air end
        response, error_message = 
            http.request(
                    "GET",
                    "https://devapi.heweather.net/v7/weather/3d?location=" ..c.location[1].id.. "&key=95f5b0cfd4184ee2bfebdb3492ebb293" 
        )
        local html2 = response.body
        local j = json.decode(html2)
        --- type start
        if string.find(j.daily[1].textDay, "晴") then
            tp = "201"
            elseif string.find(j.daily[1].textDay, "多云") then
            tp = "202"
            elseif string.find(j.daily[1].textDay, "雪") then
            tp = "205"
            elseif string.find(j.daily[1].textDay, "雾") then
            tp = "206"
            elseif string.find(j.daily[1].textDay, "霾") then
            tp = "208"
            elseif string.find(j.daily[1].textDay, "雨") then
            tp = "204"
            elseif string.find(j.daily[1].textDay, "尘") then
            tp = "207"
            else
            tp = "203"
            end
        --- type end
            ApiRet =
                    Api.Api_SendMsg(
                    CurrentQQ,
                    {
                        toUser = data.FromGroupId,
                        sendToType = 2,
                        sendMsgType = "JsonMsg",
                        groupid = 0,
                        content = string.format(
                        [[{"app":"com.tencent.weather","desc":"天气","view":"RichInfoView","ver":"1.0.0.217","prompt":"[应用]天气","meta":{"richinfo":{"adcode":"%s","air":"%s","city":"%s","date":"%s月%s日","max":"%s","min":"%s","ts":"1554951408","type":"%s","wind":"%s"}},"config":{"forward":1,"autosize":1,"type":"card"}}]],
c.location[1].id,                
air.now.aqi,
c.location[1].name,
os.date('!%m'),
os.date('!%d'),
j.daily[1].tempMax,
j.daily[1].tempMin,
tp,
j.daily[1].windSpeedDay),
                        atUser = 0
                    }
                )
                log.notice("From Lua SendMsg Ret-->%d", ApiRet.Ret)
            end
            return 1
        end
function ReceiveEvents(CurrentQQ, data, extData)
            return 1
end
-- MengXin001
