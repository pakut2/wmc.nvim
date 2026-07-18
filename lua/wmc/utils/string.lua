local M = {}

---@param values table<any, string>
---@return integer
function M.find_max_length(values)
	local max_length = 0

	for _, value in pairs(values) do
		max_length = math.max(max_length, #value)
	end

	return max_length
end

return M
