local M = {}

---@class (exact) wmc.config
---@field logger wmc.config.logger

---@class (exact) wmc.config.logger
---@field enabled boolean
---@field log_file_path string|nil

---@type wmc.config
M.default = {
	logger = {
		enabled = false,
		log_file_path = vim.fn.stdpath("data") .. "/wmc.log",
	},
}

---@type wmc.config
M.options = M.default

---@param opts? wmc.config
function M.setup(opts)
	opts = opts or {}

	M.options = vim.tbl_deep_extend("force", M.default, opts)

	local err = M.validate(M.options)
	if err then
		error(err)
	end
end

---@param config wmc.config
---@return string|nil
function M.validate(config)
	local validation_errors = {}

	M.validate_entry({ logger = { config.logger, "table", true } }, validation_errors)

	M.validate_entry({ enabled = { config.logger.enabled, "boolean", false } }, validation_errors)
	M.validate_entry({ log_file_path = { config.logger.log_file_path, "string", true } }, validation_errors)

	if #validation_errors == 0 then
		return nil
	end

	return table.concat(validation_errors, "\n")
end

---@param entry table
---@param validation_errors table
function M.validate_entry(entry, validation_errors)
	local entry_name, entry_value = next(entry)
	if not entry_name or not entry_value then
		return
	end

	local ok, err = pcall(vim.validate, entry_name, unpack(entry_value))
	if not ok then
		table.insert(validation_errors, err)
	end
end

return M
