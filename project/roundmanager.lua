--Handles the current round and timers between turns
function initiateRound(player, map, maxTurns)
	local curRound = {maxTurns = 1, curTurn = 1, playedInfTurn = false, timerList = {}, turndelay = 0.7, finished = false}
	addTimer(curRound.turndelay, "turnTimer", curRound.timerList)
	round.maxTurns = maxTurns
	return curRound
end

function updateRound(player, map, curRound, dt)
	if updateTimer(dt, "turnTimer", curRound.timerList) or curRound.finished then
		--Play a regular turn
		if curRound.curTurn <= curRound.maxTurns then
			resolveTurn(player, map, curRound.curTurn)
			advanceRound(curRound)
			return
		end
		--Play AI inf turn
		if not playedInfTurn then
			resolveAITurn(player)
		end
		--Round is over
	else
	    --Wait until the timer is done
	end
end

function advanceRound(curRound)
	curRound.curTurn = curRound.curTurn + 1
end