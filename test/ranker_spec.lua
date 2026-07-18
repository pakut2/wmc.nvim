describe("ranker", function()
	local stub = require("luassert.stub")
	local ui_stub = require("wmc.ui")
	local timer_stub = require("wmc.utils.timer")

	local ranker = require("wmc.ranker")

	local function fill_combo(combo)
		for i = 1, #combo do
			ranker.combo:append(combo:sub(i, i))
		end
	end

	setup(function()
		stub(ui_stub, "new").returns({
			render = function() end,
			clear = function() end,
		})
		stub(timer_stub, "set_interval").returns({})
	end)

	before_each(function()
		ranker = ranker:new()
	end)

	after_each(function()
		package.loaded["wmc.ranker"] = nil
	end)

	teardown(function()
		ui_stub.new:revert()
		timer_stub.set_interval:revert()
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
end)
