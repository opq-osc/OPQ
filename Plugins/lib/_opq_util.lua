local M

---Tests if `s` starts with `prefix`.
---
---@param s string: a string
---@param prefix string: a prefix
---@return boolean: true if `prefix` is a prefix of s
function M.startswith(s, prefix)
	return s:sub(1, #prefix) == prefix
end

--- Tests if `s` ends with `suffix`.
---
---@param s string: a string
---@param suffix string: a suffix
---@return boolean: true if `suffix` is a suffix of s
function M.endswith(s, suffix)
	return #suffix == 0 or s:sub(-#suffix) == suffix
end

return M
