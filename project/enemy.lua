local enemyKinds = {}
local enemyColour = {0.5, 0.5, 1, 1}

enemyKinds["swordsman"]= {
	letter = initiateLetter("S", enemyColour),
	decideAction = function(enemy, target)
		if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y) <= 4 then
			enemy.stance = "chase"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = false,
	sword = true,
	bleeds = true
}
enemyKinds["lancer"]= {
	letter = initiateLetter("L", enemyColour),
	decideAction = function(enemy, target)
		if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y) <= 2 then
			enemy.stance = "hold"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = true,
	bleeds = true
}
enemyKinds["bowman"]= {
	letter = initiateLetter("B", enemyColour),
	decideAction = function(enemy, target)
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y)
		if distance <= enemy.fleeRange then
			enemy.stance = "flee"
		elseif distance <= enemy.bow.shootRange + 2 then
			enemy.stance = "shooting"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = false,
	bow = {shootRange = 9, reloadTime = 3},
	fleeRange = 4,
	bleeds = true
}
enemyKinds["rider"]= {
	letter = initiateLetter("H", enemyColour),
	decideAction = function(enemy, target)
		enemy.stance = "ride"
	end,
	lance = true,
	mounted = true,
	bleeds = true,
	bow = {shootRange = 7, reloadTime = 4},
}
enemyKinds["messenger"]= {
	letter = initiateLetter("M", {1, 0.5, 1, 1}),
	decideAction = function(enemy, target)
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y)
		if distance <= 5 or #enemy.formation.members == 0 then
			enemy.stance = "flee"
		else
			enemy.stance = "formation"
		end
	end,
	lance = false,
	bleeds = true
}
enemyKinds["barrier"]= {
	letter = initiateLetter("#", enemyColour),
	decideAction = function(enemy, target)
		enemy.stance = "hold"
	end,
	lance = false,
	bleeds = false,
	lance = true
}


function initiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, side = "enemy", kind = kind, stance = "hold", active = false, formation = nil, decideAction = enemyKind.decideAction, sword = enemyKind.sword, bow = enemyKind.bow, fleeRange = enemyKind.fleeRange, formationX = 0, formationY = 0, formationFacing = 0}
	enemy.character = initiateCharacter(map, x, y, copyLetter(enemyKind.letter), enemy)
	enemy.character.bleeds = enemyKind.bleeds
	
	if enemy.bow then
		enemy.reloading = 0
		enemy.firing = false
	end
	
	if enemyKind.lance then
		initiateLance(map, enemy.character, enemyKind.letter.colour)
	end
	
	if enemyKind.mounted then
		enemy.speed = 0
		enemy.maxSpeed = 5
		enemy.moveDecals = {}
	end
	
	table.insert(map.inactiveEnemies, enemy)
	
	return enemy
end

function activateEnemy(enemy)
	local decal = initiateDecal(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y - 0.5, "exclamation")
	local timeLeft = math.random()
	decal.timeLeft = timeLeft
	decal.colour = {1, 1, 0, 1}
	decal.fade = 1/timeLeft
	decal.yspeed = -3
	
	enemy.active = true
	table.insert(enemy.character.map.enemies, enemy)
	activateCharacter(enemy.character)
end

function deactivateEnemy(enemy)
	if not enemy.speed then
		enemy.active = false
		deactivateCharacter(enemy.character)
	end
end

local enemyMoveToPos = function(enemy, x, y)
	local angleToTarget = angleBetweenVectors(enemy.character.tile.x, enemy.character.tile.y, x, y)
	local blocked = true
	
	local xDir, yDir
	local map = enemy.character.map
	local i = 0
	while blocked do
		local side = 1
		if i%2 == 0 then
			side = -1
		end
		
		local angle = angleToTarget + side*math.ceil(i/2)*(math.pi/4)
		local tile = getTileFromPoint(map, enemy.character.tile.x, enemy.character.tile.y, angle)
		
		local walkable = checkTileWalkable(tile, enemy.character)
		local tileCharacter = tile.waitingForCharacter
		if not tileCharacter then
			tileCharacter = tile.character
		end
		
		if not walkable and tileCharacter then
			if tileCharacter.side == "player" then
				walkable = false
			elseif checkEnemyMoving(tileCharacter.master) then
				walkable = true
			end
		end
		
		if walkable then
			blocked = false
			xDir, yDir = getRelativeGridPositionFromAngle(angle)
		else
			i = i + 1
			if i >= 8 then
				break
			end
		end
	end
	
	if not blocked then
		shiftCharacter(enemy.character, xDir, yDir)
	end
end

