local log = require("log")
local json = require("json")
local Api = require("coreApi")
local http = require("http")
local mysql = require("mysql")

--[[

    在数据库中建立2个表
CREATE TABLE `invites_info` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `Gid` varchar(50) DEFAULT NULL COMMENT '群ID',
  `GidName` varchar(100) DEFAULT NULL COMMENT '群昵称',
  `InviteUid` varchar(50) DEFAULT NULL COMMENT '邀请人ID',
  `InviteNick` varchar(100) DEFAULT NULL COMMENT '邀请人昵称',
  `MemberUid` varchar(50) DEFAULT NULL COMMENT '被邀请人ID',
  `MemberNick` varchar(100) DEFAULT NULL COMMENT '被邀请人ID',
  `InviteTime` int(11) DEFAULT NULL COMMENT '邀请进群时间',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `users_info` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Uid` varchar(50) DEFAULT NULL COMMENT '用户ID',
  `Gid` varchar(50) DEFAULT NULL COMMENT '所在群组',
  `OpCode` int(11) DEFAULT NULL COMMENT '签到分数',
  `SignTime` int(11) DEFAULT NULL COMMENT '签到时间',
  `RealDays` int(11) DEFAULT NULL COMMENT '连续签到',
  `SignDays` int(11) DEFAULT NULL COMMENT '累计签到',
  `Balance` int(11) DEFAULT NULL COMMENT '余额',
  `DiceTime` int(11) DEFAULT NULL COMMENT '骰子游戏时间',
  `CreateTime` int(11) DEFAULT NULL COMMENT '入库时间',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `games_info` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Uid` varchar(50) DEFAULT NULL COMMENT '用户ID',
  `Gid` varchar(50) DEFAULT NULL COMMENT '所在群组',
  `IsIn` tinyint(1) DEFAULT NULL COMMENT '是否入狱',
  `InTime` int(11) DEFAULT NULL COMMENT '入狱时间',
  `IsInHp` tinyint(1) DEFAULT NULL COMMENT '是否在医院',
  `HpTime` int(11) DEFAULT NULL COMMENT '在医院时间',
  `BoxCount` int(11) DEFAULT NULL COMMENT '宝箱个数',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb4;
]]
MYSQL_IP = "127.0.0.1"
MYSQL_PORT = 3306
function ReceiveWeChatMsg(CurrentWxid, data)
    if data.FromUserName == CurrentWxid then
        ToUserName = data.ToUserName
    else
        ToUserName = data.FromUserName
    end

    if string.find(data.Content, "娇喘") or string.find(data.Content, "唱歌") then
        math.randomseed(os.time())
        num = math.random(1, 19)

        keyWord = data.Content:gsub("娇喘", "")
        file = string.format("./Voice/%d.silk", num)
        Api.SendVoice(
            CurrentWxid,
            {
                ToUserName = ToUserName,
                VoicePath = file
            }
        )
        return 1
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
    if data.Content == "帮助" then
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[[天啊]RST娱乐机器人[天啊]\n[Emm]指令如下[Emm]\n[旺柴]签到----每日签到🉐️积分\n[旺柴]信息----查询用户积分\n[旺柴]启用----群里启用\n[旺柴]停用----群里停用\n[旺柴]出狱----刑满释放\n[旺柴]出院----康复出院\n[旺柴]越狱----尝试越狱\n[旺柴]打劫@好友----打劫群友\n[旺柴]劫狱@好友----解救狱中好友\n[旺柴]保释@好友----保释入狱群友\n[机智]拉人进群都会🈶️积分奖励的哟\n[红包]提现----100:1/ 10积分就可以兑换\n]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    if data.Content == "启用" then
        GetUserNick(CurrentWxid, data)
        if CheckAdmin(wxid) == nil then
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😯您不是管理员,无权操作😯]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        SetChatRoom(ToUserName)
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😯启用成功😯]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    if data.Content == "停用" then
        GetUserNick(CurrentWxid, data)
        --SetChatRoom(ToUserName)
        if CheckAdmin(wxid) == nil then
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😯您不是管理员,无权操作😯]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        file = string.format("./Plugins/Games/%s.dat", ToUserName)
        os.remove(file)
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😂停用成功😂]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    if GetChatRoom(ToUserName) == nil then
        return 1
    end
    if data.Content == "签到" then
        GetConn()
        Sign(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "提现" then
        GetConn()
        TiXian(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "信息" then
        GetConn()
        XinXi(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "出院" then
        GetConn()
        OutHP(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "出狱" then
        GetConn()
        OutCY(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "越狱" then
        GetConn()
        OutYY(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if data.Content == "积分排行" then
        GetConn()
        c.close(c)
        return 1
    end
    if string.find(data.Content, "打劫") then
        GetConn()
        DaJie(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if string.find(data.Content, "劫狱") then
        GetConn()
        InJY(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if string.find(data.Content, "保释") then
        GetConn()
        OutBS(CurrentWxid, data)
        c.close(c)
        return 1
    end
    if string.find(data.Content, "转账") then
        GetConn()
        c.close(c)
        return 1
    end

    ParseShiPin(CurrentWxid, data)
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
function GetWxidNick(CurrentWxid, UserID)
    User_Table =
        Api.GetContact(
        CurrentWxid,
        {
            ChatroomID = ToUserName,
            Wxid = {UserID}
        }
    )
    if User_Table ~= nil then
        return User_Table[1].NickName
    end
    return ""
end
function SendJiXi(CurrentWxid, ToUserName, OpCode)
    xmlStr =
        string.format(
        '<appmsg appid="%s" sdkver="0"><title>%s集</title><des>剩余积分%d</des><action /><type>4</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname /><messageext /><messageaction /><content /><contentattr>0</contentattr><url><![CDATA[%s]]></url><lowurl /><dataurl /><lowdataurl /><songalbumurl /><songlyric /><appattach><totallen>0</totallen><attachid /><emoticonmd5 /><fileext /><cdnthumburl>305c0201000450304e02010002044e38148202032f4f5502045972512a02045f7b3d8b0429777875706c6f61645f777869645f74366f723332343234676174323231365f313630313931323230330204010400030201000405004c52ad00</cdnthumburl><cdnthumbmd5>08a3e35b7973326e297e56a09213cd5a</cdnthumbmd5><cdnthumblength>3669</cdnthumblength><cdnthumbwidth>135</cdnthumbwidth><cdnthumbheight>135</cdnthumbheight><cdnthumbaeskey>766d879a4e598be7f2d629bfc4452aed</cdnthumbaeskey><aeskey>766d879a4e598be7f2d629bfc4452aed</aeskey><encryver>0</encryver><filekey>wxid_p503caafko2f12297_1601995606</filekey></appattach><extinfo /><sourceusername /><sourcedisplayname /><thumburl /><md5 /><statextstr>GhQKEnd4Y2E5NDJiYmZmMjJlMGU1MQ==</statextstr><directshare>0</directshare></appmsg>',
        appid,
        title,
        OpCode,
        string.format("https://vip.66parse.club/?url=%s", url)
    )
    --log.error("urlurl %s", xmlStr)
    --log.error("CurrentWxid %s", CurrentWxid)
    --log.error("ToUserName %s", ToUserName)
    --https://jiexi.q-q.wang/?url=
    --https://jx.ljtv365.com/?url= guanggao
    --https://jx.baikeclub.com/?url=
    --https://vip.66parse.club/?url=
    --https://jx.618g.com/

    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 49, Content = XmlStr})
end

function ReceiveWeChatEvents(CurrentWxid, data)
    if data.EventName == "ON_EVENT_FRIEND_REQ" then
        baseResonse, wxid =
            Api.VerifyUser(
            CurrentWxid,
            {
                VerifyType = 3, --同意好友请求
                V1Username = "",
                V2Ticket = "",
                Content = "",
                Sence = 0,
                XmlStr = data.Content --会自动解析xml里的参数
            }
        )
        str =
            string.format("baseResonse.Ret %d baseResonse.ErrMsg %s Wxid %s", baseResonse.Ret, baseResonse.ErrMsg, wxid)
        log.notice("From ReceiveWeChatEvents Log\n%s", str)
    end
    if data.EventName == "ON_EVENT_CHATROOM_INVITE" then
        if CurrentWxid == data.FromUserName then
            return 1
        end
        Url = data.Content:match([[<url><!%[CDATA%[(.+)%]%]></url>]])
        if Url == nil then
            Url = data.Content:match([[<url>(.+)</url]])
        end
        baseResonse, resp =
            Api.GetA8Key(
            CurrentWxid,
            {
                FromUserName = data.FromUserName,
                Sence = 2,
                Url = Url
            }
        )
        str =
            string.format(
            "baseResonse.Ret %d baseResonse.ErrMsg %s Url %s",
            baseResonse.Ret,
            baseResonse.ErrMsg,
            resp.Url
        )
        log.error("From ReceiveWeChatEvents Log\n%s", str)

        response, error_message = http.request("GET", resp.Url)
        local html = response.body
        str = string.format("当前群人数 %s", html:match("(%d+)人"))
        log.info(" %s", str)
        response, error_message =
            http.request(
            "POST",
            resp.Url,
            {
                body = ""
            }
        )
        if error_message ~= nil then
            --resp Post weixin://jump/mainframe/12028215877@chatroom: unsupported protocol scheme "weixin
            log.notice("info   %s", "进群成功" .. error_message)
        else
            log.error(" resp %s", response.body)
        end
    end
    if data.EventName == "ON_EVENT_CHATROOM_INVITE_OTHER" then
        xmlStr =
            string.format(
            "ChatRoom %s 邀请人 %s 邀请人昵称 %s 被邀请人 %s 被邀请人昵称 %s",
            data.FromUserName,
            data.InviteUserName,
            data.InviteNickName,
            data.InvitedUserName,
            data.InvitedNickName
        )
        log.error("%s", xmlStr)
        if GetChatRoom(data.FromUserName) == nil then
            --log.error("room %s", data.FromUserName)
            return 1
        end
        GetConn()
        sqlstr =
            string.format(
            [[select * from invites_info where `Gid`= "%s" and `InviteUid` = "%s" and `MemberUid` = "%s"]],
            data.FromUserName,
            data.InviteUserName,
            data.InvitedUserName
        )
        res, err = c:query(sqlstr) --判断一下被邀请人是否存在 不存在则发红包奖励 排除重复进群退群

        if #res == 0 then --不存在记录
            UserTable =
                Api.GetContact(
                CurrentWxid,
                {
                    ChatroomID = data.FromUserName
                }
            )
            GidName = UserTable[1].NickName

            sqlstr =
                string.format(
                [[INSERT INTO invites_info (Gid, GidName, InviteUid,InviteNick,MemberUid,MemberNick,InviteTime)VALUES ("%s","%s","%s","%s","%s","%s",%d)]],
                data.FromUserName,
                GidName,
                data.InviteUserName,
                data.InviteNickName,
                data.InvitedUserName,
                data.InvitedNickName,
                os.time()
            )
            res, err = c:query(sqlstr) --插入邀请信息
            sqlstr = string.format([[select * from users_info where `Uid`= "%s"]], data.InviteUserName)
            res, err = c:query(sqlstr) --存在
            if #res ~= 0 then
                OpCode = res[1].OpCode
                sqlstr =
                    string.format(
                    [[UPDATE `users_info` SET `OpCode` = OpCode + 10 WHERE `Uid` = "%s" and `Gid`="%s"]],
                    data.InviteUserName,
                    data.FromUserName
                )
                c:query(sqlstr)
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[ @%s\n[哇]邀请好友进群获🉐️积分10/人\n[哇]剩余积分:%d\n(新人请回复帮助试试吧～)\n还有[红包]奖励嗷]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    data.InviteNickName,
                    OpCode + 10
                )
                --Api.SendAppMsg(CurrentWxid, data.FromUserName, 57, XmlStr)
                Api.SendAppMsg(CurrentWxid, {ToUserName = data.FromUserName, MsgType = 57, Content = XmlStr})
            end
            hourNow = os.date("%H", os.time())

            if hourNow > 18 or hourNow < 9 then
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n该时段已经暂停提现业务\n🈺️业时间早9点-晚18点]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )

                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                return 1
            end

            if err == nil then
            end
        end
    end
    return 1
end
function ParseShiPin(CurrentWxid, data)
    bFlag = false

    if string.find(data.Content, "wxa75efa648b60994b") then
        bFlag = true
    end
    if string.find(data.Content, "wxcd10170e55a1f55d") then
        bFlag = true
    end
    if string.find(data.Content, "wxd09e2d4fceafe6e3") then
        bFlag = true
    end
    if string.find(data.Content, "wx5de0c309a1472da6") then
        bFlag = true
    end

    if data.MsgType == 49 and bFlag then
        --Sleep(sTime)
        GetUserNick(CurrentWxid, data)
        GetConn()

        appid = data.Content:match([[<appid><!%[CDATA%[(.+)%]%]></appid>]])

        if appid == nil then
            appid = data.Content:match([[<appid>(.+)</appid>]])
        end
        title = data.Content:match([[<title><!%[CDATA%[(.+)%]%]></title>]])
        if title == nil then
            title = data.Content:match([[<title>(.+)集</title>]])
        end
        if title == nil then
            title = data.Content:match([[<title>(.+)话</title>]])
        end
        url = data.Content:match([[<url><!%[CDATA%[(.+)%]%]></url>]])
        if url == nil then
            url = data.Content:match([[<url>(.+)</url>]])
        end

        --log.error("url %s", url)
        if appid == "wxa75efa648b60994b" then --腾讯视频
            appid = "wxca942bbff22e0e51"
            if string.find(url, "m.v.qq.com") then
            else
                vid = data.Content:match("vid=(.+)%]%]></pagepath>")

                url = string.format("https://v.qq.com/x/page/%s.html", vid)
            end
        end
        if appid == "wxcd10170e55a1f55d" then --爱奇艺视频
            appid = "wx2fab8a9063c8c6d0"
        end
        if appid == "wx5de0c309a1472da6" then --优酷
            appid = "wx2fab8a9063c8c6d0"
            --https://v.youku.com/v_show/id_XNDU0Mjc0NjA0MA%3D%3D.html?
            if string.find(url, "v.youku.com") then
            else
                id = data.Content:match("videoId=(.+)&picUrl=")
                url = string.format("https://v.youku.com/v_show/id_%s.html", id)
            end
        end

        if appid == "wxd09e2d4fceafe6e3" then --芒果视频
            appid = "wxbbc6e0adf8944632"
            if string.find(url, "m.mgtv.com") then
            else
                --log.error("url %s", url)
                --<pagepath><![CDATA[pages/player/player.html?id=9697951]]></pagepath>
                id = data.Content:match("player.html%?id=(.+)%]%]></pagepath>")

                url = string.format("https://www.mgtv.com/b/340679/%s.html", id)
            end
        end

        if ok then
            sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], wxid, ToUserName)
            res, err = c:query(sqlstr)
            if #res == 0 then --说明不存在记录
                sqlstr =
                    string.format(
                    [[INSERT INTO users_info (Uid,Gid,OpCode,SignTime,RealDays,SignDays,Balance,DiceTime,CreateTime)VALUES ("%s","%s",%d,%d,%d,%d,%d,0,%d)]],
                    wxid,
                    ToUserName,
                    12,
                    os.time(),
                    1,
                    1,
                    0,
                    os.time()
                )
                c:query(sqlstr) --插入邀请信息
                GetUserNick(CurrentWxid, data)
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n首次开户成功获得积分10点]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )

                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                Sleep(1)
            end

            sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], wxid, ToUserName)
            res, err = c:query(sqlstr) --判断一下被邀请人是否存在 不存在则发红包奖励 排除重复进群退群
            OpCode = tonumber(res[1].OpCode)
            if OpCode > 0 then
                --log.error("url2 %s", url)
                OpCode = OpCode - 2 --每次解析-2分
                SendJiXi(CurrentWxid, ToUserName, OpCode)
                sqlstr =
                    string.format(
                    [[UPDATE `users_info` SET `OpCode` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                    OpCode,
                    wxid,
                    ToUserName
                )
                c:query(sqlstr)
            else --积分不足
                log.error("url3 %s", url)
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n积分不足请做任务\n1⃣️ 每日签到获🉐️积分2-8/天\n2⃣️ 邀请好友进群获🉐️积分10/人]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )

                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            end
            c.close(c)
        end
    end
