local enemyKinds = {}
local enemyColour = {0.5, 0.5, 1, 1}

enemyKinds["swordsman"]= {
	letter = initiateLetter("S", enemyColour),
	decideAction = function(enemy, target)
		if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y) <= 4 then
			enemy.stance = "chase"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = false,
	sword = true,
	bleeds = true,
	
	title = "Swordsman",
	description = "A cowardly foot soldier of the Atagan legions, equipped with the simplest killing blade. Farmers torn from their native lands by the usurper's captains, they have little to no combat training, knowing barely more than to march in a straight line. Despite their inexperience they show surprising bravery in combat, likely due to the iron fist of their commanders.\n\nTheir danger lies only in their numbers advantage, and they are particularly effective against generals in the habit of fleeing from larger forces. If the Atagani ancestors could see the tactics employed by their forebears they would surely renounce their clan name and bar their halls from their children. It is a tragic sign of our times that such strategy could be so shamelessly exploited, but it is yet more tragic still that so many of our riders have been lost to forces such as these.\n\n\nSloth and recklessness typify this opponent.",
}
enemyKinds["lancer"]= {
	letter = initiateLetter("L", enemyColour),
	decideAction = function(enemy, target)
		if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y) <= 2 then
			enemy.stance = "hold"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = true,
	bleeds = true,
	
	title = "Lancer",
	description = "A soldier equipped with a horse killing spear. A corruption of the heavy lance used traditionally by our ancestors, this foot spear is the fuel in the ravaging bonfire of the Atagan advance. Few know precisely where the Atagan usurper obtained these dishonourable weapons, or where he learned how to use them to such great effect, but they are likely an import from the weak southern nations.\n\nHeavy as the spear is, it is difficult to manoeuvre on the battlefield, let alone thrust. These soldiers prefer rather to use the momentum of their opponents in their strikes, simply letting them run themselves through on their outstretched spear heads. It is most fortunate that the First Horse is no longer with us, for to see his folk so barbarically slaughtered would surely drive him mad.\n\n\nCunning and forethought typify this opponent"
}
enemyKinds["bowman"]= {
	letter = initiateLetter("B", enemyColour),
	decideAction = function(enemy, target)
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y)
		if distance <= enemy.fleeRange then
			enemy.stance = "flee"
		elseif distance <= enemy.bow.shootRange + 2 then
			enemy.stance = "shooting"
		else
			enemy.stance = enemy.formation.order
		end
	end,
	lance = false,
	bow = {shootRange = 9, reloadTime = 3},
	fleeRange = 4,
	bleeds = true,
	
	title = "Bowman",
	description = "An unmounted Atagan warrior equipped with a large straight bow. Such bows are common amongst hunters and other poorer folk who can hardly afford the cost of a riding horse, but the smaller re-curve bow more suited to fire from horseback is the true warriors weapon. The Atagan war machine hungers for fresh meat though, especially that with killing experience, and many woodsmen and poachers have found themselves pressed into service.\n\nDespite the simpler build of their weapon, the stationary footing of these men allows them an accuracy that gives them a greater killing range than could be expected from a mounted archer. Such free men are hard to chain down and are often wiser than to expect reward from a tyrant however, so they are well known to flee before the hooves of a charging warhorse rather than stand and fight."
}
enemyKinds["rider"]= {
	letter = initiateLetter("H", enemyColour),
	decideAction = function(enemy, target)
		enemy.stance = "ride"
	end,
	lance = true,
	mounted = true,
	bleeds = true,
	noFormation = true,
	bow = {shootRange = 7, reloadTime = 4},
	
	title = "Horseman",
	description = "A high ranking mounted soldier of the Atagan army. Likely the son of an Atagan noble, or a veteran fighter who remembers the true warrior code. Due to their scarcity in the Atagan legions, they have taken on the role of elite troops roused only for the most important of battles. Luckily for you, this means they are unlikely to stand in your way. Unless roused, of course.\n\nWhile they fight in much the same way as our own warriors, their elevated status has blunted their killing senses, and they have lost much of the fighting skill passed down by the ancestors. Nevertheless, they still remember the ancient art of horseback archery, and will harry you with arrows while they try to strike you down with their lance.\n\n\nHonour and speed typify this opponent"
}
enemyKinds["messenger"]= {
	letter = initiateLetter("M", {1, 0.5, 1, 1}),
	decideAction = function(enemy, target)
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, target.character.tile.x, target.character.tile.y)
		if distance <= 5 or #enemy.formation.members == 0 then
			enemy.stance = "flee"
		else
			enemy.stance = "formation"
		end
	end,
	lance = false,
	bleeds = true,
	
	title = "Messenger",
	description = "An Atagan captain tasked with raising the call when hostiles are sighted. The Atagan forces are built on discipline and hierarchy rather than honour and respect, and these men are the finest example of this folly. Dressed in ornate armour, they command small units of men, and are responsible for the messenger pigeons assigned to their company for purposes of communication. They are the only men amongst the soldiery that are trained in the launching of these birds however, and it is a common tactic amongst our warriors to strike down only the captain of a squad and leave the rest of them for dead.\n\nOne would expect that a warrior of such a rank would be a deadly combatant, but it is rather the opposite. These men are picked as leaders not for their prowess as warriors, but as administrators, and are well known to flee at the first sign of conflict. Nevertheless, the threat they pose in summoning the aid of stronger fighters is a real one, and should not be underestimated.\n\n\nCowardice and looming danger typify this opponent"
}
enemyKinds["barrier"]= {
	letter = initiateLetter("#", enemyColour),
	decideAction = function(enemy, target)
		enemy.stance = "hold"
	end,
	lance = false,
	bleeds = false,
	noFormation = true,
	lance = true,
	arrowImmune = true,
	
	title = "Barrier",
	description = "A hastily assembled stockade with a spear couched in the front. Used to shield bowman or otherwise vulnerable men. While blatantly worse than a soldier, it does have the advantage of being particularly resilient to arrows and swords. A well placed lance on the other hand will shatter the entire shoddy construct."
}


