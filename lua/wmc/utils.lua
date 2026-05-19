local M = {}

---@param  interval integer
---@param  callback function
---@return uv.uv_timer_t|nil
---@return uv.error.message|nil
function M.set_interval(interval, callback)
	local timer, err = vim.uv.new_timer()
	if not timer then
		return nil, err
	end

	local _, err = timer:start(0, interval, function()
		callback()
	end)

	if err then
		return nil, err
	end

	return timer, nil
end

---@param  timer uv.uv_timer_t
function M.clear_interval(timer)
	timer:stop()
	timer:close()
end

return M
