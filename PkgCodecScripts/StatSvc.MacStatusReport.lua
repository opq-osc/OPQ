local log = require("log")
--活跃度上报功能包
function PackCodecName()
    return "StatSvc.MacStatusReport"
end
function PackPkg(t, User)
    PkgCodec.SendSSoData(--发送包体
        {
            User = User,
            ServiceCmd = "StatSvc.MacStatusReport",
            SsoData = {8, 1}
        }
    )
    return 0
end
function UnPackPkg(rawData, User)
    str = string.format("UnPackPkg %s User %s", PkgCodec.HexDump(rawData), User.StrUin)
    log.info("%s", str)
    return 0
    --返回table 等任意类型 返回 任意整数则 不向队列/管道发送结果 直接返回
end
