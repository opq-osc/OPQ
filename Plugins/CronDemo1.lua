local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")

--语音整点报时 cron 0 0 */1 * * ?每小时执行一次
function TimeReport(CurrentQQ, task)
    log.info("%s", "\n TimeReport")

    FromGroupIdArr = {987654321,123456789}
    --启用报时的群数组 如果想动态添加可以考虑本地配置文件或mysql
    NowHour = os.date("%H", os.time())
    --取当前小时
    TimePath = string.format("./Plugins/TimeSilk/%s_00.silk", NowHour)
    --拼接文件路径
    res = ReadAll(TimePath)
    --读入文件
    base64 = PkgCodec.EncodeBase64(res)
    --将音频文件base64编码
    len = #FromGroupIdArr
    for i = 1, len, 1 do
        Api.Api_SendMsg(
            --发送语音
            CurrentQQ,
            {
                toUser = FromGroupIdArr[i],
                sendToType = 2,
                sendMsgType = "VoiceMsg",
                voiceBase64Buf = base64
            }
        )
    end
    log.info("TimeReport.lua Log\n%s", TimePath)
    return 1 --返回个任意整数即可
end

--定时指定的群 发送消息
function ScheduleJobOne(CurrentQQ, task)
    log.info("%s", "\n ScheduleJobOne")
    SendGroupText(CurrentQQ, 960839480, "dojob")
    str = string.format("%s%s task ticks %d taskid %d", "ScheduleJobOne", "done", task.Ticks, task.TaskID)
    log.info("Crondemo1.lua Log\n%s", str)
    return 1 --返回个任意整数即可
end
--定时执行命令 并返回结果回传
function ScheduleJobTwo(CurrentQQ, task)
    log.info("%s", "\n ScheduleJobTwo")
    local ts = io.popen("ls ./Plugins/")
    -- 取结果
    local ls = ts:read("*all")
    --os.execute("ping 192.168.1") --不担心结果 执行即可 尽量不要执行耗时或卡死的命令
    SendGroupText(CurrentQQ, 960839480, ls)
    --结果上报到群
    str = string.format("%s%s task ticks %d taskid %d", "ScheduleJobTwo", "done", task.Ticks, task.TaskID)
    log.info("Crondemo1.lua Log\n%s", str)
    return 1
end
--定时执行访问网页 GET POST
function TaskOne(CurrentQQ, task)
    log.info("%s", "\n TaskOne")
    response, error_message = http.request("GET", "https://v0.yiketianqi.com/api")
    local html = response.body
    local j = json.decode(html)
    --解码json
    SendGroupText(CurrentQQ, 960839480, j.errmsg)
    --结果上报到群
    str = string.format("%s%s task ticks %d taskid %d", "TaskOne", "done", task.Ticks, task.TaskID)
    log.info("Crondemo1.lua Log\n%s", str)
    return 1
end

--执行多n次 自动删除任务
function TaskTwo(CurrentQQ, task)
    log.info("%s", "\n TaskTwo")

    if task.Ticks == 2 then --执行2次后 就删除任务
        resp = Api.Api_DelCrons(task.TaskID)
        SendGroupText(CurrentQQ, 960839480, resp.Msg)
        return 1
    end
    response, error_message = http.request("GET", "https://v0.yiketianqi.com/api")
    local html = response.body
    local j = json.decode(html)
    --解码json
    SendGroupText(CurrentQQ, 960839480, j.errmsg)
    --结果上报到群
    str = string.format("%s%s task ticks %d taskid %d", "TaskTwo", "done", task.Ticks, task.TaskID)
    log.info("Crondemo1.lua Log\n%s", str)
    return 1
end

function SendGroupText(CurrentQQ, toUid, content)
    Api.Api_SendMsg(
        CurrentQQ,
        {
            toUser = toUid,
            sendToType = 2,
            sendMsgType = "TextMsg",
            content = content
        }
    )
end

function ReadAll(filePath)
    local f, err = io.open(filePath, "rb")
    if err ~= nil then
        return nil
    end
    local content = f:read("*all")
    f:close()
    return content
end
