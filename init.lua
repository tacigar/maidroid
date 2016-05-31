------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid = {}
maidroid.modname = "maidroid"
maidroid.modpath = minetest.get_modpath("maidroid")

dofile(maidroid.modpath.."/_aux.lua")
dofile(maidroid.modpath.."/util.lua")
dofile(maidroid.modpath.."/api.lua")
dofile(maidroid.modpath.."/modules.lua")
dofile(maidroid.modpath.."/maidroids.lua")

