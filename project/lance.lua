function initiateLance(map, character, colour)
	local tileX = character.x + roundFloat(math.cos(character.facing))
	local tileY = character.y + roundFloat(math.sin(character.facing))
	local lance = {character = character, tile = getMapTile(map, tileX, tileY), colour = colour}
	
	lance.tile.lance = lance
	character.lance = lance
	
	return lance
end

function drawLances(lances, camera)
	for i = 1, #lances do
		local lance = lances[i]
		local character = lance.character
		local letter = "-"
		if distanceBetweenAngles(character.facing, math.pi/4)%math.pi == 0 then
			letter = "\\"
		elseif distanceBetweenAngles(character.facing, math.pi/2)%math.pi == 0 then
			letter = "|"
		elseif distanceBetweenAngles(character.facing, 3*math.pi/4)%math.pi == 0 then
			letter = "/"
		end
		
		drawLetter({letter = letter, colour = character.lance.colour}, character.lance.tile.x, character.lance.tile.y, camera)
	end
end