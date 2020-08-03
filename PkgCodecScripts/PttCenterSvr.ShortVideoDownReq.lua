local log = require("log")
--获取短视频Url功能包
function PackCodecName()
    return "PttCenterSvr.ShortVideoDownReq"
end
function PackPkg(t, User)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(400)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(0)
    buf_221 = PkgCodec.newPbCodec()
    buf_221:EncodeVarint(1, 0)
    buf_221:EncodeVarint(User.DwUin)
    buf_221:EncodeVarint(2, 0)
    buf_221:EncodeVarint(User.DwUin)
    buf_221:EncodeVarint(3, 0)
    buf_221:EncodeVarint(1)
    buf_221:EncodeVarint(4, 0)
    buf_221:EncodeVarint(7)
    buf_221:EncodeVarint(5, 2)
    buf_221:EncodeRawBytes(PkgCodec.DecodeBase64(t.VideoUrl))
    buf_221:EncodeVarint(6, 0)
    buf_221:EncodeVarint(t.GroupID)
    buf_221:EncodeVarint(7, 0)
    buf_221:EncodeVarint(0)
    buf_221:EncodeVarint(8, 2)
    buf_221:EncodeRawBytes(PkgCodec.DecodeBase64(t.VideoMd5))
    buf_221:EncodeVarint(9, 0)
    buf_221:EncodeVarint(1)
    buf_221:EncodeVarint(10, 0)
    buf_221:EncodeVarint(2)
    buf_221:EncodeVarint(11, 0)
    buf_221:EncodeVarint(2)
    buf_221:EncodeVarint(12, 0)
    buf_221:EncodeVarint(2)
    buf_221:EncodeVarint(15, 0)
    buf_221:EncodeVarint(1)
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_221:GetPbData())
    buf_2 = PkgCodec.newPbCodec()
    buf_2:EncodeVarint(1, 0)
    buf_2:EncodeVarint(0)
    data:EncodeVarint(100, 2)
    data:EncodeRawBytes(buf_2:GetPbData())

    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "PttCenterSvr.ShortVideoDownReq",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    _, userdata = PkgCodec.ReadPbFieldData(4, rawData)
    Ret, _ = PkgCodec.ReadPbFieldData(1, userdata)
    _, msg = PkgCodec.ReadPbFieldData(2, userdata)
    _, urlbuf = PkgCodec.ReadPbFieldData(9, userdata)
    _, url = PkgCodec.ReadPbFieldData(10, urlbuf)
    _, urlkey = PkgCodec.ReadPbFieldData(11, urlbuf)
    return {
        Ret = Ret,
        MsgStr = PkgCodec.ToString(msg),
        VideoUrl = string.format("%s%s", PkgCodec.ToString(url), PkgCodec.ToString(urlkey))
    }
end
