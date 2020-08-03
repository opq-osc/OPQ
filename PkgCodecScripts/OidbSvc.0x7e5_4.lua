local log = require("log")
--点赞功能包
function PackCodecName()
    return "OidbSvc.0x7e5_4"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(2021)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(4)
    data:EncodeVarint(4, 2)
    buf_1 = PkgCodec.newPbCodec()
    buf_1:EncodeVarint(11, 0)
    buf_1:EncodeVarint(t.UserID)
    buf_1:EncodeVarint(12, 0)
    buf_1:EncodeVarint(10002)
    buf_1:EncodeVarint(13, 0)
    buf_1:EncodeVarint(1)
    data:EncodeRawBytes(buf_1:GetPbData())
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x7e5_4",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    log.notice("%s", str)
    return {Ret = 0}
end
