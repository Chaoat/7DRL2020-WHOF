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
--Oh man, this is getting out of control. There's gotta be a better way to do this

function love.load()
	math.randomseed(os.clock())
	love.keyboard.setKeyRepeat(true)
	
	doFontPreProcessing()
	preProcessFormations()
	
	Map = initiateMap(150)
	Camera = initiateCamera(0, 0, 800, 600, 0.5, 0.5, 70, 70, 12, 12)
	--Camera = initiateCamera(0, 0, 800, 600, 0.5, 0.5, 999, 999, 4, 4)
	
	Player = initiatePlayer(Map, 0, 0)
	Interface = initiateInterface(Player)

	CurRound = initiateRound(player, map, 0)
	
	--spawnFormation(Map, 15, 0, getFormationTemplateInDifficultyRange(0, 0), "left")
	--spawnStructure(Map, 0, -10, "smallfire", 0)
	
	--spawnEncounter(Map, 20, 0, 10, 2)
	
	GlobalTime = 0
end

function love.resize(x, y)
	updateCameraSize(Camera, x, y)
end

function love.update(dt)
	if dt > 0.1 then
		dt = 1/60
	end
	
	GlobalTime = GlobalTime + dt
	
	--print(dt*60)
	
	updateMap(Map, dt)
	updatePlayer(Player, Camera, dt)
	updateRound(Player, Map, CurRound, dt)
end

function love.keypressed(key)
	playerKeypressed(Player, Camera, key, CurRound)
end

function love.mousepressed(x, y, button)
	if button == 1 then
		checkInterfaceClicked(x, y, Interface, Camera, Player, CurRound)
	end
end

function love.draw()
	drawMap(Map, Camera)
	drawPlayerBowRangeOverlay(Player, Camera)
	drawInterface(Interface, Camera)
	drawTopInterface(Interface, Camera, Player)
end
