local enemyKinds = {}

enemyKinds["swordsman"]= {
	letter = initiateLetter("S", {1, 0, 0, 1}),
	decideAction = function(enemy, target)
		enemy.stance = "formation"
	end,
	lance = false
}

function initiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, kind = kind, stance = "hold", active = false, formation = nil, decideAction = enemyKind.decideAction, formationX = 0, formationY = 0, formationFacing = 0}
	enemy.character = activateCharacter(initiateCharacter(map, x, y, copyLetter(enemyKind.letter), "enemy"))
	
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
		
		if tile.properties.walkable then
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


local enemyChase = function(enemy, target)
	enemyMoveToPos(enemy, target.character.tile.x, target.character.tile.y)
end

local enemyFollowFormation = function(enemy)
	if enemy.formationFacing ~= enemy.character.facing and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	elseif enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
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