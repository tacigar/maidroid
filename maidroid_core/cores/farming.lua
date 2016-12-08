------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local state = {

}

local function on_start(self)

end

local function on_stop(self)

end

local on_resume = on_start

local on_pause = on_stop

local function on_step(self, dtime)

end

maidroid.register_core("maidroid_core:farming", {
	description      = "maidroid core : farming",
	inventory_image  = "maidroid_core_farming.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_resume,
	on_pause         = on_pause,
	on_step          = on_step,
})
