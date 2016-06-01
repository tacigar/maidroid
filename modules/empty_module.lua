------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- 何もしないモジュール
maidroid.register_module("maidroid:empty_module", {
  description = "Maidroid Module : Empty Module",
  inventory_image = "maidroid_empty_module.png",
  initialize = function(self) end,
  finalize = function(self) end,
  on_step = function(self, dtime) end,
})
