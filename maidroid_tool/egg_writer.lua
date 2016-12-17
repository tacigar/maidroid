------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

do -- register egg writer

	local dye_item_map = {
		["dye:red"] = "maidroid:maidroid_mk1_egg",
	}

	local formspec = { -- want to change.
		["inactive"] = "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "label[3.75,0;Egg]"
			.. "list[current_name;main;3.5,0.5;1,1;]"
			.. "label[2.75,2;Coal]"
			.. "list[current_name;fuel;2.5,2.5;1,1;]"
			.. "label[4.75,2;Dye]"
			.. "list[current_name;dye;4.5,2.5;1,1;]"
			.. "image[3.5,1.5;1,2;maidroid_tool_gui_arrow.png]"
			.. "image[3.1,3.5;2,1;maidroid_tool_gui_meter.png^[transformR270]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]",

		["active"] = function(time)
			local arrow_percent = (100 / 40) * time
			local merter_percent = 0
			if time % 16 >= 8 then
				meter_percent = (8 - (time % 8)) * (100 / 8)
			else
				meter_percent = (time % 8) * (100 / 8)
			end
			return "size[8,9]"
				.. default.gui_bg
				.. default.gui_bg_img
				.. default.gui_slots
				.. "label[3.75,0;Egg]"
				.. "list[current_name;main;3.5,0.5;1,1;]"
				.. "label[2.75,2;Coal]"
				.. "list[current_name;fuel;2.5,2.5;1,1;]"
				.. "label[4.75,2;Dye]"
				.. "list[current_name;dye;4.5,2.5;1,1;]"
				.. "image[3.5,1.5;1,2;maidroid_tool_gui_arrow.png^[lowpart:"
				.. arrow_percent
				.. ":maidroid_tool_gui_arrow_filled.png]"
				.. "image[3.1,3.5;2,1;maidroid_tool_gui_meter.png^[lowpart:"
				.. meter_percent
				.. ":maidroid_tool_gui_meter_filled.png^[transformR270]"
				.. "list[current_player;main;0,5;8,1;]"
				.. "list[current_player;main;0,6.2;8,3;8]"
		end,
	}

	local tiles = {
		["active"] = {
			"default_stone.png",
		},

		["inactive"] = {
			"default_stone.png",
		},
	}

	local node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.3125, -0.4375, -0.375,  0.4375, 0.4375},
			{-0.4375, -0.3125, -0.4375, 0.4375,  0.4375, -0.375},
			{  0.375, -0.3125, -0.4375, 0.4375,  0.4375, 0.4375},
			{-0.4375, -0.3125,   0.375, 0.4375,  0.4375, 0.4375},
			{-0.4375,   -0.25,  -0.375, 0.4375,    0.25,  0.375},
			{   -0.5,       0,    -0.5,    0.5,   0.125,    0.5},
			{  -0.25,    -0.5, -0.3125,   0.25, -0.3125, 0.3125},
			{-0.3125,    -0.5,   -0.25, 0.3125, -0.3125,   0.25},
		},
	}

	local selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.4375, 0.4375},
		},
	}

	local function get_nearest_egg_entity(pos)
		local all_objects = minetest.get_objects_inside_radius(pos, 1.0)
		for _, object in ipairs(all_objects) do
			if object:get_luaentity().name == "maidroid_tool:egg_entity" then
				return object:get_luaentity()
			end
		end
		return nil
	end

	local function on_deactivate(pos)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity:stop_move()
	end

	local function on_activate(pos)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity:start_move()
	end

	local function on_metadata_inventory_put_to_main(pos)
		local center_position = {
			x = pos.x, y = pos.y + 0.25, z = pos.z
		}
		local egg_entity = minetest.add_entity(center_position, "maidroid_tool:egg_entity")
		local lua_entity = egg_entity:get_luaentity()
		lua_entity:initialize(center_position)
	end

	local function on_metadata_inventory_take_from_main(pos)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity.object:remove()
	end

	maidroid_tool.register_writer("maidroid_tool:egg_writer", {
		description                           = "maidroid tool : egg writer",
		formspec                              = formspec,
		tiles                                 = tiles,
		node_box                              = node_box,
		selection_box                         = selection_box,
		duration                              = 40,
		on_activate                           = on_activate,
		on_deactivate                         = on_deactivate,
		empty_itemname                        = "maidroid:empty_egg",
		dye_item_map                          = dye_item_map,
		on_metadata_inventory_put_to_main     = on_metadata_inventory_put_to_main,
		on_metadata_inventory_take_from_main  = on_metadata_inventory_take_from_main,
	})

end -- register egg writer

do -- register a definition of an egg entity
	local function on_activate(self, staticdata)
		self.object:set_properties{textures={"maidroid:empty_egg"}}

		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			self.is_moving = data["is_moving"]

			if self.is_moving then
				self:start_move()
			end
		end
	end

	local function start_move(self)
		self.object:set_properties{automatic_rotate = 1}
		is_moving = true
	end

	local function stop_move(self)
		self.object:set_properties{automatic_rotate = 0}
		is_moving = false
	end

	local function get_staticdata(self)
		local data = {
			["is_moving"] = self.is_moving,
			["center_position"] = self.center_position,
		}
		return minetest.serialize(data)
	end

	local function on_step(self, dtime)
		if self.is_moving then

		end
		-- move up and down.
		if self.angle >= 360 then
			self.angle = 0
		else
			self.angle = self.angle + 3
		end
		local current_pos = self.object:getpos()
		self.object:setpos(
			vector.add(current_pos, {
				x = 0,
				y = math.sin(self.angle * math.pi / 180.0) * 0.0025,
				z = 0
			})
		)
	end

	local function initialize(self, pos)
		self.center_position = pos
		local init_pos = vector.add(pos, {x = 0.15, y = 0, z = 0})
		self.object:setpos(init_pos)
	end

	minetest.register_entity("maidroid_tool:egg_entity", {
		hp_max           = 1,
		visual           = "wielditem",
		visual_size      = {x = 0.2, y = 0.2},
		collisionbox     = {0, 0, 0, 0, 0, 0},
		physical         = false,
		on_activate      = on_activate,
		start_move       = start_move,
		stop_move        = stop_move,
		get_staticdata   = get_staticdata,
		on_step          = on_step,
		initialize       = initialize,
		center_position  = nil,
		is_moving        = false,
		angle            = 0,
	})
end -- register egg entity
