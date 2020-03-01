require "map"
require "tile"
require "util"
require "font"
require "character"
require "camera"
require "letter"
require "player"

function love.load()
	love.keyboard.setKeyRepeat(true)
	
	Map = innitiateMap()
	Camera = innitiateCamera(0, 0, 800, 600, 0.5, 0.5, 15, 15)
	
	Player = innitiatePlayer(Map, 0, 0)
end

function love.update(dt)
	local camSpeed = 10
	if love.keyboard.isDown("left") then
		Camera.centerX = Camera.centerX - camSpeed*dt
	end
	if love.keyboard.isDown("right") then
		Camera.centerX = Camera.centerX + camSpeed*dt
	end
	if love.keyboard.isDown("up") then
		Camera.centerY = Camera.centerY - camSpeed*dt
	end
	if love.keyboard.isDown("down") then
		Camera.centerY = Camera.centerY + camSpeed*dt
	end
	
	updateMap(Map, dt)
	updatePlayer(Player, Camera, dt)
end

function love.keypressed(key)
	playerKeypressed(Player, Camera, key)
end

function love.draw()
	drawMap(Map, Camera)
end