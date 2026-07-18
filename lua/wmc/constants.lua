local M = {}

M.RANK_IDLE_TTL_SEC = 1.5

---@enum wmc.rank_label
M.RANK_LABEL = {
	DULL = "Dull",
	COOL = "Cool!",
	BRAVO = "Bravo!",
	ABSOLUTE = "Absolute!",
	STYLISH = "Stylish!",
}

---@class wmc.rank
---@field label wmc.rank_label
---@field min_score integer

---@type table<wmc.rank_label, wmc.rank>
M.RANK_PROGRESSION = {
	[M.RANK_LABEL.DULL] = {
		label = M.RANK_LABEL.COOL,
		min_score = 110,
	},
	[M.RANK_LABEL.COOL] = {
		label = M.RANK_LABEL.BRAVO,
		min_score = 200,
	},
	[M.RANK_LABEL.BRAVO] = {
		label = M.RANK_LABEL.ABSOLUTE,
		min_score = 300,
	},
	[M.RANK_LABEL.ABSOLUTE] = {
		label = M.RANK_LABEL.STYLISH,
		min_score = 390,
	},
}

return M
