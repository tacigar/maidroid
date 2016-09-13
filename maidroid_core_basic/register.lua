------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local function on_start(self)

end

local function on_stop(self)

end

local function on_step(self, dtime)

end

maidroid.register_core("maidroid_core_basic:core_basic", {
	description     = "maidroid core : basic",
	inventory_image = "maidroid_core_basic.png",
	on_start        = on_start,
	on_stop         = on_stop,
	on_resume       = on_start,
	on_pause        = on_stop,
	on_step         = on_step,
})
