------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local _aux = maidroid.modules._aux
local state = {walk = 0, punch = 1, plant = 2}

-- 各植物ノードの種類の最大番号を探し出す
local target_plants_list = {}
minetest.after(0, function()
  local max = {}
  for name, node in pairs(minetest.registered_nodes) do
    if minetest.get_item_group(name, "plant") > 0 then
      local s, i = string.match(name, "(.+)_(%d+)")
      if max[s] == nil or max[s] < i then max[s] = i end
    end
  end
  for s, i in pairs(max) do
    table.insert(target_plants_list, s.."_"..i)
  end
end)

local max_punch_time = 20
local max_plant_time = 15

-- 種を持っているか否かを確認する
local function has_seed_item(self)
  local inv = maidroid._aux.get_maidroid_inventory(self)
  local stacks = inv:get_list("main")
  for _, stack in ipairs(stacks) do
    local item_name = stack:get_name()
    if minetest.get_item_group(item_name, "seed") > 0 then
      return true
    end
  end
  return false
end

-- 農業を行うモジュール
maidroid.register_module("maidroid:farming_module", {
  description = "Maidroid Module : Farming",
  inventory_image = "maidroid_farming_module.png",
  initialize = function(self)
    self.object:set_animation(maidroid.animations.walk, 15, 0)
    self.object:setacceleration{x = 0, y = -10, z = 0}
    self.state = state.walk
    self.preposition = self.object:getpos()
    self.time_count = 0
    _aux.change_dir(self)
  end,
  finalize = function(self)
    self.state = nil
    self.preposition = nil
    self.time_count = nil
    self.object:setvelocity{x = 0, y = 0, z = 0}
  end,
  on_step = function(self, dtime)
    local pos = self.object:getpos()
    local rpos = vector.round(pos)
    local yaw = self.object:getyaw()
    local forward_vec = _aux.get_forward(yaw)
    local forward_vec2 = _aux.get_round_forward(forward_vec)
    local forward_pos = vector.add(rpos, forward_vec2)
    local forward_node = minetest.get_node(forward_pos)
    local forward_under_pos = vector.subtract(forward_pos, {x = 0, y = 1, z = 0})
    if self.state == state.walk then -- searching plants or spaces
      if maidroid.util.table_find_value(target_plants_list, forward_node.name) then
	self.state = state.punch
	self.object:set_animation(maidroid.animations.mine, 15, 0)
	self.object:setvelocity{x = 0, y = 0, z = 0}
      elseif pos.x == self.preposition.x or pos.z == self.preposition.z then
	_aux.change_dir(self)
      elseif forward_node.name == "air"
      and minetest.get_item_group(inetest.get_node(forward_under_pos).name, "wet") > 0
      and has_seed_item(self) then
	self.state = state.plant
	self.object:set_animation(maidroid.animations.mine, 15, 0)
	self.object:setvelocity{x = 0, y = 0, z = 0}
      end
      -- 種を広い集める
      _aux.pickup_item(self, 1.5, function(itemstring)
        return minetest.get_item_group(itemstring, "seed") > 0
      end)
    elseif self.state == state.punch then
      if self.time_count >= max_punch_time then
	if maidroid.util.table_find_value(target_plants_list, forward_node.name) then
	  local inv = minetest.get_inventory{type = "detached", name = self.invname}
	  local stacks = minetest.get_node_drops(forward_node.name)
	  for _, stack in ipairs(stacks) do
	    local leftover = inv:add_item("main", stack)
	    minetest.add_item(forward_pos, leftover)
	  end
	end
	self.state = state.walk
	self.object:set_animation(maidroid.animations.walk, 15, 0)
	self.time_count = 0
	_aux.change_dir(self)
      else
	self.time_count = self.time_count + 1
      end
    elseif self.state == state.plant then
      if self.time_count >= max_plant_time then
	if forward_node.name == "air" and minetest.get_item_group(
          minetest.get_node(forward_under_pos).name, "soil") > 0 then
	  local inv = minetest.get_inventory{type = "detached", name = self.invname}
	  local stacks = inv:get_list("main")
	  for idx, stack in ipairs(stacks) do
	    local item_name = stack:get_name()
	    if minetest.get_item_group(item_name, "seed") > 0 then
	      minetest.add_node(forward_pos, {name = item_name, param2 = 1})
	      stack:take_item(1)
	      inv:set_stack("main", idx, stack)
	      break
	    end
	  end
	end
	self.state = state.walk
	self.object:set_animation(maidroid.animations.walk, 15, 0)
	self.time_count = 0
	_aux.change_dir(self)
      else
	self.time_count = self.time_count + 1
      end
    end
    self.preposition = pos
    return
  end
})
