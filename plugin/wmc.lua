local config = require("wmc.config")

vim.g.wmc_namespace_id = vim.api.nvim_create_namespace("wmc")

vim.schedule(function()
	if not config.options.enabled then
		return
	end

	vim.on_key(require("wmc.ranker"):new():on_key(), vim.g.wmc_namespace_id)
end)
