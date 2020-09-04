local log = require("log")
local Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")
--该插件运行在CronSchedules目录下 食用请注意
--定时指定的群 发送消息
function ScheduleJobOne(CurrentQQ, task)
    log.info("%s", "\n ScheduleJobOne")
    SendGroupText(CurrentQQ, 123456789, "dojob")
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
    SendGroupText(CurrentQQ, 123456789, ls)
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
    SendGroupText(CurrentQQ, 123456789, j.errmsg)
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
        SendGroupText(CurrentQQ, 123456789, resp.Msg)
        return 1
    end
    response, error_message = http.request("GET", "https://v0.yiketianqi.com/api")
    local html = response.body
    local j = json.decode(html)
    --解码json
    SendGroupText(CurrentQQ, 123456789, j.errmsg)
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
