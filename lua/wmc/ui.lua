local constants = require("wmc.constants")
local find_max_length = require("wmc.utils.string").find_max_length

---@class wmc.ui
---@field private window_id integer
---@field private buffer_id integer
---@field private extmark_id integer
---@field private max_rendered_text_length integer
---@field private last_rendered_text string|nil
local M = {}

---@type table<wmc.rank_label, string>
M.RANK_HL_GROUP_NAME = {
	[constants.RANK_LABEL.DULL] = "DULL",
	[constants.RANK_LABEL.COOL] = "COOL",
	[constants.RANK_LABEL.BRAVO] = "BRAVO",
	[constants.RANK_LABEL.ABSOLUTE] = "ABSOLUTE",
	[constants.RANK_LABEL.STYLISH] = "STYLISH",
}

---@return wmc.ui
function M:new()
	local ui = {
		window_id = nil,
		buffer_id = nil,
		extmark_id = nil,
		max_rendered_text_length = find_max_length(constants.RANK_LABEL),
		last_rendered_text = nil,
	}
	setmetatable(ui, self)
	self.__index = self

	---@type table<wmc.rank_label, string>
	local rank_color = {
		[constants.RANK_LABEL.DULL] = "#E2E22C",
		[constants.RANK_LABEL.COOL] = "#99E04D",
		[constants.RANK_LABEL.BRAVO] = "#4DE06F",
		[constants.RANK_LABEL.ABSOLUTE] = "#52A9FF",
		[constants.RANK_LABEL.STYLISH] = "#FF2B3F",
	}

	for _, rank_label in pairs(constants.RANK_LABEL) do
		vim.api.nvim_set_hl(vim.g.wmc_namespace_id, M.RANK_HL_GROUP_NAME[rank_label], {
			fg = rank_color[rank_label],
			bold = true,
		})
	end

	ui:open_window()

	vim.api.nvim_create_autocmd({ "TabEnter" }, {
		desc = "WMC window persistence",
		group = vim.api.nvim_create_augroup("wmc.ui", {}),
		callback = function()
			vim.schedule(function()
				ui:reopen_window()
			end)
		end,
	})

	return ui
end

---@private
function M:open_window()
	self.buffer_id = vim.api.nvim_create_buf(false, true)
	if self.buffer_id == 0 then
		error("Failed to create window buffer")
	end

	-- TODO customizable options
	self.window_id = vim.api.nvim_open_win(self.buffer_id, false, {
		hide = true,
		relative = "editor",
		anchor = "NE",
		row = 1,
		col = 1,
		width = 1,
		height = 1,
		zindex = 50,
		style = "minimal",
		border = "none",
		focusable = false,
		noautocmd = true,
	})
	if self.window_id == 0 then
		error("Failed to create window")
	end

	vim.api.nvim_set_option_value("filetype", "wmc", { buf = self.buffer_id })
	vim.api.nvim_set_option_value("winfixbuf", true, { win = self.window_id })
	vim.api.nvim_set_option_value("winblend", 0, { win = self.window_id })
	vim.api.nvim_win_set_hl_ns(self.window_id, vim.g.wmc_namespace_id)
end

---@private
function M:reopen_window()
	if self:is_buffer_active() then
		vim.api.nvim_buf_delete(self.buffer_id, { force = true })
	end

	if self:is_window_active() then
		vim.api.nvim_win_close(self.window_id, true)
	end

	self:open_window()

	if self.last_rendered_text then
		self:render(self.last_rendered_text)
	end
end

---@param rank_label wmc.rank_label
function M:render(rank_label)
	vim.schedule(function()
		if not self:is_window_active() or not self:is_buffer_active() then
			return
		end

		local extmark_options = {
			virt_text = { { rank_label, M.RANK_HL_GROUP_NAME[rank_label] } },
			virt_text_win_col = 0,
		}

		if self.extmark_id then
			extmark_options.id = self.extmark_id
		end

		vim.api.nvim_win_set_config(self.window_id, {
			hide = false,
			relative = "editor",
			row = 1,
			col = vim.o.columns - (self.max_rendered_text_length - #rank_label) - 5,
			width = #rank_label,
		})

		self.extmark_id = vim.api.nvim_buf_set_extmark(self.buffer_id, vim.g.wmc_namespace_id, 0, 0, extmark_options)
		self.last_rendered_text = rank_label
	end)
end

function M:clear()
	vim.schedule(function()
		if not self:is_window_active() or not self:is_buffer_active() then
			return
		end

		self.last_rendered_text = nil

		vim.api.nvim_win_set_config(self.window_id, {
			hide = true,
		})
	end)
end

---@private
---@return boolean
function M:is_window_active()
	return self.window_id and vim.api.nvim_win_is_valid(self.window_id)
end

---@private
---@return boolean
function M:is_buffer_active()
	return self.buffer_id and vim.api.nvim_buf_is_valid(self.buffer_id)
end

return M
