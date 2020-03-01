local controls = {}
controls["moveBottomLeft"] = {"4", "left"}
controls["moveRight"] = {"4", "left"}
controls["moveLeft"] = {"4", "left"}
controls["moveLeft"] = {"4", "left"}
controls["moveLeft"] = {"4", "left"}
controls["moveLeft"] = {"4", "left"}
controls["moveLeft"] = {"4", "left"}

function innitiatePlayer(map, x, y)
	player = {character = nil}
	player.character = activateCharacter(innitiateCharacter(map, x, y, innitiateLetter("@", {1, 1, 0, 1})))
	return player
end