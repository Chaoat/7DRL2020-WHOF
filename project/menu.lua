function initiateMenu()
	local menu = {mainInterface = createMainInterface(), introInterface = createIntroInterface(), morgueInterface = createMorgueInterface(), deathListOffset = 0, stage = "main", titleImage = love.graphics.newImage("images/Title Hooves.png")}
	return menu
end

function enterMenu(menu, camera)
	GameStarted = false
	menu.stage = "main"
	resetCamera(camera)
	
	pauseWind()
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
	addButtonToInterface(interface, 26, 34, "Ride Out", "ride", size)
	addButtonToInterface(interface, 26, 39, "Remember", "morgue", size)
	addButtonToInterface(interface, 28, 44, "Flee", "quit", size)
	
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
	addButtonToInterface(interface, 27, 41, "Onward", "start", size)
	addButtonToInterface(interface, 28, 46, "Back", "returnToMenu", size)
	
	return interface
end

function createMorgueInterface()
	local interface = {tilesWide = 60, tilesHigh = 50, frontColour = {1, 1, 1, 1}, backColour = {0, 0, 0, 0.8}, buttons = {}, buttonTiles = {}, text = {}}
	for i = 0, interface.tilesWide do
		interface.buttonTiles[i] = {}
	end
	for i = 0, interface.tilesWide do
		interface.text[i] = {}
	end
	
	--Start
	addButtonToInterface(interface, 28, 46, "Back", "returnToMenu", size)
	
	return interface
end

function drawMenu(menu, camera)
	if menu.stage == "main" then
		drawMenuInterface(menu, menu.mainInterface, camera)
	elseif menu.stage == "intro" then
		drawMenuInterface(menu, menu.introInterface, camera)
	elseif menu.stage == "morgue" then
		drawMenuInterface(menu, menu.morgueInterface, camera)
	end
end

function compileDeathText(menu, camera)
	local list = getDeathList()
	menu.deathHeight = #list
	
	local deathText = ""
	
	local nEntries = math.min(#list - menu.deathListOffset, 30)
	for i = 1 + menu.deathListOffset, nEntries + menu.deathListOffset do
		local newLine = i .. ".  " .. list[i].date
		while #newLine < 25 do
			newLine = newLine .. " "
		end
		
		newLine = newLine .. math.floor(100*list[i].distance) .. "%"
		while #newLine < 32 do
			newLine = newLine .. " "
		end
		
		local causeText = ""
		if list[i].cause == "shot" then
			causeText = "Shot by an arrow"
		elseif list[i].cause == "sworded" then
			causeText = "Struck down by a soldiers blade"
		elseif list[i].cause == "lanced" then
			causeText = "Skewered by a lance"
		elseif list[i].cause == "collision" then
			causeText = "Shamefully collided with deadly force"
		elseif list[i].cause == "suicide" then
			causeText = "Slain by despair"
		elseif list[i].cause == "victory" then
			causeText = "Completed the journey a hero"
		end
		
		newLine = newLine .. causeText
		
		deathText = deathText .. newLine .. "\n"
	end
	
	if #list - menu.deathListOffset > 30 then
		deathText = deathText .. "                                         V V V"
	end
	
	menu.deathText = deathText
end

function scrollDeathMenu(menu, camera, x, y)
	local list = getDeathList()
	if y < 0 then
		if #list > 30 then
			menu.deathListOffset = math.min(menu.deathListOffset + 1, #list - 30)
		end
	else
		menu.deathListOffset = math.max(menu.deathListOffset - 1, 0)
	end
	
	compileDeathText(menu, camera)
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
	
	if menu.stage == "main" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(menu.titleImage, camera.width/2, camera.height/2 - 130, 0, 1, 1, menu.titleImage:getWidth()/2, menu.titleImage:getHeight()/2)
	elseif menu.stage == "intro" then
		local text = "For one year the Atagan war machine has raged across the continent, feeding the greed of the Usurper and demolishing the ancestor's ways. Fuelled by the use of unconventional and dishonourable tactics, they have marched relentlessly through the native steppes of our peoples, destroying the lesser clans and shaming the spirits. Now they are here, in the Eijidin hunting grounds, the strongest of all the clans. If the Atagan can not be stopped by our warriors, they can be stopped by no one, and the ancient ways are surely doomed.\n\nA brave warrior bleeding from the wounds of several arrows rode into camp at sunset, telling of a great army maneuvering to flank our greatest general, Ulijin, in the east. Ulijin is currently engaged in a brutal war of attrition with the main Atagan force, and if we are to emerge victorious, he must be warned of this threat. We are positioned however on the other side of the Atagan force, and the chosen messenger must ride through the battle lines if they are to arrive in time.\n\nYou are an honourable Eijidini warrior. Since you were born, you have spent more time in the saddle than on foot. From childhood you have trained in the sword, lance and bow, and have mastered the use of each. You have been selected for this mission. May the ancestor's welcome you into their halls."
		
		local drawnText = string.sub(text, 1, math.ceil(60*GlobalTime))
		
		setFont("clacon", 24)
		
		local textX = camera.width/2 - camera.tileWidth*camera.tilesWide/2 + 15
		local textY = camera.height/2 - camera.tileHeight*camera.tilesTall/2 + 20
		local textWidth = camera.tileWidth*camera.tilesWide - 30
		
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(drawnText, textX, textY, textWidth, "left")
	elseif menu.stage == "morgue" then
		local textX = camera.width/2 - camera.tileWidth*camera.tilesWide/2 + 15
		local textY = camera.height/2 - camera.tileHeight*camera.tilesTall/2 + 30
		local textWidth = camera.tileWidth*camera.tilesWide - 30
		
		setFont("clacon", 20)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(menu.deathText, textX, textY, textWidth, "left")
		
		if menu.deathListOffset > 0 then
			love.graphics.printf("                                         ^ ^ ^", textX, textY - 15, textWidth, "left")
		end
	end
end

function checkMenuClicked(x, y, menu, camera)
	if menu.stage == "main" then
		checkMenuInterfaceClicked(x, y, menu.mainInterface, menu, camera)
	elseif menu.stage == "intro" then
		GlobalTime = 100
		checkMenuInterfaceClicked(x, y, menu.introInterface, menu, camera)
	elseif menu.stage == "morgue" then
		checkMenuInterfaceClicked(x, y, menu.morgueInterface, menu, camera)
	end
end

function checkMenuInterfaceClicked(x, y, interface, menu, camera)
	local tileX, tileY = mousePosToTilePos(x, y, camera)
	local leftMost = camera.centerX - interface.tilesWide/2
	local topMost = camera.centerY - interface.tilesHigh/2
	
	--print(tileX .. ":" .. tileY)
	
	if tileX >= leftMost and tileX <= leftMost + interface.tilesWide then
		local iX = tileX - leftMost
		local iY = tileY - topMost
		--print((tileX - leftMost) .. ":" .. (tileY - topMost))
		if interface.buttonTiles[iX][iY] then
			local command = interface.buttonTiles[iX][iY].button.letter
			--print(command)
			
			if command == "start" then
				startGame()
			elseif command == "returnToMenu" then
				menu.stage = "main"
			elseif command == "ride" then
				menu.stage = "intro"
				GlobalTime = 0
			elseif command == "morgue" then
				menu.stage = "morgue"
				menu.deathListOffset = 0
				compileDeathText(menu, camera)
			elseif command == "quit" then
				love.event.quit()
			end
			return true
		end
	end
	return false
end