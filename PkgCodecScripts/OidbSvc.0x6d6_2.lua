local log = require("log")
--获取群文件下载链接功能包
function PackCodecName()
    return "OidbSvc.0x6d6_2"
end
function PackPkg(t, User) --t.GroupID
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(1750)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(2)
    buf_38 = PkgCodec.newPbCodec()
    buf_38:EncodeVarint(1, 0)
    buf_38:EncodeVarint(t.GroupID)
    buf_38:EncodeVarint(2, 0)
    buf_38:EncodeVarint(7)
    buf_38:EncodeVarint(3, 0)
    buf_38:EncodeVarint(102)
    buf_38:EncodeVarint(4, 2)
    buf_38:EncodeStringBytes(t.FileID)
    buf_3 = PkgCodec.newPbCodec()
    buf_3:EncodeVarint(3, 2)
    buf_3:EncodeRawBytes(buf_38:GetPbData())
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_3:GetPbData())
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x6d6_2",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.notice("%s", str)

    _, userdata = PkgCodec.ReadPbFieldData(4, rawData)
    _, buf = PkgCodec.ReadPbFieldData(3, userdata)
    Ret, _ = PkgCodec.ReadPbFieldData(0, buf)
    _, ip = PkgCodec.ReadPbFieldData(5, buf)
    _, key = PkgCodec.ReadPbFieldData(6, buf)
    return {
        Ret = Ret,
        Url = string.format("http://%s/ftn_handler/%s", PkgCodec.ToString(ip), PkgCodec.HexDump(key))
    }
end
