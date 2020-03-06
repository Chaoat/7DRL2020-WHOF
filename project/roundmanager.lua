--Handles the current round and timers between turns
function initiateRound(player, map, maxTurns)
	local curRound = {maxTurns = 1, curTurn = 1, playedAITurn = false, timerList = {}, turndelay = 0.01, addedturndelay = 0, finished = false}
	addTimer(curRound.turndelay, "turnTimer", curRound.timerList)
	curRound.maxTurns = maxTurns
	return curRound
end

function resetRound(player, map, maxTurns, curRound)
	curRound.curTurn = 1
	curRound.maxTurns = maxTurns
	curRound.playedAITurn = false
	curRound.finished = false
	curRound.turndelay = 0.01
	return curRound
end

function updateRound(player, map, curRound, dt)
	--Only does the update if the animations between turns are done
	if updateTimer(dt, "turnTimer", curRound.timerList) or curRound.finished then
		--Play a regular turn
		if curRound.curTurn <= curRound.maxTurns then
			--print("play turn")
			if checkSlashConnections({player.character}) then
				curRound.addedturndelay = 0.3
			end
			resolveTurn(player, map, curRound.curTurn)
			cleanupDeadObjects(map)
			advanceRound(curRound, map)
			resetRoundTime(curRound)
			return
		end
		if checkSlashConnections({player.character}) then
			curRound.addedturndelay = 0.3
		end
		
		--Play AI inf turn
		if not curRound.playedAITurn then
			--print("ai turn")
			resolveAIRound(player, map)
			curRound.playedAITurn = true
			resetRoundTime(curRound)
			cleanupDeadObjects(map)
		--Round is over
		elseif not curRound.finished then
			--print("round finished")
		    curRound.finished = true
		    updateCharacterPositions(map.activeCharacters)
			
			--Check enemy hitting player
			if checkLanceCollisions(map.activeCharacters) then
				--Add to the turn delay when hitting a unit
				curRound.addedturndelay = 0.3
			end 
			local playerPossibleTiles = getPossiblePlayerTiles(player)
			determineEnemyAttack(map.enemies, player, playerPossibleTiles, curRound)
			checkFormationAgro(map, player.character.tile, 0)
			cleanupDeadObjects(map)
			
			characterSlash(player.character, nil)
			
			--endRoundCleanup(map)
			checkChunkExpansion(player.character.map, player.character.tile.x, player.character.tile.y)
			createPlayerDecals(player)
			createEnemyDecals(map.enemies)
		end
	else
	    --Wait until the timer is done
	end
end

function advanceRound(curRound, map)
	if checkLanceCollisions(map.activeCharacters) then
		--Add to the turn delay when hitting a unit
		curRound.addedturndelay = 0.3
	end 
	
	curRound.curTurn = curRound.curTurn + 1
end

function cleanupDeadObjects(map)
	cleanupDeadEnemies(map.enemies)
	cleanupDeadCharacters(map.characters)
	cleanupDeadCharacters(map.activeCharacters)
	cleanupDeadLances(map.lances)
	cleanupFormations(map.formations)
end

function endRoundCleanup(map)
	--Clear up slashing characters
	for i = 1, #map.activeCharacters do
		local character = map.activeCharacters[i]
		
		if character.swording then
			characterSlash(character, nil)
		end
	end
end

function resetRoundTime(curRound)
	resetTimer(curRound.turndelay + curRound.addedturndelay, "turnTimer", curRound.timerList)
	curRound.addedturndelay = 0
end