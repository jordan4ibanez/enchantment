--[[
Goals:
Make this as physically involved as possible, holding to "magic" mindset, random, unknown outcomes

-use cauldron from the old enchantments mod
-make player have to throw in lapiz from the lapiz mod to activate cauldron
-have the cauldron bubble when activated
-have the cauldron "explode", do a huge thing of particles and explode sound when
player throws in item
-have cauldron enchant single item, throw item at player
-then go back to being deactivated

-make cauldrons bubble
-bubble particles on idle along with a lot of bubble particles when active

Enchantments:
##/ = hardcoded for now, until items are modifyable
##(metadata)
##/luck        = more items per mine
##/furnace     = instant cook items if possible
##/delicate    = get source node if drop is differant than source

(hard defined)
###quickmine   = mine faster
dueler      = faster tool recover time
hard hitter = do more damage to players/entities

]]--

--meta test
minetest.register_craftitem("enchantment:test", {
	description = "Testcraftitem",
	inventory_image = "default_stone.png",
 
	on_use = function(itemstack, user, pointed_thing)
		print(itemstack:to_table().metadata)
		--if itemstack:get_metadata() == "" then
		itemstack:set_metadata("test")
		print("SETTING META")
		--end

		print(dump(itemstack:to_table()))
	end,
})

--max level for enchants, things like quickmine use time/level to calc how much performance increase
--the item has, don't get too crazy with it because it adds (enchant_level_max*item number) more items per item that 
--get enchanted
local enchant_level_max = 3


--do enchantments

--do this to stop items defs from acting strange
local tool_list = minetest.registered_tools
local tool_list_clone = {}
for item in pairs(tool_list) do
	table.insert(tool_list_clone, item)
end

--defs
for _,item in pairs(tool_list_clone) do

	local shovel = string.match(item, "shovel")
	
	local axe    = string.match(item, "axe")
	
	local pick   = string.match(item, "pick")
	
	local enchantment = string.match(item, "enchantment")
	
	--do a seperate thing of enchantments for this
	local sword = string.match(item, "sword")
	
	--if enchantable then create every variation of it that can be made
	if pick or shovel or axe then
		local description = minetest.registered_tools[item].description
		
		
		local wield_image = minetest.registered_tools[item].wield_image
		local inventory_image = minetest.registered_tools[item].inventory_image
		local full_punch_interval = minetest.registered_tools[item].tool_capabilities.full_punch_interval
		local max_drop_level = minetest.registered_tools[item].tool_capabilities.max_drop_level
		
		for quickmine = 0,enchant_level_max do
		for furnace   = 0,1 do
		for luck      = 0,1 do
		for delicate  = 0,1 do -- on or off
		if quickmine+furnace+luck+delicate > 0 then -- stop from duplicating items
		local temp_description = description
		local groupcaps = {}
		
		local groups = {flammable = 2}
		
		--quickmine enchant
		if quickmine >= 0 then
			if quickmine > 0 then
				temp_description = temp_description.."\nQuick Mine "..quickmine
			end
			for g in pairs(minetest.registered_tools[item].tool_capabilities.groupcaps) do
				groupcaps[g] = {}
				--avoid overwriting
				local timer = minetest.registered_tools[item].tool_capabilities.groupcaps[g].times
				local times = {}
				for t,n in pairs(timer) do
					times[t] = n/(quickmine+1)
				end
				
				--other vars, maybe code these into the game as enchantments?
				groupcaps[g].times = times
				
				groupcaps[g].uses = minetest.registered_tools[item].tool_capabilities.groupcaps[g].uses
				groupcaps[g].maxlevel = minetest.registered_tools[item].tool_capabilities.groupcaps[g].maxlevel
			end
		else
			groupcaps = minetest.registered_tools[item].tool_capabilities.groupcaps
		end
		
		--these three will be done on dignode
		--furnace enchant
		if furnace > 0 then
			groups["furnace"] = furnace
			temp_description = temp_description.."\nFurnace"
		end
		
		--luck enchant
		if luck > 0 then
			groups["luck"] = luck
			temp_description = temp_description.."\nLuck"
		end
		
		--delicate enchant
		if delicate > 0 then
			groups["delicate"] = delicate
			temp_description = temp_description.."\nDelicate"
		end
		
		--define the item - thanks to kaeza
		minetest.register_tool("enchantment:"..item:match("^.-:(.*)").."_"..quickmine..furnace..luck..delicate, {
			description = temp_description,
			inventory_image = inventory_image.."^[colorize:#551A8B:120",
			wield_image = wield_image,
			tool_capabilities = {
				full_punch_interval = full_punch_interval,
				max_drop_level=max_drop_level,
				groupcaps=groupcaps,
				damage_groups = {fleshy=2},
			},
			groups = groups,
			sound = {breaks = "default_tool_breaks"},
		})
		
		end
		end
		end
		end
		end
	end
	
end

