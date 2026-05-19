local M = {}

M.RANK_IDLE_TTL_SEC = 1.5

---@enum wmc.RANK_LABEL
M.RANK_LABEL = {
	DULL = "Dull",
	COOL = "Cool!",
	BRAVO = "Bravo!",
	ABSOLUTE = "Absolute!",
	STYLISH = "Stylish!",
}

---@class wmc.RANK
---@field label wmc.RANK_LABEL
---@field min_entropy number
---@field min_length integer

---@type table<wmc.RANK_LABEL, wmc.RANK>
M.RANK_PROGRESSION = {
	[M.RANK_LABEL.DULL] = {
		label = M.RANK_LABEL.COOL,
		min_entropy = 2,
		min_length = 10,
	},
	[M.RANK_LABEL.COOL] = {
		label = M.RANK_LABEL.BRAVO,
		min_entropy = 2.5,
		min_length = 15,
	},
	[M.RANK_LABEL.BRAVO] = {
		label = M.RANK_LABEL.ABSOLUTE,
		min_entropy = 3,
		min_length = 20,
	},
	[M.RANK_LABEL.ABSOLUTE] = {
		label = M.RANK_LABEL.STYLISH,
		min_entropy = 3.5,
		min_length = 25,
	},
}

return M
