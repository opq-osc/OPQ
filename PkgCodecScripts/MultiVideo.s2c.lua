local log = require("log")
function PackCodecName()
    return "MultiVideo.s2c"
end
function PackPkg(t, User)
    return 0
end
function UnPackPkg(rawData, User)
    return 0 --忽略解析
    --返回table 等任意类型 返回 任意整数则 不向队列/管道发送结果 直接返回
end