--luck,furnace,delicate enchantment - make compatible with default and item drop
if minetest.get_modpath("item_drop") then
minetest.register_on_dignode(function(pos, oldnode, digger)
		local item 
		if string.match(digger:get_wielded_item():to_string(), "enchantment") then
			item = digger:get_wielded_item():to_table().name
		else
			return -- don't do anything else if hand
		end
		
		local name = minetest.registered_tools[item].description
		local drop_count = 1
		local drop
		
		local luck = false
		local cook = false
		local delicate = false
		
		--luck enchantment
		if string.match(name, "Luck") then
			luck = true
			drop_count = math.random(1,4)
		end
				
		--Delicate enchantment
		if string.match(name, "Delicate") then
			drop = oldnode.name
			delicate = true
		else
			drop = minetest.get_node_drops(oldnode.name, name)[1]
		end
		
		--furnace enchantment
		if string.match(name, "Furnace") then
			local temper, _ = minetest.get_craft_result({ method = "cooking", width = 1, items = {drop}})
			--if the item can be smelted, smelt
			if temper and temper.item:to_table() then
				temper = temper.item:to_table().name
				
				drop = temper
				cook = true
			end
		end
		
		--add item
		minetest.add_item(pos, drop.." "..drop_count)
	end)
else
	minetest.register_on_dignode(function(pos, oldnode, digger)
		local item 
		print(dump(digger:get_wielded_item():to_string()))
		if digger:get_wielded_item():to_string() ~= "" and string.match(digger:get_wielded_item():to_string(), "enchantment") and not string.match(digger:get_wielded_item():to_string(), "crucible")  then
			item = digger:get_wielded_item():to_table().name
		else
			return -- don't do anything else if hand
		end
		local name = minetest.registered_tools[item].description
		local drop_count = 1
		local drop
		
		local luck = false
		local cook = false
		local delicate = false
		
		
		--luck enchantment
		if string.match(name, "Luck") then
			luck = true
			drop_count = math.random(1,4)
		end
				
		--Delicate enchantment
		if string.match(name, "Delicate") then
			drop = oldnode.name
			delicate = true
		else
			drop = minetest.get_node_drops(oldnode.name, name)[1]
		end
		
		--furnace enchantment
		if string.match(name, "Furnace") then
			local temper, _ = minetest.get_craft_result({ method = "cooking", width = 1, items = {drop}})
			--if the item can be smelted, smelt
			if temper and temper.item:to_table() then
				temper = temper.item:to_table().name
				
				drop = temper
				cook = true
			end
		end
		
		--process it all
		local inv = digger:get_inventory()
		if inv and inv:room_for_item("main", drop.." "..drop_count) then
			inv:add_item("main", drop.." "..drop_count)
			
			--stop players from duplicating items - basic item add override
			if cook == true or delicate == true then
				if drop ~= minetest.get_node_drops(oldnode.name, name)[1] then
					inv:remove_item("main", minetest.get_node_drops(oldnode.name, name)[1])
				end
			end
		else--no room, drop
			minetest.add_item(pos, drop.." "..drop_count)
		end
	end)
end



--generate items when enchanting by doing math.random(0,maxlevel)..math.random(0,maxlevel)......
local enchant_top = {
	name = "default_water_source_animated.png^[colorize:red:120^enchant_table_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	},
}
minetest.register_node("enchantment:crucible", {
	description = "Crucible",

	--Thanks to Gambit and kilbith for this
	tiles = {enchant_top,"enchant_table_bottom.png","enchant_table_side.png","enchant_table_side.png","enchant_table_side.png","enchant_table_side.png",},
	paramtype2 = "facedir",
	is_ground_content = true,
	groups = {snappy=1,choppy=3,flammable=2},
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {type="regular"},
	node_box = {
			type = "fixed",
			fixed = {
			--jukebox core - divide by 16 because 16 pixels
			{-8/16, -8/16, -8/16, 8/16, 7/16, 8/16},
			--top
			{-8/16, 6/16, -8/16, 8/16, 7/16, 8/16},
			--top trim
			{6/16, 7/16, -8/16, 8/16, 8/16, 8/16},
			{-8/16, 7/16, 6/16, 8/16, 8/16, 8/16},
			{-8/16, 7/16, -8/16, -6/16, 8/16, 8/16},
			{-8/16, 7/16, -8/16, 8/16, 8/16, -6/16},
			},
		},
	--on_place = minetest.rotate_node,
	on_construct = function(pos)
		set_particlespawner(pos)
	end,
	on_destruct = function(pos)
		remove_particlespawner(pos)
	end,
})

minetest.register_lbm({
	name = "enchantment:add_bubbles",
	nodenames = {"enchantment:crucible"},
	run_at_every_load = true,
	action = function(pos, node)
		set_particlespawner(pos)
	end,
})

set_particlespawner = function(pos)
	local ps = minetest.add_particlespawner({
		amount = 5,
		time = 0,
		minpos = {x=pos.x-0.35, y=pos.y+0.5, z=pos.z-0.35},
		maxpos = {x=pos.x+0.35, y=pos.y+0.5, z=pos.z+0.35},
		minvel = {x=0, y=0, z=0},
		maxvel = {x=0, y=0, z=0},
		minacc = {x=0, y=0.5, z=0},
		maxacc = {x=0, y=1.5, z=0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 1,
		maxsize = 1,
		collisiondetection = false,
		vertical = false,
		texture = "bubble.png^[colorize:#551A8B:100",
	})
	local meta = minetest.get_meta(pos)
	meta:set_string("spawner", ps)
end

remove_particlespawner = function(pos)
	local meta = minetest.get_meta(pos)
	local ps = meta:get_string("spawner")
	
	if ps then
		minetest.delete_particlespawner(ps)
	end
end
