local log = require("log")
--获取好友文件下载链接功能包
function PackCodecName()
    return "OfflineFilleHandleSvr.pb_ftn_CMD_REQ_APPLY_DOWNLOAD-1200"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(1200)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(617008520)
    buf_38 = PkgCodec.newPbCodec()
    buf_38:EncodeVarint(10, 0)
    buf_38:EncodeVarint(User.DwUin)
    buf_38:EncodeVarint(20, 2)
    buf_38:EncodeStringBytes(t.FileID)
    buf_38:EncodeVarint(30, 0)
    buf_38:EncodeVarint(2)
    data:EncodeVarint(14, 2)
    data:EncodeRawBytes(buf_38:GetPbData())
    data:EncodeVarint(101, 0)
    data:EncodeVarint(3)
    data:EncodeVarint(102, 0)
    data:EncodeVarint(303)
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OfflineFilleHandleSvr.pb_ftn_CMD_REQ_APPLY_DOWNLOAD-1200",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    _, userdata = PkgCodec.ReadPbFieldData(14, rawData)
    _, buf = PkgCodec.ReadPbFieldData(30, userdata)
    _, url = PkgCodec.ReadPbFieldData(50, buf)
    _, buf = PkgCodec.ReadPbFieldData(40, userdata)
    FromUin, _ = PkgCodec.ReadPbFieldData(1, buf)
    FileSize, _ = PkgCodec.ReadPbFieldData(3, buf)
    _, FileName = PkgCodec.ReadPbFieldData(7, buf)
    return {
        FromUin = FromUin,
        FileSize = FileSize,
        FileName = PkgCodec.ToString(FileName),
        Url = PkgCodec.ToString(url)
    }
end
