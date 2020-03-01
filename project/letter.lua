--Instantiate letter
function innitiateLetter(letter, colour)
	local letter = {letter = letter, colour = colour}
	return letter
end

--Draw a letter at tile[x][y] on camera
function drawLetter(letter, x, y, camera)
	setFont("437", camera.tileHeight)
	love.graphics.setColor(letter.colour)
	local drawX, drawY = getDrawPos(x, y, camera)
	love.graphics.print(letter.letter, drawX, drawY)
end