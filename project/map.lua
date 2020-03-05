function initiateMap()
	local map = {minX = 0, maxX = 0, minY = 0, maxY = 0, tiles = {}, characters = {}, activeCharacters = {}, enemies = {}, formations = {}, lances = {}, decals = {}, particles = {}}
	fillMapArea(map, "ground", -100, -100, 100, 100)
	return map
end

function expandMap(map, tileKind, newTileX, newTileY)
	if map.minX > newTileX then
		map.minX = newTileX
	elseif map.maxX < newTileX then
		map.maxX = newTileX
	end
	if map.minY > newTileY then
		map.minY = newTileY
	elseif map.maxY < newTileY then
		map.maxY = newTileY
	end
	
	for i = map.minX, map.maxX do
		if map.tiles[i] == nil then
			map.tiles[i] = {}
		end
		
		for j = map.minY, map.maxY do
			if map.tiles[i][j] == nil then
				map.tiles[i][j] = initiateTile(i, j, "ground")
			end
		end
	end
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

function drawMap(map, camera)
	applyParticleInfluence(map, map.particles)
	local visibleCharacters, visibleLances = drawTiles(map, camera)
	drawCharacters(visibleCharacters, camera)
	drawLances(visibleLances, camera)
	drawDecals(map.decals, camera)
end