end
--检测是否入狱
function GetSQLGame(checkWxid)
    sqlstr = string.format([[select * from games_info where `Uid`= "%s" and `Gid`="%s"]], checkWxid, ToUserName)
    res, err = c:query(sqlstr) --存在
    if #res ~= 0 then
        return res
    end
    return nil
end
--越狱
function OutYY(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    resSQL = GetSQLGame(wxid) --发消息者
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then
            if tonumber(resSQL[1].InTime) - os.time() >= 0 then
                maybe = GenRandInt(1, 100)
                --local fdNick = GetWxidNick(CurrentWxid, atuserlist)
                --print(maybe)
                if 10 < maybe and maybe <= 20 then --入狱
                    local MyINTipsStr = {
                        "@%s\n[社会社会]哇塞竟然金刚🐺附体了,一破冲天,成功逃离💨了监狱",
                        "@%s\n[旺柴]辛辛苦苦挖了好半天🕳️地洞弄🉐️自己满头大汉,差点被👮发现吓得尿了裤子爬出洞来,成功逃离了监狱全靠一股仙气儿",
                        "@%s\n[哇]可能是越狱电影看多了,竟然凭着运气逃离了出来[耶]"
                    }
                    local str = string.format(MyINTipsStr[GenRandInt(1, 3)], Nick)
                    XmlStr =
                        string.format(
                        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                        str
                    )
                    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                    sqlstr =
                        string.format(
                        [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                        0,
                        0,
                        wxid,
                        ToUserName
                    )
                    c:query(sqlstr)
                    return 1
                end

                if tonumber(resSQL[1].InTime) - os.time() > 7200 * 3 then
                    XmlStr =
                        string.format(
                        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[打脸][打脸]被拉入越狱黑名单[打脸][打脸]\n[打脸][打脸]运气太差3次都没成功[打脸][打脸]\n[打脸][打脸]剩余时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                        Nick,
                        SubUnix(tonumber(resSQL[1].InTime), os.time())
                    )
                    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                    return 1
                end

                sqlstr =
                    string.format(
                    [[UPDATE `games_info` SET `InTime` = InTime+ %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                    7200,
                    wxid,
                    ToUserName
                )
                c:query(sqlstr)

                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[打脸]越狱失败,被巡逻👮一顿电炮罪加一等,剩余时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick,
                    SubUnix(tonumber(resSQL[1].InTime) + 7200, os.time())
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                return 1
            end
        end
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n你不在监狱里啊？[捂脸]越狱是什么能吃吗？[吃瓜]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[惊讶]怎么你想上演越狱电影🎬吗,去去去这不适合你[再见]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Nick
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    return 1
end
--保释
function OutBS(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    local atuserlist = data.MsgSource:match([[<atuserlist><!%[CDATA%[(.+)%]%]></atuserlist>]])
    if atuserlist == nil then
        atuserlist = data.MsgSource:match([[<atuserlist>(.+)</atuserlist>]])
    end
    local resSQL = GetSQLGame(wxid) --发消息者
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --自己在监狱不能保释别人
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔自身都难保还想保释别人?[旺柴]老实在监狱里给我待着吧]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        if tonumber(resSQL[1].IsInHp) == 1 then --自己在医院不能保释别人
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔在医院里的人都有妄想症?真是体残+智残+脑残还是先保自己吧[机智]\n[旺柴]老实在医院里给我好好养病吧！真是病都不轻]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
    end

    local resSQL = GetSQLGame(atuserlist) --获取好友

    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --好友在监狱 可以保释
            local myCode = GetSQLCode(wxid)
            if myCode == nil then --黑户
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔你竟然是本群的黑户💔\n😭快回复签到试试😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )
                return 1
            end
            OpCode = tonumber(myCode[1].OpCode)
            --查询一下自己的积分
            if tonumber(resSQL[1].InTime) - os.time() > 7200 * 3 then --保费50
                if OpCode < 50 then
                    XmlStr =
                        string.format(
                        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😭你的积分不足50啊😭\n💔想从越狱黑名单里捞人可不是一件容易的事💔]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                        Nick
                    )
                    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                    return 1
                end

                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[社会社会][社会社会]花费了巨额保费50保出了此人,可见二人关系不一样般[Emm]都说三对情侣两对基]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                --扣出自己积分
                sqlstr =
                    string.format(
                    [[UPDATE `users_info` SET `OpCode` = OpCode - 50 WHERE `Uid` = "%s" and `Gid`="%s"]],
                    wxid,
                    ToUserName
                )
                c:query(sqlstr)
                --设置对方正常状态
                sqlstr =
                    string.format(
                    [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                    0,
                    0,
                    atuserlist,
                    ToUserName
                )
                c:query(sqlstr)
                return 1
            end
            --保费30

            if OpCode < 30 then
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😭你的积分不足30啊😭\n💔穷光蛋还想做慈善家💔\n[机智]我看你是勇气可家吧[机智]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                return 1
            end

            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[加油]花费了30积分保释了对方、乐于助人也无常不是好事,希望他出狱后做个良好市民[机智]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            --扣出自己积分
            sqlstr =
                string.format(
                [[UPDATE `users_info` SET `OpCode` = OpCode - 30 WHERE `Uid` = "%s" and `Gid`="%s"]],
                wxid,
                ToUserName
            )
            c:query(sqlstr)
            --设置对方正常状态
            sqlstr =
                string.format(
                [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                0,
                0,
                atuserlist,
                ToUserName
            )
            c:query(sqlstr)

            return 1
        end

        --好友不在监狱
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n你要被保释的对象不在监狱里,他早就改过自新了[拳头],某人一定会铭记在❤️]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n你要被保释的对象没有任何违规记录,已经被评选为本群的三好市民[好的]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Nick
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    return 1
end
--劫狱
function InJY(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    local atuserlist = data.MsgSource:match([[<atuserlist><!%[CDATA%[(.+)%]%]></atuserlist>]])
    if atuserlist == nil then
        atuserlist = data.MsgSource:match([[<atuserlist>(.+)</atuserlist>]])
    end
    local resSQL = GetSQLGame(wxid) --发消息者
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --自己在监狱 不能劫狱
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[机智]还想在监狱里劫狱?[打脸]这是要造反吗[打脸]谁给你勇气]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
    end

    local resSQL = GetSQLGame(atuserlist)
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --对方在监狱 可以劫狱
            maybe = GenRandInt(1, 100)

            if 50 < maybe and maybe <= 80 then --自己进了监狱
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n万万没想到劫狱被发现了👀,把自己搞进去了,二人在狱里团聚了😄\n刑期:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick,
                    SubUnix(os.time() + 7200, os.time())
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                sqlstr =
                    string.format(
                    [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                    1,
                    os.time() + 7200,
                    wxid,
                    ToUserName
                )
                c:query(sqlstr)
                return 1
            end

            if maybe < 30 then --劫狱成功
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n真是人品大爆发💥,竟然劫狱成功了,顺利将好友解救出来[耶]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                sqlstr =
                    string.format(
                    [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                    0,
                    0,
                    atuserlist,
                    ToUserName
                )
                c:query(sqlstr)
                return 1
            end
            if maybe > 80 then --劫狱没成功
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[衰]好像什么都没发生一样,尽管没劫狱成功,自己却躲了一劫[汗]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick
                )
                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            end

            return 1
        end
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n你要被劫狱的对象不在监狱里,他早就改过自新了[拳头],某人一定会铭记在❤️]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end

    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n这么想劫狱啊[捂脸]动作电影看多了吧]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Nick
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})

    return 1
