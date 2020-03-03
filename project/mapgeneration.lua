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
			updateLancePos(enemy.character.lance)
		end
		
		table.insert(enemyList, enemy)
	end
	
	initiateFormation(map, enemyList, x, y, formationTemplate, rotation)
end