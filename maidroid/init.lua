------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid = {}

maidroid.modname = "maidroid"
maidroid.modpath = minetest.get_modpath(maidroid.modname)

dofile(maidroid.modpath .. "/api.lua")
dofile(maidroid.modpath .. "/register.lua")
