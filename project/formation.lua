--Create a formation from a list of enemies
function initiateFormation(map, enemyList, x, y, template, formFacing)
	local formation = {map = map, members = {}, messenger = nil, x = x, y = y, template = template, size = template.size, order = "follow", facing = formFacing, behaviour = template.behaviour, leniency = template.leniency, active = false, triggerDistance = template.size + 20}
	for i = 1, #enemyList do
		local enemy = enemyList[i]
		local templateEntry = template.positions[i]
		
		local posX, posY = orthogRotate(templateEntry.x, templateEntry.y, formFacing)
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

function attachMessenger(formation, messenger)
	formation.messenger = messenger
	messenger.formation = formation
	formation.leniency = 0
	formation.behaviour = "escort"
	
	messenger.formationX = formation.x
	messenger.formationY = formation.y
	messenger.formationFacing = 0
end

function detachMessenger(formation)
	formation.messenger = nil
	formation.leniency = formation.template.leniency
	formation.behaviour = formation.template.behaviour
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

function checkFormationAgro(map, target, layers)
	if layers > 10 then
		return
	end
	
	for i = 1, #map.formations do
		local formation = map.formations[i]
		
		local distance = orthogDistance(formation.x, formation.y, target.x, target.y)
		if formation.active then
			if distance > 5*formation.triggerDistance then
				deactivateFormation(formation)
			end
		end
		if not formation.active then
			if distance < formation.triggerDistance then
				activateFormation(formation, true)
				--checkFormationAgro(map, formation, layers + 1)
			end
		end
	end
end

function activateFormation(formation)
	formation.active = true
	for j = 1, #formation.members do
		local enemy = formation.members[j].enemy
		activateEnemy(enemy)
	end
	
	if formation.messenger then
		activateEnemy(formation.messenger)
	end
end

function deactivateFormation(formation)
	formation.active = false
	for j = 1, #formation.members do
		local enemy = formation.members[j].enemy
		deactivateEnemy(enemy)
	end
	
	if formation.messenger then
		activateEnemy(formation.messenger)
	end
end

function updateFormationMembers(formation)
	for i = 1, #formation.members do
		local member = formation.members[i]
		
		member.enemy.formationX = formation.x + member.posX
		member.enemy.formationY = formation.y + member.posY
		member.enemy.formationFacing = formation.facing + member.facing
		
		--initiateParticle(member.enemy.character.map, member.enemy.formationX, member.enemy.formationY, 0, 0, 1, "collect")
	end
	
	if formation.messenger then
		formation.messenger.formationX = formation.x
		formation.messenger.formationY = formation.y
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
	if formation.messenger then
		if formation.messenger.dead then
			detachMessenger(formation)
		end
	end
	
	if formation.active then
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
				
				--if formation.facing == nil then
				--	error("wat")
				--end
				
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
		elseif formation.behaviour == "escort" then
			local angleToTarget = math.atan2(player.character.tile.y - formation.y, player.character.tile.x - formation.x)
			local distanceToTarget = orthogDistance(player.character.tile.x, player.character.tile.y, formation.x, formation.y)
			
			print(membersNotReady .. ":" .. #formation.members*formation.leniency)
			if membersNotReady <= #formation.members*formation.leniency then
				if distanceToTarget <= formation.size/2 + 8 then
					targetFacing = cardinalRound(angleToTarget)
					action = "rotate"
				else
					local xOff, yOff = getRelativeGridPositionFromAngle(angleToTarget + math.pi)
					targetX = formation.x + xOff
					targetY = formation.y + yOff
					action = "move"
				end
			end
			
			formation.order = "formation"
		elseif formation.behaviour == "intercept" then
			if membersNotReady <= #formation.members*formation.leniency then 
				if distanceBetweenAngles(formation.facing, player.character.facing + math.pi) ~= 0 then
					targetFacing = player.character.facing + math.pi
					action = "rotate"
				else
					local targetTile = getTileFromPointAtDistance(map, player.character.tile.x, player.character.tile.y, player.character.facing, 3*player.speed)
					targetX = targetTile.x
					targetY = targetTile.y
					action = "move"
				end
			end
			
			formation.order = "formation"
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