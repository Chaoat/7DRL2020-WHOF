local decalBank = {}

function initiateDecal(map, x, y, imageName)
	if not decalBank[imageName] then
		decalBank[imageName] = love.graphics.newImage("images/" .. imageName .. ".png")
		decalBank[imageName]:setFilter("nearest", "nearest")
	end
	
	local decal = {map = map, x = x, y = y, image = decalBank[imageName], imageWidth = decalBank[imageName]:getWidth(), imageHeight = decalBank[imageName]:getHeight(), colour = {1, 1, 1, 1}, facing = 0}
	table.insert(map.decals, decal)
	return decal
end

function updateDecals(decals, dt)
	local i = 1
	while i <= #decals do
		local decal = decals[i]
		
		if decal.remove then
			table.remove(decals, i)
		else
			i = i + 1
		end
	end
end

function drawDecals(decals, camera)
	for i = 1, #decals do
		local decal = decals[i]
		love.graphics.setColor(decal.colour)
		local drawX, drawY = getDrawPos(decal.x, decal.y, camera)
		love.graphics.draw(decal.image, drawX + camera.tileWidth/2, drawY + camera.tileHeight/2, decal.facing, camera.tileWidth/decal.imageWidth, camera.tileHeight/decal.imageHeight, decal.imageWidth/2, decal.imageHeight/2)
	end
end