local enemyRotate = function(enemy, targetFacing)
	local rotateDir = findAngleDirection(enemy.character.facing, targetFacing)
	if rotateDir > 0 then
		shiftClockwise(enemy.character)
	elseif rotateDir < 0 then
		shiftAnticlockwise(enemy.character)
	end
end


local enemyRotateToPoint = function(enemy, x, y)
	local angleToTarget = cardinalRound(math.atan2(y - enemy.character.tile.y, x - enemy.character.tile.x))
	if distanceBetweenAngles(angleToTarget, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, angleToTarget)
		return true
	end
	return false
end

local enemyRotateThenMoveToPoint = function(enemy, x, y)
	if not enemyRotateToPoint(enemy, x, y) and x ~= enemy.character.tile.x or y ~= enemy.character.tile.y then
		enemyMoveToPos(enemy, x, y)
	end
end

local enemyFlee = function(enemy, target)
	local angleAway = math.atan2(enemy.character.tile.y - target.character.tile.y, enemy.character.tile.x - target.character.tile.x)
	local awayX, awayY = getRelativeGridPositionFromAngle(angleAway)
	enemyMoveToPos(enemy, enemy.character.tile.x + awayX, enemy.character.tile.y + awayY)
end

local enemyChase = function(enemy, target)
	enemyRotateThenMoveToPoint(enemy, target.character.tile.x, target.character.tile.y)
end

local enemyHold = function(enemy, target)
	if enemy.character.lance then
		local playerTiles = getTilesFromPoint(target.character.map, target.character.tile.x, target.character.tile.y, target.character.facing, 3*target.speed)
		for i = 1, #playerTiles do
			local tile = playerTiles[i]
			
			if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, tile.x, tile.y) <= 1 then
				enemyRotateToPoint(enemy, tile.x, tile.y)
				return
			end
		end
		enemyRotateToPoint(enemy, target.character.tile.x, target.character.tile.y)
	end
end

local enemyFollowFormation = function(enemy)
	if distanceBetweenAngles(enemy.formationFacing, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	elseif enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
		--print("Moving To: [" .. enemy.formationX .. ":" .. enemy.formationY .. "]")
		enemyMoveToPos(enemy, enemy.formationX, enemy.formationY)
	end
end

local enemyRide = function(enemy, player)
	local character = enemy.character
	--AvoidObstacles
	local rotation = 0
	local acceleration = 0
	
	local blocked = false
	if enemy.speed > 0 then
		blocked = true
		local i = 1
		while blocked and i <= 3 do
			local checkingRotation = 0
			if i == 2 then
				checkingRotation = math.pi/4
			elseif i == 3 then
				checkingRotation = -math.pi/4
			end
			
			local tilesInPath = getTilesFromPoint(character.map, enemy.character.tile.x, character.tile.y, character.facing + checkingRotation, math.ceil(2*enemy.speed))
			
			for j = 2, #tilesInPath do
				local tile = tilesInPath[j]
				if checkTileWalkable(tile, character) then
					if j == #tilesInPath then
						blocked = false
						rotation = checkingRotation
					end
				else
					break
				end
			end
			
			i = i + 1
		end
	else
		local targetX = player.character.tile.x
		local targetY = player.character.tile.y
		
		local angleToTarget = math.atan2(targetY - character.tile.y, targetX - character.tile.x)
		character.facing = cardinalRound(angleToTarget)
	end
	
	local targetX = player.character.tile.x
	local targetY = player.character.tile.y
	local dist = orthogDistance(targetX, targetY, character.tile.x, character.tile.y)
	if not blocked then
		if dist <= enemy.bow.shootRange then
			enemy.stance = "shooting"
		else
			local angleToTarget = math.atan2(targetY - character.tile.y, targetX - character.tile.x)
			--if angleToTarget == nil then
			--	error()
			--end
			
			local angleDist = distanceBetweenAngles(angleToTarget, character.facing)
			
			if angleDist <= math.pi/8 then
				acceleration = 1
			else
				local proposedRotation = 0
				if findAngleDirection(character.facing, angleToTarget) > 0 then
					proposedRotation = math.pi/4
				else
					proposedRotation = -math.pi/4
				end
				
				local tilesInPath = getTilesFromPoint(character.map, enemy.character.tile.x, character.tile.y, character.facing + proposedRotation, math.ceil(1.5*enemy.speed))
				
				for j = 2, #tilesInPath do
					local tile = tilesInPath[j]
					if checkTileWalkable(tile, character) then
						if j == #tilesInPath then
							rotation = proposedRotation
						end
					else
						break
					end
				end
				
				if angleDist >= math.pi/2 then
					acceleration = -1
				end
			end
		end
	end
	
	modifySpeed(enemy, acceleration)
	if rotation > 0 then
		shiftClockwise(character)
	elseif rotation < 0 then
		shiftAnticlockwise(character)
	end
end

function enemyAct(enemy, player)
	if enemy.firing then
		fireArrow(enemy.character, enemy.targetX, enemy.targetY)
		enemy.firingdecal.remove = true
		enemy.firing = false
		enemy.character.letter.shaking = 0
		enemy.reloading = enemy.bow.reloadTime
	elseif not enemy.character.swording then
		if enemy.stance == "chase" then
			enemyChase(enemy, player)
		elseif enemy.stance == "formation" then
			enemyFollowFormation(enemy)
		elseif enemy.stance == "hold" then
			enemyHold(enemy, player)
		elseif enemy.stance == "flee" then
			enemyFlee(enemy, player)
		elseif enemy.stance == "ride" then
			enemyRide(enemy, player)
		end
	end
	
	if enemy.cavCount then
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y)
		
		if distance >= 2*enemy.formation.triggerDistance then
			for i = 1, enemy.cavCount do
				local spawnTile = findFreeTileFromPoint(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y, 3)
				activateEnemy(initiateEnemy(enemy.character.map, spawnTile.x, spawnTile.y, "rider"))
			end
			enemy.cavCount = nil
			detachMessenger(enemy.formation)
		end
	end
