local constants = require("wmc.constants")
local logger = require("wmc.logger")
local utils = require("wmc.utils")

---@class wmc.ranker
---@field private combo string
---@field private rank wmc.RANK_LABEL|nil
---@field private last_input_sec number
---@field private watcher uv.uv_timer_t
local M = {}

---@return wmc.ranker
function M:new()
	local ranker = {
		combo = "",
		rank = nil,
		last_input_sec = 0,
		watcher = nil,
	}
	setmetatable(ranker, self)
	self.__index = self

	ranker:start_watcher()

	return ranker
end

---@private
function M:start_watcher()
	local watcher, err = utils.set_interval(500, function()
		if self.last_input_sec >= constants.RANK_IDLE_TTL_SEC then
			self.combo = ""
			self.last_input_sec = 0
			self.rank = nil

			-- TOOD ui clear
			print("")

			return
		end

		self.last_input_sec = self.last_input_sec + 0.5
	end)

	if not watcher then
		error("Cannot start timer, error: " .. err)
	end

	self.watcher = watcher
end

---@return fun(key: string, typed: string): string?
function M:on_key()
	return function(key, typed)
		local current_mode = vim.api.nvim_get_mode().mode
		if current_mode:match("^i") then
			return
		end

		local entered_key = typed or key
		if not entered_key or #entered_key == 0 then
			return
		end

		self.last_input_sec = 0
		self.combo = self.combo .. entered_key

		local combo_entropy = self:get_combo_entropy()
		self.rank = self:get_display_rank(combo_entropy)

		-- TODO ui display, only after rank change
		print(self.rank or "")

		logger.log(
			("%s: %d, %s: %f, %s: %s"):format("Length", #self.combo, "Entropy", combo_entropy, "Rank", self.rank)
		)
	end
end

-- TODO permanently set to Dull when mouse is used
---@private
---@return number
function M:get_combo_entropy()
	local combo_length = #self.combo
	if combo_length == 0 then
		return 0
	end

	local char_occurrences = {}
	for i = 1, combo_length do
		local char = self.combo:sub(i, i)

		char_occurrences[char] = (char_occurrences[char] or 0) + 1
	end

	local entropy = 0

	for _, char_occurrence_count in pairs(char_occurrences) do
		local char_occurrence_propability = char_occurrence_count / combo_length

		entropy = entropy - (char_occurrence_propability * math.log(char_occurrence_propability, 2))
	end

	return entropy
end

---@param combo_entropy number
---@return wmc.RANK_LABEL|nil
function M:get_display_rank(combo_entropy)
	if not self.rank and combo_entropy > 1.5 then
		return constants.RANK_LABEL.DULL
	end

	local next_rank = constants.RANK_PROGRESSION[self.rank]
	if not next_rank or next_rank.min_entropy > combo_entropy or next_rank.min_length > #self.combo then
		return self.rank
	end

	return next_rank.label
end

return M:new()
