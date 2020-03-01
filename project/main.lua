require "map"
require "tile"
require "util"
require "font"
require "character"
require "camera"
require "letter"
require "player"
require "round"
require "aiturn"
require "turn"

function love.load()
	love.keyboard.setKeyRepeat(true)
	
	Map = innitiateMap()
	Camera = innitiateCamera(0, 0, 800, 600, 0.5, 0.5, 15, 15)
	
	Player = innitiatePlayer(Map, 0, 0)
end

function love.update(dt)	
	updateMap(Map, dt)
	updatePlayer(Player, Camera, dt)
end

function love.keypressed(key)
	playerKeypressed(Player, Camera, key)
end

function love.draw()
	drawMap(Map, Camera)
end