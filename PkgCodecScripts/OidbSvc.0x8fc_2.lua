local log = require("log")
--设置头衔功能包
function PackCodecName()
    return "OidbSvc.0x8fc_2"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(2300)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(2)
    buf_40 = PkgCodec.newPbCodec()
    buf_40:EncodeVarint(1, 0)
    buf_40:EncodeVarint(t.GroupID)
    buf_32 = PkgCodec.newPbCodec()
    buf_32:EncodeVarint(1, 0)
    buf_32:EncodeVarint(t.UserID)
    buf_32:EncodeVarint(5, 2)
    buf_32:EncodeStringBytes(t.NewTitle)
    buf_32:EncodeVarint(6, 0)
    buf_32:EncodeVarint(4294967295)
    buf_32:EncodeVarint(7, 2)
    buf_32:EncodeStringBytes("")
    buf_40:EncodeVarint(3, 2)
    buf_40:EncodeRawBytes(buf_32:GetPbData())
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_40:GetPbData())

    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x8fc_2",
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