function initiateEnemy(map, x, y, kind)
	local enemyKind = enemyKinds[kind]
	
	local enemy = {character = nil, side = "enemy", kind = kind, stance = "hold", active = false, formation = nil, decideAction = enemyKind.decideAction, sword = enemyKind.sword, bow = enemyKind.bow, fleeRange = enemyKind.fleeRange, formationX = 0, formationY = 0, formationFacing = 0, title = enemyKind.title, description = enemyKind.description, noFormation = enemyKind.noFormation}
	enemy.character = initiateCharacter(map, x, y, copyLetter(enemyKind.letter), enemy)
	enemy.character.bleeds = enemyKind.bleeds
	enemy.character.arrowImmune = enemyKind.arrowImmune
	
	if enemy.bow then
		enemy.reloading = 0
		enemy.firing = false
	end
	
	if enemyKind.lance then
		initiateLance(map, enemy.character, enemyKind.letter.colour)
	end
	
	if enemyKind.mounted then
		enemy.speed = 0
		enemy.maxSpeed = 5
		enemy.moveDecals = {}
	end
	
	table.insert(map.inactiveEnemies, enemy)
	
	return enemy
end

function activateEnemy(enemy)
	local decal = initiateDecal(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y - 0.5, "exclamation")
	local timeLeft = math.random()
	decal.timeLeft = timeLeft
	decal.colour = {1, 1, 0, 1}
	decal.fade = 1/timeLeft
	decal.yspeed = -3
	
	enemy.active = true
	table.insert(enemy.character.map.enemies, enemy)
	activateCharacter(enemy.character)
end

function deactivateEnemy(enemy)
	if not enemy.speed then
		enemy.active = false
		deactivateCharacter(enemy.character)
	end
end

local enemyMoveToPos = function(enemy, x, y)
	local angleToTarget = angleBetweenVectors(enemy.character.tile.x, enemy.character.tile.y, x, y)
	local blocked = true
	
	local xDir, yDir
	local map = enemy.character.map
	local i = 0
	while blocked do
		local side = 1
		if i%2 == 0 then
			side = -1
		end
		
		local angle = angleToTarget + side*math.ceil(i/2)*(math.pi/4)
		local tile = getTileFromPoint(map, enemy.character.tile.x, enemy.character.tile.y, angle)
		
		local walkable = checkTileWalkable(tile, enemy.character)
		local tileCharacter = tile.waitingForCharacter
		if not tileCharacter then
			tileCharacter = tile.character
		end
		
		if not walkable and tileCharacter then
			if tileCharacter.side == "player" then
				walkable = false
			elseif checkEnemyMoving(tileCharacter.master) then
				walkable = true
			end
		end
		
		if walkable then
			blocked = false
			xDir, yDir = getRelativeGridPositionFromAngle(angle)
		else
			i = i + 1
			if i >= 8 then
				break
			end
		end
	end
	
	if not blocked then
		shiftCharacter(enemy.character, xDir, yDir)
	end
end

local enemyRotate = function(enemy, targetFacing)
	local rotateDir = findAngleDirection(enemy.character.facing, targetFacing)
	if rotateDir > 0 then
		shiftClockwise(enemy.character)
	elseif rotateDir < 0 then
		shiftAnticlockwise(enemy.character)
	end
end


