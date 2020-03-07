--Starts a new round now that the player has chosen their input
function startRound(player, map, curRound)
	--print("starting new round")
	removeEnemyDecals(map.enemies)
	removePlayerDecals(player)
	local roundLength = getRoundLength(player, map)

	curRound = resetRound(player, map, roundLength, curRound)
	
	return round
end

function resolveAIRound(player, map)
	for i = 1, #map.formations do
		determineFormationAction(map, player, map.formations[i])
	end
	
	for i = 1, #map.enemies do
		resolveAITurn(map.enemies[i], player)
	end
	updateCharacterPositions(map.activeCharacters)
end

function resolveTurn(player, map, curTurn)
	--shift the player
	
	if curTurn <= player.rounds then
		local xDir, yDir = getRelativeGridPositionFromAngle(player.character.facing)
		movePlayer(player, xDir, yDir)
	end
	for i = 1, #map.enemies do
		local enemy = map.enemies[i]
		if enemy.speed then
			if curTurn <= enemy.rounds then
				local xDir, yDir = getRelativeGridPositionFromAngle(enemy.character.facing)
				enemyGallopSound(orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y))
				shiftCharacter(enemy.character, xDir, yDir)
			end
		end
	end
	
	--TODO shift all horseman AI
	updateCharacterPositions(map.activeCharacters)
end

--resolve all the infintry
function resolveAITurn(enemy, player)
	if not enemy.dead then
		enemy.decideAction(enemy, player)
		enemyAct(enemy, player)
	end
end

function getRoundLength(player, map)
	local roundLength = player.speed
	
	player.rounds = player.speed
	for i = 1, #map.enemies do
		local enemy = map.enemies[i]
		if enemy.speed then
			enemy.rounds = enemy.speed
			roundLength = math.max(roundLength, enemy.speed)
		end
	end
	
	--TODO get enemy horseman speed
	return roundLength
end