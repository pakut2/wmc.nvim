local M = {}

---@class (exact) wmc.config
---@field enabled boolean
---@field logger wmc.config.logger
---@field ui wmc.config.ui

---@class (exact) wmc.config.logger
---@field enabled boolean
---@field log_file_path string

---@class (exact) wmc.config.ui
---@field anchor string
---@field row number|fun(): number
---@field col number|fun(): number
---@field zindex number
---@field border string

---@type wmc.config
M.default = {
	enabled = true,
	ui = {
		anchor = "NE",
		row = 1,
		col = function()
			return vim.o.columns - 5
		end,
		zindex = 50,
		border = "none",
	},
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

	M.validate_entry({ enabled = { config.enabled, "boolean", true } }, validation_errors)

	M.validate_entry({ ui = { config.ui, "table", true } }, validation_errors)
	M.validate_entry({ anchor = { config.ui.anchor, "string", true } }, validation_errors)
	M.validate_entry({ row = { config.ui.row, { "number", "function" }, true } }, validation_errors)
	M.validate_entry({ col = { config.ui.col, { "number", "function" }, true } }, validation_errors)
	M.validate_entry({ zindex = { config.ui.zindex, "number", true } }, validation_errors)
	M.validate_entry({ border = { config.ui.border, { "string", "table" }, true } }, validation_errors)

	M.validate_entry({ logger = { config.logger, "table", true } }, validation_errors)
	M.validate_entry({ enabled = { config.logger.enabled, "boolean", true } }, validation_errors)
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
