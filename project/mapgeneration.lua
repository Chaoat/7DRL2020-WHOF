local treeList = {"tree"}

local difficultyBrackets = {}
--difficulty 1
table.insert(difficultyBrackets, {
	cutPoint = 50,
	
	patrolFrequency = 20000,
	patrolStrength = 5,
	
	campFrequency = 30000,
	campStrength = 10,
	campBuildings = 1,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 1,
	treeSpawnChance = 0.02
})
--difficulty 2
table.insert(difficultyBrackets, {
	cutPoint = 250,
	
	patrolFrequency = 10000,
	patrolStrength = 5,
	
	campFrequency = 25000,
	campStrength = 5,
	campBuildings = 1,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 1,
	treeSpawnChance = 0.03
})
--difficulty 3
table.insert(difficultyBrackets, {
	cutPoint = 500,
	
	patrolFrequency = 5000,
	patrolStrength = 7,
	
	campFrequency = 20000,
	campStrength = 15,
	campBuildings = 1,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 1,
	treeSpawnChance = 0.01
})
--difficulty 4
table.insert(difficultyBrackets, {
	cutPoint = 1000,
	
	patrolFrequency = 3000,
	patrolStrength = 11,
	
	campFrequency = 10000,
	campStrength = 20,
	campBuildings = 2,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 2,
	treeSpawnChance = 0.04
})
--difficulty 5
table.insert(difficultyBrackets, {
	cutPoint = 2000,
	
	patrolFrequency = 2000,
	patrolStrength = 15,
	
	campFrequency = 5000,
	campStrength = 25,
	campBuildings = 4,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 3,
	treeSpawnChance = 0.02
})
--difficulty 6
table.insert(difficultyBrackets, {
	cutPoint = 2500,
	
	patrolFrequency = 1000,
	patrolStrength = 25,
	
	campFrequency = 5000,
	campStrength = 40,
	campBuildings = 2,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 5,
	treeSpawnChance = 0.01
})
--difficulty 6
table.insert(difficultyBrackets, {
	cutPoint = 2740,
	
	patrolFrequency = 500,
	patrolStrength = 25,
	
	campFrequency = 1000,
	campStrength = 50,
	campBuildings = 2,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 5,
	treeSpawnChance = 0.005
})
--difficulty final
table.insert(difficultyBrackets, {
	cutPoint = 9999999999999,
	
	patrolFrequency = 500,
	patrolStrength = 0,
	
	campFrequency = 500,
	campStrength = 0,
	campBuildings = 0,
	
	patrolRemainder = 0,
	campRemainder = 0,
	
	messengerCavCount = 0,
	treeSpawnChance = 0
})

function expandMap(map, tileKind, newTileX, newTileY)
	if map.minX > newTileX then
		map.minX = newTileX
	elseif map.maxX < newTileX then
		map.maxX = newTileX
	end
	if map.minY > newTileY then
		map.minY = newTileY
	elseif map.maxY < newTileY then
		map.maxY = newTileY
	end
	
	local cDiffBracket = 1
	local tilesInBrackets = {{}}
	local campTilesInBrackets = {{}}
	
	for i = map.minX, map.maxX do
		while difficultyBrackets[cDiffBracket].cutPoint < i do
			print("increasing difficulty to: ")
			cDiffBracket = cDiffBracket + 1
			print(cDiffBracket)
			tilesInBrackets[cDiffBracket] = {}
			campTilesInBrackets[cDiffBracket] = {}
		end
		
		if map.tiles[i] == nil then
			map.tiles[i] = {}
		end
		
		for j = map.minY, map.maxY do
			if map.tiles[i][j] == nil then
				map.tiles[i][j] = initiateTile(i, j, "ground")
				forestVal = love.math.noise(map.treeNoiseMult*i + map.treeNoiseXOff, map.treeNoiseMult*j + map.treeNoiseYOff)
				
				local cutoffVal = 0.7
				local treeChance = ((forestVal - (1 - cutoffVal))/cutoffVal)*difficultyBrackets[cDiffBracket].treeSpawnChance
				if math.random() < treeChance then
					map.tiles[i][j].spawnTree = true
				end
				table.insert(tilesInBrackets[cDiffBracket], {i, j})
				if treeChance <= 0.1 then
					table.insert(campTilesInBrackets[cDiffBracket], {i, j})
				end
			end
		end
	end
	
	for i = map.minX, map.maxX do
		for j = map.minY, map.maxY do
			local tile = getMapTile(map, i, j)
			if tile.spawnTree then
				if spawnTree(map, i, j) then
					tile.spawnTree = false 
				end
			end
		end
	end
	
	for i = 1, #tilesInBrackets do
		populateNewChunkWithEncounters(map, i, tilesInBrackets[i], campTilesInBrackets[i])
	end
end

function spawnTree(map, x, y)
	return spawnStructure(map, x, y, randomFromTable(treeList), randomFromTable({0, math.pi/2, math.pi, -math.pi/2}))
end

