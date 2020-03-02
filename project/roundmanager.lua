--Handles the current round and timers between turns
function initiateRound(player, map, maxTurns)
	local curRound = {maxTurns = 1, curTurn = 1, playedAITurn = false, timerList = {}, turndelay = 0, finished = false}
	addTimer(curRound.turndelay, "turnTimer", curRound.timerList)
	curRound.maxTurns = maxTurns
	return curRound
end

function resetRound(player, map, maxTurns, curRound)
	curRound.curTurn = 1
	curRound.maxTurns = maxTurns
	curRound.playedAITurn = false
	curRound.finished = false
	return curRound
end

function updateRound(player, map, curRound, dt)
	--Only does the update if the animations between turns are done
	if updateTimer(dt, "turnTimer", curRound.timerList) or curRound.finished then
		--Play a regular turn
		if curRound.curTurn <= curRound.maxTurns then
			print("play turn")
			resolveTurn(player, map, curRound.curTurn)
			advanceRound(curRound)
			resetRoundTime(curRound)
			return
		end
		--Play AI inf turn
		if not curRound.playedAITurn then
			print("ai turn")
			resolveAIRound(player, map)
			curRound.playedAITurn = true
			resetRoundTime(curRound)
		--Round is over
		elseif not curRound.finished then
			print("round finished")
		    curRound.finished = true
		    updateCharacterPositions(map.activeCharacters)
			createPlayerDecals(player)
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