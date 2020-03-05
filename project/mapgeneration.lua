function spawnEncounter(map, x, y, difficulty, nStructures)
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
			
			if spawnFormation(map, pointX, pointY, formation, randomFromTable({0, math.pi/2, math.pi, -math.pi/2})) then
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
	
	initiateFormation(map, enemyList, x, y, formationTemplate, rotation)
	return true
end