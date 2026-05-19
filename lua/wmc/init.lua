local ranker = require("wmc.ranker")

local M = {}

function M.setup() end

vim.on_key(ranker:on_key(), vim.api.nvim_create_namespace("wmc"))

return M
