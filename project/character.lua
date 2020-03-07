local charID = 0

--creates a character
function initiateCharacter(map, x, y, letter, master)
	local tile = getMapTile(map, x, y)
	local side = nil
	if master then
		side = master.side
	end
	local character = {id = charID, x = x, y = y, facing = 0, tile = tile, letter = letter, map = map, approachingTile = tile, moving = false, lance = nil, side = side, master = master, active = false, blockedBy = nil, forceMove = false, swording = false, bleeds = true}
	--x and tile.x can be unequal, same with y. character.x determines draw pos, can be used for animation
	
	charID = charID + 1
	
	tile.character = character
	table.insert(map.characters, character)
	return character
end

function updateActiveCharacters(charList, dt)
	local i = 1
	while i <= #charList do
		local speed = 20
		local character = charList[i]
		
		local xMoveDiff = character.tile.x - character.x
		local yMoveDiff = character.tile.y - character.y
		
		character.x = character.x + speed*xMoveDiff*dt
		character.y = character.y + speed*yMoveDiff*dt
		
		if character.active == false then
			table.remove(charList, i)
		else
			i = i + 1
		end
	end
end

function cleanupDeadCharacters(characters)
	local i = 1
	while i <= #characters do
		local character = characters[i]
		if character.dead then
			if character.bleeds then
				local tileLetter = getMapTile(character.map, character.tile.x, character.tile.y).letter
				tileLetter.letter = "x"
				tileLetter.colour = {1, 0, 0, 1}
			end
			
			removeCharFromTile(character)
			character.tile.waitingForCharacter = false
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

function deactivateCharacter(character)
	character.active = false
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
	
	--print("--")
end

function removeCharFromTile(character)
	character.tile.character = nil
	character.tile.waitingForCharacter = character
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
			if idEncountered[character.id] then
				break
			end
			
			table.insert(blockedList, character)
			idEncountered[character.id] = true
			--print(character.id)
			
			if blockedList[1].id == character.blockedBy.id then
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
		--print(character.id)
		
		character.blockedBy = nil
		if not character.approachingTile.waitingForCharacter or forceNoMove then
			local walkable = checkTileWalkable(character.approachingTile, character)
			
			character.tile.waitingForCharacter = false
			character.moving = false
			if (walkable and not forceNoMove) or character.forceMove then
				placeCharOnTile(character, character.approachingTile)
				character.forceMove = false
			else
				placeCharOnTile(character, character.tile)
				if character.master.speed and not character.approachingTile.character then
					if character.master.speed > 2 then
						damageCharacter(character, (character.master.speed - 2), 0, 0, "collision")
						if character.master.side == "player" then
							love.audio.play("whinny.ogg", "static", false, 1)
						end
					end
					character.master.speed = 0
				end
			end
			
			table.remove(movingCharacters, i)
			moved = true
		else
			character.blockedBy = character.approachingTile.waitingForCharacter
			--initiateParticle(Map, character.approachingTile.x, character.approachingTile.y, 0, 0, 1, "collect")
			--print(character.id .. " is blocked by " .. character.blockedBy.id)
			i = i + 1
		end
		
		if i > #movingCharacters then
			 if not moved then
				forceNoMove = true
				
				for j = 1, #movingCharacters do
					local character = movingCharacters[j]
					if character.moving and not character.forceMove then
						local blockedList = {}
						if checkIfCircularBlockage(character, blockedList) then
							for k = 1, #blockedList do
								blockedList[k].forceMove = true
								--print("WOW IT ACTUALLY HAPPENED")
							end
						end
					end
				end
				
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
		if not checkTileWalkable(targetTile, character) then
			break
		else
			shiftCharacter(character, targetTile.x - character.tile.x, targetTile.y - character.tile.y)
		end
	end
end

--Begin slashing process for a character
function characterStartSlashing(character)
	character.swording = true
	character.letter.shaking = 0.1
end

function checkSlashConnections(characters)
	local characterHit = false
	for i = 1, #characters do
		local character = characters[i]
		local map = character.map
		
		if character.swording then
			local lastTarget = nil
			for j = 1, #map.activeCharacters do
				local targetChar = map.activeCharacters[j]
				
				if targetChar.side ~= character.side and targetChar.bleeds then
					if orthogDistance(character.tile.x, character.tile.y, targetChar.tile.x, targetChar.tile.y) == 1 then
						lastTarget = targetChar
						if targetChar.swording then
							characterSlash(character, targetChar)
							characterHit = true
						end
						break
					end
				end
			end
			
			if lastTarget and not characterHit then
				characterSlash(character, lastTarget)
				characterHit = true
			end
		end
	end
	return characterHit
end

function characterSlash(character, targetCharacter)
	if targetCharacter then
		local angleBetween = math.atan2(targetCharacter.tile.y - character.tile.y, targetCharacter.tile.x - character.tile.x)
		local speed = 2
		if character.master.speed then
			speed = speed + character.master.speed/2
		end
		damageCharacter(targetCharacter, 4, findAngleBetween(character.facing, angleBetween, 0.8), speed, "sworded")
		enemyswordsound()
		
		local shiftX, shiftY = getRelativeGridPositionFromAngle(angleBetween)
		character.x = character.x + shiftX/2
		character.y = character.y + shiftY/2
	end
	
	character.swording = false
	character.letter.shaking = 0
end

--Given a character table and a camera, draw all the characters on the camera
function drawCharacters(characters, camera)
	for i = 1, #characters do
		local character = characters[i]
		drawLetter(character.letter, character.x, character.y, camera)
		
		--local drawX, drawY = getDrawPos(character.x, character.y, camera)
		--love.graphics.setColor(1, 1, 1, 1)
		--love.graphics.print(character.id, drawX, drawY)
	end
end

--Damages the characters master, if it has one
function damageCharacter(character, damage, angle, speed, source)
	if character.side == "enemy" then
		damageEnemy(character.master, damage)
	elseif character.side == "player" then
		damagePlayer(character.master, damage, source)
	end
	
	if character.master then
		if character.master.speed then
			local speedRatio = speed/(speed + character.master.speed)
			speed = (1 - speedRatio)*character.master.speed + speedRatio*speed
			angle = findAngleBetween(character.facing, angle, speedRatio)
		end
		
		if character.bleeds then
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
	
	local blocked = false
	if character.lance then
		blocked = not rotateLanceToPos(character.lance, math.rad(degFacing))
	end
	
	if not blocked then
		character.facing = math.rad(degFacing)
	end
end

--Shifts a character facing 45 deg anticlockwise
function shiftAnticlockwise(character)
	local degFacing = math.deg(character.facing)
	degFacing = degFacing - 45
	if degFacing <= 0 then
		degFacing = degFacing + 360
	end
	
	local blocked = false
	if character.lance then
		blocked = not rotateLanceToPos(character.lance, math.rad(degFacing))
	end
	
	if not blocked then
		character.facing = math.rad(degFacing)
	end
end