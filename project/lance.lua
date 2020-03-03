function initiateLance(map, character, colour)
	local tileX = character.x + roundFloat(math.cos(character.facing))
	local tileY = character.y + roundFloat(math.sin(character.facing))
	
	local lance = {character = character, tile = nil, tileI = nil, colour = colour}
	placeLanceOnTile(lance, getMapTile(map, tileX, tileY))
	
	lance.tile.lance = lance
	character.lance = lance
	
	return lance
end

function removeLanceFromTile(lance)
	if lance.tile then
		table.remove(lance.tile.lances, lance.tileI)
		local i = lance.tileI
		while i <= #lance.tile.lances do
			lance.tile.lances[i].tileI = lance.tile.lances[i].tileI - 1
			i = i + 1
		end
		
		lance.tile = nil
		lance.tileI = nil
	end
end

function placeLanceOnTile(lance, tile)
	removeLanceFromTile(lance)
	
	table.insert(tile.lances, lance)
	lance.tileI = #tile.lances
	lance.tile = tile
end

function updateLancePos(lance)
	local character = lance.character
	local tile = getTileFromPoint(character.map, character.tile.x, character.tile.y, character.facing)
	placeLanceOnTile(lance, tile)
end

function drawLances(lances, camera)
	for i = 1, #lances do
		local lance = lances[i]
		local character = lance.character
		local letter = "-"
		if distanceBetweenAngles(character.facing, math.pi/4)%math.pi == 0 then
			letter = "\\"
		elseif distanceBetweenAngles(character.facing, math.pi/2)%math.pi == 0 then
			letter = "|"
		elseif distanceBetweenAngles(character.facing, 3*math.pi/4)%math.pi == 0 then
			letter = "/"
		end
		
		local xShift, yShift = getRelativeGridPositionFromAngle(character.facing)
		drawLetter({letter = letter, colour = character.lance.colour}, character.x + xShift, character.y + yShift, camera)
	end
end