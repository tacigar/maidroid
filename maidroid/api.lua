------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- maidroid.animation_frames represents the animation frame data
-- of "models/maidroid.b3d".
maidroid.animation_frames = {
	STAND     = {x =   0, y =  79},
	SIT       = {x =  81, y = 160},
	LAY       = {x = 162, y = 166},
	WALK      = {x = 168, y = 187},
	MINE      = {x = 189, y = 198},
	WALK_MINE = {x = 200, y = 219},
}

-- maidroid.registered_maidroids represents a table that contains
-- definitions of maidroid registered by maidroid.register_maidroid.
maidroid.registered_maidroids = {}

-- maidroid.registered_cores represents a table that contains
-- definitions of core registered by maidroid.register_core.
maidroid.registered_cores = {}

-- maidroid.is_core reports whether a item is a core item by the name.
function maidroid.is_core(item_name)
	if maidroid.registered_cores[item_name] then
		return true
	end
	return false
end

---------------------------------------------------------------------

-- maidroid.maidroid represents a table that contains common methods
-- for maidroid object.
-- this table must be contains by a metatable.__index of maidroid self tables.
-- minetest.register_entity set initial properties as a metatable.__index, so
-- this table's methods must be put there.
maidroid.maidroid = {}

-- maidroid.maidroid.get_inventory returns a inventory of a maidroid.
function maidroid.maidroid.get_inventory(self)
	return minetest.get_inventory {
		type = "detached",
		name = self.inventory_name,
	}
end

-- maidroid.maidroid.get_core_name returns a name of a maidroid's current core.
function maidroid.maidroid.get_core_name(self)
	return self.core_name
end

-- maidroid.maidroid.get_core returns a maidroid's current core definition.
function maidroid.maidroid.get_core(self)
	local name = self:get_core_name(self)
	if name ~= "" then
		return maidroid.registered_cores[name]
	end
	return nil
end

-- maidroid.maidroid.get_nearest_player returns a player object who
-- is the nearest to the maidroid.
function maidroid.maidroid.get_nearest_player(self, range_distance)
	local player, min_distance = nil, range_distance
	local position = self.object:getpos()

	local all_objects = minetest.get_objects_inside_radius(position, range_distance)
	for _, object in pairs(all_objects) do
		if object:is_player() then
			local player_position = object:getpos()
			local distance = vector.distance(position, player_position)

			if distance < min_distance then
				min_distance = distance
				player = object
			end
		end
	end
	return player
end

-- maidroid.maidroid.get_front_node returns a node that exists in front of the maidroid.
function maidroid.maidroid.get_front_node(self)
	local direction = self:get_look_direction()
	if math.abs(direction.x) >= 0.5 then
		if direction.x > 0 then	direction.x = 1	else direction.x = -1 end
	else
		direction.x = 0
	end

	if math.abs(direction.z) >= 0.5 then
		if direction.z > 0 then	direction.z = 1	else direction.z = -1 end
	else
		direction.z = 0
	end

	local front = vector.add(vector.round(self.object:getpos()), direction)
	return minetest.get_node(front)
end

-- maidroid.maidroid.get_look_direction returns a normalized vector that is
-- the maidroid's looking direction.
function maidroid.maidroid.get_look_direction(self)
	local yaw = self.object:getyaw()
	return vector.normalize{x = math.sin(yaw), y = 0.0, z = -math.cos(yaw)}
end

-- maidroid.maidroid.set_animation sets the maidroid's animation.
-- this method is wrapper for self.object:set_animation.
function maidroid.maidroid.set_animation(self, frame)
	self.object:set_animation(frame, 15, 0)
end

-- maidroid.maidroid.set_yaw_by_direction sets the maidroid's yaw
-- by a direction vector.
function maidroid.maidroid.set_yaw_by_direction(self, direction)
	self.object:setyaw(math.atan2(direction.z, direction.x) + math.pi / 2)
end

---------------------------------------------------------------------

