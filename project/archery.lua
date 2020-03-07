function fireArrow(character, targetX, targetY)
	love.audio.play("bowRelease.ogg", "static", false)
	local targetTile = getMapTile(character.map, targetX, targetY)
	
	local arrowTiles = getTilesInLine(character.map, character.tile.x, character.tile.y, targetX, targetY)
	for i = 2, #arrowTiles do
		local arrowTile = arrowTiles[i]
		local particle = initiateParticle(character.map, arrowTile.x, arrowTile.y, 0, 0, 1, "arrowTrail")
		particle.infFade = #arrowTiles - i + 1
	end
	
	if targetTile.character then
		if not targetTile.character.arrowImmune then
			damageCharacter(targetTile.character, 2, math.atan2(targetY - character.tile.y, targetX - character.tile.x), 4, "shot")
			enemyarrowsound()
		end
	else
	    love.audio.play("arrowmiss.ogg", "static", false)
	end
end

function drawPlayerBowRangeOverlay(player, camera)
	if player.firing then
		love.graphics.setColor(0, 0, 0, 0.8)
		local topSquareEnd = (0.5*camera.height) - (camera.tileHeight*(player.fireRange))
		love.graphics.rectangle('fill', 0, 0, camera.width, topSquareEnd)
		local botSquareStart = (0.5*camera.height) + (camera.tileHeight*(player.fireRange + 1))
		love.graphics.rectangle('fill', 0, botSquareStart, camera.width, camera.height - botSquareStart)
		
		local leftSquareEnd = (0.5*camera.width) - (camera.tileWidth*(player.fireRange))
		love.graphics.rectangle('fill', 0, topSquareEnd, leftSquareEnd, botSquareStart - topSquareEnd)
		local rightSquareStart = (0.5*camera.width) + (camera.tileWidth*(player.fireRange + 1))
		love.graphics.rectangle('fill', rightSquareStart, topSquareEnd, camera.width - rightSquareStart, botSquareStart - topSquareEnd)
	end
end