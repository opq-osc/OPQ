local log = require("log")
local json = require("json")
local Api = require("coreApi")
local http = require("http")
local mysql = require("mysql")

MYSQL_IP = "127.0.0.1"
MYSQL_PORT = 3306

function GetConn()
    c = mysql.new()
    ok, err = c:connect({host = MYSQL_IP, port = MYSQL_PORT, database = "OPQDB", user = "root", password = "1234566"})
    if err ~= nil then
        log.error("mysql err %v", err)
        return 1
    end
    --log.notice("==========Sleep==========\n%d", n)
end

--获取用户积分等信息
function GetSQLCode(checkWxid)
    sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], checkWxid, ToUserName)
    res, err = c:query(sqlstr) --存在
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

    if data.Content == "猜歌名" then
        local music_cfg = GetGuessMusicConfig(ToUserName)
        local tips =
            string.format(
            "🎵猜歌名🎵游戏规则\n3分钟内根据语音猜出正确的歌名\n[耶]猜对➕30分\n[耶]猜错➖30分\n[耶]提示➖5分\n[耶]跳过➖20分\n[耶]歌曲答案➖20分\n[奸笑]支持的指令如下\n[天啊]猜+歌名----不含+号\n[天啊]提示----提示歌曲相关信息\n[天啊]跳过----跳过当前歌曲\n[社会社会]该🎮试运行中不会增减积分"
        )

        WxSendMsg(CurrentWxid, tips)
        if music_cfg == nil then --答案文件不存在 创建
            local file_index, music = GenMusic()
            Api.SendVoice(
                CurrentWxid,
                {
                    ToUserName = ToUserName,
                    VoiceUrl = string.format("http://192.168.199.63:8097/guess/%d_1.silk", file_index)
                }
            )

            WxSendMsg(
                CurrentWxid,
                string.format("这首歌🎵%d个字\n[哇]回复猜+歌名即可参与(不含+号)\n[哇]如回复指令 猜芒种\n[哇]猜不出来？回复提示试试吧", music.num_answer)
            )
        else
            if os.time() - music_cfg.guess_time < 300 then --游戏时间过3分钟
                WxSendMsg(
                    CurrentWxid,
                    string.format(
                        "🎮当前正在猜歌游戏中,游戏已进行%s\n[Emm]温馨提示：\n[旺柴]提示----提示歌名相关信息\n[旺柴]跳过----切换歌曲\n[天啊]歌曲答案----正确答案",
                        SubUnix(os.time(), music_cfg.guess_time)
                    )
                )
            else
                local file_index, music = GenMusic()
                Api.SendVoice(
                    CurrentWxid,
                    {
                        ToUserName = ToUserName,
                        VoiceUrl = string.format("http://192.168.199.63:8097/guess/%d_1.silk", file_index)
                    }
                )

                WxSendMsg(
                    CurrentWxid,
                    string.format("这首歌🎵%d个字\n[哇]回复猜+歌名即可参与(不含+号)\n[哇]如回复指令 猜芒种\n[哇]猜不出来？回复提示试试吧", music.num_answer)
                )
            end
        end
        return 1
    end

    if string.find(data.Content, "猜") then
        if CurrentWxid == wxid then
            return 1
        end
        local keyWords = data.Content:gsub("猜", "")
        local music_cfg = GetGuessMusicConfig(ToUserName)
        if music_cfg ~= nil then
            if os.time() - music_cfg.guess_time < 180 then --在规定的时间内 进行游戏 否则不给予响应
                local tips = ""
                if keyWords == music_cfg.answer then
                    tips =
                        string.format(
                        "[社会社会]厉害啊竟然猜对了👍,没错歌名正是:%s\n⌚️思考时间⌚️%s\n即将为您播放下一首歌曲认真猜哦",
                        music_cfg.answer,
                        SubUnix(os.time(), music_cfg.guess_time)
                    )
                    WxSendMsg(CurrentWxid, tips)
                    local file_index, music = GenMusic()
                    Api.SendVoice(
                        CurrentWxid,
                        {
                            ToUserName = ToUserName,
                            VoiceUrl = string.format("http://192.168.199.63:8097/guess/%d_1.silk", file_index)
                        }
                    )

                    WxSendMsg(
                        CurrentWxid,
                        string.format("这首歌🎵%d个字\n[哇]回复猜+歌名即可参与(不含+号)\n[哇]如回复指令 猜芒种", music.num_answer)
                    )
                    return 1
                else
                    tips = string.format("[打脸]回答❌好好想想？[打脸]实在想不出来就回复一下提示试试把[打脸]")
                end
                WxSendMsg(CurrentWxid, tips)
                return 1
            end
        end
    end

    if data.Content == "歌曲答案" then
        local music_cfg = GetGuessMusicConfig(ToUserName)
        if music_cfg ~= nil then
            WxSendMsg(CurrentWxid, string.format("✅正确答案是:🎵%s🎵你猜对了嘛", music_cfg.answer))
            return 1
        end
    end

    if data.Content == "跳过" or data.Content == "下一曲" or data.Content == "下一首" then
        local music_cfg = GetGuessMusicConfig(ToUserName)
        if music_cfg ~= nil then
            WxSendMsg(CurrentWxid, string.format("你不想知道✅正确的答案吗,这就跳过了[鄙视]"))
            local file_index, music = GenMusic()
            Api.SendVoice(
                CurrentWxid,
                {
                    ToUserName = ToUserName,
                    VoiceUrl = string.format("http://192.168.199.63:8097/guess/%d_1.silk", file_index)
                }
            )

            WxSendMsg(
                CurrentWxid,
                string.format("这首歌🎵%d个字\n[哇]回复猜+歌名即可参与(不含+号)\n[哇]如回复指令 猜芒种\n[哇]猜不出来？回复提示试试吧", music.num_answer)
            )
            return 1
        end
    end

    if data.Content == "提示" then
        local music_cfg = GetGuessMusicConfig(ToUserName)
        if music_cfg ~= nil then --答案文件不存在 创建
            if os.time() - music_cfg.guess_time >= 180 then --游戏超过3分钟
                return 1
            end
            if music_cfg.tips_counts == 0 then
                Api.SendVoice(
                    CurrentWxid,
                    {
                        ToUserName = ToUserName,
                        VoiceUrl = string.format("http://192.168.199.63:8097/guess/%d_2.silk", music_cfg.id)
                    }
                )
                music_cfg.tips_counts = music_cfg.tips_counts + 1
                local file = string.format("./Plugins/Games/music_%s.dat", ToUserName)
                local write_json = json.encode(music_cfg)
                writeFile(file, write_json)
                return 1
            end
            if music_cfg.tips_counts == 1 then
                music_cfg.tips_counts = music_cfg.tips_counts + 1

                local words = ""
                local w_len = #music_cfg.words

                for i = 1, w_len, 1 do
                    words = words .. music_cfg.words[i] .. ","
                end

                local write_json = json.encode(music_cfg)
                local file = string.format("./Plugins/Games/music_%s.dat", ToUserName)
                writeFile(file, write_json)
                WxSendMsg(CurrentWxid, string.format("提示歌名可能的关键字:%s", words))
                return 1
            end
            if music_cfg.tips_counts == 2 then
                music_cfg.tips_counts = music_cfg.tips_counts + 1
                local write_json = json.encode(music_cfg)
                local file = string.format("./Plugins/Games/music_%s.dat", ToUserName)
                writeFile(file, write_json)
                local tips = ""
                if music_cfg.heart_speak ~= nil then
                    tips = music_cfg.heart_speak
                else
                    tips = music_cfg.artist
                end

                WxSendMsg(CurrentWxid, string.format("在提示你一下:%s", tips))
                return 1
            end
            if music_cfg.tips_counts >= 3 then
                music_cfg.tips_counts = music_cfg.tips_counts + 1
                local write_json = json.encode(music_cfg)
                local file = string.format("./Plugins/Games/music_%s.dat", ToUserName)
                writeFile(file, write_json)
                WxSendMsg(CurrentWxid, "不会把不会吧[Emm]提示了这么多还没猜出来 回复歌曲答案试试把[鄙视]")
            end
            return 1
        end
    end
    return 1
