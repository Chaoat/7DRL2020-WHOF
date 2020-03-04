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