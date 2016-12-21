------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_core._aux = {}

function maidroid_core._aux.search_surrounding(pred, searching_range)
	for x = -searching_range.x, searching_range.x do
		for y = -searching_range.y, searching_range.y do
			for z = -searching_range.z, searching_range.z do
				local pos = {x = x, y = y, z = z}
				if pred(pos) then
					return pos
				end
			end
		end
	end
	return nil
end