end

--出狱
function OutCY(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    resSQL = GetSQLGame(wxid) --发消息者
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then
            if tonumber(resSQL[1].InTime) - os.time() >= 0 then
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[打脸]正在监狱服役中,🈲️止任何娱乐活动,剩余时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick,
                    SubUnix(tonumber(resSQL[1].InTime), os.time())
                )

                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                return 1
            end
            sqlstr =
                string.format(
                [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                0,
                0,
                wxid,
                ToUserName
            )
            c:query(sqlstr)

            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n❤️出狱成功,[机智]老老实实做个良好市民吧[加油]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n你不在监狱里啊？[捂脸]这是来探亲来了吗]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n没有任何违规记录,有望评选本群的三好市民[拳头]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Nick
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    return 1
end
--出院
function OutHP(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    resSQL = GetSQLGame(wxid) --发消息者
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsInHp) == 1 then
            if tonumber(resSQL[1].HpTime) - os.time() >= 0 then
                XmlStr =
                    string.format(
                    '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n[打脸]正在医院康复中,禁止多人游戏等👥运动,剩余时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                    Nick,
                    SubUnix(tonumber(resSQL[1].HpTime), os.time())
                )

                Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
                return 1
            end

            sqlstr =
                string.format(
                [[UPDATE `games_info` SET `IsInHp` = %d ,`HpTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                0,
                0,
                wxid,
                ToUserName
            )
            c:query(sqlstr)

            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n❤️出院成功,下次做什么事都要认真点避免意外伤害😯]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n早就痊愈出院了,😯,没事来医院瞎溜达什么？]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n精神病院😯还没有你这位病号啊？去去去,一边去[捂脸]]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        Nick
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    return 1
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

function CheckGame(CurrentWxid, data)
    local atuserlist = data.MsgSource:match([[<atuserlist><!%[CDATA%[(.+)%]%]></atuserlist>]])
    if atuserlist == nil then
        atuserlist = data.MsgSource:match([[<atuserlist>(.+)</atuserlist>]])
    end

    GetUserNick(CurrentWxid, data)

    local resUser = GetSQLCode(wxid)

    if resUser == nil then
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔你竟然是本群的黑户💔\n😭快回复签到试试😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    local resUser = GetSQLCode(atuserlist)

    if resUser == nil then
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔对方是个黑户快去召唤小伙伴加入游戏把让小伙伴回复签到哦😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end

    resSQL = GetSQLGame(wxid) --获取自己
    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --自己在监狱
            local MyINTipsStr = {
                "@%s\n👋在监狱里还想打劫？都泥菩萨过江自身难保了,劫你妹的劫😭\n预计出狱🕐:%s\n剩余时间:%s\n提示:\n越狱----尝试越狱",
                "@%s\n在里不知悔改,还想一错再错。在犯错就要进入1⃣️8⃣️层监狱了[机智]\n预计出狱:%s\n剩余时间:%s\n提示:\n越狱----尝试越狱"
            }
            local str =
                string.format(
                MyINTipsStr[GenRandInt(1, 2)],
                Nick,
                FormatUnixTime2Date(tonumber(resSQL[1].InTime)),
                SubUnix(tonumber(resSQL[1].InTime), os.time())
            )
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                str
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
        if tonumber(resSQL[1].IsInHp) == 1 then --自己在医院
            local MyINTipsStr = {
                "@%s\n👋光天化日之下还想在医院里打劫,真是脑残至极,该吃💊了,随手吃了2粒脑残片冷静了一会😄\n预计出院时间:%s\n剩余时间:%s\n提示:\n出院----到时间出院",
                "@%s\n在医院里不珍惜护士小姐姐,还想打劫[打脸][打脸]等病好了再说吧。\n预计出院时间:%s\n剩余时间:%s\n提示:\n出院----到时间出院"
            }
            local str =
                string.format(
                MyINTipsStr[GenRandInt(1, 2)],
                Nick,
                FormatUnixTime2Date(tonumber(resSQL[1].HpTime)),
                SubUnix(tonumber(resSQL[1].HpTime), os.time())
            )
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                str
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
    end
    --Nick = GetWxidNick(CurrentWxid, atuserlist)
    local resSQL = GetSQLGame(atuserlist) --获取好友

    if resSQL ~= nil then
        if tonumber(resSQL[1].IsIn) == 1 then --好友在监狱
            local MyINTipsStr = {
                "@%s\n⚡️对方已经在监狱里了,难道你想在监狱里打劫？💥你先入狱再说吧\n对方预计出狱时间:%s\n剩余时间:%s\n提示:\n劫狱@好友----尝试解救好友\n保释@好友----花费30保费",
                "@%s\n对方已经在监狱里了,你也想进监狱陪他吗😄\n对方预计出狱时间:%s\n剩余时间:%s\n提示:\n劫狱@好友----尝试解救好友\n保释@好友----花费30保费",
                "[社会社会]对方@%s正在监狱里劳改[衰],请不要打扰人家\n对方预计出狱时间:%s\n剩余时间:%s\n提示:\n劫狱@好友----尝试解救好友\n保释@好友----花费30保费"
            }
            local str =
                string.format(
                MyINTipsStr[GenRandInt(1, 3)],
                Nick,
                FormatUnixTime2Date(tonumber(resSQL[1].InTime)),
                SubUnix(tonumber(resSQL[1].InTime), os.time())
            )
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                str
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})

            return 1
        end
        if tonumber(resSQL[1].IsInHp) == 1 then --好友在医院
            local MyINTipsStr = {
                "@%s\n你的好友正被医院里的护士小姐姐[色]抢救中\n对方预计苏醒时间:%s\n剩余时间:%s",
                "@%s\n你的好友自从进了医院,精神越来越不正常[捂脸],吃了一粒安眠药还在休眠中[发抖]\n对方预计出院时间:%s\n剩余时间:%s\n提示:\n出院----尝试出院",
                "@%s\n[社会社会]对方正在医院很享受,请不要打扰人家\n对方预计出院时间:%s\n剩余时间:%s\n提示:\n出院----尝试出院"
            }
            local str =
                string.format(
                MyINTipsStr[GenRandInt(1, 3)],
                Nick,
                FormatUnixTime2Date(tonumber(resSQL[1].HpTime)),
                SubUnix(tonumber(resSQL[1].HpTime), os.time())
            )
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                str
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return 1
        end
    end

    return 0
end

function DaJie(CurrentWxid, data)
    if CheckGame(CurrentWxid, data) ~= 0 then
        return 1
    end

    local atuserlist = data.MsgSource:match([[<atuserlist><!%[CDATA%[(.+)%]%]></atuserlist>]])
    if atuserlist == nil then
        atuserlist = data.MsgSource:match([[<atuserlist>(.+)</atuserlist>]])
    end

    maybe = GenRandInt(1, 100)
    --local fdNick = GetWxidNick(CurrentWxid, atuserlist)
    if maybe < 90 and maybe >= 80 then --入狱
        local MyINTipsStr = {
            "[炸弹]头戴丝袜的@%s的他正准备打劫[菜刀],碰巧遇到了👮,警察说兄弟你的丝袜没扣洞啊。。\n入狱时间:%s\n出狱时间:%s\n提示:\n出狱----刑期已满",
            "@%s打劫没打成,反而被对方举报了,[心碎]并成功送进去了监狱\n入狱时间:%s\n出狱时间:%s\n提示:\n出狱----刑期已满"
        }
        local str =
            string.format(
            MyINTipsStr[GenRandInt(1, 2)],
            Nick,
            FormatUnixTime2Date(os.time()),
            SubUnix(os.time() + 7200, os.time())
        )
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            str
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        local sqldata = GetSQLGame(wxid)
        if sqldata == nil then --插入
            sqlstr =
                string.format(
                [[INSERT INTO `games_info` (Uid,Gid,IsIn,InTime,IsInHp,HpTime,BoxCount)VALUES ("%s","%s",%d,%d,%d,%d,%d)]],
                wxid,
                ToUserName,
                1,
                os.time() + 7200,
                0,
                0,
                0
            )
        else -- 更新
            sqlstr =
                string.format(
                [[UPDATE `games_info` SET `IsIn` = %d ,`InTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                1,
                os.time() + 7200,
                wxid,
                ToUserName
            )
        end
        c:query(sqlstr)
        return 1
    end

    maybe = GenRandInt(1, 100)
    if maybe <= 50 and maybe >= 40 then --入院
        local MyINTipsStr = {
            "@%s一不留神,踩到个对方仍的🍌皮,滑倒摔伤进了🏥\n入院时间:%s\n出院时间:%s\n提示:\n出院----身体已康复",
            "@%s头戴丝袜,刚出门没走几步,掉进了正在🚧施工的马虎路,把大门牙磕掉了重度摔伤[捂脸],进入了医院进行抢救\n入院时间:%s\n出院时间:%s\n提示:\n出院----身体已康复"
        }
        local str =
            string.format(
            MyINTipsStr[GenRandInt(1, 2)],
            Nick,
            FormatUnixTime2Date(os.time()),
            SubUnix(os.time() + 7200, os.time())
        )
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            str
        )
        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        local sqldata = GetSQLGame(wxid)
        if sqldata == nil then --插入自己信息
            sqlstr =
                string.format(
                [[INSERT INTO `games_info` (Uid,Gid,IsIn,InTime,IsInHp,HpTime,BoxCount)VALUES ("%s","%s",%d,%d,%d,%d,%d)]],
                wxid,
                ToUserName,
                0,
                0,
                1,
                os.time() + 7200,
                0
            )
        else -- 更新
            sqlstr =
                string.format(
                [[UPDATE `games_info` SET `IsInHp` = %d ,`HpTime` = %d WHERE `Uid` = "%s" and `Gid`="%s"]],
                1,
                os.time() + 7200,
                wxid,
                ToUserName
            )
        end
        c:query(sqlstr)
        return 1
    end
    local code = GenRandInt(10, 30)
    local MyINTipsStr = {
        "@%s仿佛上演了电影的那一幕[吃瓜],竟然打劫成功了,从对方劫走了%d点积分",
        "[机智]@%s真是幸运的一天,成功躲过了巡逻的👮,成功🉐️到%d积分[耶]",
        "@%s[Emm][Emm]对方是个穷光蛋,兜里一分💰都没有,自己却施舍了-%d点积分"
    }
    str = string.format(MyINTipsStr[GenRandInt(1, 3)], Nick, code)
    XmlStr =
        string.format(
        '<appmsg appid=""  sdkver="0"><title><![CDATA[%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
        str
    )
    Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})

    if string.find(str, "穷光蛋") then
        sqlstr =
            string.format(
            [[UPDATE `users_info` SET `OpCode` = OpCode-%d WHERE `Uid` = "%s" and `Gid`="%s"]],
            code,
            wxid,
            ToUserName
        )
        c:query(sqlstr)
        sqlstr =
            string.format(
            [[UPDATE `users_info` SET `OpCode` =OpCode+ %d WHERE `Uid` = "%s" and `Gid`="%s"]],
            code,
            atuserlist,
            ToUserName
        )
        c:query(sqlstr)
        local str = string.format("wxid %s userlist %s", wxid, atuserlist)
        log.error("%s", str)
        return 0
    end
    sqlstr =
        string.format(
        [[UPDATE `users_info` SET `OpCode` =OpCode+ %d WHERE `Uid` = "%s" and `Gid`="%s"]],
        code,
        wxid,
        ToUserName
    )
    c:query(sqlstr)
    sqlstr =
        string.format(
        [[UPDATE `users_info` SET `OpCode` =OpCode- %d WHERE `Uid` = "%s" and `Gid`="%s"]],
        code,
        atuserlist,
        ToUserName
    )
    c:query(sqlstr)
    return 0
