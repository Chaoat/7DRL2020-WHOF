--Create a formation from a list of enemies
function initiateFormation(map, enemyList, x, y, template, formFacing)
	local formation = {map = map, members = {}, x = x, y = y, size = template.size, order = "follow", facing = formFacing, behaviour = template.behaviour, leniency = template.leniency}
	for i = 1, #enemyList do
		local enemy = enemyList[i]
		local templateEntry = template.positions[i]
		
		local posX = templateEntry.x
		local posY = templateEntry.y
		local facing = templateEntry.facing
		if not facing then
			facing = 0
		end
		table.insert(formation.members, {enemy = enemy, posX = posX, posY = posY, facing = facing})
		
		enemy.formation = formation
		enemy.formationX = x + posX
		enemy.formationY = y + posY
		enemy.formationFacing = formFacing + facing
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
		
		member.posX, member.posY = orthogRotate(member.posX, member.posY, rotation)
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

function cleanupFormations(formations)
	local i = 1
	while i <= #formations do
		local formation = formations[i]
		
		local j = 1
		while j <= #formation.members do
			local member = formation.members[j]
			if member.enemy.dead then
				table.remove(formation.members, j)
			else
				j = j + 1
			end
		end
		
		if #formation.members == 0 then
			table.remove(formations, i)
		else
			i = i + 1
		end
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
		targetX = player.character.tile.x
		targetY = player.character.tile.y
		if membersNotReady <= #formation.members*formation.leniency then 
			local angleToTarget = math.atan2(targetY - formation.y, targetX - formation.x)
			
			if formation.facing == nil then
				error("wat")
			end
			
			if distanceBetweenAngles(formation.facing, angleToTarget) >= math.pi/2 then
				targetFacing = cardinalRound(angleToTarget)
				action = "rotate"
			else
				action = "move"
			end
		end
		
		if orthogDistance(targetX, targetY, formation.x, formation.y) <= formation.size/2 + 3 then
			formation.order = "chase"
		else
			formation.order = "formation"
		end
	elseif formation.behaviour == "guard" then
		formation.order = "hold"
	end
	
	--print("formation members not ready: " .. membersNotReady)
	--print("formation action: " .. action)
	
	if action == "move" then
		local angle = cardinalRound(math.atan2(targetY - formation.y, targetX - formation.x))
		moveFormation(formation, roundFloat(math.cos(angle)), roundFloat(math.sin(angle)))
	elseif action == "rotate" then
		local rotation = findAngleDirection(formation.facing, targetFacing)*math.pi/2
		rotateFormation(formation, rotation)
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