local log = require("log")
--设置/取消管理員功能包
function PackCodecName()
    return "OidbSvc.0x55c_1"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(1372)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(1)
    data:EncodeVarint(4, 2)
    bufs = PkgCodec.newBufferStream()
    bufs:WriteInt(4, t.GroupID)
    bufs:WriteInt(4, t.UserID)
    bufs:WriteBuffer({t.Flag})
    data:EncodeRawBytes(bufs:GetBuffer())
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x55c_1",
            SsoData = data:GetPbData()
        }
    )
    return 0 --返回只能为0
end
function UnPackPkg(rawData, User)
    Ret, _ = PkgCodec.ReadPbFieldData(3, rawData)
    return {Ret = Ret}
end
