------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid.modules = {}
local modules_dir = maidroid.modpath.."/modules"

dofile(modules_dir.."/_aux.lua")
dofile(modules_dir.."/chasing_player_module.lua")
dofile(modules_dir.."/farming_module.lua")
dofile(modules_dir.."/lumberjack_module.lua")
