local log = require("log")
--搜素群组功能包
function PackCodecName()
    return "OidbSvc.0x8ba_31"
end
function PackPkg(t, User)
    str = string.format("PackPkg User %s t %d", t.Content, User.StrUin)
    log.info("%s", str)
    data = PkgCodec.newPbCodec()
    data:EncodeVarint(1, 0)
    data:EncodeVarint(2234)
    data:EncodeVarint(2, 0)
    data:EncodeVarint(31)
    buf_73 = PkgCodec.newPbCodec()
    buf_64 = PkgCodec.newPbCodec()
    buf_64:EncodeVarint(1, 0)
    buf_64:EncodeVarint(50)
    buf_64:EncodeVarint(2, 0)
    buf_64:EncodeVarint(50 * t.Page)
    buf_58 = PkgCodec.newPbCodec()
    buf_56 = PkgCodec.newPbCodec()
    buf_56:EncodeVarint(1, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(2, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(3, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(4, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(5, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(6, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(7, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(8, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(9, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(10, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(11, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(14, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(15, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(17, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(18, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(21, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(24, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(36, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(39, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(40, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(42, 2)
    buf_56:EncodeStringBytes("")
    buf_56:EncodeVarint(56, 0)
    buf_56:EncodeVarint(1)
    buf_56:EncodeVarint(77, 0)
    buf_56:EncodeVarint(1)
    buf_58:EncodeVarint(1, 2)
    buf_58:EncodeRawBytes(buf_56:GetPbData())
    buf_64:EncodeVarint(4, 2)
    buf_64:EncodeRawBytes(buf_58:GetPbData())
    buf_73:EncodeVarint(1, 2)
    buf_73:EncodeRawBytes(buf_64:GetPbData())
    buf_73:EncodeVarint(2, 2)
    buf_73:EncodeStringBytes(t.Content)
    buf_73:EncodeVarint(4, 0)
    buf_73:EncodeVarint(0)
    data:EncodeVarint(4, 2)
    data:EncodeRawBytes(buf_73:GetPbData())

    PkgCodec.SendSSoData(
        {
            User = User,
            ServiceCmd = "OidbSvc.0x8ba_31",
            SsoData = data:GetPbData()
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    --str = string.format("OidbSvc.0x8ba_31 %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    --log.info("%s", str)

    _, userdata = PkgCodec.ReadPbFieldData(4, rawData)
    tables = PkgCodec.ReadPbArray(4, userdata)
    --log.notice("len tab  1-->%s", #tables)

    array = {}
    for i, v in ipairs(tables) do
        GroupID, _ = PkgCodec.ReadPbFieldData(1, v)
        _, valBuf = PkgCodec.ReadPbFieldData(2, v)
        _, valBuf = PkgCodec.ReadPbFieldData(1, valBuf)
        GroupOwner, _ = PkgCodec.ReadPbFieldData(1, valBuf)
        GroupMaxMembers, _ = PkgCodec.ReadPbFieldData(5, valBuf)
        GroupTotalMembers, _ = PkgCodec.ReadPbFieldData(6, valBuf)
        _, valName = PkgCodec.ReadPbFieldData(15, valBuf)
        GroupName = PkgCodec.ToString(valName)
        _, valName = PkgCodec.ReadPbFieldData(16, valBuf)
        GroupNotice = PkgCodec.ToString(valName)
        _, valName = PkgCodec.ReadPbFieldData(17, valBuf)
        GroupData = PkgCodec.ToString(valName)
        _, valName = PkgCodec.ReadPbFieldData(24, valBuf)
        GroupQuestion = PkgCodec.ToString(valName)
        _, valName = PkgCodec.ReadPbFieldData(40, valBuf)
        GroupDes = PkgCodec.ToString(valName)

        array[i] = {
            GroupID = GroupID,
            GroupOwner = GroupOwner,
            GroupMaxMembers = GroupMaxMembers,
            GroupTotalMembers = GroupTotalMembers,
            GroupName = GroupName,
            GroupData = GroupData,
            GroupQuestion = GroupQuestion,
            GroupDes = GroupDes,
            GroupNotice = GroupNotice
        }
    end

    return array
end
