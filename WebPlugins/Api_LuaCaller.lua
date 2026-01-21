---@diagnostic disable: unused-local
--[[v6.9.6]]
local API_MODNAME = "_opq_api"
local log = require("log")
local api = require("coreApi")
local ok = pcall(require, "_opq_empty")

local builtin = {
	MagicCgiCmd = function(qq, funcname, data)
		return api.Api_MagicCgiCmd(qq, data)
	end,
	--添加定时任务
	AddCrons = function(qq, funcname, data)
		return api.Api_AddCrons(data)
	end,
	--添加删除定时任务
	DelCrons = function(qq, funcname, data)
		return api.Api_DelCrons(data.TaskID)
	end,
	--获取任务列表
	GetCrons = function()
		return api.Api_GetCrons()
	end,
}

-- CurrentQQ 当前操作的QQ号 /funcName 欲调用LuaApi函数名 ／data  组装Json数据
function Api_LuaCaller(CurrentQQ, funcName, data)
	log.info("%s", string.format("Api_LuaCaller FuncName %s\n", funcName))
	return (builtin[funcName] or (ok and require("_opq_api") or {})[funcName] or api.Api_CallFunc)(
		CurrentQQ,
		funcName,
		data
	)
end
