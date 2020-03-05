function initiateMap(chunkSize)
	local map = {minX = 0, maxX = 0, minY = 0, maxY = 0, tiles = {}, characters = {}, activeCharacters = {}, inactiveEnemies = {}, enemies = {}, formations = {}, lances = {}, decals = {}, particles = {}, treeNoiseMult = 0.004, treeNoiseXOff = math.random(), treeNoiseYOff = math.random(), chunkSize = chunkSize}
	fillMapArea(map, "ground", -chunkSize/2, -chunkSize/2, chunkSize/2, chunkSize/2)
	return map
end

function fillMapArea(map, tileKind, x1, y1, x2, y2)
	expandMap(map, tileKind, x1, y1)
	expandMap(map, tileKind, x2, y2)
end

function updateMap(map, dt)
	updateActiveCharacters(map.activeCharacters, dt)
	updateParticles(map, map.particles, dt)
	updateDecals(map.decals, dt)
end

function checkChunkExpansion(map, x, y)
	if map.maxX - x <= map.chunkSize/2 then
		expandMap(map, "ground", x + map.chunkSize, y)
	elseif x - map.minX <= map.chunkSize/2 then
		expandMap(map, "ground", x - map.chunkSize, y)
	end
	
	if map.maxY - y <= map.chunkSize/2 then
		expandMap(map, "ground", x, y + map.chunkSize)
	elseif y - map.minY <= map.chunkSize/2 then
		expandMap(map, "ground", x, y - map.chunkSize)
	end
end

function getMapTile(map, x, y)
	if map.minX <= x and x <= map.maxX and map.minY <= y and y <= map.maxY then
		return map.tiles[x][y]
	else
		return initiateTile(x, y, "empty")
	end
end

function getTileFromPoint(map, x, y, angle)
	local xDir, yDir = getRelativeGridPositionFromAngle(angle)
	return getMapTile(map, x + xDir, y + yDir)
end

function getTileFromPointAtDistance(map, x, y, angle, dist)
	local tX, tY = orthogRotate(dist, 0, angle)
	return getMapTile(map, x + tX, y + tY)
end

function getTilesInLine(map, x1, y1, x2, y2)
	local distBetween = orthogDistance(x1, y1, x2, y2)
	local angle = math.atan2(y2 - y1, x2 - x1)
	
	local tileList = {getMapTile(map, x1, y1)}
	for i = 1, distBetween do
		local dirX, dirY = orthogRotate(i, 0, angle)
		table.insert(tileList, getMapTile(map, x1 + dirX, y1 + dirY))
	end
	
	return tileList
end

function getTilesFromPoint(map, x1, y1, angle, dist)
	local tileList = {getMapTile(map, x1, y1)}
	for i = 1, dist do
		local dirX, dirY = orthogRotate(i, 0, angle)
		table.insert(tileList, getMapTile(map, x1 + dirX, y1 + dirY))
	end
	
	return tileList
end

function findFreeTileFromPoint(map, x, y, size)
	local tile = nil
	while tile == nil do
		local tileX = x + roundFloat(randBetween(-size, size))
		local tileY = y + roundFloat(randBetween(-size, size))
		
		tile = getMapTile(map, tileX, tileY)
		if not checkTileWalkable(tile) then
			tile = nil
			size = size + 1
		end
	end
	return tile
end

function drawMap(map, camera)
	applyParticleInfluence(map, map.particles)
	local visibleCharacters, visibleLances = drawTiles(map, camera)
	drawCharacters(visibleCharacters, camera)
	drawLances(visibleLances, camera)
	drawDecals(map.decals, camera)
end