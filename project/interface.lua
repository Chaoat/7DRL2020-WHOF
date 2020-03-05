function initiateInterface(player)
	local interface = {tilesWide = 50, tilesHigh = 12, frontColour = {1, 1, 1, 1}, backColour = {0, 0, 0, 0.8}, buttons = {}, buttonTiles = {}, text = {}, player = player, healthBar = {x = 29, y = 10}, arrowBar = {x = 17, y = 8}}
	for i = 0, interface.tilesWide do
		interface.buttonTiles[i] = {}
	end
	for i = 0, interface.tilesWide do
		interface.text[i] = {}
	end
	
	--Escape
	addButtonToInterface(interface, 2, 2, "Esc", "escape", size)
	addTextToInterface(interface, 6, 2, {"-", " ", "b", "a", "c", "k"})
	
	--Sword
	addButtonToInterface(interface, 2, 10, "s", "s", size)
	addTextToInterface(interface, 4, 10, {"-", " ", "s", "w", "o", "r", "d"})
	--Bow
	addButtonToInterface(interface, 2, 6, "f", "f", size)
	addTextToInterface(interface, 4, 6, {"-", " ", "s", "h", "o", "o", "t"})
	--Examine
	addButtonToInterface(interface, 13, 10, "x", "x", size)
	addTextToInterface(interface, 15, 10, {"-", " ", "e", "x", "a", "m", "i", "n", "e"})
	
	local keyPadX = 38
	addButtonToInterface(interface, keyPadX + 2, 10, "1", "kp1", size)
	addTextToInterface(interface, keyPadX + 4, 8, {"dlA"})
	addButtonToInterface(interface, keyPadX + 6, 10, "2", "kp2", size)
	addTextToInterface(interface, keyPadX + 6, 8, {"dA"})
	addButtonToInterface(interface, keyPadX + 10, 10, "3", "kp3", size)
	addTextToInterface(interface, keyPadX + 8, 8, {"drA"})
	addButtonToInterface(interface, keyPadX + 2, 6, "4", "kp4", size)
	addTextToInterface(interface, keyPadX + 4, 6, {"lA"})
	addButtonToInterface(interface, keyPadX + 6, 6, "5", "kp5", size)
	addButtonToInterface(interface, keyPadX + 10, 6, "6", "kp6", size)
	addTextToInterface(interface, keyPadX + 8, 6, {"rA"})
	addButtonToInterface(interface, keyPadX + 2, 2, "7", "kp7", size)
	addTextToInterface(interface, keyPadX + 4, 4, {"ulA"})
	addButtonToInterface(interface, keyPadX + 6, 2, "8", "kp8", size)
	addTextToInterface(interface, keyPadX + 6, 4, {"uA"})
	addButtonToInterface(interface, keyPadX + 10, 2, "9", "kp9", size)
	addTextToInterface(interface, keyPadX + 8, 4, {"urA"})
	
	addTextToInterface(interface, interface.healthBar.x, interface.healthBar.y, {"H", "E", "A", "L", "T", "H"})
	addTextToInterface(interface, interface.arrowBar.x, interface.arrowBar.y, {"A", "R", "R", "O", "W", "S"})
	
	return interface
end

function addButtonToInterface(interface, x, y, displayLetter, letter, size)
	local button = {x = x, y = y, letter = letter, size = size, tiles = {}}
	
	local addButtonTile = function(bX, bY, letterI)
		local tileLetter = initiateLetter(letter, interface.frontColour, interface.backColour)
		interface.buttonTiles[bX][bY] = {button = button, letter = initiateLetter(letterI, interface.frontColour, interface.backColour)}
		table.insert(button.tiles, tileLetter)
	end
	
	addButtonTile(x - 1, y - 1, "/")
	addButtonTile(x - 1, y, "|")
	addButtonTile(x - 1, y + 1, "\\")
	
	local xOff = 0
	for i = 1, #displayLetter do
		local c = string.sub(displayLetter, i, i)
		addButtonTile(x + xOff, y, c)
		addButtonTile(x + xOff, y + 1, "-")
		addButtonTile(x + xOff, y - 1, "-")
		xOff = xOff + 1
	end
	
	addButtonTile(x + xOff, y + 1,  "/")
	addButtonTile(x + xOff, y, "|")
	addButtonTile(x + xOff, y - 1,  "\\")
	
	table.insert(interface.buttons, button)
	return button
