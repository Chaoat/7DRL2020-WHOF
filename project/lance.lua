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

function rotateLanceToPos(lance, targetAngle)
	local character = lance.character
	local tile = getTileFromPoint(character.map, character.tile.x, character.tile.y, targetAngle)
	
	local placeable = checkTileWalkable(tile, character)
	
	if not placeable then
		if tile.character then
			if tile.character.side == character.side then
				placeable = true
			end
		end
	end
	
	if placeable then
		placeLanceOnTile(lance, tile)
		return true
	else
		return false
	end
end

function cleanupDeadLances(lances)
	local i = 1
	while i <= #lances do
		local lance = lances[i]
		if lance.dead then
			removeLanceFromTile(lance)
			table.remove(lances, i)
		else
			i = i + 1
		end
	end
end

function checkLanceCollisions(characters)
	local lanceCollision = false
	for i = 1, #characters do
		local character = characters[i]
		local cTile = character.tile
		
		for j = 1, #cTile.lances do
			local lance = cTile.lances[j]
			local lanceChar = lance.character
			if lanceChar.side ~= character.side then
				local angle = math.atan2(character.tile.y - lanceChar.tile.y, character.tile.x - lanceChar.tile.x) + randBetween(-math.pi/16, math.pi/16)
				local speed = 0
				if lanceChar.master.speed then
					speed = lanceChar.master.speed
					
					lanceChar.master.speed = math.max(speed - 1, 0)
				end
				
				damageCharacter(character, 10, angle, speed + 1, "lanced")
				-- There was a collision
				lanceCollision = true
			end
		end
	end
	-- There wasnt a collision
	return lanceCollision
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
		drawLetter(initiateLetter(letter, character.lance.colour), character.x + xShift, character.y + yShift, camera)
	end
end