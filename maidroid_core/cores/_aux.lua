------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_core._aux = {}

local default_searching_range = {
	x = 5, y = 0, z = 5,
}

-- maidroid_core._aux.search_surrounding searchs maidroid surrounding.
function maidroid_core._aux.search_surrounding(self, pred, searching_range)
	if searching_range == nil then
		searching_range = default_searching_range
	end
	for x = -searching_range.x, searching_range.x do
		for y = -searching_range.y, searching_range.y do
			for z = -searching_range.z, searching_range.z do
				local pos = {x = x, y = y, z = z}
				if pred(self, pos) then
					return pos
				end
			end
		end
	end
	return nil
end
