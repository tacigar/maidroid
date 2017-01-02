------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local maidroid_instruction_set = {
	getpos = function(_, thread)
		local pos = thread.droid.object:getpos()
		return true, {pos.x, pos.y, pos.z}
	end,

	beep = function(_, thread)
		minetest.sound_play("maidroid_beep", {pos = thread.droid.object:getpos()})
		return true
	end,

	getyaw = function(_, thread)
		return true, thread.droid.object:getyaw()
	end,

	setyaw = function(params, thread)
		if #params ~= 1 then
			return false, "wrong number of arguments"
		end
		local p = params[1]
		if type(p) ~= "number" then
			return false, "unsupported argument"
		end
		thread.droid.object:setyaw(p)
		return true
	end,
}


local function mylog(log)
	-- This happens to the maidroids messages
	minetest.chat_send_all("maidroid says " .. log)
end

-- the program is loaded from a "default:book_written" with title "main"
-- if it's not present, following program is used in lieu:
local dummycode = [[
beep
print $No book with title "main" found.
]]

local function get_code(self)
	local list = self:get_inventory():get_list"main"
	for i = 1,#list do
		local stack = list[i]
		if stack:get_name() == "default:book_written" then
			local data = minetest.deserialize(stack:get_metadata())
			if data
			and data.title == "main" then
				return data.text
			end
		end
	end
end

local function on_start(self)
	self.object:setacceleration{x = 0, y = -10, z = 0}
	self.object:setvelocity{x = 0, y = 0, z = 0}

	local parsed_code = pdisc.parse(get_code(self) or dummycode)
	self.thread = pdisc.create_thread(function(thread)
		thread.flush = function(self)
			mylog(self.log)
			self.log = ""
			return true
		end
		table.insert(thread.is, 1, maidroid_instruction_set)
		thread.droid = self
	end, parsed_code)
	self.thread:suscitate()
end

local function on_step(self)
	local thread = self.thread
	if thread.stopped then
		thread:try_rebirth()
	end
end

local function on_resume(self)
	self.thread:continue()
end

local function on_pause(self)
	self.thread:flush()
end

local function on_stop(self)
	self.thread:exit()

	self.object:setvelocity{x = 0, y = 0, z = 0}
end

-- register a definition of a new core.
maidroid.register_core("maidroid_core:ocr", {
	description      = "OCR programmable maidroid core",
	inventory_image  = "maidroid_core_ocr.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_resume,
	on_pause         = on_pause,
	on_step          = on_step,
})
