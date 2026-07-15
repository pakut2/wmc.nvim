---@class wmc.image_ui : wmc.ui
---@field private renderer_write_stream uv.uv_pipe_t
local M = {}

---@return wmc.image_ui
function M:new()
	local image_ui = {
		renderer_channel_id = nil,
	}
	setmetatable(image_ui, self)
	self.__index = self

	image_ui:init_render()

	return image_ui
end

---@private
function M:init_render()
	local renderer_write_stream = vim.uv.new_pipe(false)

	local renderer_handle = vim.uv.spawn("ueberzug", {
		args = { "layer", "--silent" },
		stdio = { renderer_write_stream, vim.uv.new_tty(1, false), vim.uv.new_pipe(false) },
	}, function(code)
		if code == 1 then
			error("Failed to start ueberzug renderer process")
		end
	end)

	if not renderer_handle or not renderer_write_stream then
		error("Failed to start ueberzug renderer process")
	end

	self.renderer_write_stream = renderer_write_stream
end

---@private
---@param message table
function M:send_renderer_message(message)
	vim.cmd("redraw")

	vim.schedule(function()
		vim.uv.write(self.renderer_write_stream, vim.fn.json_encode(message) .. "\n")
	end)
end

---@param rank_label wmc.rank_label
function M:render(rank_label)
	local img_path = "/Users/neoteric/Desktop/stylish.png"

	self:send_renderer_message({
		action = "add",
		identifier = "waat",
		path = img_path,
		x = 100,
		y = 1,
		width = 200,
		height = 1000,
	})
end

function M.clear() end

return M
