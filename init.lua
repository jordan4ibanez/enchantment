--table length thing
function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
--if in table thing
function intable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end
	

--current goal, give a pickaxe a random table of enchantments - 

--for the cherry pick enchantment, do an on_dignode function for all players, then check for the enchantment, drop the item that was mined using player:dig_node

--do multiple levels for these

--make the thing slowly raise the tool with a sound, make a noise with particles and throw the tool at the player

--possibly a max level enchant? maybe?

--damage group enchant?

enchant = {}

enchant.enchantments_pick = {
"speed", --speed (check a .after thing to tell how fast you'll dig it.) 
"durable", --resistance or infinity - 1 is resistance 2 is infinity
"luck", --get multiple items
"cherry pick", --similar to silk touch in MC
}
enchant.pick = {
"default:pick_bronze",
"default:pick_diamond",
"default:pick_mese",
"default:pick_steel",
"default:pick_stone",
"default:pick_wood",
}

--since tools can't be modified on the fly, I have to do this. 384 tools from 6. GREAT.
--pickaxe enchantments
for x = 1,tablelength(enchant.pick) do
	print(enchant.pick[x])
	--try to do this some other, maybe
	for a = 0,1 do --speed
	for b = 0,1 do --durable
	for c = 0,1 do --luck
	for d = 0,1 do --cherry pick
	if a.."_"..b.."_"..c.."_"..d ~= "0_0_0_0" then -- no enchantments, then don't duplicate the tool

		--name the tool, and define it
		local tool = enchant.pick[x]
		local name = minetest.registered_items[enchant.pick[x]]["description"]
		if a == 1 then
			name = name.."\n-Speed"
		end
		if b == 1 then
			name = name.."\n-Durable"
		end
		if c == 1 then
			name = name.."\n-Luck"
		end
		if d == 1 then
			name = name.."\n-Cherry Pick"
		end
		print(tool.."_"..a.."_"..b.."_"..c.."_"..d)
		--add the enchant to the tools - don't add to the logic above to improve readability
		--global because of bugs with registered tools or something

		local table = {}
		local uses = 0
		local maxlevel = 0
		--if enchanted with speed, half time, if not, use standard tool time.
		if a == 1 then
			for i = 1,3 do
				if  minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"][i] then
					table[i] = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"][i]/2
				end
			end
		else
			table = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"]
		end
		--if enchanted with durable, double the uses, if not, use standard uses.
		if b == 1 then
			uses = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["uses"] * 2
		else
			uses = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["uses"]
		end
		--possibly turn this into enchant
		maxlevel = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["maxlevel"]

		minetest.register_tool(":"..tool.."_"..a.."_"..b.."_"..c.."_"..d, {
			description = name,
			inventory_image = minetest.registered_items[enchant.pick[x]]["inventory_image"],
			groups = {not_in_creative_inventory=1,enchanted_pick=1,luck=c,cherry_pick=d}, --don't clutter the inventory
			tool_capabilities = {
				--full_punch_interval = 1.3,
				--max_drop_level=0,
				groupcaps={
					cracky = {times=table, uses=uses, maxlevel=maxlevel},
				},
				damage_groups = {fleshy=3},
			},
		})
	end
	end
	end
	end
	end	
end












minetest.register_node("enchant:enchantbox", {
	description = "Cactus",
	tiles = {"default_cactus_top.png", "default_stone.png"},
	paramtype2 = "facedir",
	is_ground_content = true,
	groups = {snappy=1,choppy=3,flammable=2},
	on_place = minetest.rotate_node,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local meta = itemstack:get_metadata()
		--only enchant unenchanted tools
		if intable(enchant.pick, name) ~= false and meta == "" then 
			--set up a random amount of perks, with random perks, in a random order, random.
			local enc_tab = {}
			local counter = 1
			for i = 1,math.random(1,tablelength(enchant.enchantments_pick)) do
				local perk = enchant.enchantments_pick[math.random(1,tablelength(enchant.enchantments_pick))]
				if intable(enc_tab, perk) == false then
					enc_tab[counter] = perk
					counter = counter + 1
				end
			end
			local tool = itemstack:get_name()
			local a, b, c, d = 0,0,0,0
			if intable(enc_tab, enchant.enchantments_pick[1]) then --speed
				a = 1 
			end
			if intable(enc_tab, enchant.enchantments_pick[2]) then --durable
				b = 1 
			end
			if intable(enc_tab, enchant.enchantments_pick[3]) then --luck
				c = 1 
			end
			if intable(enc_tab, enchant.enchantments_pick[4]) then --cherry pick
				d = 1 
			end
			if a.."_"..b.."_"..c.."_"..d ~= "0_0_0_0" then -- no enchantments, then don't put out a normal tool
				local name = itemstack:get_name()
				itemstack:take_item()--set_name(tool.."_"..a.."_"..b.."_"..c.."_"..d)
				local pos = pointed_thing.under
				pos.y = pos.y + 0.7
				--local item = minetest.add_item(pos, tool.."_"..a.."_"..b.."_"..c.."_"..d)
				local item = minetest.add_item(pos,name)
				if item == nil then
					print(tool.."_"..a.."_"..b.."_"..c.."_"..d)
					print("BUG!")
					return
				end 
				local item = item:get_luaentity().object
				item:setvelocity({x = 0, y = 0.1, z = 0})
				item:setacceleration({x = 0, y = 0, z = 0})
				item:set_properties({automatic_rotate = 0}) --or do 10
				local sound = minetest.sound_play("build", {
					pos = pos,
					max_hear_distance = 20,
					gain = 1,
				})
				minetest.add_particlespawner({
					amount = 100,
					time = 13,
					minpos = {x=pos.x-0.5, y=pos.y-0.1, z=pos.z-0.5},
					maxpos = {x=pos.x+0.5, y=pos.y-0.1, z=pos.z+0.5},
					minvel = {x=0, y=0, z=0},
					maxvel = {x=0, y=0, z=0},
					minacc = {x=0, y=0.1, z=0},
					maxacc = {x=0, y=1, z=0},
					minexptime = 1,
					maxexptime = 2,
					minsize = 1,
					maxsize = 1,
					collisiondetection = false,
					vertical = false,
					texture = "bubble.png",
				})
				minetest.after(13, function()
					--don't do anything if the player cancelled the event
					if item:get_luaentity() == nil then
						return
					end
					minetest.sound_stop(sound)
					minetest.sound_play("enchant", {
						pos = pos,
						max_hear_distance = 20,
						gain = 1,
					})
					minetest.add_particlespawner({
						amount = 100,
						time = 0.1,
						minpos = item:getpos(),
						maxpos = item:getpos(),
						minvel = {x=-1, y=-1, z=-1},
						maxvel = {x=1, y=1, z=1},
						minacc = {x=0, y=0, z=0},
						maxacc = {x=0, y=0, z=0},
						minexptime = 1,
						maxexptime = 2,
						minsize = 1,
						maxsize = 1,
						collisiondetection = false,
						vertical = false,
						texture = "bubble.png",
					})
					--make it so you cannot get the enchantment before it's done with the cinematic
					local newpos = item:getpos()
					local newpos2= clicker:getpos()
					item:remove()
					local item = minetest.add_item(newpos, tool.."_"..a.."_"..b.."_"..c.."_"..d)
					item:setvelocity({x=newpos2.x-newpos.x,y=(newpos2.y-newpos.y)+6,z=newpos2.z-newpos.z})
					item:setacceleration({x = 0, y = -10, z = 0})
				end)



				return(itemstack)
			else
				print("very unlucky motherfucker")
			end
		end
		-- then do the enchantments for other tools

		--now let's make it do some enchanted actions!
		--local meta_table = minetest.deserialize(itemstack:get_metadata()) 
		--for i = 1,tablelength(meta_table) do --do all the enchantment actions -----    This should probably be some kind of function!    ------ 
		--	if meta_table[i] == "speed" then
		--		print("this item has speed")
		--	end
		--end

		--return(itemstack)
	end,
})


--do some enchantments

--the on_dig enchantments --
minetest.register_on_dignode(function(pos, oldnode, digger)
	local inv = digger:get_inventory()
	local itemstack = digger:get_wielded_item()
	local name = itemstack:get_name()
	if minetest.get_item_group(name, "enchanted_pick") == 1 then
		--this player just dug with an enchanted pickaxe
		if minetest.get_item_group(name, "luck") == 1 and minetest.get_item_group(name, "cherry_pick") == 0 then
			if math.random() > 0.5 then
				local drop = minetest.registered_nodes[oldnode.name]["drop"]
				if inv:room_for_item("main", drop) == true then
					inv:add_item("main", drop)
				end
			end
		elseif minetest.get_item_group(name, "cherry_pick") == 1 then
			--take out the old drop and replace it with the node itself
			inv:remove_item("main", minetest.registered_nodes[oldnode.name]["drop"])
			inv:add_item("main", oldnode.name)
			--add luck to this
			if minetest.get_item_group(name, "luck") == 1 then
				if math.random() > 0.5 then
					local drop = oldnode.name
					if inv:room_for_item("main", drop) == true then
						inv:add_item("main", drop)
					end
				end			
			end
		end
			

	end
	--local meta = itemstack:get_metadata()
	
	--itemstack:take_item()
	--digger:set_wielded_item(itemstack)
	--itemstack:set_stack(itemstack)
end)





