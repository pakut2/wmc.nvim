describe("ring_buffer", function()
	local ring_buffer = require("wmc.utils.ring_buffer")

	describe("append", function()
		it("should restrict buffer length by capacity", function()
			local buffer = ring_buffer:new(3)

			for _, v in ipairs({ "a", "b", "c", "d", "e" }) do
				buffer:append(v)
			end

			assert.are.equal(3, buffer:get_length())
		end)

		it("should evict the oldest element when buffer is full", function()
			local buffer = ring_buffer:new(3)

			buffer:append("a")
			buffer:append("b")
			buffer:append("c")
			buffer:append("d")

			assert.are.equal("dcb", buffer:to_string())
		end)
	end)

	describe("clear", function()
		it("should reset the buffer", function()
			local buffer = ring_buffer:new(3)

			buffer:append("a")
			buffer:append("b")
			buffer:clear()

			assert.are.equal(0, buffer:get_length())
			assert.are.equal("", buffer:to_string())
		end)
	end)

	describe("to_string", function()
		it("should return an empty string for empty buffer", function()
			local buffer = ring_buffer:new(3)

			assert.are.equal("", buffer:to_string())
		end)

		it("should serialize buffer contents", function()
			local buffer = ring_buffer:new(2)

			buffer:append("a")
			buffer:append("b")
			buffer:append("c")

			assert.are.equal("cb", buffer:to_string())
		end)
	end)
end)
