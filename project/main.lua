require "map"
require "tile"
require "util"
require "font"
require "character"
require "camera"
require "letter"
require "player"
require "enemy"
require "mapgeneration"
require "formationTable"
require "formation"
require "round"
require "aiturn"
require "mapstructures"
require "lance"
require "decal"
require "SimplyTimers"
require "roundmanager"
require "particles"
require "archery"
require "interface"
require "consumable"
require "foliage"
require "menu"
require "endScreen"
require "soundmanager"
require "love.audio"
require "morgue"
--Oh man, this is getting out of control. There's gotta be a better way to do this

function love.load()
	math.randomseed(os.clock())
	love.keyboard.setKeyRepeat(true)
	
	initWind()
	doFontPreProcessing()
	preProcessFormations()
	
	GlobalTime = 0
	
	WinDistance = 2000
	Camera = initiateCamera(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), 0.5, 0.5, 60, 60, 12, 12)
	Menu = initiateMenu()
	
	GameStarted = false
	enterMenu(Menu, Camera)
end

function startGame()
	resetEndScreen()
	resetCamera(Camera)
	GlobalTime = 0
	Map = initiateMap(120)
	--Camera = initiateCamera(0, 0, 800, 600, 0.5, 0.5, 999, 999, 4, 4)
	
	Player = initiatePlayer(Map, 0, 0)
	Interface = initiateInterface(Player)

	CurRound = initiateRound(player, map, 0)
	
	--spawnFormation(Map, 15, 0, getFormationTemplateInDifficultyRange(0, 0), "left")
	--spawnFormation(Map, 15, 5, getFormationTemplateInDifficultyRange(0, 0), "left")
	--spawnFormation(Map, 15, -5, getFormationTemplateInDifficultyRange(0, 0), "left")
	
	--spawnEncounter(Map, 20, 0, 10, 2)
	
	GameStarted = true
	
	playWind()
end

function love.resize(x, y)
	updateCameraSize(Camera, x, y)
end

function love.quit()
	if GameStarted and Player.dead == false then
		damagePlayer(Player, 8, "suicide")
		startRound(Player, Map, CurRound)
		return true
	end
	return false
end

function love.update(dt)
	if dt > 0.1 then
		dt = 1/60
	end
	
	GlobalTime = GlobalTime + dt
	--print(dt*60)
	
	if GameStarted then
		updateMap(Map, dt)
		updatePlayer(Player, Camera, dt)
		updateRound(Player, Map, CurRound, dt)
		updateWind(dt)
	end

	love.audio.update()
end

function love.keypressed(key)
	if GameStarted then
		playerKeypressed(Player, Camera, key, CurRound)
	end
end

function love.wheelmoved(x, y)
	scrollDeathMenu(Menu, Camera, x, y)
end

function love.mousepressed(x, y, button)
	if GameStarted then
		if button == 1 then
			if not checkInterfaceClicked(x, y, Interface, Camera, Player, CurRound) then
				playerDecalsClicked(x, y, Player, Camera, CurRound)
			end
			clickEndScreen(x, y, Menu, Camera)
		end
	else
		if button == 1 then
			checkMenuClicked(x, y, Menu, Camera)
		end
	end
end

function love.draw()
	if GameStarted then
		drawMap(Map, Camera)
		drawPlayerBowRangeOverlay(Player, Camera)
		drawExamineScreen(Map, Interface, Camera, Player)
		drawInterface(Interface, Camera)
		drawTopInterface(Interface, Camera, Player)
		
		drawEndScreen(Camera)
		
		drawCameraBars(Camera)
	else
		drawMenu(Menu, Camera)
	end
end
