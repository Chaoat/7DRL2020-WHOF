--Starts a new round now that the player has chosen their input
function startRound(player, map, curRound)
	--print("starting new round")
	removePlayerDecals(player)
	local roundLength = getRoundLength(player)

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
	local xDir, yDir = getRelativeGridPositionFromAngle(player.character.facing)
	movePlayer(player, xDir, yDir)
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
	--TODO get enemy horseman speed
	return player.speed
end