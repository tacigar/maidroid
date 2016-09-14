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

	local tiles = {
		"maidroid_tool_core_writer_top.png",
		"maidroid_tool_core_writer_bottom.png",
		"maidroid_tool_core_writer_right.png",
		"maidroid_tool_core_writer_right.png^[transformFX",
		"maidroid_tool_core_writer_front.png^[transformFX",
		"maidroid_tool_core_writer_front.png",
	}

	minetest.register_node("maidroid_tool:core_writer", {
		description        = "maidroid tool : core writer",
		drawtype           = "nodebox",
		paramtype          = "light",
		paramtype2         = "facedir",
		groups             = {cracky = 2},
		is_ground_content  = false,
		sounds             = default.node_sound_stone_defaults(),
		node_box           = node_box,
		tiles              = tiles,
	})
end) ()

-- register a definition of a core entity.
(function()

end) ()
