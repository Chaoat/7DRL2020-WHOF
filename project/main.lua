require "map"
require "tile"
require "util"
require "font"
require "character"
require "camera"
require "letter"

function love.load()
	Map = innitiateMap()
	Camera = innitiateCamera(0, 0, 800, 600, 0.5, 0.5, 15, 15)
	
	CameraX = 0.5
	CameraY = 0.5
	
	innitiateCharacter(Map, 3, 3, innitiateLetter("@", {1, 0, 0, 1}))
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
end

function love.draw()
	drawMap(Map, Camera)
end