local config = require("wmc.config")
local constants = require("wmc.constants")
local logger = require("wmc.logger")
local timer = require("wmc.utils.timer")
local ring_buffer = require("wmc.utils.ring_buffer")
local ui = require("wmc.ui")

---@class wmc.ranker
---@field private combo wmc.ring_buffer
---@field private is_combo_valid boolean
---@field private rank_label wmc.rank_label|nil
---@field private rank_progression number|nil
---@field private last_input_sec number
---@field private watcher uv.uv_timer_t
---@field private ui wmc.ui
local M = {}

---@return wmc.ranker
function M:new()
	local ranker = {
		combo = ring_buffer:new(30),
		is_combo_valid = true,
		rank_label = nil,
		rank_progression = nil,
		last_input_sec = 0,
		watcher = nil,
		ui = ui:new(),
	}
	setmetatable(ranker, self)
	self.__index = self

	ranker:start_combo_watcher()

	return ranker
end

---@private
function M:start_combo_watcher()
	local watcher, err = timer.set_interval(500, function()
		if self.last_input_sec >= constants.RANK_IDLE_TTL_SEC then
			self.combo:clear()
			self.is_combo_valid = true
			self.last_input_sec = 0
			self.rank_label = nil
			self.rank_progression = nil

			self.ui:clear()

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
function M:on_key_entered()
	return function(key, typed)
		self.last_input_sec = 0

		local current_mode = vim.api.nvim_get_mode().mode
		if current_mode:match("^i") then
			return
		end

		local entered_key = typed or key
		if not entered_key or #entered_key == 0 then
			return
		end

		self.combo:append(entered_key)

		local readable_entered_key = vim.fn.keytrans(entered_key)
		if
			readable_entered_key:match("Mouse")
			or readable_entered_key:match("Release")
			or readable_entered_key:match("Middle")
			or readable_entered_key:match("Scroll")
			or readable_entered_key:match("Drag")
		then
			self.is_combo_valid = false
		end

		if not self.is_combo_valid then
			local invalid_rank = constants.RANK_LABEL.DULL

			if invalid_rank ~= self.rank_label or self.rank_progression then
				self.ui:render(invalid_rank, nil)
			end

			self.rank_label = invalid_rank
			self.rank_progression = nil

			logger.log(
				("Length: %d, Rank - %s (Invalid)\n%s"):format(
					self.combo:get_length(),
					self.rank_label,
					vim.fn.keytrans(self.combo:to_string())
				)
			)

			return
		end

		local combo_entropy = self:get_combo_entropy()
		local combo_score = self:get_combo_score(combo_entropy)

		local new_rank = self:get_display_rank(combo_entropy, combo_score)
		local rank_progression = new_rank
				and config.options.ui.progress_bar.enabled
				and self.get_rank_progression(new_rank, combo_score)
			or nil

		if new_rank and (new_rank ~= self.rank_label or rank_progression ~= self.rank_progression) then
			self.ui:render(new_rank, rank_progression)
		end

		self.rank_label = new_rank
		self.rank_progression = rank_progression

		logger.log(
			("%s: %d, %s: %f, %s: %f, %s: %s\n%s"):format(
				"Length",
				self.combo:get_length(),
				"Entropy",
				combo_entropy,
				"Score",
				combo_score,
				"Rank",
				self.rank_label,
				vim.fn.keytrans(self.combo:to_string())
			)
		)
	end
end

---@private
---@return number
function M:get_combo_entropy()
	local combo_length = self.combo:get_length()
	if combo_length == 0 then
		return 0
	end

	local char_occurrences = {}
	for _, char in pairs(self.combo:get_buffer()) do
		char_occurrences[char] = (char_occurrences[char] or 0) + 1
	end

	local entropy = 0

	for _, char_occurrence_count in pairs(char_occurrences) do
		local char_occurrence_propability = char_occurrence_count / combo_length

		entropy = entropy - (char_occurrence_propability * math.log(char_occurrence_propability, 2))
	end

	return entropy
end

---@private
---@param combo_entropy number
---@return number
function M:get_combo_score(combo_entropy)
	return math.pow(combo_entropy, 2) * self.combo:get_length()
end

---@private
---@param combo_entropy number
---@param combo_score number
---@return wmc.rank_label|nil
function M:get_display_rank(combo_entropy, combo_score)
	if not self.rank_label and combo_entropy > 1.5 then
		return constants.RANK_LABEL.DULL
	end

	local next_rank = constants.RANK_PROGRESSION[self.rank_label]
	if not next_rank or next_rank.min_score > combo_score then
		return self.rank_label
	end

	return next_rank.label
end

---@private
---@param combo_rank wmc.rank_label
---@param combo_score number
---@return number|nil
function M.get_rank_progression(combo_rank, combo_score)
	if not combo_rank then
		return nil
	end

	local rank_score_bounds = constants.RANK_SCORE[combo_rank]
	if not rank_score_bounds.max_score then
		return nil
	end

	return math.max(combo_score - rank_score_bounds.min_score, 0)
		/ (rank_score_bounds.max_score - rank_score_bounds.min_score)
end

return M