-- maidroid.manufacturing_data represents a table that contains manufacturing data.
-- this table's keys are product names, and values are manufacturing numbers
-- that has been already manufactured.
maidroid.manufacturing_data = (function()
	local file_name = minetest.get_worldpath() .. "/manufacturing_data"

	minetest.register_on_shutdown(function()
		local file = io.open(file_name, "w")
		file:write(minetest.serialize(maidroid.manufacturing_data))
		file:close()
	end)

	local file = io.open(file_name, "r")
	if file ~= nil then
		local data = file:read("*a")
		file:close()
		return minetest.deserialize(data)
	end
	return {}
end) ()

---------------------------------------------------------------------

-- maidroid.register_core registers a definition of a new core.
function maidroid.register_core(core_name, def)
	maidroid.registered_cores[core_name] = def

	minetest.register_craftitem(core_name, {
		stack_max       = 1,
		description     = def.description,
		inventory_image = def.inventory_image,
	})
end

-- maidroid.register_maidroid registers a definition of a new maidroid.
function maidroid.register_maidroid(product_name, def)
	-- initialize manufacturing number of a new maidroid.
	if maidroid.manufacturing_data[product_name] == nil then
		maidroid.manufacturing_data[product_name] = 0
	end

	local function update_infotext(self)
		if self.core_name ~= "" then
			local infotext = ""
			if self.pause then
				infotext = infotext .. "this maidroid is paused\n"
			else
				infotext = infotext .. "this maidroid is active\n"
			end
			infotext = infotext .. "[Core] : " .. self.core_name

			self.object:set_properties{infotext = infotext}
			return
		end
		self.object:set_properties{infotext = "this maidroid is inactive"}
	end

	-- create_inventory creates a new inventory, and returns it.
	local function create_inventory(self)
		self.inventory_name = self.product_name .. tostring(self.manufacturing_number)
		local inventory = minetest.create_detached_inventory(self.inventory_name, {
			on_put = function(inv, listname, index, stack, player)
				if listname == "core" then
					local core_name = stack:get_name()
					local core = maidroid.registered_cores[core_name]
					core.on_start(self)
					self.core_name = core_name

					update_infotext(self)
				end
			end,

			allow_put = function(inv, listname, index, stack, player)
				-- only cores can put to a core inventory.
				if listname == "main" then
					return stack:get_count()
				elseif listname == "core" and maidroid.is_core(stack:get_name()) then
					return stack:get_count()
				end
				return 0
			end,

			on_take = function(inv, listname, index, stack, player)
				if listname == "core" then
					local core = maidroid.registered_cores[self.core_name]
					self.core_name = ""
					core.on_stop(self)

					update_infotext(self)
				end
			end,
		})
		inventory:set_size("main", 16)
		inventory:set_size("core",  1)

		return inventory
	end

	-- create_formspec_string returns a string that represents a formspec definition.
	local function create_formspec_string(self)
		return "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "list[detached:"..self.inventory_name..";main;0,0;4,4;]"
			.. "label[5,0;core]"
			.. "list[detached:"..self.inventory_name..";core;6,0;1,1;]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]"
	end

	-- on_activate is a callback function that is called when the object is created or recreated.
	local function on_activate(self, staticdata)
		-- parse the staticdata, and compose a inventory.
		if staticdata == "" then
			self.product_name = product_name
			self.manufacturing_number = maidroid.manufacturing_data[product_name]
			maidroid.manufacturing_data[product_name] = maidroid.manufacturing_data[product_name] + 1
			create_inventory(self)
		else
			-- if static data is not empty string, this object has beed already created.
			local data = minetest.deserialize(staticdata)

			self.product_name = data["product_name"]
			self.manufacturing_number = data["manufacturing_number"]

			local inventory = create_inventory(self)
			local core_name = data["inventory"]["core"]
			local items = data["inventory"]["main"]

			if core_name ~= "" then -- set a core
				core_stack = ItemStack(core_name)
				core_stack:set_count(1)
				inventory:add_item("core", core_stack)
				self.core_name = core_name
			end

			for _, item in ipairs(items) do -- set items
				local item_stack = ItemStack(item["name"])
				item_stack:set_count(item["count"])
				inventory:add_item("main", item_stack)
			end
		end

		self.formspec_string = create_formspec_string(self)
		update_infotext(self)

		local core = self:get_core()
		if core ~= nil then
			core.on_start(self)
		else
			self.object:setvelocity{x = 0, y = 0, z = 0}
			self.object:setacceleration{x = 0, y = -10, z = 0}
		end
	end

	-- get_staticdata is a callback function that is called when the object is destroyed.
	local function get_staticdata(self)
		local inventory = self:get_inventory()
		local data = {
			["product_name"] = self.product_name,
			["manufacturing_number"] = self.manufacturing_number,
			["inventory"] = {
				["main"] = {},
				["core"] = self.core_name,
			},
		}

		for _, item in ipairs(inventory:get_list("main")) do
			local count = item:get_count()
			local itemname = item:get_name()
			if count ~= 0 then
				local itemdata = {count = count, name = itemname}
				table.insert(data["inventory"]["main"], itemdata)
			end
		end
		return minetest.serialize(data)
	end

	-- on_step is a callback function that is called every delta times.
	local function on_step(self, dtime)
		if (not self.pause) and self.core_name ~= "" then
			local core = maidroid.registered_cores[self.core_name]
			core.on_step(self, dtime)
		end
	end

	-- on_rightclick is a callback function that is called when a player right-click them.
	local function on_rightclick(self, clicker)
		minetest.show_formspec(
			clicker:get_player_name(),
			self.inventory_name,
			self.formspec_string
		)
	end

	-- on_punch is a callback function that is called when a player punch then.
	local function on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if self.pause == true then
			self.pause = false
			if self.core_name ~= "" then
				local core = maidroid.registered_cores[self.core_name]
				core.on_pause(self)
			end
		else
			self.pause = true
			if self.core_name ~= "" then
				local core = maidroid.registered_cores[self.core_name]
				core.on_resume(self)
			end
		end
	end

	-- register a definition of a new maidroid.
	minetest.register_entity(product_name, {
		-- basic initial properties
		hp_max                       = def.hp_max,
		weight                       = def.weight,
		mesh                         = def.mesh,
		textures                     = def.textures,

		physical                     = true,
		visual                       = "mesh",
		visual_size                  = {x = 10, y = 10},
		collisionbox                 = {-0.25, -0.5, -0.25, 0.25, 1.05, 0.25},
		is_visible                   = true,
		makes_footstep_sound         = true,
		automatic_face_movement_dir  = 90.0,
		infotext                     = "",

		-- extra initial properties
		pause                        = false,
		product_name                 = "",
		manufacturing_number         = -1,
		core_name                    = "",

		-- callback methods.
		on_activate                  = on_activate,
		on_step                      = on_step,
		on_rightclick                = on_rightclick,
		on_punch                     = on_punch,
		get_staticdata               = get_staticdata,

		-- extra methods.
		get_inventory                = maidroid.maidroid.get_inventory,
		get_core                     = maidroid.maidroid.get_core,
		get_core_name                = maidroid.maidroid.get_core_name,
		get_nearest_player           = maidroid.maidroid.get_nearest_player,
		get_front_node               = maidroid.maidroid.get_front_node,
		get_look_direction           = maidroid.maidroid.get_look_direction,
		set_animation                = maidroid.maidroid.set_animation,
		set_yaw_by_direction         = maidroid.maidroid.set_yaw_by_direction,
	})

	-- register a spawner for debugging maidroid mods.
	minetest.register_craftitem(product_name .. "_spawner", {
		description     = product_name .. " spawner",
		inventory_image = def.inventory_image,
		stack_max       = 1,
		on_use  = function(item_stack, user, pointed_thing)
			if pointed_thing.above ~= nil then
				minetest.add_entity(pointed_thing.above, product_name)
				return itemstack
			end
			return nil
		end,
	})
end
