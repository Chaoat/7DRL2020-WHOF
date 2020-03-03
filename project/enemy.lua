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
	lance = false
}
enemyKinds["lancer"]= {
	letter = initiateLetter("L", enemyColour),
	decideAction = function(enemy, target)
		if enemy.formation.order == "disperse" then
			enemy.stance = "chase"
		else
			enemy.stance = "formation"
		end
	end,
	lance = true
}
enemyKinds["bowman"]= {
	letter = initiateLetter("B", enemyColour),
	decideAction = function(enemy, target)
		if enemy.formation.order == "disperse" then
			enemy.stance = "chase"
		else
			enemy.stance = "formation"
		end
	end,
	lance = false
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
	
	local enemy = {character = nil, side = "enemy", kind = kind, stance = "hold", active = false, formation = nil, decideAction = enemyKind.decideAction, formationX = 0, formationY = 0, formationFacing = 0}
	enemy.character = activateCharacter(initiateCharacter(map, x, y, copyLetter(enemyKind.letter), enemy))
	
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
		
		local walkable = tile.properties.walkable
		if walkable then
			if tile.character then
				if tile.character.side == "enemy" then
					if not checkEnemyMoving(tile.character.master) then
						walkable = false
					end
				end
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


local enemyRotateThenMoveToPoint = function(enemy, x, y)
	local angleToTarget = cardinalRound(math.atan2(y - enemy.character.tile.y, x - enemy.character.tile.x))
	if distanceBetweenAngles(angleToTarget, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, angleToTarget)
	elseif x ~= enemy.character.tile.x or y ~= enemy.character.tile.y then
		enemyMoveToPos(enemy, x, y)
	end
end

local enemyChase = function(enemy, target)
	enemyRotateThenMoveToPoint(enemy, target.character.tile.x, target.character.tile.y)
end

local enemyFollowFormation = function(enemy)
	if distanceBetweenAngles(enemy.formationFacing, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	elseif enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
		print("Moving To: [" .. enemy.formationX .. ":" .. enemy.formationY .. "]")
		enemyMoveToPos(enemy, enemy.formationX, enemy.formationY)
	end
end

function enemyAct(enemy, player)
	if enemy.stance == "chase" then
		enemyChase(enemy, player)
	elseif enemy.stance == "formation" then
		enemyFollowFormation(enemy)
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