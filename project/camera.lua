--creates a camera
function initiateCamera(screenX, screenY, width, height, centerX, centerY, tilesWide, tilesTall, minTileWidth, minTileHeight)
	local camera = {screenX = screenX, screenY = screenY, width = width, height = height, centerX = centerX, centerY = centerY, tileWidth = nil, tileHeight = nil, targetTilesWide = tilesWide, tilesWide = nil, targetTilesTall = tilesTall, tilesTall = nil, minTileWidth = minTileWidth, minTileHeight = minTileHeight, movingCursor = false, cursor = nil, cursorX = 0, cursorY = 0}
	updateCameraSize(camera, width, height)
	return camera
end

function resetCamera(camera)
	camera.centerX = 0
	camera.centerY = 0
end

--Updates the width and height of the camera. Necessary so that dependent variable can also be updated
function updateCameraSize(camera, width, height)
	--camera.tilesWide = camera.targetTilesWide
	--camera.tilesTall = camera.targetTilesTall
	--
	--camera.width = width
	--camera.height = height
	--camera.tileWidth = camera.minTileWidth--math.min(math.floor(camera.width/camera.tilesWide), math.floor(camera.height/camera.tilesTall))
	--camera.tileHeight = camera.minTileHeight--camera.tileWidth
	--
	--if camera.tileWidth < camera.minTileWidth then
	--	camera.tileWidth = camera.minTileWidth
	--	camera.tilesWide = math.ceil(camera.width/camera.tileWidth)
	--end
	--if camera.tileHeight < camera.minTileHeight then
	--	camera.tileHeight = camera.minTileHeight
	--	camera.tilesTall = math.ceil(camera.height/camera.tileHeight)
	--end
	
	camera.width = width
	camera.height = height
	camera.tileWidth = camera.minTileWidth
	camera.tileHeight = camera.minTileHeight
	
	camera.tilesWide = math.min(camera.targetTilesWide, math.floor(camera.width/camera.minTileWidth))
	camera.tilesTall = math.min(camera.targetTilesTall, math.floor(camera.height/camera.minTileHeight))
end

function initCameraCursor(camera, player, firing)
	camera.cursor = initiateDecal(player.character.map, player.character.tile.x, player.character.tile.y, "cursor")
	camera.cursorX = player.character.tile.x
	camera.cursorY = player.character.tile.y
	
	if firing then
		camera.cursor.colour = {1, 0, 0, 1}
	end
	
	return camera.cursor
end

function moveCameraCursor(camera, xDir, yDir, inFiringBounds, player)
	jumpCameraCursor(camera, camera.cursorX + xDir, camera.cursorY + yDir, inFiringBounds, player)
end

function jumpCameraCursor(camera, x, y, inFiringBounds, player)
	if inFiringBounds then
		if orthogDistance(player.character.tile.x, player.character.tile.y, x, y) > player.fireRange then
			return false
		end
	end
	
	camera.cursorX = x
	camera.cursorY = y
	camera.cursor.x = camera.cursorX
	camera.cursor.y = camera.cursorY
end

--Given a tilex, tiley and camera, determine the draw position of the tile
function getDrawPos(x, y, camera)
	local drawX = camera.screenX + camera.width/2 + (x - camera.centerX)*camera.tileWidth
	local drawY = camera.screenY + camera.height/2 + (y - camera.centerY)*camera.tileHeight
	return roundFloat(drawX), roundFloat(drawY)
end

function mousePosToTilePos(x, y, camera)
	local xFromCenter = x - camera.width/2
	local yFromCenter = y - camera.height/2
	
	local tileX = math.floor(camera.centerX + xFromCenter/camera.tileWidth)
	local tileY = math.floor(camera.centerY + yFromCenter/camera.tileHeight)
	return tileX, tileY
end

function drawCameraBars(camera)
	local barWidth = camera.width/2 - (camera.tilesWide/2)*camera.tileWidth
	local barHeight = camera.height/2 - (camera.tilesTall/2)*camera.tileHeight
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.rectangle("fill", camera.screenX, camera.screenY, barWidth, camera.height)
	love.graphics.rectangle("fill", camera.screenX, camera.screenY, camera.width, barHeight)
	love.graphics.rectangle("fill", camera.screenX + camera.width, camera.screenY, -barWidth, camera.height)
	love.graphics.rectangle("fill", camera.screenX, camera.screenY + camera.height, camera.width, -barHeight)
end