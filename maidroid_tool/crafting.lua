------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

minetest.register_craft{
	output = "maidroid_tool:core_writer",
	recipe = {
		{"default:steel_ingot",     "default:diamond", "default:steel_ingot"},
		{     "default:cobble", "default:steel_ingot",      "default:cobble"},
		{     "default:cobble",      "default:cobble",      "default:cobble"},
	},
}
