local tileProperties = {}
local tileCharacters = {}

tileProperties['ground'] = {walkable = true, blockVision = false}
tileCharacters['ground'] = {
{tile = ".", chance = 9},
{tile = ";", chance = 1},
{tile = ",", chance = 2}, 
{tile = "~", chance = 1},
{tile = "'", chance = 1}}

tileProperties['empty'] = {walkable = false, blockVision = true}
tileCharacters['empty'] = {
{tile = " ", chance = 1}}

function innitiateTile(x, y, kind)
	local tile = {x = x, y = y, kind = tileKind, properties = tileProperties[kind], letter = nil, character = nil}
	
	chosenChar = ""
	local totalChance = 0
	for i = 1, #tileCharacters[kind] do
		totalChance = totalChance + tileCharacters[kind][i].chance
	end
	local randChoice = math.random()*totalChance
	for i = 1, #tileCharacters[kind] do
		randChoice = randChoice - tileCharacters[kind][i].chance
		if randChoice < 0 then
			chosenChar = tileCharacters[kind][i].tile
			break
		end
	end
	
	tile.letter = innitiateLetter(chosenChar, {1, 1, 1, 1})
	
	return tile
end

function drawTiles(map, camera)
	local tilesWide = camera.tilesWide
	local tilesTall = camera.tilesTall
	
	local startX = roundFloat(camera.centerX) - math.ceil(camera.tilesWide/2)
	local startY = roundFloat(camera.centerY) - math.ceil(camera.tilesTall/2)
	
	for i = startX, startX + tilesWide do
		for j = startY, startY + tilesTall do
			local tile = getMapTile(map, i, j)
			if tile.properties.walkable then
				local letter = tile.letter
				if tile.character then
					letter = tile.character.letter
				end
				
				drawLetter(letter, i, j, camera)
			end
		end
	end
end