---@class wmc.image_ui : wmc.ui
local M = {}

---@return wmc.image_ui
function M:new()
	local image_ui = {}
	setmetatable(image_ui, self)
	self.__index = self

	return image_ui
end

---@param rank_label wmc.rank_label
function M:render(rank_label) end

function M:clear() end

return M
