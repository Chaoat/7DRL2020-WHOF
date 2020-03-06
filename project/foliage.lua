local windAngle = 0
local windBlowStrength = 0

function initWind()
	windAngle = 2*math.pi*math.random()
	windBlowStrength = 0
end

function initiateFoliage(character, colour, windFactor)
	local letter = initiateLetter(character, colour)
	letter.windWave = windFactor
	return letter
end

function updateWind(dt)
	windAngle = windAngle + randBetween(-dt, dt)
	windBlowStrength = windBlowStrength + randBetween(-dt, dt)
	windBlowStrength = math.max(0, windBlowStrength)
	windBlowStrength = math.min(1, windBlowStrength)
end

function getWindAtPoint(windStrength, x, y)
	--local strengthFunc = function()
	--	local mult = 0.05
	--	return love.math.noise(mult*x, mult*y)
	--end
	local strengthFunc = function()
		return 0.05*(x + y)
	end
	
	local noise = (GlobalTime + strengthFunc())
	noise = windBlowStrength*(math.cos(noise) + 1)/2
	return windStrength*noise*math.cos(windAngle), windStrength*noise*math.sin(windAngle)
end

function drawFoliage(foliageTiles, camera)
	for i = 1, #foliageTiles do
		local tile = foliageTiles[i]
		drawLetter(tile.foliage, tile.x, tile.y, camera)
	end
end