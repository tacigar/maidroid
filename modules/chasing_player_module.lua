------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local util = maidroid.util
local _aux = maidroid.modules._aux

local state = { idle = 0, chase = 1}
local view_of_range = 7
local stop_of_range = 2

maidroid.register_module("maidroid:chasing_player_module", {
    description = "Maidroid Module : Chasing Player",
    inventory_image = "maidroid_chasing_player_module.png",

    initialize = function(self)
        self.state = state.idle
        self.object:setacceleration{x = 0, y = -10, z = 0}
        self.object:setvelocity{x = 0, y = 0, z = 0}
    end,

    finalize = function(self)
        self.state = nil
        self.object:setvelocity{x = 0, y = 0, z = 0}
    end,

    on_step = function(self, dtime)
        local pos = self.object:getpos()
        local all_objects = minetest.get_objects_inside_radius(pos, view_of_range)
        local player = nil
        for _, obj in pairs(all_objects) do
            if obj:is_player() then player = obj; break end
        end
        if not player then
            self.object:set_animation(maidroid.animations.stand, 15, 0)
            self.state = state.idle
            return
        end
        local ppos = player:getpos()
        local dir = vector.subtract(ppos, pos)
        local vel = self.object:getvelocity()
        if (vector.length(dir) < stop_of_range) then
            if self.state == state.chase then
                self.object:set_animation(maidroid.animations.stand, 15, 0)
                self.state = state.idle
                self.object:setvelocity({x = 0, y = vel.y, z = 0})
            end
        else
            if self.state == state.idle then
                self.object:set_animation(maidroid.animations.walk, 15, 0)
                self.state = state.chase
            end
            self.object:setvelocity({x = dir.x, y = vel.y, z = dir.z})
        end
        local yaw = math.atan2(dir.z, dir.x) + math.pi/2
        self.object:setyaw(yaw)

        -- jump process
        if vel.y == 0 and self.state == state.chase then
            local rdir = vector.round(dir)
            local front_vec = { x = 0, y = 0, z = 0 }
            if math.abs((rdir.x / (math.abs(rdir.x) + math.abs(rdir.z)))) > 0.5 then
                if rdir.x > 0 then front_vec.x = 1 else front_vec.x = -1 end
            end
            if math.abs((rdir.z / (math.abs(rdir.x) + math.abs(rdir.z)))) > 0.5 then
                if rdir.z > 0 then front_vec.z = 1 else front_vec.z = -1 end
            end
            local front_pos = vector.add(vector.round(pos), front_vec)
            if minetest.get_node(front_pos).name ~= "air" then
                self.object:setvelocity({x = dir.x, y = 5, z = dir.z})
            end
        end
    end,
})
