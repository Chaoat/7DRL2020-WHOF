function initiateMenu()
	local menu = {mainInterface = createMainInterface(), introInterface = createIntroInterface(), stage = "main"}
	return menu
end

function createMainInterface()
	local interface = {tilesWide = 60, tilesHigh = 50, frontColour = {1, 1, 1, 1}, backColour = {0, 0, 0, 0.8}, buttons = {}, buttonTiles = {}, text = {}}
	for i = 0, interface.tilesWide do
		interface.buttonTiles[i] = {}
	end
	for i = 0, interface.tilesWide do
		interface.text[i] = {}
	end
	
	--Start
	addButtonToInterface(interface, 26, 28, "Ride Out", "ride", size)
	addButtonToInterface(interface, 26, 35, "Remember", "morgue", size)
	addButtonToInterface(interface, 28, 42, "Flee", "quit", size)
	
	return interface
end

function createIntroInterface()
	local interface = {tilesWide = 60, tilesHigh = 50, frontColour = {1, 1, 1, 1}, backColour = {0, 0, 0, 0.8}, buttons = {}, buttonTiles = {}, text = {}}
	for i = 0, interface.tilesWide do
		interface.buttonTiles[i] = {}
	end
	for i = 0, interface.tilesWide do
		interface.text[i] = {}
	end
	
	--Start
	addButtonToInterface(interface, 27, 38, "Onward", "start", size)
	addButtonToInterface(interface, 28, 44, "Back", "returnToMenu", size)
	
	return interface
end

function drawMenu(menu, camera)
	if menu.stage == "main" then
		drawMenuInterface(menu, menu.mainInterface, camera)
	elseif menu.stage == "intro" then
		drawMenuInterface(menu, menu.introInterface, camera)
	end
end

function drawMenuInterface(menu, interface, camera)
	local left = camera.centerX - interface.tilesWide/2
	local top = camera.centerY - interface.tilesHigh/2
	
	-- Drawing the bottom interface box
	local backLetter = initiateLetter(" ", {0, 0, 0, 0}, interface.backColour)
	local sideLetter = initiateLetter("|", interface.frontColour, interface.backColour)
	local topLetter = initiateLetter("-", interface.frontColour, interface.backColour)
	for i = 0, interface.tilesWide do
		for j = 0, interface.tilesHigh do
			local x = i + left
			local y = j + top
			
			if interface.text[i][j] then
				drawLetter(interface.text[i][j], x, y, camera)
			elseif interface.buttonTiles[i][j] then
				--print(interface.buttonTiles[i][j].letter)
				drawLetter(interface.buttonTiles[i][j].letter, x, y, camera)
			else
				drawLetter(backLetter, x, y, camera)
			end
		end
	end
end

function checkMenuClicked(x, y, menu, camera)
	if menu.stage == "main" then
		checkMenuInterfaceClicked(x, y, menu.mainInterface, menu, camera)
	elseif menu.stage == "intro" then
		checkMenuInterfaceClicked(x, y, menu.introInterface, menu, camera)
	end
end

function checkMenuInterfaceClicked(x, y, interface, menu, camera)
	local tileX, tileY = mousePosToTilePos(x, y, camera)
	local leftMost = math.floor(camera.centerX) - interface.tilesWide/2
	local topMost = math.floor(camera.centerY) + math.ceil(camera.tilesTall/2 - interface.tilesHigh)
	
	--print(tileX .. ":" .. tileY)
	
	if tileX >= leftMost and tileX <= leftMost + interface.tilesWide then
		local iX = tileX - leftMost
		local iY = tileY - topMost
		--print((tileX - leftMost) .. ":" .. (tileY - topMost))
		if interface.buttonTiles[iX][iY] then
			local command = interface.buttonTiles[iX][iY].button.letter
			
			if command == "start" then
				startGame()
			elseif command == "returnToMenu" then
				menu.stage = "main"
			elseif command == "ride" then
				menu.stage = "intro"
				GlobalTime = 0
			elseif command == "quit" then
				love.event.quit()
			end
			return true
		end
	end
	return false
end