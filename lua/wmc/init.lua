local config = require("wmc.config")
local ranker = require("wmc.ranker")

local M = {}

---@param opts? wmc.config
function M.setup(opts)
	config.setup(opts)
end

vim.on_key(ranker:on_key(), vim.api.nvim_create_namespace("wmc"))

return M
