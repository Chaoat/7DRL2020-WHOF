--Instantiate letter
function initiateLetter(letter, colour)
	local letter = {letter = letter, colour = colour}
	return letter
end

function copyLetter(letter)
	local newLetter = initiateLetter(letter.letter, letter.colour)
	return newLetter
end

--Draw a letter at tile[x][y] on camera
function drawLetter(letter, x, y, camera)
	setFont("square", camera.tileHeight)
	love.graphics.setColor(letter.colour)
	local drawX, drawY = getDrawPos(x, y, camera)
	love.graphics.print(letter.letter, drawX, drawY)
end