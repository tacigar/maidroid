------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local _aux = maidroid.modules._aux

local state = {
  walk = 0,
  punch = 1,
  plant = 2,
  walk_to_plant = 3,
  walk_to_soil = 4,
}
local max_punch_time = 20
local max_plant_time = 15
local search_lenvec = {x = 3, y = 0, z = 3}


-- find max size of each plants
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


-- check the maidroid has seed items
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


-- check can plant plants.
local function can_plant(self, pos)
  local node = minetest.get_node(pos)
  local upos = _aux.get_under_pos(pos)
  local unode = minetest.get_node(upos)
  return node.name == "air"
     and minetest.get_item_group(unode.name, "wet") > 0
     and has_seed_item(self)
end


-- check can punch plant
local function can_punch(self, pos)
  local node = minetest.get_node(pos)
  return maidroid.util.table_find_value(target_plants_list, node.name)
end


-- change state to walk
local function to_walk(self)
  self.state = state.walk
  self.destination = nil
  self.object:set_animation(maidroid.animations.walk, 15, 0)
  self.time_count = 0
  _aux.change_dir(self)
end


maidroid.register_module("maidroid:farming_module", {
  description = "Maidroid Module : Farming",
  inventory_image = "maidroid_farming_module.png",

  initialize = function(self)
    self.object:set_animation(maidroid.animations.walk, 15, 0)
    self.object:setacceleration{x = 0, y = -10, z = 0}
    self.state = state.walk
    self.preposition = self.object:getpos()
    self.time_count = 0
    self.destination = nil -- for walk_to_*
    _aux.change_dir(self)
  end,

  finalize = function(self)
    self.state = nil
    self.preposition = nil
    self.time_count = nil
    self.destination = nil
    self.object:setvelocity{x = 0, y = 0, z = 0}
  end,

  on_step = function(self, dtime)
    local pos = self.object:getpos()
    local rpos = vector.round(pos)
    local upos = _aux.get_under_pos(pos)
    local yaw = self.object:getyaw()

    _aux.pickup_item(self, 1.5, function(itemstring) -- pickup droped seed items
      return minetest.get_item_group(itemstring, "seed") > 0
    end)
    if self.state == state.walk then -- searching plants or spaces
      local b1, dest1 = _aux.search_surrounding(self, search_lenvec, can_plant)
      local b2, dest2 = _aux.search_surrounding(self, search_lenvec, can_punch)
      -- search soil node near
      if b1 then -- to soil
        self.state = state.walk_to_soil
        self.destination = dest1
        _aux.change_dir_to(self, dest1)
      elseif b2 then
        self.state = state.walk_to_plant
        self.destination = dest2
        _aux.change_dir_to(self, dest2)
      elseif pos.x == self.preposition.x or pos.z == self.preposition.z then
        _aux.change_dir(self)
      end

    elseif self.state == state.punch then
      if self.time_count >= max_punch_time then
        if can_punch(self, self.destination) then
          local destnode = minetest.get_node(self.destination)
          minetest.remove_node(self.destination)
          local inv = minetest.get_inventory{type = "detached", name = self.invname}
          local stacks = minetest.get_node_drops(destnode.name)
          for _, stack in ipairs(stacks) do
            local leftover = inv:add_item("main", stack)
            minetest.add_item(self.destination, leftover)
          end
        end
        to_walk(self)
      else
        self.time_count = self.time_count + 1
      end

    elseif self.state == state.plant then
      if self.time_count >= max_plant_time then
        if can_plant(self, self.destination) then
          local inv = minetest.get_inventory{type = "detached", name = self.invname}
          local stacks = inv:get_list("main")
          for idx, stack in ipairs(stacks) do
            local item_name = stack:get_name()
            if minetest.get_item_group(item_name, "seed") > 0 then
              minetest.add_node(self.destination, {name = item_name, param2 = 1})
              stack:take_item(1)
              inv:set_stack("main", idx, stack)
              break
            end
          end
        end
        to_walk(self)
      else
        self.time_count = self.time_count + 1
      end

    elseif self.state == state.walk_to_soil then
      if vector.distance(pos, self.destination) < 1.5 then -- to plant state
        local destnode = minetest.get_node(self.destination)
        if (can_plant(self, self.destination)) then
          self.state = state.plant
          self.object:set_animation(maidroid.animations.mine, 15, 0)
          self.object:setvelocity{x = 0, y = 0, z = 0}
        else to_walk(self) end
      else
        if pos.x == self.preposition.x or pos.z == self.preposition.z then
          to_walk(self)
        end
      end

    elseif self.state == state.walk_to_plant then
      if vector.distance(pos, self.destination) < 1.5 then
        local destnode = minetest.get_node(self.destination)
        if maidroid.util.table_find_value(target_plants_list, destnode.name) then
          self.state = state.punch
          self.object:set_animation(maidroid.animations.mine, 15, 0)
          self.object:setvelocity{x = 0, y = 0, z = 0}
        else to_walk(self) end
      else
        if pos.x == self.preposition.x or pos.z == self.preposition.z then
          to_walk(self)
        end
      end
    end
    self.preposition = pos
    return
  end
})
