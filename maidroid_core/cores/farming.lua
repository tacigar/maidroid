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

local VELOCITY = 3
local SEARCHING_TIME_INTERVAL = 20
local MOWING_TIME_INTERVAL = 20
local PLANTING_TIME_INTERVAL = 5
local TO_TARGET_DISTANCE = 1.25

-- has_seeditem reports whether maidroid has seed items.
local function has_seeditem(self)
	local inv = self:get_inventory()
	local stacks = inv:get_list("main")

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
	return maidroid_aux.table.find(target_plants, node.name)
end

-- does_move reports whether the maidroid move in 1 frame.
local function does_move(self)
	local pos = self.object:getpos()
	return self.pre_position.x ~= pos.x or self.pre_position.z ~= pos.z
end

local function change_direction_randomly(self)
	local dir = {
		x = math.random(0, 5) * 2 - 5, -- -5.0 ~ 5.0
		y = 0,
		z = math.random(0, 5) * 2 - 5, -- -5.0 ~ 5.0
	}
	local vel = vector.multiply(vector.normalize(dir), VELOCITY)
	self.object:setvelocity(vel)
	self:set_yaw_by_direction(vel)
end

local function start_walk_randomly(self)
	self.state = state.WALK_RANDOMLY
	self.destination = nil
	self:set_animation(maidroid.animation_frames.WALK)
	self.time_counter = 0
	self:change_direction_randomly()
end

do -- register farming core

	local function on_start(self)
		self.object:setacceleration{x = 0, y = -10, z = 0}
		self.object:setvelocity{x = 0, y = 0, z = 0}
		self.state = state.WALK_RANDOMLY
		self.pre_position = self.object:getpos()
		self.time_counter = 0
		self.destination = nil
	end

	local function on_stop(self)
		self.object:setvelocity{x = 0, y = 0, z = 0}
		self.state = nil
		self.pre_position = nil
		self.time_counter = nil
		self.destination = nil
	end

	local function on_step(self, dtime)
		self:pickup_item() -- at first, pickup item dropped.

		if self.state == state.WALK_RANDOMLY then
			if self.time_counter >= SEARCHING_TIME_INTERVAL then
				self.time_counter = 0 -- reset time_counter
				if self:has_seeditem() then
					local dest = maidroid_core._aux.search_surrounding(is_plantable_place)
					if dest ~= nil then
						self.state = state.WALK_TO_PLANT
						self.destination = dest
						self.pre_position = self.object:getpos()
						return
					end
				end

				local dest = maidroid_core._aux.search_surrounding(is_mowable_place)
				if dest ~= nil then
					self.state = state.WALK_TO_MOW
					self.destination = dest
					self.pre_position = self.object:getpos()
					return
				end
			else
				if not self:does_move() then -- if doesn't move change direction.
					self:change_direction_randomly()
				end
				self.time_counter = self.time_counter + 1
				self.pre_position = self.object:getpos()
				return
			end

		elseif self.state == state.MOW then
			if self.time_counter >= MOWING_TIME_INTERVAL then
				self.time_counter = 0
				if is_mowable_place(self.destination) then
					local node = minetest.get_node(self.destination)
          local inv = self:get_inventory()
          local stacks = minetest.get_node_drops(node.name)

					minetest.remove_node(self.destination)
          for _, stack in ipairs(stacks) do
            local leftover = inv:add_item("main", stack)
            minetest.add_item(self.destination, leftover)
          end
				end
				self:start_walk_randomly()
				self.pre_position = self.object:getpos()
				return

			else
				self.time_counter = self.time_counter + 1
				self.pre_position = self.object:getpos()
				return
			end

		elseif self.state == state.PLANT then
			if self.time_counter >= PLANTING_TIME_INTERVAL then
				self.time_counter = 0
				if is_plantable_place(self.destination) then
					local inv = self:get_inventory()
					local stack = inv:get_stack("wield_item", 1)
					local itemname = stack:get_name()
					minetest.add_node(self.destination, {name = item_name, param2 = 1})
          stack:take_item(1)
          inv:set_stack("wield_item", 1, stack)
				end
				self:start_walk_randomly()
				self.pre_position = self.object:getpos()

			else
				self.time_counter = self.time_counter + 1
				self.pre_position = self.object:getpos()
				return
			end

		elseif self.state == state.WALK_TO_MOW then
			local pos = self.object:getpos()
			if vector.distance(pos, self.destination) < TO_TARGET_DISTANCE then
				local destination_node = minetest.get_node(self.destination)

				if is_target_plant(destination_node.name) then
					self.state = state.MOW
					self:set_animation(maidroid.animation_frames.MINE)
					self.object:setvelocity{x = 0, y = 0, z = 0}
					self.pre_position = self.object:getpos()
					return
				else
					self:start_walk_randomly()
					self.preposition = self.object:getpos()
					return
				end

			elseif not self:does_move() then
				self:start_walk_randomly()
				self.preposition = self.getpos()
				return
			end
		elseif self.state == state.WALK_TO_PLANT then
			local pos = self.object:getpos()
			if vector.distance(pos, self.destination) < TO_TARGET_DISTANCE then
				local destination_node = minetest.get_node(self.destiantion)

				if is_plantable_place(self.destination) then
					self.state = state.PLANT
					self:set_animation(maidroid.animation_frames.MINE)
					self.object:setvelocity{x = 0, y = 0, z = 0}
					self.pre_position = self.object:getpos()
				else
					self:start_walk_randomly()
					self.preposition = self.object:getpos()
					return
					
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
		on_resume        = on_start,
		on_pause         = on_stop,
		on_step          = on_step,
	})

end -- register farming core
