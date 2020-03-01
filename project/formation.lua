--Create a formation from a list of enemies
function initiateFormation(map, enemyList, x, y, template, facing)
	local formation = {map = map, members = {}, x = x, y = y, size = template.size, facing = template.facing, behaviour = template.behaviour}
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
		
		local dist = math.sqrt(member.posX^2 + member.posY^2)
		local angle = math.atan2(member.posY, member.posX) + rotation
		member.posX = dist*math.cos(angle)
		member.posY = dist*math.sin(angle)
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
	
	testForceFormationPosition(formation)
end

function testForceFormationPosition(formation)
	for i = 1, #formation.members do
		local member = formation.members[i]
		multiSlide(member.enemy.character, member.enemy.formationX, member.enemy.formationY)
	end
end

function determineFormationAction(map, player, formation)
	local fightersNotReady = checkFormationInLine(formation)
	local targetX = nil
	local targetY = nil
	local targetFacing = nil
	local action = "none"
	if formation.behaviour == "chase" then
		targetX = player.character.x
		targetY = player.character.y
		if fightersNotReady >= #formation.members/2 then 
			action = "move"
		end
		
		if math.sqrt((targetX - formation.x)^2 + (targetY - formation.y)^2) <= 3 then
			action = "disperse"
		end
	end
	
	if action == "move" then
		local angle = cardinalRound(math.atan2(targetY - player.character.y, targetX - player.character.x))
		moveFormation(formation, roundFloat(math.cos(angle)), roundFloat(math.sin(angle)))
	end
end

function checkFormationInLine(formation)
	local nFightersNotReady = 0
	for i = 1, #formation.members do
		local member = formation.members[i]
		if not (member.enemy.character.x == member.enemy.formationX and member.enemy.character.y == member.enemy.formationY and member.enemy.character.facing == member.enemy.formationFacing) then
			nFighters = nFighters + 1
		end
	end
	return nFighters
end