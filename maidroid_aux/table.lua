------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_aux.table = {}

function maidroid_aux.table.find(t, v)
	for _, value in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end
