local log = require("log")
local json = require("json")
local Api = require("coreApi")
local http = require("http")
local mysql = require("mysql")
MYSQL_IP = "127.0.0.1"
--MYSQL_IP = "192.168.1.12"
MYSQL_PORT = 3306

function GetConn()
    c = mysql.new()
    ok, err = c:connect({host = MYSQL_IP, port = MYSQL_PORT, database = "OPQDB", user = "root", password = "123456"})
    if err ~= nil then
        log.error("mysql err %v", err)
        return 1
    end
end

--获取用户积分等信息
function GetSQLCode(checkWxid)
    sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], checkWxid, ToUserName)
    res, err = c:query(sqlstr) --存在
    if err ~= nil then
        log.error("%s", err)
        return nil
    end

    if #res ~= 0 then
        return res
    end -- 不存在
    return nil
end
--每个插件必须实现该事件
function ReceiveWeChatMsg(CurrentWxid, data)
    if data.FromUserName == CurrentWxid then
        ToUserName = data.ToUserName
    else
        ToUserName = data.FromUserName
    end
    wxid = ""
    if string.find(ToUserName, "@chatroom") then
        wxid = data.ActionUserName
        if wxid == "" then
            wxid = data.FromUserName
        end
    else
        wxid = data.FromUserName
    end

    if GetChatRoom(ToUserName) == nil then
        return 1
    end

    if data.MsgType == 47 then
        GetUserNick(CurrentWxid, data)
        GetConn()
        local user_info = GetSQLCode(wxid)
        local type = data.Content:match('gameext type="(%d+)" content')
        local content = data.Content:match(' content="(%d+)"')
        if type == "1" then --猜拳
        --3-->布 2-->石头 1--剪刀
        end

        if type == "2" then --骰子
           
            local num = ""
            if content == "8" then
                num = "5"
            end
            if content == "7" then
                num = "4"
            end
            if content == "9" then
                num = "6"
            end
            if content == "4" then
                num = "1"
            end
            if content == "5" then
                num = "2"
            end
            if content == "6" then
                num = "3"
            end
            if num == "" then
                return 1
            end

            if user_info ~= nil then
                local rndCode = GenRandInt(2, 10)
                local Opcode = tonumber(num) * rndCode
                local XmlStr = string.format("@%s摇骰子🎲摇出来了[天啊]%s倍 * %d = %d 积分", Nick, num, rndCode, Opcode)
                local maybe = GenRandInt(1, 100)
                if maybe >= 85 and maybe <= 95 then -- 触发buf 且摇骰子次数-1
                    local MyINTipsStr = {
                        "@%s\n[社会社会]用力过猛🎲摇飞了,群友直呼🤙🤙🤙",
                        "@%s\n[旺柴]什么都没摇到",
                        "@%s\n[哇]摇啊摇,摇啊摇[哇]一下子冒烟了,摇出个俄罗斯大妞来,兴高采烈的拿回家充气去了[皱眉]"
                    }
                    XmlStr = string.format(MyINTipsStr[GenRandInt(1, 3)], Nick)
                    WxSendMsg(CurrentWxid, XmlStr)
                    sqlstr =
                        string.format(
                        [[UPDATE `users_info` SET `DiceCount` = DiceCount-1,`DiceTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                        os.time(),
                        wxid,
                        ToUserName
                    )
                    c:query(sqlstr)
                    c.close(c)
                    return 1
                end

                if user_info[1].DiceCount == nil then -- 首次摇骰子
                    sqlstr =
                        string.format(
                        [[UPDATE `users_info` SET `OpCode` = OpCode + %d ,`DiceCount` = 2,`DiceTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                        Opcode,
                        os.time(),
                        wxid,
                        ToUserName
                    )
                    c:query(sqlstr)
                else
                    local DiceTime = tonumber(user_info[1].DiceTime)
                    local day = os.date("%d", os.time()) - os.date("%d", DiceTime)
                    if day == 0 then
                        if tonumber(user_info[1].DiceCount) > 0 then --一天只能摇3次
                            sqlstr =
                                string.format(
                                [[UPDATE `users_info` SET `OpCode` = OpCode + %d ,`DiceCount` = DiceCount - 1,`DiceTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                                Opcode,
                                os.time(),
                                wxid,
                                ToUserName
                            )
                            c:query(sqlstr)
                        else
                            XmlStr = string.format("@%s每天只能摇3次哦[天啊]～当日摇骰子次数已用完明天再继续摇ba[社会社会]～", Nick)
                        end
                    else
                        sqlstr =
                            string.format(
                            [[UPDATE `users_info` SET `OpCode` = OpCode + %d ,`DiceCount` = 2,`DiceTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                            Opcode,
                            os.time(),
                            wxid,
                            ToUserName
                        )
                        c:query(sqlstr)
                    end
                end
                WxSendMsg(CurrentWxid, XmlStr)
            end
        end
        c.close(c)
    end

    return 1
end
--每个插件必须实现该事件
function ReceiveWeChatEvents(CurrentWxid, data)
    return 1
end
function GenRandInt(x, y)
    --math.randomseed(os.time())
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    num = math.random(x, y)
    return num
end
function GetUserNick(CurrentWxid, data)
    Nick = data.ActionNickName
    if Nick == "" then
        UserTable =
            Api.GetContact(
            CurrentWxid,
            {
                ChatroomID = ToUserName,
                Wxid = {wxid}
            }
        )
        if UserTable ~= nil then
            Nick = UserTable[1].NickName
        end
    end
end
function WxSendMsg(CurrentWxid, Content)
    local str =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Content
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 49, Content = str})

    --Api.SendMsgNew(CurrentWxid, {ToUserName = ToUserName, MsgType = 1, Content = Content, AtUsers = ""})
end

function Sleep(n)
    --log.notice("==========Sleep==========\n%d", n)
    local t0 = os.clock()
    while os.clock() - t0 <= n do
    end
    --log.notice("==========over Sleep==========\n%d", n)
end

function GetChatRoom(RoomId)
    file = string.format("./Plugins/Games/%s.dat", RoomId)
    UserDat = readAll(file)
    if UserDat == nil then
    else
        return UserDat
    end
    return nil
end
function readAll(filePath)
    local f, err = io.open(filePath, "rb")
    if err ~= nil then
        return nil
    end
    local content = f:read("*all")
    f:close()
    return content
end
function writeFile(path, content)
    local file = io.open(path, "wb+")
    --log.error("%v", err)
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end
