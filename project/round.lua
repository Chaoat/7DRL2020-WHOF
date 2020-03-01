--Starts a new round now that the player has chosen their input
function startRound(player, dirX, dirY, camera)
	local roundLength = getRoundLength(player)

	aiInput()

	resolveRound(player, roundLength, dirX, dirY, camera)
end

--The AI select their actions for the turn
function aiInput()
	--TODO
end

function resolveRound(player, roundLength, dirX, dirY, camera)
	for i=1,roundLength do
		resolveTurn()
	end

	resolveAITurn()
end

function resolveTurn()
	--TODO
end

function resolveAITurn()

end

function getRoundLength(player)
	--TODO get enemy horseman speed
	return 1
end