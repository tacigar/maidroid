------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid.modules._aux = {}

-- change direction and velocity vector
function maidroid.modules._aux.change_dir(self)
  local rnd = function() return math.random(0, 5) * 2 - 5 end
  local dir = {x = rnd(), y = 0, z = rnd()}
  local vel = vector.multiply(vector.normalize(dir), 3)
  self.object:setvelocity(vel)
  self.object:setyaw(math.atan2(vel.z, vel.x) + math.pi / 2)
end

-- get direction vector by yaw
function maidroid.modules._aux.get_forward(yaw)
  return { x = math.sin(yaw), y = 0.0, z = -math.cos(yaw) }
end

-- round direction vector
function maidroid.modules._aux.get_round_forward(forward)
  local rforward = { x = 0, y = 0, z = 0}
  if math.abs((forward.x / (math.abs(forward.x) + math.abs(forward.z)))) > 0.5 then
    if forward.x > 0 then rforward.x = 1
    else rforward.x = -1 end
  end
  if math.abs((forward.z / (math.abs(forward.x) + math.abs(forward.z)))) > 0.5 then
    if forward.z > 0 then rforward.z = 1
    else rforward.z = -1 end
  end
  return rforward
end

function maidroid.modules._aux.get_under_pos(vec)
  return { x = vec.x, y = vec.y - 1, z = vec.z }
end

function maidroid.modules._aux.get_upper_pos(vec)
  return { x = vec.x, y = vec.y + 1, z = vec.z }
end

-- pickup droped items
function maidroid.modules._aux.pickup_item(self, radius, target_pred)
  local pos = self.object:getpos()
  local pred = target_pred or (function(itemstring) return true end)
  local all_objects = minetest.get_objects_inside_radius(pos, radius)
  for _, obj in ipairs(all_objects) do
    if not obj:is_player() and obj:get_luaentity() then
      local itemstring = obj:get_luaentity().itemstring
      if itemstring then
	if pred(itemstring) then
	  local inv = maidroid._aux.get_maidroid_inventory(self)
	  local stack = ItemStack(itemstring)
	  local leftover = inv:add_item("main", stack)
	  minetest.add_item(obj:getpos(), leftover)
	  obj:get_luaentity().itemstring = ""
	  obj:remove()
	end
      end
    end
  end
end