end
--每个插件必须实现该事件
function ReceiveWeChatEvents(CurrentWxid, data)
    return 1
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
    --Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 49, Content = Content})

    Api.SendMsgNew(CurrentWxid, {ToUserName = ToUserName, MsgType = 1, Content = Content, AtUsers = ""})
    --<appmsg appid=""  sdkver="0"><title><![CDATA[]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>
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

function GetGuessMusicConfig(RoomId)
    local file = string.format("./Plugins/Games/music_%s.dat", RoomId)
    local UserDat = readAll(file)
    if UserDat == nil then
    else
        return json.decode(UserDat)
    end
    return nil
end
function GenRandInt(x, y)
    --math.randomseed(os.time())
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    num = math.random(x, y)
    return num
end
function GenMusic()
    local num = GenRandInt(15, 7058)
    local url = string.format("http://192.168.199.63:8097/guess/%d.json", num)
    local response, error_message = http.request("GET", url)
    local music = response.body
    if string.find(music, "404 page not found") then
        return GenMusic()
    end
    local answer = json.decode(music)
    local file = string.format("./Plugins/Games/music_%s.dat", ToUserName)
    local a = {
        id = answer.d.list[1].id,
        answer = answer.d.list[1].answer,
        num_answer = answer.d.list[1].num_answer,
        artist = answer.d.list[1].artist,
        words = answer.d.list[1].words,
        heart_speak = answer.d.list[1].heart_speak,
        tips_counts = 0,
        guess_time = os.time()
    }
    local write_json = json.encode(a)
    writeFile(file, write_json)
    return num, a
end
function SubUnix(t1, t2)
    local t3 = t1 - t2
    return string.format("%.2d秒", t3 % 60)
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
