------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_tool.shared = {}

-- maidroid_tool.shared.generate_writer is a shared
-- function called for registering egg writer and core writer.
function maidroid_tool.shared.generate_writer(options)
	local nodename                              = options.node_name
	local formspecs                             = options.formspecs
	local tiles                                 = options.tiles
	local duration                              = options.duration
	local on_activate                           = options.on_activate
	local on_deactivate                         = options.on_deactivate
	local empty_itemname                        = options.empty_itemname
	local dye_item_map                          = options.dye_item_map
	local is_mainitem                           = options.is_mainitem
	local on_metadata_inventory_put_to_main     = options.on_metadata_inventory_put_to_main
	local on_metadata_inventory_take_from_main  = options.on_metadata_inventory_take_from_main

	-- can_dig is a common callback.
	local function can_dig(pos, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		return (
			inventory:is_empty("main") and
			inventory:is_empty("fuel") and
			inventory:is_empty("dye")
		)
	end

	-- swap_node is a helper function that swap two nodes.
	local function swap_node(pos, name)
		local node = minetest.get_node(pos)
		node.name = name
		minetest.swap_node(pos, node)
	end

	-- on_timer is a common callback.
	local function on_timer(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local main_list = inventory:get_list("main")
		local fuel_list = inventory:get_list("fuel")
		local dye_list = inventory:get_list("dye")

		local time = meta:get_float("time")
		local output = meta:get_string("output")

		-- if time is positive, this node is active.
		if time >= 0 then
			if time <= max_time then
				meta:set_float("time", time + 1)
				meta:set_string("formspec", formspec.active(time))
			else
				meta:set_float("time", -1)
				meta:set_string("output", "")
				meta:set_string("formspec", formspec.inactive)
				inventory:set_stack("main", 1, ItemStack(output))

				swap_node(pos, nodename)

				if on_deactivate ~= nil then -- call on_deactivate callback.
					on_deactivate(pos)
				end
			end
		else
			local main_name = main_list[1]:get_name()

			if main_name == empty_itemname and (not fuel_list[1]:is_empty()) and (not dye_list[1]:is_empty()) then
				meta:set_string("time", 0)
				meta:set_string("output", dye_item_map[dye_list[1]:get_name()])

				local fuel_stack = fuel_list[1]
				fuel_stack:take_item()
				inventory:set_stack("fuel", 1, fuel_stack)

				local dye_stack = dye_list[1]
				dye_stack:take_item()
				inventory:set_stack("dye", 1, dye_stack)

				swap_node(pos, nodename .. "_active")

				if on_activate ~= nil then -- call on_activate callback.
					on_activate(pos)
				end
			end
		end
		return true -- on_timer should return boolean value.
	end

	-- allow_metadata_inventory_put is a common callback.
	local function allow_metadata_inventory_put(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local itemname = stack:get_name()

		if (listname == "fuel" and itemname == "default:coal_lump") then
			return stack:get_count()
		elseif listname == "dye" and dye_core_map[itemname] ~= nil then
			return stack:get_count()
		elseif listname == "main" and is_mainitem(itemname) then
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

	do -- register a definition of an inactive core writer.
		local function on_construct(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec_inactive)
			meta:set_string("output", "")
			meta:set_string("time", -1)

			local inventory = meta:get_inventory()
			inventory:set_size("main", 1)
			inventory:set_size("fuel", 1)
			inventory:set_size("dye", 1)
		end

		local function on_metadata_inventory_put(pos, listname, index, stack, player)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.25)

			local meta = minetest.get_meta(pos)
			if listname == "main" then
				if on_metadata_inventory_put_to_main ~= nil then
					on_metadata_inventory_put_to_main(pos) -- call on_metadata_inventory_put_to_main callback.
				end
			end
		end

		local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
			local meta = minetest.get_meta(pos)
			local inventory = meta:get_inventory()
			local stack = inventory:get_stack(from_list, from_index)

			on_metadata_inventory_put(pos, listname, to_index, stack, player)
		end

		local function on_metadata_inventory_take(pos, listname, index, stack, player)
			if listname == "main" then
				if on_metadata_inventory_take_from_main ~= nil then
					on_metadata_inventory_take_from_main(pos) -- call on_metadata_inventory_take_from_main callback.
				end
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
			node_box                       = options.node_box,
			selection_box                  = options.selection_box,
			tiles                          = tiles.inactive,
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

	end -- end register inactive node.

	do -- register a definition of an active core writer.
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
			node_box                       = options.node_box,
			selection_box                  = options.selection_box,
			tiles                          = tiles.active,
			can_dig                        = can_dig,
			on_timer                       = on_timer,
			allow_metadata_inventory_put   = allow_metadata_inventory_put,
			allow_metadata_inventory_move  = allow_metadata_inventory_move,
			allow_metadata_inventory_take  = allow_metadata_inventory_take,
		})
	end -- end register active node.
end
