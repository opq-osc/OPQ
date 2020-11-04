local log = require("log")
--获取群成员列表功能包
function PackCodecName()
    return "friendlist.GetFriendListReq"
end
function PackPkg(t, User)
    jceWriteStream = PkgCodec.newBufferStream()
    jceWriteStream:JceWriteInt(User.DwUin, 0)
    jceWriteStream:JceWriteInt(t.GroupUin, 1)
    jceWriteStream:JceWriteInt(t.LastUin, 2)
    jceWriteStream:JceWriteInt(t.GroupUin, 3)
    jceWriteStream:JceWriteInt(2, 4)
    jceWriteStream:JceWriteBool(false, 5)
    jceWriteStream:JceWriteBool(false, 6)
    jceWriteStream:JceWriteStruct(0)
    jceWriteStream:JceWriteMap("GTML", "friendlist.GetTroopMemberListReq", 0)
    req = jceWriteStream:GetBuffer()
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "friendlist.GetTroopMemberListReq",
            ServantName = "mqq.IMService.FriendListServiceServantObj",
            SFuncName = "GetTroopMemberListReq",
            SsoData = req
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.notice("%s", str)
    jceOutStream = PkgCodec.newBufferStream(rawData)
    jceOutStream:JceReadMap("GTMLRESP", "friendlist.GetTroopMemberListResp", 0)
    jceOutStream:JceReadStruct()
    jceOutStream:JceReadInt(0)
    GroupUin = jceOutStream:JceReadInt(1)
    jceOutStream:JceReadInt(2)
    len = jceOutStream:JceReadList(3)
    MemberListInfo = {
        GroupUin = GroupUin,
        LastUin = 0,
        Count = len,
        MemberList = {}
    }
    for i = 1, len, 1 do
        jceOutStream:Skip(1) --跳过struct头 0xa
        MemberUin = jceOutStream:JceReadInt(0)
        FaceId = jceOutStream:JceReadInt(1)
        Age = jceOutStream:JceReadInt(2)
        Gender = jceOutStream:JceReadInt(3)
        NickName = jceOutStream:JceReadString(4)
        Status = jceOutStream:JceReadInt(5)
        ShowName = jceOutStream:JceReadString(6)
        GroupCard = jceOutStream:JceReadString(8)
        jceOutStream:JceReadInt(9)
        jceOutStream:JceReadString(10)
        Email = jceOutStream:JceReadString(11)
        Memo = jceOutStream:JceReadString(12)
        AutoRemark = jceOutStream:JceReadString(13)
        MemberLevel = jceOutStream:JceReadInt(14)
        JoinTime = jceOutStream:JceReadInt(15)
        LastSpeakTime = jceOutStream:JceReadInt(16)
        CreditLevel = jceOutStream:JceReadInt(17)
        GroupAdmin = jceOutStream:JceReadInt(18)
        jceOutStream:JceReadInt(19)
        jceOutStream:JceReadInt(20)
        jceOutStream:JceReadInt(21)
        jceOutStream:JceReadInt(22)
        SpecialTitle = jceOutStream:JceReadString(23)
        jceOutStream:JceReadInt(24)
        jceOutStream:JceReadString(25)
        jceOutStream:JceReadInt(26)
        jceOutStream:JceReadInt(27)
        jceOutStream:JceReadInt(28)
        jceOutStream:JceReadInt(29)
        jceOutStream:JceReadInt(30)
        jceOutStream:JceReadInt(31)
        jceOutStream:Skip(2)
        jceOutStream:JceReadInt(0)
        jceOutStream:Skip(2)
        jceOutStream:Skip(1)
        jceOutStream:JceReadInt(33)
        jceOutStream:JceReadInt(34)
        jceOutStream:JceReadInt(35)
        jceOutStream:JceReadInt(36)
        jceOutStream:JceReadInt(37)
        jceOutStream:JceReadInt(38)
        jceOutStream:JceReadBytes(39)
        jceOutStream:JceReadBytes(40)
        jceOutStream:JceReadInt(41)

        jceOutStream:Skip(1) --跳过struct尾 0xb

        info = {
            MemberUin = MemberUin,
            FaceId = FaceId,
            Age = Age,
            Gender = Gender,
            NickName = NickName,
            Status = Status,
            ShowName = ShowName,
            GroupAdmin = GroupAdmin,
            GroupCard = GroupCard,
            Email = Email,
            Memo = Memo,
            AutoRemark = AutoRemark,
            MemberLevel = MemberLevel,
            JoinTime = JoinTime,
            LastSpeakTime = LastSpeakTime,
            CreditLevel = CreditLevel,
            SpecialTitle = SpecialTitle
        }

        MemberListInfo.MemberList[i] = info
    end

    LastUin = jceOutStream:JceReadInt(4)
    MemberListInfo.LastUin = LastUin

    return MemberListInfo
end
