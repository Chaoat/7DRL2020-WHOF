--Starts a new round now that the player has chosen their input
function startRound(player, map)
	removePlayerDecals(player)
	local roundLength = getRoundLength(player)

	aiInput()

	round = initiateRound(player, map, roundLength)
	createPlayerDecals(player)
	return round
end

--The AI select their actions for the turn
function aiInput()
	--TODO
end

function resolveRound(player, map, roundLength)
	for i=1,roundLength do
		resolveTurn(player)
	end

	resolveAITurn()
end

function resolveTurn(player)
	--shift the player
	local xDir, yDir = getRelativeGridPositionFromAngle(player.character.facing)
	movePlayer(player, xDir, yDir)
	--TODO shift all horseman AI
end

function updateRound(player, map, curRound)
	
end

--resolve all the infintry
function resolveAITurn()

end

function getRoundLength(player, map)
	--TODO get enemy horseman speed
	return player.speed
end