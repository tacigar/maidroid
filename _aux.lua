------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid._aux = {}

-- get inventory of the maidroid
function maidroid._aux.get_maidroid_inventory(self)
  return minetest.get_inventory{
    type = "detached",
    name = self.invname,
  }
end
