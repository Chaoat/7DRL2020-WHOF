local enemyKinds = {}
local enemyColour = {0.5, 0.5, 1, 1}

enemyKinds["swordsman"]= {
	letter = initiateLetter("S", enemyColour),
	decideAction = function(enemy, target)
		if enemy.formation.order == "disperse" then
			enemy.stance = "chase"
		else
			enemy.stance = "formation"
		end
	end,
	lance = false,
	sword = true
}
enemyKinds["lancer"]= {
	letter = initiateLetter("L", enemyColour),
	decideAction = function(enemy, target)
		if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y) <= 4 then
			enemy.stance = "hold"
		else
			if enemy.formation.order == "disperse" then
				enemy.stance = "chase"
			else
				enemy.stance = "formation"
			end
		end
	end,
	lance = true
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
			if enemy.formation.order == "disperse" then
				enemy.stance = "chase"
			else
				enemy.stance = "formation"
			end
		end
	end,
	lance = false,
	bow = {shootRange = 9, reloadTime = 3},
	fleeRange = 4
}
enemyKinds["messenger"]= {
	letter = initiateLetter("M", enemyColour),
	decideAction = function(enemy, target)
		if enemy.formation.order == "disperse" then
			enemy.stance = "chase"
		else
			enemy.stance = "formation"
		end
	end,
	lance = false
}


function initiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, side = "enemy", kind = kind, stance = "hold", active = false, formation = nil, decideAction = enemyKind.decideAction, sword = enemyKind.sword, bow = enemyKind.bow, fleeRange = enemyKind.fleeRange, formationX = 0, formationY = 0, formationFacing = 0}
	enemy.character = activateCharacter(initiateCharacter(map, x, y, copyLetter(enemyKind.letter), enemy))
	
	if enemy.bow then
		enemy.reloading = 0
		enemy.firing = false
	end
	
	if enemyKind.lance then
		initiateLance(map, enemy.character, enemyKind.letter.colour)
	end
	
	table.insert(map.enemies, enemy)
	
	return enemy
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

local enemyFollowFormation = function(enemy)
	if distanceBetweenAngles(enemy.formationFacing, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	elseif enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
		--print("Moving To: [" .. enemy.formationX .. ":" .. enemy.formationY .. "]")
		enemyMoveToPos(enemy, enemy.formationX, enemy.formationY)
	end
end

function enemyAct(enemy, player)
	if enemy.firing then
		fireArrow(enemy.character, enemy.targetX, enemy.targetY)
		enemy.firingdecal.remove = true
		enemy.firing = false
		enemy.reloading = enemy.bow.reloadTime
	elseif not enemy.character.swording then
		if enemy.stance == "chase" then
			enemyChase(enemy, player)
		elseif enemy.stance == "formation" then
			enemyFollowFormation(enemy)
		elseif enemy.stance == "hold" then
			enemyRotateToPoint(enemy, player.character.tile.x, player.character.tile.y)
		elseif enemy.stance == "flee" then
			enemyFlee(enemy, player)
		end
	end
end

function determineEnemyAttack(enemies, player, possiblePlayerTiles)
	for i = 1, #enemies do
		local enemy = enemies[i]
		
		if enemy.sword then
			if enemy.character.swording then
				if not checkSlashConnections({enemy.character}) then
					characterSlash(enemy.character, nil)
				end
			else
				if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y) == 1 then
					characterStartSlashing(enemy.character)
				end
			end
		end
		if enemy.stance == "shooting" then
			if enemy.reloading <= 0 and not enemy.firing then
				if #possiblePlayerTiles > 0 then
					enemy.targetX = possiblePlayerTiles[1].x
					enemy.targetY = possiblePlayerTiles[1].y
					local decal = initiateDecal(enemy.character.map, possiblePlayerTiles[1].x, possiblePlayerTiles[1].y, "square")
					
					decal.colour = {1, 1, 0, 0.8}
					decal.flashing = 0.1
					
					enemy.firingdecal = decal
					enemy.firing = true
					
					table.remove(possiblePlayerTiles, 1)
				end
			else
				enemy.reloading = enemy.reloading - 1
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
			enemy.character.dead = true
			table.remove(enemies, i)
		else
			i = i + 1
		end
	end
end