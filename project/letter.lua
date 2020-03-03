local fontImage = love.graphics.newImage("fonts/font.png")
local quadBank = {}
local letterTileWidth = 12
local letterTileHeight = 12

function doFontPreProcessing()
	local addQuadToBank = function(letter, x, y)
		quadBank[letter] = love.graphics.newQuad(1 + (letterTileWidth + 1)*x, 1 + (letterTileHeight + 1)*y, letterTileWidth, letterTileHeight, fontImage:getWidth(), fontImage:getHeight())
	end
	
	for i = 0, 25 do
		addQuadToBank(string.char(65 + i), i%13, math.floor(i/13))
		addQuadToBank(string.char(97 + i), i%13, 2 + math.floor(i/13))
	end
	addQuadToBank("\\", 0, 4)
	addQuadToBank("|", 1, 4)
	addQuadToBank("/", 2, 4)
	addQuadToBank("-", 3, 4)
	addQuadToBank("+", 4, 4)
	
	addQuadToBank(";", 8, 4)
	addQuadToBank(",", 9, 4)
	addQuadToBank(".", 10, 4)
	addQuadToBank("~", 11, 4)
	addQuadToBank("'", 12, 4)
	
	addQuadToBank("@", 0, 5)
	addQuadToBank(" ", 1, 5)
	addQuadToBank("#", 2, 5)
end

--Instantiate letter
function initiateLetter(letter, colour)
	local letter = {letter = letter, colour = colour, facing = 0}
	return letter
end

function copyLetter(letter)
	local newLetter = initiateLetter(letter.letter, letter.colour)
	return newLetter
end

--Draw a letter at tile[x][y] on camera
function drawLetter(letter, x, y, camera)
	love.graphics.setColor(letter.colour)
	
	local drawX, drawY = getDrawPos(x, y, camera)
	
	if not quadBank[letter.letter] then
		print("Letter missing: " .. letter.letter)
	end
	love.graphics.draw(fontImage, quadBank[letter.letter], drawX + camera.tileWidth/2, drawY + camera.tileHeight/2, letter.facing, camera.tileWidth/letterTileWidth, camera.tileHeight/letterTileHeight, letterTileWidth/2, letterTileHeight/2)
end