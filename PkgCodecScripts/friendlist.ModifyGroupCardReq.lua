local log = require("log")
--修改群成员名片功能包

function PackCodecName()
    return "friendlist.ModifyGroupCardReq"
end
function PackPkg(t, User)
    str = string.format("PackPkg UserNewNick %s t %d", t.NewNick, User.StrUin)
    log.info("%s", str)
    jceWriteStream = PkgCodec.newBufferStream()
    jceWriteStream:JceWriteInt(t.UserID, 0)
    jceWriteStream:JceWriteInt(31, 1)
    jceWriteStream:JceWriteString(t.NewNick, 2)
    jceWriteStream:JceWriteBool(false, 3)
    jceWriteStream:JceWriteString("", 4)
    jceWriteStream:JceWriteString("", 5)
    jceWriteStream:JceWriteString("", 6)
    jceWriteStream:JceWriteStruct(0)
    req = jceWriteStream:GetBuffer()
    listStream = PkgCodec.newBufferStream()
    listStream:JceWriteBool(false, 0)
    listStream:JceWriteInt(t.GroupID, 1)
    listStream:JceWriteBool(false, 2)
    listStream:JceWriteList(req, 3)
    listStream:JceWriteStruct(0)
    listStream:JceWriteMap("MGCREQ", "friendlist.ModifyGroupCardReq", 0)
    req = listStream:GetBuffer()
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "friendlist.ModifyGroupCardReq",
            ServantName = "mqq.IMService.FriendListServiceServantObj",
            SFuncName = "ModifyGroupCardReq",
            SsoData = req
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    jceOutStream = PkgCodec.newBufferStream(rawData)
    jceOutStream:JceReadMap("MGCRESP", "friendlist.ModifyGroupCardResp", 0)
    jceOutStream:JceReadStruct()
    jceOutStream:JceReadInt(0)
    jceOutStream:JceReadInt(1)
    GroupID = jceOutStream:JceReadInt(2)
    len = jceOutStream:JceReadList(3)
    UserID = jceOutStream:JceReadInt(0)
    --str = string.format(" GroupID %s len %d User %s", GroupID, len, User.StrUin)
    --log.info("%s", str)
    return {GroupID = GroupID, UserID = UserID}
end
