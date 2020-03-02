--Handles the current round and timers between turns
function initiateRound(player, map, maxTurns)
	local curRound = {maxTurns = 1, curTurn = 1, playedInfTurn = false, timerList = {}, turndelay = 0.7, finished = false}
	addTimer(curRound.turndelay, "turnTimer", curRound.timerList)
	round.maxTurns = maxTurns
	return curRound
end

function updateRound(player, map, curRound, dt)
	--Only does the update if the animations between turns are done
	if updateTimer(dt, "turnTimer", curRound.timerList) or curRound.finished then
		--Play a regular turn
		if curRound.curTurn <= curRound.maxTurns then
			resolveTurn(player, map, curRound.curTurn)
			advanceRound(curRound)
			resetRoundTime(curRound)
			return
		end
		--Play AI inf turn
		if not curRound.playedInfTurn then
			resolveAIRound(player, map)
			curRound.playedInfTurn = true
			resetRoundTime(curRound)
		--Round is over
		elseif not curRound.finished then
		    curRound.finished = true
		end
	else
	    --Wait until the timer is done
	end
end

function advanceRound(curRound)
	curRound.curTurn = curRound.curTurn + 1
end

function resetRoundTime(curRound)
	resetTimer(curRound.turndelay, "turnTimer", curRound.timerList)
end