local enemyRotateToPoint = function(enemy, x, y)
	local angleToTarget = cardinalRound(math.atan2(y - enemy.character.tile.y, x - enemy.character.tile.x))
	if distanceBetweenAngles(angleToTarget, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, angleToTarget)
		return true
	end
	return false
end

local enemyRotateThenMoveToPoint = function(enemy, x, y)
	if not enemyRotateToPoint(enemy, x, y) and x ~= enemy.character.tile.x or y ~= enemy.character.tile.y then
		enemyMoveToPos(enemy, x, y)
	end
end

local enemyFlee = function(enemy, target)
	local angleAway = math.atan2(enemy.character.tile.y - target.character.tile.y, enemy.character.tile.x - target.character.tile.x)
	local awayX, awayY = getRelativeGridPositionFromAngle(angleAway)
	enemyMoveToPos(enemy, enemy.character.tile.x + awayX, enemy.character.tile.y + awayY)
end

local enemyChase = function(enemy, target)
	enemyRotateThenMoveToPoint(enemy, target.character.tile.x, target.character.tile.y)
end

local enemyHold = function(enemy, target)
	if enemy.character.lance then
		local playerTiles = getTilesFromPoint(target.character.map, target.character.tile.x, target.character.tile.y, target.character.facing, 3*target.speed)
		for i = 1, #playerTiles do
			local tile = playerTiles[i]
			
			if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, tile.x, tile.y) <= 1 then
				enemyRotateToPoint(enemy, tile.x, tile.y)
				return
			end
		end
		enemyRotateToPoint(enemy, target.character.tile.x, target.character.tile.y)
	end
end

local enemyFollowFormation = function(enemy)
	if distanceBetweenAngles(enemy.formationFacing, enemy.character.facing) > 0 and enemy.character.lance then
		enemyRotate(enemy, enemy.formationFacing)
	elseif enemy.formationX ~= enemy.character.tile.x or enemy.formationY ~= enemy.character.tile.y then
		--print("Moving To: [" .. enemy.formationX .. ":" .. enemy.formationY .. "]")
		enemyMoveToPos(enemy, enemy.formationX, enemy.formationY)
	end
end

local enemyRide = function(enemy, player)
	local character = enemy.character
	--AvoidObstacles
	local rotation = 0
	local acceleration = 0
	
	local blocked = false
	if enemy.speed > 0 then
		blocked = true
		local i = 1
		while blocked and i <= 3 do
			local checkingRotation = 0
			if i == 2 then
				checkingRotation = math.pi/4
			elseif i == 3 then
				checkingRotation = -math.pi/4
			end
			
			local tilesInPath = getTilesFromPoint(character.map, enemy.character.tile.x, character.tile.y, character.facing + checkingRotation, math.ceil(2*enemy.speed))
			
			for j = 2, #tilesInPath do
				local tile = tilesInPath[j]
				if checkTileWalkable(tile, character) then
					if j == #tilesInPath then
						blocked = false
						rotation = checkingRotation
					end
				else
					break
				end
			end
			
			i = i + 1
		end
	else
		local targetX = player.character.tile.x
		local targetY = player.character.tile.y
		
		local angleToTarget = math.atan2(targetY - character.tile.y, targetX - character.tile.x)
		character.facing = cardinalRound(angleToTarget)
	end
	
	local targetX = player.character.tile.x
	local targetY = player.character.tile.y
	local dist = orthogDistance(targetX, targetY, character.tile.x, character.tile.y)
	if not blocked then
		if dist <= enemy.bow.shootRange then
			enemy.stance = "shooting"
		else
			local angleToTarget = math.atan2(targetY - character.tile.y, targetX - character.tile.x)
			--if angleToTarget == nil then
			--	error()
			--end
			
			local angleDist = distanceBetweenAngles(angleToTarget, character.facing)
			
			if angleDist <= math.pi/8 then
				acceleration = 1
			else
				local proposedRotation = 0
				if findAngleDirection(character.facing, angleToTarget) > 0 then
					proposedRotation = math.pi/4
				else
					proposedRotation = -math.pi/4
				end
				
				local tilesInPath = getTilesFromPoint(character.map, enemy.character.tile.x, character.tile.y, character.facing + proposedRotation, math.ceil(1.5*enemy.speed))
				
				for j = 2, #tilesInPath do
					local tile = tilesInPath[j]
					if checkTileWalkable(tile, character) then
						if j == #tilesInPath then
							rotation = proposedRotation
						end
					else
						break
					end
				end
				
				if angleDist >= math.pi/2 then
					acceleration = -1
				end
			end
		end
	end
	
	modifySpeed(enemy, acceleration)
	if rotation > 0 then
		shiftClockwise(character)
	elseif rotation < 0 then
		shiftAnticlockwise(character)
	end
