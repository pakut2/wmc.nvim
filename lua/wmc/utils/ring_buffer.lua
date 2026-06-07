---@class wmc.ring_buffer
---@field private capacity integer
---@field private length integer
---@field private buffer table
local M = {}

---@param capacity integer
---@return wmc.ring_buffer
function M:new(capacity)
	local ring_buffer = {
		capacity = capacity,
		length = 0,
		buffer = {},
	}
	setmetatable(ring_buffer, self)
	self.__index = self

	return ring_buffer
end

---@return table
function M:get_buffer()
	return { unpack(self.buffer) }
end

---@return integer
function M:get_length()
	return self.length
end

---@param value any
function M:append(value)
	if self.length >= self.capacity then
		table.remove(self.buffer)
	else
		self.length = self.length + 1
	end

	table.insert(self.buffer, 1, value)
end

function M:clear()
	self.buffer = {}
	self.length = 0
end

---@return string
function M:to_string()
	local string_buffer = ""

	for _, value in ipairs(self.buffer) do
		string_buffer = string_buffer .. tostring(value)
	end

	return string_buffer
end

return M
