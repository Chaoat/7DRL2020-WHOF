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

function love.load()
	math.randomseed(os.clock())
	love.keyboard.setKeyRepeat(true)
	
	doFontPreProcessing()
	
	Map = initiateMap()
	Camera = initiateCamera(0, 0, 800, 600, 0.5, 0.5, 12, 12)
	
	Player = initiatePlayer(Map, 0, 0)

	CurRound = initiateRound(player, map, 0)
	
	spawnFormation(Map, 8, 0, getFormationTemplateInDifficultyRange(0, 0), "right")
	spawnStructure(Map, 0, -10, "tree", 0)
	
	GlobalTime = 0
end

function love.update(dt)	
	GlobalTime = GlobalTime + dt
	
	updateMap(Map, dt)
	updatePlayer(Player, Camera, dt)
	updateRound(Player, Map, CurRound, dt)
end

function love.keypressed(key)
	playerKeypressed(Player, Camera, key, CurRound)
end

function love.draw()
	drawMap(Map, Camera)
end
