--Starts a new round now that the player has chosen their input
function startRound(player, map)
	local roundLength = getRoundLength(player)

	aiInput()

	resolveRound(player, map, roundLength)
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
	print("resolving turn: ")
	print(player.character.facing)
	local xDir, yDir = getRelativeGridPositionFromAngle(0, 0, player.character.facing)
	movePlayer(player, xDir, yDir)
	--TODO shift all horseman AI
end

--resolve all the infintry
function resolveAITurn()

end

function getRoundLength(player, map)
	--TODO get enemy horseman speed
	return player.speed
end