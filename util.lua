------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid.util = {}

-- check that the table has the value
function maidroid.util.table_find_value(tbl, value)
  for k, v in ipairs(tbl) do
    if v == value then return true, k end
  end
  return false, nil
end

-- table shallow copy
function maidroid.util.table_shallow_copy(source)
  local copy = {}
  for key, value in pairs(source) do
    copy[key] = value
  end
  return copy
end
