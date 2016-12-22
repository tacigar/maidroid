------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_core._aux = {}

function maidroid_core._aux.search_surrounding(pos, pred, searching_range)
	for x = -searching_range.x, searching_range.x do
		for y = -searching_range.y, searching_range.y do
			for z = -searching_range.z, searching_range.z do
				local p = vector.add(pos, {x = x, y = y, z = z})
				if pred(p) then
					return p
				end
			end
		end
	end
	return nil
end
