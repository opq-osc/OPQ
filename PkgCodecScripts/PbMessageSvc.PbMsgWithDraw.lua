local log = require("log")
--撤回功能包
function PackCodecName()
    return "PbMessageSvc.PbMsgWithDraw"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    buf_38 = PkgCodec.newPbCodec()
    buf_38:EncodeVarint(1, 0)
    buf_38:EncodeVarint(1)
    buf_38:EncodeVarint(2, 0)
    buf_38:EncodeVarint(0)
    buf_38:EncodeVarint(3, 0)
    buf_38:EncodeVarint(t.GroupID)
    buf_11 = PkgCodec.newPbCodec()
    buf_11:EncodeVarint(1, 0)
    buf_11:EncodeVarint(t.MsgSeq)
    buf_11:EncodeVarint(2, 0)
    buf_11:EncodeVarint(t.MsgRandom)
    buf_11:EncodeVarint(3, 0)
    buf_11:EncodeVarint(0)
    buf_38:EncodeVarint(4, 2)
    buf_38:EncodeRawBytes(buf_11:GetPbData())
    buf_13 = PkgCodec.newPbCodec()
    buf_13:EncodeVarint(1, 0)
    buf_13:EncodeVarint(0)
    buf_9 = PkgCodec.newPbCodec()
    buf_9:EncodeVarint(1, 0)
    buf_9:EncodeVarint(t.MsgSeq)
    buf_9:EncodeVarint(2, 0)
    buf_9:EncodeVarint(0)
    buf_9:EncodeVarint(3, 0)
    buf_9:EncodeVarint(0)
    buf_9:EncodeVarint(4, 0)
    buf_9:EncodeVarint(0)
    buf_13:EncodeVarint(2, 2)
    buf_13:EncodeRawBytes(buf_9:GetPbData())
    buf_38:EncodeVarint(5, 2)
    buf_38:EncodeRawBytes(buf_13:GetPbData())
    data:EncodeVarint(2, 2)
    data:EncodeRawBytes(buf_38:GetPbData())

    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "PbMessageSvc.PbMsgWithDraw",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.notice("%s", str)

    _, userdata = PkgCodec.ReadPbFieldData(2, rawData)
    Ret, _ = PkgCodec.ReadPbFieldData(1, userdata)
    _, msg = PkgCodec.ReadPbFieldData(2, userdata)
    return {Ret = Ret, Msg = PkgCodec.ToString(msg)}
end
