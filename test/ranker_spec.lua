describe("ranker", function()
	local stub = require("luassert.stub")
	local ui_stub = require("wmc.ui")
	local config = require("wmc.config")
	local constants = require("wmc.constants")

	local ranker

	local function fill_combo(combo)
		for i = 1, #combo do
			ranker.combo:append(combo:sub(i, i))
		end
	end

	local function type_combo(combo)
		local handler = ranker:on_key_entered()

		for i = 1, #combo do
			local key = combo:sub(i, i)

			handler(key, key)
		end
	end

	setup(function()
		stub(ui_stub, "new").returns({
			render = function() end,
			clear = function() end,
		})
	end)

	before_each(function()
		ranker = require("wmc.ranker"):new()
	end)

	after_each(function()
		package.loaded["wmc.ranker"] = nil
	end)

	teardown(function()
		ui_stub.new:revert()
	end)

	describe("on_key_entered", function()
		it("should assign a rank", function()
			type_combo("jackpot")

			assert.are.equal(constants.RANK_LABEL.DULL, ranker.rank_label)
		end)

		it("should reset idle counter on input", function()
			ranker.last_input_sec = 1.0

			type_combo("a")

			assert.are.equal(0, ranker.last_input_sec)
		end)

		it("should advance rank", function()
			type_combo("jackpotjackpot")

			assert.are.equal(constants.RANK_LABEL.COOL, ranker.rank_label)
		end)

		it("should not advance rank for insert mode input", function()
			stub(vim.api, "nvim_get_mode").returns({ mode = "i" })
			finally(function()
				vim.api.nvim_get_mode:revert()
			end)

			type_combo("jackpot")

			assert.is_nil(ranker.rank_label)
			assert.are.equal(0, ranker.combo:get_length())
			assert.are.equal(0, ranker.last_input_sec)
		end)

		it("should invalidate rank on mouse usage", function()
			local mouse_input = vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true)

			ranker:on_key_entered()(mouse_input, mouse_input)

			assert.are.equal(constants.RANK_LABEL.DULL, ranker.rank_label)
			assert.is_false(ranker.is_combo_valid)

			type_combo("jackpotjackpot")

			assert.are.equal(constants.RANK_LABEL.DULL, ranker.rank_label)
			assert.is_false(ranker.is_combo_valid)
		end)

		it("should re-render only when rank or progression changes", function()
			config.options.ui.progress_bar.enabled = true

			local rank_progressions = { 0.1, 0.1, 0.2, 0.2, 0.2 }
			stub(ranker, "get_rank_progression").invokes(function()
				return table.remove(rank_progressions, 1)
			end)

			local render_stub = stub(ranker.ui, "render")
			finally(function()
				config.options.ui.progress_bar.enabled = false
				render_stub:revert()
			end)

			type_combo("jackpot")

			assert.stub(render_stub).was.called(2)
			assert.stub(render_stub).was.called_with(ranker.ui, constants.RANK_LABEL.DULL, 0.1)
			assert.stub(render_stub).was.called_with(ranker.ui, constants.RANK_LABEL.DULL, 0.2)
		end)

		it("should clear rank after inactivity", function()
			type_combo("jackpot")
			vim.wait(2000)

			assert.is_nil(ranker.rank_label)
			assert.are.equal(0, ranker.combo:get_length())
		end)
	end)

	describe("get_combo_entropy", function()
		it("should return 0 for empty combo", function()
			assert.are.equal(0, ranker:get_combo_entropy())
		end)

		it("should return 0 for a single repeated character", function()
			fill_combo("aaaa")

			assert.are.equal(0, ranker:get_combo_entropy())
		end)

		it("should return 1 for two uniformly distributed characters", function()
			fill_combo("ab")

			assert.are.equal(1, ranker:get_combo_entropy())
		end)

		it("should return combo entropy", function()
			fill_combo("jackpot")

			assert.are.near(2.8074, ranker:get_combo_entropy(), 1e-4)
		end)
	end)

	describe("get_rank_progression", function()
		it("should return nil for a missing rank", function()
			assert.is_nil(ranker.get_rank_progression(nil, 100))
		end)

		it("should return nil for the top rank", function()
			assert.is_nil(ranker.get_rank_progression(constants.RANK_LABEL.STYLISH, 500))
		end)

		it("should return 0 for score below the rank minimum", function()
			assert.are.equal(0, ranker.get_rank_progression(constants.RANK_LABEL.DULL, 0))
		end)

		it("should return progression within rank score bounds", function()
			assert.are.equal(0.5, ranker.get_rank_progression(constants.RANK_LABEL.COOL, 155))
		end)
	end)
end)