end
function XinXi(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], wxid, ToUserName)
    res, err = c:query(sqlstr) --存在
    if #res ~= 0 then
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😜查询成功😜\n🍺剩余积分:%s\n☑️连续签到:%d天\n☑️累计签到:%d天\n✔️上次签到时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick,
            res[1].OpCode,
            res[1].RealDays,
            res[1].SignDays,
            FormatUnixTime2Date(tonumber(res[1].SignTime))
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})

        return
    else -- 不存在
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔你还没有记录哦💔\n😭快回复签到试试😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    end
end
function TiXian(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)

    hourNow = tonumber(os.date("%H", os.time()))

    if hourNow > 18 or hourNow < 9 then
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n该时段已经暂停提现业务\n🈺️业时间早9点-晚18点]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return 1
    end
    sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], wxid, ToUserName)
    res, err = c:query(sqlstr) --存在
    if #res ~= 0 then
        OpCode = tonumber(res[1].OpCode)
        if OpCode < 10 then
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔积分不足💔\n😭每日签到/拉好友进群都可以获🉐️积分哦😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )

            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return
        end

        return
    else -- 不存在
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n💔你还没有记录哦💔\n😭快回复签到赚取积分吧😭]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
    end
end

function Sign(CurrentWxid, data)
    GetUserNick(CurrentWxid, data)
    sqlstr = string.format([[select * from users_info where `Uid`= "%s" and `Gid`="%s"]], wxid, ToUserName)
    res, err = c:query(sqlstr) --存在
    if #res ~= 0 then
        rndCode = math.random(2, 8)
        OpCode = tonumber(res[1].OpCode) + rndCode
        SignTime = tonumber(res[1].SignTime)
        day = os.date("%d", os.time()) - os.date("%d", SignTime)
        --log.error("ret %d", day)
        if day == 0 then
            XmlStr =
                string.format(
                '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n今天已经签到过了,不要重复签到哦😄]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
                Nick
            )
            Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
            return
        end
        if day == 1 then --连续签到
            RealDays = tonumber(res[1].RealDays) + 1
        end
        if day > 1 or day < 0 then
            RealDays = 1
        end

        if day == -30 or day == -29 then
            RealDays = tonumber(res[1].RealDays) + 1
        end

        NSignTime = os.time()
        sqlstr =
            string.format(
            [[UPDATE `users_info` SET `Gid` = "%s" ,`OpCode` = %d ,`SignDays` = SignDays +1 ,`RealDays` = %d ,`SignTime` = %d WHERE `Uid` = "%s"]],
            ToUserName,
            OpCode,
            RealDays,
            NSignTime,
            wxid
        )
        c:query(sqlstr)
        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n😜签到成功😜\n🍺获🉐️积分:%d\n🍺剩余积分:%d\n☑️连续签到:%d天\n☑️累计签到:%d天\n✔️上次签到时间:%s\n📝本次签到时间:%s]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick,
            rndCode,
            OpCode,
            RealDays,
            res[1].SignDays + 1,
            FormatUnixTime2Date(SignTime),
            FormatUnixTime2Date(NSignTime)
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return
    else --不存在记录
        sqlstr =
            string.format(
            [[INSERT INTO users_info (Uid,Gid,OpCode, SignTime,RealDays,SignDays,Balance,DiceTime,CreateTime)VALUES ("%s","%s",%d,%d,%d,%d,%d,0,%d)]],
            wxid,
            ToUserName,
            12,
            os.time(),
            1,
            1,
            0,
            os.time()
        )
        res, err = c:query(sqlstr) --插入邀请信息

        XmlStr =
            string.format(
            '<appmsg appid=""  sdkver="0"><title><![CDATA[@%s\n首次开户成功获得积分10点\n每日签到和拉好友进群都会获🉐️积分哦\n[机智]积分🉑️进行🎮或提现]]></title><des></des><action></action><type>57</type><showtype>0</showtype><soundtype>0</soundtype><mediatagname></mediatagname><messageext></messageext><messageaction></messageaction><content></content><contentattr>0</contentattr><url></url><lowurl></lowurl><dataurl></dataurl><lowdataurl></lowdataurl><songalbumurl></songalbumurl><songlyric></songlyric><appattach><totallen>0</totallen><attachid></attachid><emoticonmd5></emoticonmd5><fileext></fileext><cdnthumbaeskey></cdnthumbaeskey><aeskey></aeskey></appattach><extinfo></extinfo><sourceusername></sourceusername><sourcedisplayname></sourcedisplayname><thumburl></thumburl><md5></md5><statextstr></statextstr><directshare>0</directshare><refermsg><type>1</type><svrid>413279805977715132</svrid><fromusr></fromusr><chatusr></chatusr><displayname>消息来自:IPhone 12 X Max 1024GB📱</displayname><content>😄</content><msgsource></msgsource></refermsg></appmsg><fromusername></fromusername>',
            Nick
        )

        Api.SendAppMsg(CurrentWxid, {ToUserName = ToUserName, MsgType = 57, Content = XmlStr})
        return
    end
