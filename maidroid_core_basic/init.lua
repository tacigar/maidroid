------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_core_basic = {}

maidroid_core_basic.modname = "maidroid_core_basic"
maidroid_core_basic.modpath = minetest.get_modpath(maidroid_core_basic.modname)

dofile(maidroid_core_basic.modpath .. "/register.lua")
