function innitiateMap()
	local map = {minX = 0, maxX = 0, minY = 0, maxY = 0, tiles = {}}
	fillMapArea(map, "ground", -50, -50, 50, 50)
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
				map.tiles[i][j] = innitiateTile(i, j, "ground")
			end
		end
	end
end

function fillMapArea(map, tileKind, x1, y1, x2, y2)
	expandMap(map, tileKind, x1, y1)
	expandMap(map, tileKind, x2, y2)
end

function getMapTile(map, x, y)
	if map.minX <= x and x <= map.maxX and map.minY <= y and y <= map.maxY then
		return map.tiles[x][y]
	else
		return innitiateTile(x, y, "empty")
	end
end

function drawMap(map, screenX, screenY, width, height, centerX, centerY, tileSizeX, tileSizeY)
	local tilesWide = math.ceil(width/tileSizeX) + 1
	local tilesTall = math.ceil(height/tileSizeY) + 1
	
	local startX = roundFloat(centerX) - math.ceil(tilesWide/2)
	local startY = roundFloat(centerY) - math.ceil(tilesTall/2)
	
	for i = startX, startX + tilesWide do
		for j = startY, startY + tilesTall do
			local tile = getMapTile(map, i, j)
			if tile.properties.walkable then
				local drawX = screenX + width/2 + (i - centerX)*tileSizeX
				local drawY = screenY + height/2 + (j - centerY)*tileSizeY
				
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.rectangle('line', drawX, drawY, tileSizeX, tileSizeY)
				love.graphics.print(i .. ":" .. j, drawX, drawY)
			end
		end
	end
end