end
function GetConn()
    c = mysql.new()
    ok, err = c:connect({host = MYSQL_IP, port = MYSQL_PORT, database = "OPQDB", user = "root", password = "fu4ku."})
    if err ~= nil then
        log.error("mysql err %v", err)
        return 1
    end
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
function CheckAdmin(id)
    file = string.format("./Plugins/Games/admin_%s.dat", id)
    UserDat = readAll(file)
    if UserDat == nil then
    else
        return UserDat
    end
    return nil
end
function SetChatRoom(RoomId)
    file = string.format("./Plugins/Games/%s.dat", RoomId)
    writeFile(file, "1")
end

function FormatUnixTime2Date(t)
    return string.format(
        "%s年%s月%s日%s时%s分%s秒",
        os.date("%Y", t),
        os.date("%m", t),
        os.date("%d", t),
        os.date("%H", t),
        os.date("%M", t),
        os.date("%S", t)
    )
end

function SubUnix(t1, t2)
    local t3 = t1 - t2
    return string.format("%.2d时%.2d分%.2d秒", t3 / (60 * 60), t3 / 60 % 60, t3 % 60)
end

function GenRandInt(x, y)
    math.randomseed(os.time())
    num = math.random(x, y)
    return num
end
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end
function Sleep(n)
    --log.notice("==========Sleep==========\n%d", n)
    local t0 = os.clock()
    while os.clock() - t0 <= n do
    end
    --log.notice("==========over Sleep==========\n%d", n)
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
