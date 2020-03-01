function spawnFormation(map, x, y, formationTemplate, direction)
	local rotation = direction
	if direction == "left" then
		rotation = math.pi
	elseif direction == "top" then
		rotation = -math.pi/2
	elseif direction == "bot" then
		rotation = math.pi/2
	elseif direction == "right" then
		rotation = 0
	end
	
	local enemyList = {}
	for i = 1, #formationTemplate.positions do
		local position = formationTemplate.positions[i]
		
		local dist = math.sqrt(position.y^2 + position.x^2)
		local angle = math.atan2(position.y, position.x)
		angle = angle + rotation
		local xPos = roundFloat(dist*math.cos(angle))
		local yPos = roundFloat(dist*math.sin(angle))
		
		local enemy = initiateEnemy(map, x + xPos, y + yPos, position.kind)
		if position.stance then
			enemy.stance = position.stance
		end
		if position.facing then
			enemy.character.facing = position.facing
		end
		enemy.character.facing = enemy.character.facing + rotation
		
		if enemy.character.lance then
			updateLancePos(enemy.character.lance)
		end
		
		table.insert(enemyList, enemy)
	end
	
	initiateFormation(map, enemyList, x, y, formationTemplate, rotation)
end