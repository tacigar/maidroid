------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- register a definition of a core writer.
(function()
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

	end

	-- allow_metadata_inventory_put is a common callback for the core writer.
	local function allow_metadata_inventory_put(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local itemname = stack:get_name()

		if (listname == "fuel" and itemname == "default:coal_lump") then
			return stack:get_count()
		elseif listname == "dye" and minetest.get_item_group(itemname, "dye") > 0 then
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

		local formspec_string =	"size[8,9]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]"

		local function on_construct(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec_string)

			local inventory = meta:get_inventory()
			inventory:set_size("core", 1)
			inventory:set_size("fuel", 1)
			inventory:set_size("dye", 1)
		end

		local function on_metadata_inventory_move(pos)

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
			tiles                          = tiles,
			can_dig                        = can_dig,
			on_construct                   = on_construct,
			on_metadata_inventory_move     = on_metadata_inventory_move,
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
			"maidroid_tool_core_writer_front.png^[transformFX",
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
			tiles                          = tiles,
			can_dig                        = can_dig,
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

	minetest.register_entity("maidroid_tool:core_entity", {
		physical       = false,
		visual         = "wielditem",
		visual_size    = {x = 0.5, y = 0.5},
		collisionbox   = {0, 0, 0, 0, 0, 0},

		on_activate = function(self, staticdata)
			self.object:set_properties{textures = {"maidroid_tool:core_node"}}
		end,

		on_step = function(self, dtime)
			local yaw = self.object:getyaw()
			self.object:setyaw(yaw + 0.1)
		end,
	})
end) ()
