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
	if a == 0 and b == 0 and c == 0 and d == 0 then -- no enchantments, then don't duplicate the tool
		break
	end
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
	--add the enchant to the tools - don't add to the logic above to improve readability
	--global because of bugs with registered tools or something
--	capabilities = minetest.registered_tools[enchant.pick[x]]["tool_capabilities"] --this is here twice because of the logic of this stupid thing

	local table = {minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"][1],minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"][2],minetest.registered_tools[enchant.pick[x]]["tool_capabilities"]["groupcaps"]["cracky"]["times"][3]}
	if table[1] then
		table[1] = table[1] / 2
	end
	if table[2] then
		table[2] = table[2] / 2
	end
	if table[3] then
		table[3] = table[3] / 2
	end
	minetest.register_tool(":"..tool.."_"..a.."_"..b.."_"..c.."_"..d, {
		description = name,
		inventory_image = minetest.registered_items[enchant.pick[x]]["inventory_image"],
		tool_capabilities = {
			--full_punch_interval = 1.3,
			--max_drop_level=0,
			groupcaps={
				cracky = {times=table, uses=20, maxlevel=1},
			},
			damage_groups = {fleshy=3},
		},
		})
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
			if a == 0 and b == 0 and c == 0 and d == 0 then -- no enchantments, then don't put out a normal tool
				return
			end
			itemstack:take_item()--set_name(tool.."_"..a.."_"..b.."_"..c.."_"..d)
			local pos = pointed_thing.under
			pos.y = pos.y + 1
			local item = minetest.add_item(pos, tool.."_"..a.."_"..b.."_"..c.."_"..d)
			local item = item:get_luaentity().object
			item:setvelocity({x=math.random(-3,3)*math.random(),y=math.random(5,7)*math.random(),z=math.random(-3,3)*math.random()})

			return(itemstack)
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
--[[
minetest.register_on_dignode(function(pos, oldnode, digger)
	local itemstack = digger:get_wielded_item()
	local name = itemstack:get_name()
	local meta = itemstack:get_metadata()
	itemstack:take_item()
	digger:set_wielded_item(itemstack)
	--itemstack:set_stack(itemstack)
end)
]]--




