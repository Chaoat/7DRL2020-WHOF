--creates a character
function innitiateCharacter(map, x, y, letter)
	local tile = getMapTile(map, x, y)
	local character = {x = x, y = y, facing = 0, tile = tile, letter = letter, map = map, active = false}
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
	
	if checkTileWalkable(nextTile) then
		oldTile.character = nil
		nextTile.character = character
		character.tile = nextTile
	end
end

--Given a character table and a camera, draw all the characters on the camera
function drawCharacters(characters, camera)
	for i = 1, #characters do
		local character = characters[i]
		drawLetter(character.letter, character.x, character.y, camera)
	end
end