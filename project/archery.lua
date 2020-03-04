function fireArrow(character, targetX, targetY)
	local targetTile = getMapTile(character.map, targetX, targetY)
	
	local arrowTiles = getTilesInLine(character.map, character.tile.x, character.tile.y, targetX, targetY)
	for i = 2, #arrowTiles do
		local arrowTile = arrowTiles[i]
		local particle = initiateParticle(character.map, arrowTile.x, arrowTile.y, 0, 0, 1, "arrowTrail")
		particle.infFade = #arrowTiles - i + 1
	end
	
	if targetTile.character then
		damageCharacter(targetTile.character, 2, math.atan2(targetY - character.tile.y, targetX - character.tile.x), 4)
	end
end

function drawPlayerBowRangeOverlay(player, camera)
	if player.firing then
		love.graphics.setColor(0, 0, 0, 0.8)
		local topSquareEnd = (0.5*camera.tilesTall*camera.tileHeight) - (camera.tileHeight*(player.fireRange + 0.5))
		love.graphics.rectangle('fill', 0, 0, ScreenX, topSquareEnd)
		local botSquareStart = (0.5*camera.tilesTall*camera.tileHeight) + (camera.tileHeight*(player.fireRange + 0.5))
		love.graphics.rectangle('fill', 0, botSquareStart, ScreenX, ScreenY - botSquareStart)
		
		local leftSquareEnd = (0.5*camera.tilesWide*camera.tileWidth) - (camera.tileWidth*(player.fireRange + 0.5))
		love.graphics.rectangle('fill', 0, topSquareEnd, leftSquareEnd, botSquareStart - topSquareEnd)
		local rightSquareStart = (0.5*camera.tilesWide*camera.tileWidth) + (camera.tileWidth*(player.fireRange + 0.5))
		love.graphics.rectangle('fill', rightSquareStart, topSquareEnd, ScreenX - rightSquareStart, botSquareStart - topSquareEnd)
	end
end