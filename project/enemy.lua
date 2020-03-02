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
	local xDir, yDir
	local blocked = true
	
	while blocked do
		
	end
	
	
	shiftCharacter(enemy.character, xDir, yDir)
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
	if enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
		enemyMoveToPos(enemy, enemy.formationX, enemy.formationY)
		print(enemy.formationX)
	elseif enemy.formationFacing ~= enemy.character.facing and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	end
end

function enemyAct(enemy, player)
	if enemy.stance == "chase" then
		enemyChase(enemy, player)
	elseif enemy.stance == "formation" then
		enemyFollowFormation(enemy)
	end
end