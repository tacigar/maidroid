------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

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
		{   -0.5,  -0.375, -0.4375,     0.5,  0.3125, 0.4375},
		{-0.4375, -0.4375,    -0.5,  0.4375,    0.25,    0.5},
		{-0.3125,    -0.5, -0.3125,  0.3125, -0.4375, 0.3125},
		{ -0.375,  0.3125,  -0.375, -0.3125,   0.375,  0.375},
		{ 0.3125,  0.3125,  -0.375,   0.375,   0.375,  0.375},
		{ -0.125,    -0.5, -0.0625,   0.125,   0.375, 0.0625},
	},
}

local selection_box = {
	type = "fixed",
	fixed = {
		{-0.4375, -0.4375, -0.4375, 0.4375, -0.4375, 0.4375},
	},
}

maidroid_tool.register_writer("maidroid_tool:egg_writer", {
	description     = "maidroid tool : egg writer",
	formspec        = formspec,
	tiles           = tiles,
	node_box        = node_box,
	selection_box   = selection_box,
	duration        = 40,
	empty_itemname  = "maidroid:empty_egg",
	dye_item_map    = dye_item_map,
})