end

function addTextToInterface(interface, x, y, text)
	local xOff = 0
	for i = 1, #text do
		local c = text[i]
		local letter = initiateLetter(c, interface.frontColour, interface.backColour)
		
		interface.text[x + xOff][y] = letter
		xOff = xOff + 1
	end
end

function drawInterface(interface, camera)
	local left = camera.centerX - interface.tilesWide/2
	local top = camera.centerY + (camera.tilesTall/2 - interface.tilesHigh)
	
	local backLetter = initiateLetter(" ", {0, 0, 0, 0}, interface.backColour)
	local sideLetter = initiateLetter("|", interface.frontColour, interface.backColour)
	local topLetter = initiateLetter("-", interface.frontColour, interface.backColour)
	for i = 0, interface.tilesWide do
		for j = 0, interface.tilesHigh do
			local x = i + left
			local y = j + top
			
			if y == top then
				if x == left then
					drawLetter(initiateLetter("/", interface.frontColour, interface.backColour), x, y, camera)
				elseif x == left + interface.tilesWide then
					drawLetter(initiateLetter("\\", interface.frontColour, interface.backColour), x, y, camera)
				else
					drawLetter(topLetter, x, y, camera)
				end
			elseif x == left or x == left + interface.tilesWide then
				drawLetter(sideLetter, x, y, camera)
			else
				if interface.text[i][j] then
					drawLetter(interface.text[i][j], x, y, camera)
				elseif interface.buttonTiles[i][j] then
					drawLetter(interface.buttonTiles[i][j].letter, x, y, camera)
				else
					drawLetter(backLetter, x, y, camera)
				end
			end
		end
	end
	
	local healthLetter = initiateLetter("#", {1, 0, 0, 1}, {0.5, 0, 0, 0.5})
	local flash = 1 - (GlobalTime - interface.player.lastHit)
	local flashHealthLetter = initiateLetter("#", {1, 1, 1, flash}, {0.5, 0, 0, 0.5})
	local healthBackLetter = initiateLetter(" ", {1, 0, 0, 1}, {0.5, 0, 0, 0.5})
	for i = 1, interface.player.maxHealth do
		for j = 0, 3 do
			if i <= interface.player.health then
				drawLetter(healthLetter, left + j + interface.healthBar.x + 1, top - i + interface.healthBar.y, camera)
			elseif i <= interface.player.lastHealth then
				drawLetter(flashHealthLetter, left + j + interface.healthBar.x + 1, top - i + interface.healthBar.y, camera)
			else
				drawLetter(healthBackLetter, left + j + interface.healthBar.x + 1, top - i + interface.healthBar.y, camera)
			end
		end
	end
	
	local arrowLetter1 = initiateLetter(">>", interface.frontColour, interface.backColour)
	local arrowLetter2 = initiateLetter("-", interface.frontColour, interface.backColour)
	local arrowLetter3 = initiateLetter("rA", interface.frontColour, interface.backColour)
	for i = 1, interface.player.arrows do
		drawLetter(arrowLetter1, left + interface.arrowBar.x + 1, top - i + interface.arrowBar.y, camera)
		drawLetter(arrowLetter2, left + interface.arrowBar.x + 2, top - i + interface.arrowBar.y, camera)
		drawLetter(arrowLetter2, left + interface.arrowBar.x + 3, top - i + interface.arrowBar.y, camera)
		drawLetter(arrowLetter3, left + interface.arrowBar.x + 4, top - i + interface.arrowBar.y, camera)
	end
end

function checkInterfaceClicked(x, y, interface, camera, player, curRound)
	local tileX, tileY = mousePosToTilePos(x, y, camera)
	local leftMost = math.floor(camera.centerX) - interface.tilesWide/2
	local topMost = math.floor(camera.centerY) + math.ceil(camera.tilesTall/2 - interface.tilesHigh)
	
	--print(tileX .. ":" .. tileY)
	
	if tileX >= leftMost and tileX <= leftMost + interface.tilesWide then
		local iX = tileX - leftMost
		local iY = tileY - topMost
		--print((tileX - leftMost) .. ":" .. (tileY - topMost))
		if interface.buttonTiles[iX][iY] then
			playerKeypressed(player, camera, interface.buttonTiles[iX][iY].button.letter, curRound)
		end
	end
end