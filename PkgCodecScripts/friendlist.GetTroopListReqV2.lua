local log = require("log")
--获取群列表功能包
function PackCodecName()
    return "friendlist.GetTroopListReqV2"
end
function PackPkg(t, User)
    jceWriteStream = PkgCodec.newBufferStream()
    jceWriteStream:JceWriteInt(User.DwUin, 0)
    jceWriteStream:JceWriteBool(true, 1)
    if t.NextToken == "" then
        jceWriteStream:JceWriteStringArray(nil, 2)
    else
        jceWriteStream:JceWriteBytes(PkgCodec.DecodeBase64(t.NextToken), 2)
    end
    jceWriteStream:JceWriteBool(true, 4)
    jceWriteStream:JceWriteInt(7, 5)
    jceWriteStream:JceWriteStruct(0)
    jceWriteStream:JceWriteMap("GetTroopListReqV2", "friendlist.GetTroopListReqV2", 0)
    req = jceWriteStream:GetBuffer()
    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "friendlist.GetTroopListReqV2",
            ServantName = "mqq.IMService.FriendListServiceServantObj",
            SFuncName = "GetTroopListReqV2",
            SsoData = req
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    jceOutStream = PkgCodec.newBufferStream(rawData)
    jceOutStream:JceReadMap("GetTroopListRespV2", "friendlist.GetTroopListRespV2", 0)
    jceOutStream:JceReadStruct()
    jceOutStream:JceReadInt(0)
    Count = jceOutStream:JceReadInt(1)
    jceOutStream:JceReadInt(2)
    jceOutStream:JceReadInt(3)
    NextToken = jceOutStream:JceReadBytes(4)
    len = jceOutStream:JceReadList(5)
    --str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(jceOutStream:GetBuffer()), User.StrUin)
    --log.info("%s", str)
    TroopListInfo = {NextToken = NextToken, Count = Count, TroopList = {}}
    for i = 1, len, 1 do
        jceOutStream:Skip(1)
        jceOutStream:JceReadInt(0)
        GroupId = jceOutStream:JceReadInt(1)
        jceOutStream:JceReadInt(2)
        jceOutStream:JceReadInt(3)
        GroupName = jceOutStream:JceReadString(4)
        GroupNotice = jceOutStream:JceReadString(5)

        jceOutStream:JceReadInt(6)
        jceOutStream:JceReadInt(7)
        jceOutStream:JceReadInt(8)
        jceOutStream:JceReadInt(9)
        jceOutStream:JceReadInt(10)
        jceOutStream:JceReadInt(11)
        jceOutStream:JceReadInt(12)
        jceOutStream:JceReadInt(13)
        jceOutStream:JceReadInt(14)
        jceOutStream:JceReadInt(15)
        jceOutStream:JceReadInt(16)
        jceOutStream:JceReadInt(17)
        jceOutStream:JceReadInt(18)

        GroupMemberCount = jceOutStream:JceReadInt(19)
        jceOutStream:JceReadInt(20)
        jceOutStream:JceReadInt(21)
        jceOutStream:JceReadInt(22)
        GroupOwner = jceOutStream:JceReadInt(23)
        jceOutStream:JceReadInt(24)
        jceOutStream:JceReadInt(25)
        jceOutStream:JceReadInt(26)
        jceOutStream:JceReadInt(27)
        jceOutStream:JceReadInt(28)
        GroupTotalCount = jceOutStream:JceReadInt(29)
        jceOutStream:JceReadInt(30)
        jceOutStream:JceReadInt(31)
        jceOutStream:JceReadInt(32)
        jceOutStream:JceReadInt(33)
        jceOutStream:JceReadInt(34)
        jceOutStream:JceReadInt(35)
        jceOutStream:JceReadInt(36)
        jceOutStream:JceReadInt(37)
        jceOutStream:JceReadBytes(38)
        jceOutStream:Skip(1)

        info = {
            GroupId = GroupId,
            GroupName = GroupName,
            GroupNotice = GroupNotice,
            GroupMemberCount = GroupMemberCount,
            GroupOwner = GroupOwner,
            GroupTotalCount = GroupTotalCount
        }
        TroopListInfo.TroopList[i] = info
    end

    return TroopListInfo
end
