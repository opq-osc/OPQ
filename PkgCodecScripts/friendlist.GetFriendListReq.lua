local log = require("log")
--获取好友列表功能包
function PackCodecName()
    return "friendlist.GetFriendListReq"
end
function PackPkg(t, User)
    jceWriteStream = PkgCodec.newBufferStream()
    jceWriteStream:JceWriteInt(3, 0)
    jceWriteStream:JceWriteBool(true, 1)
    jceWriteStream:JceWriteInt(User.DwUin, 2)
    jceWriteStream:JceWriteInt(t.StartIndex, 3)
    jceWriteStream:JceWriteInt(200, 4)
    jceWriteStream:JceWriteBool(false, 5)
    jceWriteStream:JceWriteBool(true, 6)
    jceWriteStream:JceWriteBool(false, 7)
    jceWriteStream:JceWriteInt(100, 8)
    jceWriteStream:JceWriteBool(true, 9)
    jceWriteStream:JceWriteBool(true, 10)
    jceWriteStream:JceWriteInt(7, 11)
    jceWriteStream:JceWriteStringArray(nil, 12)
    --[ ]
    jceWriteStream:JceWriteBool(false, 13)
    jceWriteStream:JceWriteStruct(0)
    jceWriteStream:JceWriteMap("FL", "friendlist.GetFriendListReq", 0)
    req = jceWriteStream:GetBuffer()
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "friendlist.GetFriendListReq",
            ServantName = "mqq.IMService.FriendListServiceServantObj",
            SFuncName = "GetFriendListReq",
            SsoData = req
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    jceOutStream = PkgCodec.newBufferStream(rawData)
    jceOutStream:JceReadMap("FLRESP", "friendlist.GetFriendListResp", 0)
    jceOutStream:JceReadStruct()
    jceOutStream:JceReadInt(0)
    jceOutStream:JceReadInt(1)
    jceOutStream:JceReadInt(2)
    StartIndex = jceOutStream:JceReadInt(3)
    GetfriendCount = jceOutStream:JceReadInt(4)
    Totoal_friend_count = jceOutStream:JceReadInt(5)
    Friend_count = jceOutStream:JceReadInt(6)
    len = jceOutStream:JceReadList(7)
    FriendlistInfo = {
        StartIndex = StartIndex,
        GetfriendCount = GetfriendCount,
        Totoal_friend_count = Totoal_friend_count,
        Friend_count = Friend_count,
        Friendlist = {}
    }
    for i = 1, len, 1 do
        jceOutStream:Skip(1) --跳过struct头 0xa
        FriendUin = jceOutStream:JceReadInt(0)
        jceOutStream:JceReadInt(1)
        jceOutStream:JceReadInt(2)
        Remark = jceOutStream:JceReadString(3)
        jceOutStream:JceReadInt(4)
        Status = jceOutStream:JceReadInt(5)
        jceOutStream:JceReadInt(6)
        jceOutStream:JceReadInt(7)
        jceOutStream:JceReadInt(8)
        jceOutStream:JceReadInt(9)
        jceOutStream:JceReadInt(10)
        jceOutStream:JceReadInt(11)
        jceOutStream:JceReadString(12)
        IsRemark = jceOutStream:JceReadBool(13)
        NickName = jceOutStream:JceReadString(14)
        jceOutStream:JceReadInt(15)
        jceOutStream:JceReadString(16)
        jceOutStream:JceReadString(17)
        jceOutStream:JceReadInt(18)
        jceOutStream:Skip(5)
        --str = string.format("GetFriendListResp %s len %s", PkgCodec.HexDump(jceOutStream:GetBuffer()), len)
        --log.info("%s", str)
        for i = 1, 4, 1 do
            jceOutStream:JceReadInt(0)
            jceOutStream:Skip(1)
            jceOutStream:JceReadInt(0)
            jceOutStream:JceReadInt(1)
            jceOutStream:JceReadInt(2)
            jceOutStream:JceReadInt(3)
            jceOutStream:JceReadInt(4)
            jceOutStream:Skip(1)
        end
        jceOutStream:Skip(3)
        jceOutStream:JceReadInt(20)
        jceOutStream:JceReadBytes(21)
        jceOutStream:JceReadInt(22)
        jceOutStream:JceReadInt(23)
        jceOutStream:JceReadInt(24)
        jceOutStream:JceReadInt(25)
        jceOutStream:JceReadInt(26)
        OnlineStr = jceOutStream:JceReadString(27)
        jceOutStream:JceReadInt(28)
        jceOutStream:JceReadInt(29)
        jceOutStream:JceReadInt(30)
        jceOutStream:JceReadInt(31)
        jceOutStream:JceReadInt(32)
        jceOutStream:JceReadString(33)
        jceOutStream:JceReadString(34)
        jceOutStream:JceReadInt(35)
        jceOutStream:JceReadInt(36)
        jceOutStream:JceReadInt(37)
        jceOutStream:JceReadInt(38)
        jceOutStream:JceReadInt(39)
        jceOutStream:JceReadInt(40)
        jceOutStream:JceReadBytes(41)
        jceOutStream:JceReadInt(42)
        jceOutStream:JceReadInt(43)
        jceOutStream:JceReadInt(44)
        jceOutStream:JceReadString(45)
        jceOutStream:JceReadInt(46)
        jceOutStream:JceReadInt(47)
        jceOutStream:JceReadInt(48)
        jceOutStream:JceReadString(49)
        jceOutStream:JceReadInt(50)
        jceOutStream:JceReadInt(51)
        jceOutStream:JceReadBytes(52)
        jceOutStream:JceReadInt(53)
        jceOutStream:JceReadInt(54)
        jceOutStream:JceReadBytes(55)
        jceOutStream:JceReadBytes(56)
        jceOutStream:JceReadInt(57)
        jceOutStream:JceReadInt(58)
        jceOutStream:JceReadBytes(59)
        jceOutStream:JceReadBytes(60)
        jceOutStream:JceReadBytes(61)
        jceOutStream:JceReadBytes(62)
        jceOutStream:Skip(1) --跳过struct尾 0xb

        info = {
            FriendUin = FriendUin,
            Remark = Remark,
            Status = Status,
            IsRemark = IsRemark,
            NickName = NickName,
            OnlineStr = OnlineStr
        }

        FriendlistInfo.Friendlist[i] = info
    end

    --str = string.format("GetFriendListResp %s len %s", PkgCodec.HexDump(jceOutStream:GetBuffer()), len)
    --log.info("%s", str)

    return FriendlistInfo
end