function populateNewChunkWithEncounters(map, bracketI, tiles, campTiles)
	local bracket = difficultyBrackets[bracketI]
	
	local patrolTileCount = #tiles + bracket.patrolRemainder
	local campTileCount = #campTiles + bracket.campRemainder
	
	while patrolTileCount >= bracket.patrolFrequency do
		local tile, i = randomFromTable(tiles)
		spawnEncounter(map, tile[1], tile[2], bracket.patrolStrength, 0, true, bracket.messengerCavCount)
		table.remove(tiles, i)
		patrolTileCount = patrolTileCount - bracket.patrolFrequency
	end
	bracket.patrolRemainder = patrolTileCount
	
	while campTileCount >= bracket.campFrequency do
		local tile, i = randomFromTable(campTiles)
		spawnEncounter(map, tile[1], tile[2], bracket.campStrength, bracket.campBuildings, false, bracket.messengerCavCount)
		table.remove(campTiles, i)
		campTileCount = campTileCount - bracket.campFrequency
	end
	bracket.campRemainder = campTileCount
end

function spawnEncounter(map, x, y, difficulty, nStructures, patrol, messengerCavCount)
	local spaceNeeded = 0
	
	local formationsChosen = {}
	while difficulty > 0 do
		local formation = getFormationTemplateInDifficultyRange(difficulty/2, difficulty)
		if formation == nil then
			break
		else
			spaceNeeded = spaceNeeded + formation.size
			difficulty = difficulty - formation.difficulty
			table.insert(formationsChosen, formation)
		end
	end
	
	local structuresChosen = {}
	while nStructures > 0 do
		local structure = getRandomConstructionName()
		spaceNeeded = spaceNeeded + getStructureSize(structure)
		table.insert(structuresChosen, structure)
		nStructures = nStructures - 1
	end
	
	spaceNeeded = 1.5*math.sqrt(spaceNeeded)
	
	local possibleFormationAngles = {0, math.pi/2, math.pi, -math.pi/2}
	if patrol then
		possibleFormationAngles = {math.pi}
	end
	
	
	local messenger = nil
	if math.random() < 0.5 or not patrol then
		local messengerTile = findFreeTileFromPoint(map, x, y, 2)
		messenger = initiateEnemy(map, messengerTile.x, messengerTile.y, "messenger")
		messenger.cavCount = messengerCavCount
	end
	
	local i = 1
	while #formationsChosen > 0 or #structuresChosen > 0 do
		if #structuresChosen > 0 then
			local pointX, pointY = randomPointInArea(x - math.ceil(spaceNeeded/2), y - math.ceil(spaceNeeded/2), x + math.ceil(spaceNeeded/2), y + math.ceil(spaceNeeded/2))
			if spawnStructure(map, pointX, pointY, structuresChosen[1], randomFromTable({0, math.pi/2, math.pi, -math.pi/2})) then
				table.remove(structuresChosen, 1)
			end
		end
		
		if #formationsChosen > 0 then
			local formation = formationsChosen[i]
			local pointX, pointY = randomPointInArea(x - math.ceil(spaceNeeded/2), y - math.ceil(spaceNeeded/2), x + math.ceil(spaceNeeded/2), y + math.ceil(spaceNeeded/2))
			
			local formationSpawned = spawnFormation(map, pointX, pointY, formation, randomFromTable(possibleFormationAngles))
			if formationSpawned then
				if messenger then
					attachMessenger(formationSpawned, messenger)
					messenger = nil
				end
				
				table.remove(formationsChosen, i)
			else
				i = i + 1
			end
		end
		
		if i > #formationsChosen then
			i = 1
			spaceNeeded = spaceNeeded + 2
			print(spaceNeeded)
		end
	end
end

function spawnFormation(map, x, y, formationTemplate, direction)
	local rotation = direction
	if direction == "left" then
		rotation = math.pi
	elseif direction == "up" then
		rotation = -math.pi/2
	elseif direction == "down" then
		rotation = math.pi/2
	elseif direction == "right" then
		rotation = 0
	end
	
	--CheckBlocked
	for i = 1, #formationTemplate.positions do
		local position = formationTemplate.positions[i]
		
		local xPos, yPos = orthogRotate(position.x, position.y, rotation)
		local tile = getMapTile(map, x + xPos, y + yPos)
		if not checkTileWalkable(tile) then
			return false
		end
	end
	
	local enemyList = {}
	for i = 1, #formationTemplate.positions do
		local position = formationTemplate.positions[i]
		
		local xPos, yPos = orthogRotate(position.x, position.y, rotation)
		
		local enemy = initiateEnemy(map, x + xPos, y + yPos, position.kind)
		if position.stance then
			enemy.stance = position.stance
		end
		if position.facing then
			enemy.character.facing = position.facing
		end
		enemy.character.facing = enemy.character.facing + rotation
		
		if enemy.character.lance then
			rotateLanceToPos(enemy.character.lance, enemy.character.facing)
		end
		
		table.insert(enemyList, enemy)
	end
	
	return initiateFormation(map, enemyList, x, y, formationTemplate, rotation)
end