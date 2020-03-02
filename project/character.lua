--creates a character
function initiateCharacter(map, x, y, letter, side)
	local tile = getMapTile(map, x, y)
	local character = {x = x, y = y, facing = 0, tile = tile, letter = letter, map = map, approachingTile = tile, moving = false, lance = nil, side = side, active = false}
	--x and tile.x can be unequal, same with y. character.x determines draw pos, can be used for animation
	
	tile.character = character
	table.insert(map.characters, character)
	return character
end

function updateActiveCharacters(charList, dt)
	for i = 1, #charList do
		local character = charList[i]
		
		local xMoveDiff = character.tile.x - character.x
		local yMoveDiff = character.tile.y - character.y
		
		character.x = character.x + 20*xMoveDiff*dt
		character.y = character.y + 20*yMoveDiff*dt
	end
end

--Activates a character, prepares it for movement
--Permanently stationary characters do not need to be active
function activateCharacter(character)
	character.active = true
	table.insert(character.map.activeCharacters, character)
	return character
end

--Shifts a character one tile in the direction
function shiftCharacter(character, xDir, yDir)
	xDir = xDir/math.max(xDir/math.abs(xDir), 1) --messiness to set magnitude of xDir to 1
	yDir = yDir/math.max(yDir/math.abs(yDir), 1) --same as above
	
	local oldTile = character.tile
	local nextTile = getMapTile(character.map, oldTile.x + xDir, oldTile.y + yDir)
	
	character.approachingTile = nextTile
	character.moving = true
	removeCharFromTile(character)
end

function removeCharFromTile(character)
	character.tile.character = nil
	character.tile.waitingForCheck = true
	if character.lance then
		character.lance.tile.lance = nil
	end
end

function placeCharOnTile(character, tile)
	character.tile = tile
	tile.character = character
	if character.lance then
		local lanceTile = getTileFromPoint(character.map, tile.x, tile.y, character.facing)
		character.lance.tile = lanceTile
		lanceTile.lance = character.lance
	end
end

function updateCharacterPositions(characterList)
	local movingCharacters = {}
	for i = 1, #characterList do
		local character = characterList[i]
		table.insert(movingCharacters, character)
	end
	
	--print("b")
	local i = 1
	local loops = 0
	while #movingCharacters > 0 do
		--print("a")
		local character = movingCharacters[i]
		
		if not character.approachingTile.waitingForCheck then
			local walkable = checkTileWalkable(character.approachingTile)
			
			character.tile.waitingForCheck = false
			character.moving = false
			if walkable then
				placeCharOnTile(character, character.approachingTile)
			else
				placeCharOnTile(character, character.tile)
			end
			
			table.remove(movingCharacters, i)
			loops = 0
		else
			i = i + 1
		end
		
		if i > #movingCharacters then
			 i = 1
			 loops = loops + 1
			 
			 if loops > #movingCharacters then
				break
			 end
		end
	end
end

--Repeatedly shift until character arrives at target position
function multiSlide(character, targetX, targetY)
	while character.tile.x ~= targetX or character.tile.y ~= targetY do
		local targetTile = getTileFromPoint(character.map, character.tile.x, character.tile.y, math.atan2(targetY - character.tile.y, targetX - character.tile.x))
		if not checkTileWalkable(targetTile) then
			break
		else
			shiftCharacter(character, targetTile.x - character.tile.x, targetTile.y - character.tile.y)
		end
	end
end

--Given a character table and a camera, draw all the characters on the camera
function drawCharacters(characters, camera)
	for i = 1, #characters do
		local character = characters[i]
		drawLetter(character.letter, character.x, character.y, camera)
	end
end

--Sets a character facing to degree
function SetFacingDeg(character, angle)
	character.facing = math.rad(angle)
end

--Shifts a character facing 45 deg clockwise
function shiftClockwise(character)
	local degFacing = math.deg(character.facing)
	degFacing = degFacing + 45
	if degFacing >= 360 then
		degFacing = degFacing - 360
	end
	character.facing = math.rad(degFacing)
	
	if character.lance then
		updateLancePos(character.lance)
	end
end

--Shifts a character facing 45 deg anticlockwise
function shiftAnticlockwise(character)
	local degFacing = math.deg(character.facing)
	degFacing = degFacing - 45
	if degFacing <= 0 then
		degFacing = degFacing + 360
	end
	character.facing = math.rad(degFacing)
	
	if character.lance then
		updateLancePos(character.lance)
	end
end