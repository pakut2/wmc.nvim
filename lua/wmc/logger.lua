local M = {}

---@param message string
function M.log(message)
	local logger_config = require("wmc.config").options.logger
	if not logger_config.enabled then
		return
	end

	if not logger_config.log_file_path then
		print(M.format_message(message))

		return
	end

	local log_file, err = io.open(logger_config.log_file_path, "a")
	if not log_file then
		print(err)

		return
	end

	log_file:write(M.format_message(message) .. "\n")

	log_file:close()
end

---@param message string
function M.error(message)
	vim.notify(M.format_message(message), vim.log.levels.ERROR)
end

---@param message string
function M.format_message(message)
	return ("[%s] - %s"):format(os.date("%H:%M:%S"), message)
end

return M
