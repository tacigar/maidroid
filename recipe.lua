------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- maidroids
minetest.register_craft{
	output = "maidroid:maidroid_spawn_egg",
	recipe = {
		{"default:diamond", "default:diamond", "default:diamond"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:papyrus", "default:mese_crystal", "default:papyrus"},
	},
}

minetest.register_craft{
	output = "maidroid:maidroid_mk2_spawn_egg",
	recipe = {
		{"dye:blue", "dye:blue", "dye:blue"},
		{"dye:blue", "maidroid:maidroid_spawn_egg", "dye:blue"},
		{"dye:blue", "dye:blue", "dye:blue"},
	},
}

minetest.register_craft{
	output = "maidroid:maidroid_mk3_spawn_egg",
	recipe = {
		{"dye:pink", "dye:pink", "dye:pink"},
		{"dye:pink", "maidroid:maidroid_spawn_egg", "dye:pink"},
		{"dye:pink", "dye:pink", "dye:pink"},
	},
}

-- modules
minetest.register_craft{
	output = "maidroid:empty_module",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:obsidian", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
}

minetest.register_craft{
	output = "maidroid:chasing_player_module",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "maidroid:empty_module", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
}

minetest.register_craft{
	output = "maidroid:farming_module",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:gold_ingot", "maidroid:empty_module", "default:gold_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
	},
}

minetest.register_craft{
	output = "maidroid:lumberjack_module",
	recipe = {
		{"default:diamond", "default:diamond", "default:diamond"},
		{"default:diamond", "maidroid:empty_module", "default:diamond"},
		{"default:diamond", "default:diamond", "default:diamond"},
	},
}
