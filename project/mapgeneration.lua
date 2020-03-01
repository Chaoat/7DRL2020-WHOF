function spawnFormation(map, x, y, formationTemplate, direction)
	for i = 1, #formationTemplate.positions do
		local position = formationTemplate.positions[i]
		
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
		
		local dist = math.sqrt(position.y^2 + position.x^2)
		local angle = math.atan2(position.y, position.x)
		angle = angle + rotation
		local xPos = roundFloat(dist*math.cos(angle))
		local yPos = roundFloat(dist*math.sin(angle))
		
		innitiateEnemy(map, x + xPos, y + yPos, position.kind)
	end
end