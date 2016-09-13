------------------------------------------------------------
-- Copyright (c) 2016 tacigar
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- maidroid.animation_frames represents the animation frame data
-- of "models/maidroid.b3d".
maidroid.animation_frames = {
	STAND     = {x =   0, y =  79},
	SIT       = {x =  81, y = 160},
	LAY       = {x = 162, y = 166},
	WALK      = {x = 168, y = 187},
	MINE      = {x = 189, y = 198},
	WALK_MINE = {x = 200, y = 219},
}

-- maidroid.get_inventory returns a inventory of a maidroid.
function maidroid.get_inventory(self)
	return minetest.get_inventory {
		type = "detached",
		name = self.inventory_name,
	}
end

-- maidroid.register_maidroid registers a definition of a new maidroid.
function maidroid.register_maidroid(product_name, def)

	-- create_inventory creates a new inventory, and returns it.
	function create_inventory(self)
		self.inventory_name = self.product_name .. tostring(self.manufacturing_number)

		local inventory = minetest.create_detached_inventory(self.inventory_name, {
			on_put = function(inv, listname, index, stack, player)

			end,

			allow_put = function(inv, listname, index, stack, player)

			end,

			on_take = function(inv, listname, index, stack, player)

			end,
		})
		inventory:set_size("main", 16)
		inventory:set_size("core",  1)

		return inventory
	end

	-- create_formspec_string returns a string that represents a formspec definition.
	function create_formspec_string(self)
		return "size[8,9]"
			.. "list[detached:"..self.inventory_name..";main;0,0;4,4;]"
			.. "label[5,0;core]"
			.. "list[detached:"..self.inventory_name..";core;6,0;1,1;]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]"
	end

	-- on_activate is a callback function that is called when the object is created or recreated.
	function on_activate(self, staticdata)
		if staticdata == "" then
			self.product_name = product_name
			create_inventory(self)
		else
			-- if static data is not empty string, this object has beed already created.
			local data = minetest.deserialize(staticdata)

			self.product_name = data["product_name"]
			self.manufacturing_number = data["manufacturing_number"]

			local inventory = create_inventory(self)

			if data["inventory"]["module"] ~= "" then

			end

		end

		self.formspec_string = create_formspec_string(self)
	end

	-- get_staticdata is a callback function that is called when the object is destroyed.
	function get_staticdata = function(self)
		local inventory = maidroid.get_inventory(self)
		local data = {
			["product_name"] = self.product_name,
			["manufacturing_number"] = self.manufacturing_number,
			["inventory"] = {
				["main"] = {},
				["core"] = core_name, -- TODO
			},
		}

		for _, item in ipairs(inventory:get_list("main")) do
			local count = item:get_count()
			local itemname = item:get_name()
			if count ~= 0 then
				local itemdata = {count = count, name = itemname}
				table.insert(data["inventory"]["main"], itemdata)
			end
		end
		return minetest.serialize(data)
	end

	-- register a definition of a new maidroid.
	minetest.register_entity(product_name, {
		product_name = "",
		manufacturing_number = -1,

		on_activate = on_activate,
	})
end
