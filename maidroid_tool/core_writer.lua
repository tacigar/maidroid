------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local dye_core_map = {
	["dye:red"] = "maidroid_core:basic",
}

-- register a definition of a core writer.
;(function()
	local node_box = {
		type = "fixed",
		fixed = {
			{-0.4375,   -0.25, -0.4375,  0.4375,  0.1875,  0.4375},
			{ 0.1875,  0.3125,  0.0625,  0.4375,   0.375,   0.125},
			{ -0.375,  0.1875,  -0.375,   0.375,    0.25,   0.375},
			{-0.0625,    -0.5, -0.0625,  0.0625,   0.375,  0.0625},
			{  0.375,  0.1875,  0.0625,  0.4375,   0.375,   0.125},
			{ -0.375,    -0.5,  -0.375,   0.375,   -0.25,   0.375},
		},
	}

	local selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.25, 0.4375},
		},
	}

	local formspec_inactive = "size[8,9]"
		.. default.gui_bg
		.. default.gui_bg_img
		.. default.gui_slots
		.. "label[3.75,0;Core]"
		.. "list[current_name;core;3.5,0.5;1,1;]"
		.. "label[2.75,2;Coal]"
		.. "list[current_name;fuel;2.5,2.5;1,1;]"
		.. "label[4.75,2;Dye]"
		.. "list[current_name;dye;4.5,2.5;1,1;]"
		.. "image[3.5,1.5;1,2;maidroid_tool_gui_arrow.png]"
		.. "image[3.1,3.5;2,1;maidroid_tool_gui_meter.png^[transformR270]"
		.. "list[current_player;main;0,5;8,1;]"
		.. "list[current_player;main;0,6.2;8,3;8]"

	local function generate_formspec_active(writing_time)
		local arrow_percent = (100 / 40) * writing_time

		local merter_percent = 0
		if writing_time % 16 >= 8 then
			meter_percent = (8 - (writing_time % 8)) * (100 / 8)
		else
			meter_percent = (writing_time % 8) * (100 / 8)
		end

		return "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "label[3.75,0;Core]"
			.. "list[current_name;core;3.5,0.5;1,1;]"
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
	end

	-- get_nearest_core_entity returns the nearest core entity.
	local function get_nearest_core_entity(pos)
		local all_objects = minetest.get_objects_inside_radius(pos, 1.0)
		for _, object in ipairs(all_objects) do
			if object:get_luaentity().name == "maidroid_tool:core_entity" then
				return object:get_luaentity()
			end
		end
		return nil
	end

	-- can_dig is a common callback for the core writer.
	local function can_dig(pos, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		return (
			inventory:is_empty("core") and
			inventory:is_empty("fuel") and
			inventory:is_empty("dye")
		)
	end

	-- on_timer is a common callback for the core writer.
	local function on_timer(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()

		local core_list = inventory:get_list("core")
		local fuel_list = inventory:get_list("fuel")
		local dye_list = inventory:get_list("dye")

		local writing_time = meta:get_float("writing_time")
		local writing_total_time = 40
		local output_core = meta:get_string("output_core")

		-- if writing time is positive, the core writer is active.
		if writing_time >= 0 then
			if writing_time <= writing_total_time then
				meta:set_float("writing_time", writing_time + 1)
				meta:set_string("formspec", generate_formspec_active(writing_time))

			else -- else place output core to core list.
				meta:set_float("writing_time", -1)
				meta:set_string("output_core", "")
				meta:set_string("formspec", formspec_inactive)
				inventory:set_stack("core", 1, ItemStack(output_core))
				minetest.swap_node(pos, {name = "maidroid_tool:core_writer"})

				local core_entity = get_nearest_core_entity(pos)
				core_entity:stop_rotate()
			end

		else -- else the core writer is inactive.
			local core_name = core_list[1]:get_name()

			if core_name == "maidroid_core:empty" and (not fuel_list[1]:is_empty()) and (not dye_list[1]:is_empty()) then
				meta:set_float("writing_time", 0)
				meta:set_string("output_core", dye_core_map[dye_list[1]:get_name()])

				local fuel_stack = fuel_list[1]
				fuel_stack:take_item()
				inventory:set_stack("fuel", 1, fuel_stack)

				local dye_stack = dye_list[1]
				dye_stack:take_item()
				inventory:set_stack("dye", 1, dye_stack)

				minetest.swap_node(pos, {name = "maidroid_tool:core_writer_active"})

				local core_entity = get_nearest_core_entity(pos)
				core_entity:start_rotate()
			end
		end
		return true
	end

	-- allow_metadata_inventory_put is a common callback for the core writer.
	local function allow_metadata_inventory_put(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local itemname = stack:get_name()

		if (listname == "fuel" and itemname == "default:coal_lump") then
			return stack:get_count()
		elseif listname == "dye" and dye_core_map[itemname] ~= nil then
			return stack:get_count()
		elseif listname == "core" and maidroid.is_core(itemname) then
			return stack:get_count()
		end
		return 0
	end

	-- allow_metadata_inventory_move is a common callback for the core writer.
	local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local stack = inventory:get_stack(from_list, from_index)

		return allow_metadata_inventory_put(pos, listname, to_index, stack, player)
	end

	--------------------------------------------------------------------

	;(function() -- register a definition of an inactive core writer.
		local tiles = {
			"maidroid_tool_core_writer_top.png",
			"maidroid_tool_core_writer_bottom.png",
			"maidroid_tool_core_writer_right.png",
			"maidroid_tool_core_writer_right.png^[transformFX",
			"maidroid_tool_core_writer_front.png^[transformFX",
			"maidroid_tool_core_writer_front.png",
		}

		local function on_construct(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec_inactive)
			meta:set_string("output_core", "")
			meta:set_float("writing_time", -1)

			local inventory = meta:get_inventory()
			inventory:set_size("core", 1)
			inventory:set_size("fuel", 1)
			inventory:set_size("dye", 1)
		end

		local function on_metadata_inventory_put(pos, listname, index, stack, player)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.25)

			local meta = minetest.get_meta(pos)
			if listname == "core" then
				local entity_position = {
					x = pos.x, y = pos.y + 0.65, z = pos.z
				}
				minetest.add_entity(entity_position, "maidroid_tool:core_entity")
			end
		end

		local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
			local meta = minetest.get_meta(pos)
			local inventory = meta:get_inventory()
			local stack = inventory:get_stack(from_list, from_index)

			on_metadata_inventory_put(pos, listname, to_index, stack, player)
		end

		local function on_metadata_inventory_take(pos, listname, index, stack, player)
			if listname == "core" then
				local core_entity = get_nearest_core_entity(pos)
				core_entity.object:remove()
			end
		end

		local function allow_metadata_inventory_take(pos, listname, index, stack, player)
			return stack:get_count() -- maybe add more.
		end

		minetest.register_node("maidroid_tool:core_writer", {
			description                    = "maidroid tool : core writer",
			drawtype                       = "nodebox",
			paramtype                      = "light",
			paramtype2                     = "facedir",
			groups                         = {cracky = 2},
			is_ground_content              = false,
			sounds                         = default.node_sound_stone_defaults(),
			node_box                       = node_box,
			selection_box                  = selection_box,
			tiles                          = tiles,
			can_dig                        = can_dig,
			on_timer                       = on_timer,
			on_construct                   = on_construct,
			on_metadata_inventory_put      = on_metadata_inventory_put,
			on_metadata_inventory_move     = on_metadata_inventory_move,
			on_metadata_inventory_take     = on_metadata_inventory_take,
			allow_metadata_inventory_put   = allow_metadata_inventory_put,
			allow_metadata_inventory_move  = allow_metadata_inventory_move,
			allow_metadata_inventory_take  = allow_metadata_inventory_take,
		})
	end) ()

	--------------------------------------------------------------------

	;(function () -- register a definition of an active core writer.
		local tiles = {
			"maidroid_tool_core_writer_top.png",
			"maidroid_tool_core_writer_bottom.png",
			"maidroid_tool_core_writer_right.png",
			"maidroid_tool_core_writer_right.png^[transformFX",
			{
				backface_culling = false,
				image = "maidroid_tool_core_writer_front_active.png^[transformFX",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
			{
				backface_culling = false,
				image = "maidroid_tool_core_writer_front_active.png",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
		}

		local function allow_metadata_inventory_take(pos, listname, index, stack, player)
			if listname == "core" then
				return 0
			end
			return stack:get_count()
		end

		minetest.register_node("maidroid_tool:core_writer_active", {
			drawtype                       = "nodebox",
			paramtype                      = "light",
			paramtype2                     = "facedir",
			groups                         = {cracky = 2},
			is_ground_content              = false,
			sounds                         = default.node_sound_stone_defaults(),
			node_box                       = node_box,
			selection_box                  = selection_box,
			tiles                          = tiles,
			can_dig                        = can_dig,
			on_timer                       = on_timer,
			allow_metadata_inventory_put   = allow_metadata_inventory_put,
			allow_metadata_inventory_move  = allow_metadata_inventory_move,
			allow_metadata_inventory_take  = allow_metadata_inventory_take,
		})
	end) ()
end) ()

-- register a definition of a core entity.
;(function()
	local node_box = {
		type = "fixed",
		fixed = {
			{   -0.5,    -0.5,  -0.125,     0.5, -0.4375,   0.125},
			{ -0.125,    -0.5,    -0.5,   0.125, -0.4375,     0.5},
			{  -0.25,    -0.5, -0.4375,    0.25, -0.4375,  0.4375},
			{ -0.375,    -0.5,  -0.375,   0.375, -0.4375,   0.375},
			{-0.4375,    -0.5,   -0.25,  0.4375, -0.4375,    0.25},
		},
	}

	local tiles = {
		"maidroid_tool_core_top.png",
		"maidroid_tool_core_top.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
	}

	minetest.register_node("maidroid_tool:core_node", {
		drawtype    = "nodebox",
		tiles       = tiles,
		node_box    = node_box,
		paramtype   = "light",
		paramtype2  = "facedir",
	})

	local function on_activate(self, staticdata)
		self.object:set_properties{textures = {"maidroid_tool:core_node"}}
	end

	local function start_rotate(self)
		self.object:set_properties{automatic_rotate = 1}
	end

	local function stop_rotate(self)
		self.object:set_properties{automatic_rotate = 0}
	end

	minetest.register_entity("maidroid_tool:core_entity", {
		physical      = false,
		visual        = "wielditem",
		visual_size   = {x = 0.5, y = 0.5},
		collisionbox  = {0, 0, 0, 0, 0, 0},
		on_activate   = on_activate,
		start_rotate  = start_rotate,
		stop_rotate   = stop_rotate,
	})
end) ()
