local log = require("log")
--设置群成员禁言功能包
function PackCodecName()
    return "OidbSvc.0x570_8"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(1392)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(8)
    data:EncodeVarint(4, 2)
    bufs = PkgCodec.newBufferStream()
    bufs:WriteInt(4, t.GroupID)
    bufs:WriteBuffer({0x20, 0x0, 0x1})
    bufs:WriteInt(4, t.ShutUpUserID)
    bufs:WriteInt(4, t.ShutTime * 60)
    data:EncodeRawBytes(bufs:GetBuffer())
    
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x570_8",
            SsoData = data:GetPbData()
        }
    )
    return 0 --返回只能为0 
end
function UnPackPkg(rawData, User)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.notice("%s", str)
    Ret, _ = PkgCodec.ReadPbFieldData(3, rawData)
    return {Ret = Ret} 
end
