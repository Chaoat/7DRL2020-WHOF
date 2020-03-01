require "map"
require "tile"
require "util"

function love.load()
	Map = innitiateMap()
	
	CameraX = 0.5
	CameraY = 0.5
end

function love.update(dt)
	local camSpeed = 10
	if love.keyboard.isDown("left") then
		CameraX = CameraX - camSpeed*dt
	end
	if love.keyboard.isDown("right") then
		CameraX = CameraX + camSpeed*dt
	end
	if love.keyboard.isDown("up") then
		CameraY = CameraY - camSpeed*dt
	end
	if love.keyboard.isDown("down") then
		CameraY = CameraY + camSpeed*dt
	end
end

function love.draw()
	drawMap(Map, 0, 0, 800, 600, CameraX, CameraY, 40, 40)
end