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
table = {}
function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

