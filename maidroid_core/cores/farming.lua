------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local state = {
	WALK_RANDOMLY = 0,
	WALK_TO_PLANT = 1,
	WALK_TO_MOW   = 2,
	PLANT         = 3,
	MOW           = 4,
}

local target_plants = {
	"farming:cotton_8",
	"farming:wheat_8",
}

local _aux = maidroid_core._aux

local FIND_PATH_TIME_INTERVAL = 20
local CHANGE_DIRECTION_TIME_INTERVAL = 20
local MAX_WALK_TIME = 120

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

do -- register farming core

	local function on_start(self)
		self.object:setacceleration{x = 0, y = -10, z = 0}
		self.object:setvelocity{x = 0, y = 0, z = 0}
		self.state = state.WALK_RANDOMLY
		self.time_counters = {}
		self.path = nil
	end

	local function on_stop(self)

	end

	local searching_range = {x = 5, y = 2, z = 5}

	local function walk_randomly(self, dtime)
		if self.time_counters[1] >= FIND_PATH_TIME_INTERVAL then
			self.time_counters[1] = 0
			self.time_counters[2] = self.time_counters[2] + 1

			if self:has_item_in_main(function(itemname)	return (minetest.get_item_group(itemname, "seed") > 0)) then
				local destination = _aux.search_surrounding(is_plantable_place, searching_range)
				if destination ~= nil then
					local path = minetest.find_path(self.object:getpos(), destination, 10, 1, 1)
					if path ~= nil then -- to walk to plant state.
						to_walk_to_plant(self, path, destination)
						return
					end
				end
			end
			-- if couldn't find path to plant, try to mow.
			local destination = _aux.search_surrounding(is_mowable_place, searching_range)
			if destination ~= nil then
				local path = minetest.find_path(self.object:getpos(), destination, 10, 1, 1)
				if path ~= nil then -- to walk to mow state.
					to_walk_to_mow(self, path, destination)
					return
				end
			end
			-- else do nothing.
			return

		elseif self.time_counters[2] >= CHANGE_DIRECTION_TIME_INTERVAL then
			self.time_counters[1] = self.time_counters[1] + 1
			self.time_counters[2] = 0
			self:change_direction_randomly()
			return
		else
			self.time_counters[1] = self.time_counters[1] + 1
			self.time_counters[2] = self.time_counters[2] + 1
			return
		end
	end

	local function to_walk_to_plant(self, path, destination)
		self.state = state.WALK_TO_PLANT
		self.path = path
		self.destination = destination
		self.time_counters[1] = 0 -- find path interval
		self.time_counters[2] = 0
		self.pre_position = self.object:getpos()
	end

	local function to_walk_to_mow(self, path, destination)
		self.state = state.WALK_TO_MOW
		self.path = path
		self.destination = destination
		self.time_counters[1] = 0 -- find path interval
		self.time_counters[2] = 0
		self.pre_position = self.object:getpos()
	end

	local function walk_to_plant_and_mow_common(self, dtime)
		if self.time_counters[2] >= MAX_WALK_TIME then -- time over.
			to_walk_randomly(self)
			return
		end

		if self.time_counters[1] >= FIND_PATH_TIME_INTERVAL then
			self.time_counters[1] = 0
			self.time_counters[2] = self.time_counters[2] + 1
			local path = minetest.find_path(self.object:getpos(), self.destination, 10, 1, 1)
			if path == nil then
				to_walk_randomly(self)
				return
			end
			self.path = path
		end

		-- follow path
		if vector.distance(path[1], self.object:getpos()) < 0.01 then
			table.remove(path, 1) -- next step, follow next path.
		else
			-- if maidroid is stopped by obstacles, the maidroid must jump.
			local velocity = self.object:getvelocity()
			if velocity.y == 0 then
				local front_node = self:get_front_node()
				if front_node.name ~= "air" then
					self.object:setvelocity{x = velocity.x, y = 3, z = velocity.z}
				end
			end
		end
	end

	local function on_step(self, dtime)
		if self.state == state.WALK_RANDOMLY then
			walk_randomly(self, dtime)
		elseif self.state == state.WALK_TO_PLANT or self.state == state.WALK_TO_MOW then
			walk_to_plant_and_mow_common(self, dtime)
		elseif self.state == state.PLANT or self.state == state.MOW then
			plant_and_mow_common(self, dtime)
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
