---@class wmc.ui
---@field render fun(self, rank_label: wmc.rank_label)
---@field clear fun(self)
local M = {}

---@return wmc.ui
function M:new()
	local config = require("wmc.config")

	if config.options.image_ui_enabled then
		local image_ui = require("wmc.ui.image")

		return image_ui:new()
	end

	local text_ui = require("wmc.ui.text")

	return text_ui:new()
end

return M
