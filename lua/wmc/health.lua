local M = {}

function M.check()
	vim.health.start("dmc.nvim")

	if vim.fn.has("nvim-0.11.0") == 1 then
		vim.health.ok("Neovim version >= 0.11.0")
	else
		vim.health.error("Neovim version < 0.11.0")
	end

	local config = require("wmc.config")

	local err = config.validate(config.options)
	if not err then
		vim.health.ok("Config matches schema")
	else
		vim.health.error(("Config violates schema:\n%s"):format(err))
	end
end

return M
