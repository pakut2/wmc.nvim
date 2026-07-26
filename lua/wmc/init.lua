local config = require("wmc.config")

local M = {}

---@param opts? wmc.config
function M.setup(opts)
	config.setup(opts)
end

return M