end

function enemyAct(enemy, player)
	if enemy.firing then
		fireArrow(enemy.character, enemy.targetX, enemy.targetY)
		enemy.firingdecal.remove = true
		enemy.firing = false
		enemy.character.letter.shaking = 0
		enemy.reloading = enemy.bow.reloadTime
	elseif not enemy.character.swording then
		if enemy.stance == "chase" then
			enemyChase(enemy, player)
		elseif enemy.stance == "formation" then
			enemyFollowFormation(enemy)
		elseif enemy.stance == "hold" then
			enemyHold(enemy, player)
		elseif enemy.stance == "flee" then
			enemyFlee(enemy, player)
		elseif enemy.stance == "ride" then
			enemyRide(enemy, player)
		end
	end
	
	if enemy.cavCount then
		local distance = orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y)
		
		if distance >= 2*enemy.formation.triggerDistance then
			for i = 1, enemy.cavCount do
				local spawnTile = findFreeTileFromPoint(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y, 3)
				activateEnemy(initiateEnemy(enemy.character.map, spawnTile.x, spawnTile.y, "rider"))
			end
			enemy.cavCount = nil
			detachMessenger(enemy.formation)
		end
	end
end

function determineEnemyAttack(enemies, player, possiblePlayerTiles, curRound)
	for i = 1, #enemies do
		local enemy = enemies[i]
		
		if enemy.sword then
			if enemy.character.swording then
				if not checkSlashConnections({enemy.character}) then
					characterSlash(enemy.character, nil)
				else
					curRound.addedturndelay = 0.3
				end
			else
				if orthogDistance(enemy.character.tile.x, enemy.character.tile.y, player.character.tile.x, player.character.tile.y) == 1 then
					characterStartSlashing(enemy.character)
				end
			end
		end
		
		if enemy.bow then
			if enemy.reloading > 0 then
				enemy.reloading = enemy.reloading - 1
			end
		end
		
		if enemy.stance == "shooting" then
			if enemy.reloading <= 0 and not enemy.firing then
				if #possiblePlayerTiles > 0 then
					enemy.targetX = possiblePlayerTiles[1].x
					enemy.targetY = possiblePlayerTiles[1].y
					local decal = initiateDecal(enemy.character.map, possiblePlayerTiles[1].x, possiblePlayerTiles[1].y, "bullseye")
					
					decal.colour = {1, 0, 0, 0.8}
					decal.flashing = 0.1
					
					enemy.firingdecal = decal
					enemy.firing = true
					enemy.character.letter.shaking = 0.1
					
					table.remove(possiblePlayerTiles, 1)
				end
			end
		end
	end
end

function checkEnemyMoving(enemy)
	if enemy.stance == "chase" then
		return false
	end
	
	if enemy.character.lance then
		if enemy.formationFacing ~= enemy.character.facing and enemy.stance == "formation" then
			return false
		end
	end
	
	if enemy.stance == "formation" then
		--print(enemy.character.id .. "= " .. enemy.formationX .. ":" .. enemy.character.tile.x .. " , " .. enemy.formationY .. ":" .. enemy.character.tile.y)
		if enemy.formationX == enemy.character.tile.x and enemy.formationY == enemy.character.tile.y then
			return false
		end
	end
	
	return true
end

function damageEnemy(enemy, damage)
	enemy.dead = true
end

function cleanupDeadEnemies(enemies)
	local i = 1
	while i <= #enemies do
		local enemy = enemies[i]
		if enemy.dead then
			if enemy.firingdecal then
				enemy.firingdecal.remove = true
			end
			enemy.character.dead = true
			table.remove(enemies, i)
		elseif enemy.active == false then
			if enemy.firingdecal then
				enemy.firingdecal.remove = true
			end
			table.remove(enemies, i)
		else
			i = i + 1
		end
	end
end

function removeEnemyDecals(enemies)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy.speed then
			for j = 1, #enemy.moveDecals do
				local moveDecal = enemy.moveDecals[j]
				moveDecal.remove = true
			end
		end
	end
end

function createEnemyDecals(enemies)
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy.speed then
			local pathTiles = getTilesFromPoint(enemy.character.map, enemy.character.tile.x, enemy.character.tile.y, enemy.character.facing, enemy.speed)
			for j = 2, #pathTiles do
				local pathTile = pathTiles[j]
				local arrow = createArrowDecal(enemy.character.map, pathTile.x, pathTile.y, enemy.character.facing)
				arrow.colour = {0.5, 0.5, 1, 0.5}
				arrow.flashing = 0.3
				table.insert(enemy.moveDecals, arrow)
			end
		end
	end
end