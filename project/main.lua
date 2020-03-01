require "map"
require "tile"
require "util"
require "font"
require "character"
require "camera"
require "letter"
require "player"

function love.load()
	Map = innitiateMap()
	Camera = innitiateCamera(0, 0, 800, 600, 0.5, 0.5, 15, 15)
	
	CameraX = 0.5
	CameraY = 0.5
	
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
end

function love.keypressed(key)
	if key == "a" then
		shiftCharacter(Player.character, -1, 0)
	elseif key == "d" then
		shiftCharacter(Player.character, 1, 0)
	end
	if key == "w" then
		shiftCharacter(Player.character, 0, -1)
	elseif key == "s" then
		shiftCharacter(Player.character, 0, 1)
	end
end

function love.draw()
	drawMap(Map, Camera)
end