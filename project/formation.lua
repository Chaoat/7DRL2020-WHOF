--Create a formation from a list of enemies
function initiateFormation(map, enemyList, x, y, template, facing)
	local formation = {map = map, members = {}, x = x, y = y, size = template.size, order = "follow", facing = facing, behaviour = template.behaviour}
	for i = 1, #enemyList do
		local enemy = enemyList[i]
		
		local posX = enemy.character.x - x
		local posY = enemy.character.y - y
		local facing = enemy.character.facing - facing
		table.insert(formation.members, {enemy = enemy, posX = posX, posY = posY, facing = facing})
		
		enemy.formation = formation
		enemy.formationX = x + posX
		enemy.formationY = y + posY
		enemy.formationFacing = facing + enemy.character.facing
	end
	
	table.insert(map.formations, formation)
	return formation
end

function moveFormation(formation, xDir, yDir)
	formation.x = formation.x + xDir
	formation.y = formation.y + yDir
	updateFormationMembers(formation)
end

function rotateFormation(formation, rotation)
	formation.facing = formation.facing + rotation
	for i = 1, #formation.members do
		local member = formation.members[i]
		
		local dist = orthogDistance(0, 0, member.posX, member.posY)
		local angle = math.atan2(member.posY, member.posX) + rotation
		member.posX = dist*roundFloat(math.cos(angle))
		member.posY = dist*roundFloat(math.sin(angle))
	end
	updateFormationMembers(formation)
end

function updateFormationMembers(formation)
	for i = 1, #formation.members do
		local member = formation.members[i]
		
		member.enemy.formationX = formation.x + member.posX
		member.enemy.formationY = formation.y + member.posY
		member.enemy.formationFacing = formation.facing + member.facing
	end
end

function testForceFormationPosition(formation)
	for i = 1, #formation.members do
		local member = formation.members[i]
		multiSlide(member.enemy.character, member.enemy.formationX, member.enemy.formationY)
	end
end

function determineFormationAction(map, player, formation)
	local membersNotReady = checkFormationInLine(map, formation)
	
	local targetX = nil
	local targetY = nil
	local targetFacing = nil
	
	local action = "none"
	if formation.behaviour == "chase" then
		targetX = player.character.x
		targetY = player.character.y
		if membersNotReady < #formation.members/2 then 
			local angleToTarget = math.atan2(targetY - formation.y, targetX - formation.x)
			if distanceBetweenAngles(formation.facing, angleToTarget) >= math.pi/2 then
				targetFacing = cardinalRound(angleToTarget)
				action = "rotate"
			else
				action = "move"
			end
		end
		
		if math.sqrt((targetX - formation.x)^2 + (targetY - formation.y)^2) <= 3 then
			action = "disperse"
		end
	end
	
	print("formation members not ready: " .. membersNotReady)
	print("formation action: " .. action)
	
	formation.order = "follow"
	if action == "move" then
		local angle = cardinalRound(math.atan2(targetY - formation.y, targetX - formation.x))
		moveFormation(formation, roundFloat(math.cos(angle)), roundFloat(math.sin(angle)))
	elseif action == "rotate" then
		local rotation = findAngleDirection(formation.facing, targetFacing)*math.pi/2
		rotateFormation(formation, rotation)
	elseif action == "disperse" then
		formation.order = "disperse"
	end
end

function checkFormationInLine(map, formation)
	local nFightersNotReady = 0
	for i = 1, #formation.members do
		local member = formation.members[i]
		local tile = getMapTile(map, member.enemy.formationX, member.enemy.formationY)
		if tile.properties.walkable then
			if not (member.enemy.character.tile.x == member.enemy.formationX and member.enemy.character.tile.y == member.enemy.formationY and (distanceBetweenAngles(member.enemy.character.facing, member.enemy.formationFacing) == 0 or not member.enemy.character.lance)) then
				nFightersNotReady = nFightersNotReady + 1
			end
		end
	end
	return nFightersNotReady
end