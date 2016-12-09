------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local state = {
	WALK_RANDOMLY = 0,
	WALK_TO_PLANT = 1,
	WALK_TO_MOW   = 2,
	MOW           = 3,
	PLANT         = 4,
}

local searching_range = {
	x = 5,
	y = 1,
	z = 5,
}

local target_plants = {
	"farming:cotton_8",
	"farming:wheat_8",
}

local SEARCHING_TIME_INTERVAL = 20
local MOWING_TIME = 5
local TO_TARGET_DISTANCE = 1.25

-- has_seed_item reports whether maidroid has seed items.
local function has_seed_item(self)
	local inv = self:get_inventory()
	local stack_list = inv:get_list("main")

	for _, stack in ipairs(stacks) do
		local itemname = stack:get_name()
		if minetest.get_item_group(item_name, "seed") > 0 then
			return true
		end
	end
	return false
end

-- is_plantable_place reports whether maidroid can plant any seed.
local function is_plantable_place(pos)
	local node = minetest.get_node(pos)
	local lpos = vector.sub(pos, {x = 0, y = -1, z = 0})
	local lnode = minetest.get_node(lpos)
	return node.name == "air" 
		and minetest.get_item_group(lnode.name, "wet") > 0
end

-- is_mowable_place reports whether maidroid can mow.
local function is_mowable_place(pos)
	local node = minetest.get_node(pos)
	for _, target in ipairs(target_plants) do
		if node.name == target then
			return true
		end
	end
	return false
end

-- search surrounding searchs maidroid surrounding.
local function search_surrounding(self, pred)
	for x = -searching_range.x, searching_range.x do
		for y = -searching_range.y, searching_range.y do
			for z = -searching_range.z, searching_range.z do
				local pos = {x = x, y = y, z = z}
				if pred(self, pos) then
					return pos
				end
			end
		end
	end
	return nil
end

local function on_start(self)
	self.state = state.WALK_RANDOMLY
	self.object:setacceleration{x = 0, y = -10, z = 0}
	self.object:setvelocity{x = 0, y = 0, z = 0}
end

local function on_stop(self)
	self.state = nil
	self.object:setvelocity{x = 0, y = 0, z = 0}
end

local on_resume = on_start

local on_pause = on_stop

local function on_step(self, dtime)
	if self.state == state.WALK_RANDOMLY then
		if self.time_counter >= SEARCHING_TIME_INTERVAL then
			self.time_counter = 0 -- reset time_counter

			if self:has_seed_item() then
				local d = search_surrounding(is_plantable_place)
				if d ~= nil then
					self.state = state.WALK_TO_PLANT
					self.destination = d
					return
				end
			end

			local d = search_surrounding(is_mowable_place)
			if d ~= nil then
				self.state = state.WALK_TO_MOW
				self.destination = d
				return
			end
		else
			self.time_counter = self.time_counter + 1
		end
	elseif self.state == state.MOW then

	elseif self.state == state.PLANT then

	elseif self.state == state.WALK_TO_MOW then
		local pos = self.object:getpos()
		if vector.distance(pos, self.destination) < TO_TARGET_DISTANCE then
			local destination_node = minetest.get_node(self.destination)

			if is_target_plant(destination_node.name) then
				self.state = state.MOW
			else
				
			end
		elseif hoge then
			
		end
	elseif self.state == state.WALK_TO_PLANT then
		local pos = self.object:getpos()
		if vector.distance(pos, self.destination) < TO_TARGET_DISTANCE then
			local destination_node = minetest.get_node(self.destiantion)

			if is_plantable_place(self.destination) then

			else
				
			end
		elseif hoge then
		end
	end
end

maidroid.register_core("maidroid_core:farming", {
	description      = "maidroid core : farming",
	inventory_image  = "maidroid_core_farming.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_resume,
	on_pause         = on_pause,
	on_step          = on_step,
})
