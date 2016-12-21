------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local formspec = "size[4,1.25]"
			.. default.gui_bg
			.. default.gui_bg_img
 			.. default.gui_slots
			.. "button_exit[3,0.25;1,0.875;apply_name;Apply]"
			.. "field[0.5,0.5;2.75,1;name;name;]"

local maidroid_buf = {} -- for buffer of target maidroids.

minetest.register_craftitem("maidroid_tool:nametag", {
	description      = "maidroid tool : nametag",
	inventory_image  = "maidroid_tool_nametag.png",
	stack_max        = 1,

	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "object" then
			return nil
		end

		local obj = pointed_thing.ref
		local luaentity = obj:get_luaentity()

		if not obj:is_player() and luaentity then
			local name = luaentity.name
			print(name)
			print(luaentity:is_named())

			if maidroid.registered_maidroids[name] and not luaentity:is_named() then
				local player_name = user:get_player_name()

				minetest.show_formspec(player_name, "maidroid_tool:nametag", formspec)
				maidroid_buf[player_name] = luaentity
				return itemstack
			end
		end
		return nil
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "maidroid_tool:nametag" then
		return
	end

	if fields.name then
		local luaentity = maidroid_buf[player:get_player_name()]
		luaentity.nametag = fields.name

		luaentity.object:set_nametag_attributes{
			text = fields.name,
		}
	end
end)
