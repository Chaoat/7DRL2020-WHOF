--creates a camera
function initiateCamera(screenX, screenY, width, height, centerX, centerY, tileWidth, tileHeight)
	local camera = {screenX = screenX, screenY = screenY, width = width, height = height, centerX = centerX, centerY = centerY, tileWidth = tileWidth, tileHeight = tileHeight, tilesWide = nil, tilesTall = nil, movingCursor = false, cursor = nil, cursorX = 0, cursorY = 0}
	updateCameraSize(camera, width, height)
	return camera
end

--Updates the width and height of the camera. Necessary so that dependent variable can also be updated
function updateCameraSize(camera, width, height)
	camera.tilesWide = math.ceil(camera.width/camera.tileWidth) + 1
	camera.tilesTall = math.ceil(camera.height/camera.tileHeight) + 1
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
	if inFiringBounds then
		if orthogDistance(player.character.tile.x, player.character.tile.y, camera.cursorX + xDir, camera.cursorY + yDir) > player.fireRange then
			return false
		end
	end
	
	camera.cursorX = camera.cursorX + xDir
	camera.cursorY = camera.cursorY + yDir
	
	camera.cursor.x = camera.cursorX
	camera.cursor.y = camera.cursorY
end

--Given a tilex, tiley and camera, determine the draw position of the tile
function getDrawPos(x, y, camera)
	local drawX = camera.screenX + camera.width/2 + (x - camera.centerX)*camera.tileWidth
	local drawY = camera.screenY + camera.height/2 + (y - camera.centerY)*camera.tileHeight
	return roundFloat(drawX), roundFloat(drawY)
end