local log = require("log")
--设置全群禁言功能包
function PackCodecName()
    return "OidbSvc.0x89a_0"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(2202)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(0)
    buf_14 = PkgCodec.newPbCodec()
    buf_14:EncodeVarint(1, 0)
    buf_14:EncodeVarint(t.GroupID)
    buf_14:EncodeVarint(2, 2)
    data_1 = PkgCodec.newPbCodec()
    data_1:EncodeVarint(17, 0)
    data_1:EncodeVarint(t.Switch)
    buf_14:EncodeRawBytes(data_1:GetPbData())
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_14:GetPbData())
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x89a_0",
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