end

function determineEnemyAttack(enemies, player, possiblePlayerTiles, curRound)
	for i = 1, #enemies do
		local enemy = enemies[i]
		
		if enemy.sword then
			if enemy.character.swording then
				if not checkSlashConnections({enemy.character}) then
					characterSlash(enemy.character, nil)
				else
					curRound.addedturndelay = 0.3
				end
			else
				if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y) == 1 then
					characterStartSlashing(enemy.character)
				end
			end
		end
		
		if enemy.bow then
			if enemy.reloading > 0 then
				enemy.reloading = enemy.reloading - 1
			end
		end
		
		if enemy.stance == "shooting" then
			if enemy.reloading <= 0 and not enemy.firing then
				if #possiblePlayerTiles > 0 then
					enemy.targetX = possiblePlayerTiles[1].x
					enemy.targetY = possiblePlayerTiles[1].y
					local decal = initiateDecal(enemy.character.map, possiblePlayerTiles[1].x, possiblePlayerTiles[1].y, "bullseye")
					
					decal.colour = {1, 0, 0, 0.8}
					decal.flashing = 0.1
					
					enemy.firingdecal = decal
					enemy.firing = true
					enemy.character.letter.shaking = 0.1
					
					table.remove(possiblePlayerTiles, 1)
				end
			end
		end
	end
end

function checkEnemyMoving(enemy)
	if enemy.stance == "chase" then
		return false
	end
	
	if enemy.character.lance then
		if enemy.formationFacing ~= enemy.character.facing and enemy.stance == "formation" then
			return false
		end
	end
	
	if enemy.stance == "formation" then
		--print(enemy.character.id .. "= " .. enemy.formationX .. ":" .. enemy.character.tile.x .. " , " .. enemy.formationY .. ":" .. enemy.character.tile.y)
		if enemy.formationX == enemy.character.tile.x and enemy.formationY == enemy.character.tile.y then
			return false
		end
	end
	
	return true
end

function damageEnemy(enemy, damage)
	enemy.dead = true
end

function cleanupDeadEnemies(enemies)
	local i = 1
	while i <= #enemies do
		local enemy = enemies[i]
		if enemy.dead then
			if enemy.firingdecal then
				enemy.firingdecal.remove = true
			end
			enemy.character.dead = true
			table.remove(enemies, i)
		elseif enemy.active == false then
			if enemy.firingdecal then
				enemy.firingdecal.remove = true
			end
			table.remove(enemies, i)
		else
			i = i + 1
		end
	end
end

function removeEnemyDecals(enemies)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy.speed then
			for j = 1, #enemy.moveDecals do
				local moveDecal = enemy.moveDecals[j]
				moveDecal.remove = true
			end
		end
	end
end

function createEnemyDecals(enemies)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy.speed then
			local pathTiles = getTilesFromPoint(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y, enemy.character.facing, enemy.speed)
			for j = 2, #pathTiles do
				local pathTile = pathTiles[j]
				local arrow = createArrowDecal(enemy.character.map, pathTile.x, pathTile.y, enemy.character.facing)
				arrow.colour = {0.5, 0.5, 1, 0.5}
				arrow.flashing = 0.3
				table.insert(enemy.moveDecals, arrow)
			end
		end
	end
end