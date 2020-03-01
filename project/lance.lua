function initiateLance(map, character, colour)
	local tileX = character.x + roundFloat(math.cos(character.facing))
	local tileY = character.y + roundFloat(math.sin(character.facing))
	local lance = {character = character, tile = getMapTile(map, tileX, tileY), colour = colour}
	lance.tile.lance = lance
	return lance
end