------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local _aux = maidroid._aux

-- aux function to generate serialnumber for inventories
local gen_inv_serialnumber = (function ()
    local serialnumber = 0
    return function ()
        serialnumber = serialnumber + 1
        return serialnumber - 1
    end
end) ()

local main_invsize = 16
local main_invname = "main"
local module_invsize = 1
local module_invname = "module"

-- key = modulename, value = moduledef
maidroid.registered_modules = {}

function maidroid.register_module(module_name, def)
    maidroid.registered_modules[module_name] = def
    minetest.register_craftitem(module_name, {
        description = def.description,
        stack_max = 1,
        inventory_image = def.inventory_image,
    })
end

-- animation frame
maidroid.animations = {
    stand = {x = 0, y = 79},
    lay = {x = 162, y = 166},
    walk = {x = 168, y = 187},
    mine = {x = 189, y = 198},
    walk_mine = {x = 200, y = 219},
    sit = {x = 81, y = 160},
}

function maidroid.register_maidroid(product_name, def)
    minetest.register_entity(product_name, {
        hp_max = def.hp_max or 1,
        physical = true,
        weight = def.weight or 5,
        collistionbox = def.collistionbox or { -0.35, -0.5, -0.35, 0.35, 1.1, 0.35 },
        visual = "mesh",
        visual_size = {x = 10, y = 10},
        mesh = def.mesh or "maidroid.b3d",
        textures = def.textures or {"maidroid.png"},
        is_visible = true,
        makes_footstep_sound = true,
        module = nil,
        invname = "",

        on_activate = function(self, staticdata)
            self.invname = "maidroid"..tostring(gen_inv_serialnumber())
            local inv = minetest.create_detached_inventory(self.invname, {
                on_put = function(inv, listname, index, stack, player)
                    if listname == module_invname then
                        local module_name = stack:get_name()
                        local module_def = maidroid.registered_modules[module_name]
                        self.module = module_def
                        module_def.initialize(self)
                    end
                end,
                allow_put = function(inv, listname, index, stack, player)
                    local item_name = stack:get_name()
                    local is_module = maidroid.registered_modules[item_name]
                    if listname == main_invname
                    or (listname == module_invname and is_module) then
                        return stack:get_count()
                    end
                    return 0
                end,
                on_take = function(inv, listname, index, stack, player)
                    if listname == module_invname then
                        local module_name = stack:get_name()
                        local module_def = maidroid.registered_modules[module_name]
                        self.module = nil
                        module_def.finalize(self)
                    end
                end,
            })
            inv:set_size(main_invname, main_invsize)
            inv:set_size(module_invname, module_invsize)
            -- process staticdata
            if staticdata ~= "" then
                local data = minetest.deserialize(staticdata)
                if data.inv.module ~= "" then
                    module_stack = ItemStack(data.inv.module)
                    module_stack:set_count(1)
                    inv:add_item(module_invname, module_stack)
                    self.module = maidroid.registered_modules[data.inv.module]
                end
                for _, item in ipairs(data.inv.main) do
                    local itemstack = ItemStack(item.name)
                    itemstack:set_count(item.count)
                    inv:add_item(main_invname, itemstack)
                end
            end
            -- initialize module
            if self.module then self.module.initialize(self)
            else
                self.object:setvelocity{x = 0, y = 0, z = 0}
                self.object:setacceleration{x = 0, y = -10, z = 0}
            end
        end,

        on_step = function(self, dtime)
            if self.module then self.module.on_step(self, dtime) end
        end,

        on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
        end,

        on_rightclick = function(self, clicker)
            local formspec = "size[8,9]"
            .."list[detached:"..self.invname..";"..main_invname..";0,0;4,4;]"
            .."label[5,0;MODULE]"
            .."list[detached:"..self.invname..";"..module_invname..";6,0;1,1;]"
            .."list[current_player;"..main_invname..";0,5;8,1;]"
            .."list[current_player;"..main_invname..";0,6.2;8,3;8]"
            minetest.show_formspec(clicker:get_player_name(), self.invname, formspec)
        end,

        get_staticdata = function(self)
            local inv = _aux.get_maidroid_inventory(self)
            local staticdata = {}
            staticdata.inv = {}
            local module_name = inv:get_list(module_invname)[1]:get_name()
            staticdata.inv.module = module_name or ""
            staticdata.inv.main = {}
            for _, item in ipairs(inv:get_list(main_invname)) do
                local count = item:get_count()
                local itemname = item:get_name()
                if count ~= 0 then
                    local itemdata = { count = count, name = itemname }
                    table.insert(staticdata.inv.main, itemdata)
                end
            end
            return minetest.serialize(staticdata)
        end,
    })

    -- register spawn egg
    minetest.register_craftitem(product_name.."_spawn_egg", {
        description = def.description.." Spawn Egg",
        inventory_image = def.inventory_image,
        stack_max = 1,
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.above ~= nil then
                minetest.add_entity(pointed_thing.above, product_name)
                return itemstack
            end
            return nil
        end
    })
end
