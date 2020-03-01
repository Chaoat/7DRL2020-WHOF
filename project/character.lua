--creates a character
function innitiateCharacter(map, x, y, letter)
	local tile = getMapTile(map, x, y)
	local character = {x = x, y = y, tile = tile, letter = letter, map = map}
	
	tile.character = character
	table.insert(map.characters, character)
	return character
end