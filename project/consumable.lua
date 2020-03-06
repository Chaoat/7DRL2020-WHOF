function initiateConsumable(map, x, y, kind)
	local letter = nil
	if kind == "health" then
		letter = initiateLetter("+", {1, 1, 1, 1}, {1, 1, 1, 0.1})
	elseif kind == "arrows" then
		letter = initiateLetter("=", {100/255, 50/255, 0, 1}, {100/255, 50/255, 0, 0.2})
	end
	
	local consumable = {kind = kind, letter = letter}
	local tile = getMapTile(map, x, y)
	tile.consumable = consumable
end

function collectPickupsInRange(map, x, y, range)
	local consumables = {}
	for i = x - range, x + range do
		for j = y - range, y + range do
			local tile = getMapTile(map, i, j)
			
			if tile.consumable then
				if consumables[tile.consumable.kind] then
					consumables[tile.consumable.kind] = consumables[tile.consumable.kind] + 1
				else
					consumables[tile.consumable.kind] = 1
				end
				initiateParticle(map, i, j, 0, 0, 1, "collect")
				tile.consumable = nil
			end
		end
	end
	
	return consumables
end