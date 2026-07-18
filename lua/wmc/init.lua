local config = require("wmc.config")
local ranker = require("wmc.ranker")

local M = {}

---@param opts? wmc.config
function M.setup(opts)
	config.setup(opts)

	vim.on_key(ranker:new():on_key(), vim.g.wmc_namespace_id)
end

return M
