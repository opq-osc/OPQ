local log = require("log")
--拍一拍
function PackCodecName()
    return "OidbSvc.0xed3_1"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(3795)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(1)
    buf_40 = PkgCodec.newPbCodec()
    buf_40:EncodeVarint(1, 0)
    buf_40:EncodeVarint(t.UserID)
    if t.Type == 1 then
        buf_40:EncodeVarint(2, 0)
        buf_40:EncodeVarint(t.GroupID)
    end
    buf_40:EncodeVarint(3, 0)
    buf_40:EncodeVarint(417649)
    buf_40:EncodeVarint(4, 0)
    buf_40:EncodeVarint(0)
    if t.Type == 1 then
        buf_40:EncodeVarint(5, 0)
        buf_40:EncodeVarint(0)
    else
        buf_40:EncodeVarint(5, 0)
        buf_40:EncodeVarint(t.UserID)
    end
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_40:GetPbData())
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0xed3_1",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.notice("%s", str)
    return {Ret = 0}
end
