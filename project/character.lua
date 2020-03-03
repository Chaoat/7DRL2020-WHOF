local charID = 0

--creates a character
function initiateCharacter(map, x, y, letter, master)
	local tile = getMapTile(map, x, y)
	local side = nil
	if master then
		side = master.side
	end
	local character = {id = charID, x = x, y = y, facing = 0, tile = tile, letter = letter, map = map, approachingTile = tile, moving = false, lance = nil, side = side, master = master, active = false, blockedBy = nil, forceMove = false}
	--x and tile.x can be unequal, same with y. character.x determines draw pos, can be used for animation
	
	charID = charID + 1
	
	tile.character = character
	table.insert(map.characters, character)
	return character
end

function updateActiveCharacters(charList, dt)
	for i = 1, #charList do
		local speed = 20
		local character = charList[i]
		
		local xMoveDiff = character.tile.x - character.x
		local yMoveDiff = character.tile.y - character.y
		
		character.x = character.x + speed*xMoveDiff*dt
		character.y = character.y + speed*yMoveDiff*dt
	end
end

function cleanupDeadCharacters(characters)
	local i = 1
	while i <= #characters do
		local character = characters[i]
		if character.dead then
			removeCharFromTile(character)
			character.tile.waitingForCheck = false
			if character.lance then
				character.lance.dead = true
			end
			table.remove(characters, i)
		else
			i = i + 1
		end
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
		removeLanceFromTile(character.lance)
	end
end

function placeCharOnTile(character, tile)
	character.tile = tile
	tile.character = character
	if character.lance then
		local lanceTile = getTileFromPoint(character.map, tile.x, tile.y, character.facing)
		placeLanceOnTile(character.lance, lanceTile)
	end
end

function updateCharacterPositions(characterList)
	local checkIfCircularBlockage = function(character, blockedList)
		local idEncountered = {}
		while character.blockedBy do
			table.insert(blockedList, character)
			idEncountered[character.id] = true
			print(character.id)
			
			if idEncountered[character.blockedBy.id] then
				return true
			else
				character = character.blockedBy
			end
		end
		return false
	end
	
	local movingCharacters = {}
	for i = 1, #characterList do
		local character = characterList[i]
		if character.moving then
			table.insert(movingCharacters, character)
		end
	end
	
	--print("b")
	local i = 1
	local moved = false
	local forceNoMove = false
	while #movingCharacters > 0 do
		local character = movingCharacters[i]
		
		if not character.approachingTile.waitingForCheck or forceNoMove then
			local walkable = checkTileWalkable(character.approachingTile)
			
			character.tile.waitingForCheck = false
			character.moving = false
			if walkable or character.forceMove then
				placeCharOnTile(character, character.approachingTile)
				character.forceMove = false
			else
				placeCharOnTile(character, character.tile)
			end
			
			table.remove(movingCharacters, i)
			moved = true
		else
			character.blockedBy = character.approachingTile.character
			i = i + 1
		end
		
		if i > #movingCharacters then
			 if not moved then
				forceNoMove = true
				
				--for j = 1, #movingCharacters do
				--	local character = movingCharacters[j]
				--	if character.moving and not character.forceMove then
				--		local blockedList = {}
				--		if checkIfCircularBlockage(character, blockedList) then
				--			for k = 1, #blockedList do
				--				blockedList[k].forceMove = true
				--				print("WOW IT ACTUALLY HAPPENED")
				--			end
				--		end
				--	end
				--end
				
				print("Fix Move Stalemate")
			 end
			 
			 i = 1
			 moved = false
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

--Damages the characters master, if it has one
function damageCharacter(character, damage, angle, speed)
	if character.side == "enemy" then
		damageEnemy(character.master, damage)
	end
	
	if character.master then
		if character.master.dead then
			local tileLetter = getMapTile(character.map, character.tile.x, character.tile.y).letter
			tileLetter.letter = "x"
			tileLetter.colour = {1, 0, 0, 1}
			spawnBloodBurst(character.map, character.tile.x + 0.5, character.tile.y + 0.5, 5*speed, angle)
		end
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