------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_tool = {}

maidroid_tool.modname = "maidroid_tool"
maidroid_tool.modpath = minetest.get_modpath(maidroid_tool.modname)

dofile(maidroid_tool.modpath .. "/api.lua")
dofile(maidroid_tool.modpath .. "/core_writer.lua")
dofile(maidroid_tool.modpath .. "/egg_writer.lua")
dofile(maidroid_tool.modpath .. "/crafting.lua")
