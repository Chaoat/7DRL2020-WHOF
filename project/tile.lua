local tileProperties = {}
local tileCharacters = {}

tileProperties['ground'] = {walkable = true, blockVision = false}
tileCharacters['ground'] = {
{tile = ".", chance = 9, colour1 = {173/255, 105/255, 0, 1}, colour2 = {137/255, 200/255, 0, 1}},
{tile = ";", chance = 1, colour1 = {173/255, 105/255, 0, 1}, colour2 = {142/255, 142/255, 142/255, 1}},
{tile = ",", chance = 2, colour1 = {137/255, 194/255, 0, 1}, colour2 = {74/255, 193/255, 0, 1}}, 
{tile = "~", chance = 1, colour1 = {86/255, 193/255, 60/255, 1}, colour2 = {36/255, 193/255, 42/255, 1}},
{tile = "'", chance = 1, colour1 = {137/255, 194/255, 0, 1}, colour2 = {74/255, 193/255, 0, 1}}}

tileProperties['empty'] = {walkable = false, blockVision = false}
tileCharacters['empty'] = {
{tile = " ", chance = 1}}

tileProperties['building'] = {walkable = false, blockVision = true}
tileCharacters['building'] = {
{tile = " ", chance = 1}}

tileProperties['tree'] = {walkable = false, blockVision = true}
tileCharacters['tree'] = {
{tile = " ", chance = 1}}

grassTiles = {
	{targetRegion = 0.125, tile = "~", colour = {100/255, 112/255, 55/255, 1}, windWave = 0},
	{targetRegion = 0.375, tile = ",", colour = {85/255, 102/255, 57/255, 1}, windWave = 0.05},
	{targetRegion = 0.625, tile = "'", colour = {54/255, 62/255, 14/255, 1}, windWave = 0.1},
	{targetRegion = 0.875, tile = "\"", colour = {68/255, 76/255, 35/255, 1}, windWave = 0.15},
}

function initiateTile(x, y, kind, letter)
	local tile = {x = x, y = y, kind = tileKind, properties = tileProperties[kind], letter = nil, particleInfluence = 0, partInfColour = {0, 0, 0, 0}, character = nil, waitingForCharacter = false, consumable = nil, foliage = nil, lances = {}}
	--tile.foliage = initiateFoliage("O", {0, 1, 0, 0.3}, 1)
	
	if letter == nil then
		local chosenChar = ""
		local windWave = nil
		local colour = {1, 1, 1, 1}
		local totalChance = 0
		for i = 1, #tileCharacters[kind] do
			totalChance = totalChance + tileCharacters[kind][i].chance
		end
		--local randChoice = math.random()*totalChance
		--for i = 1, #tileCharacters[kind] do
		--	randChoice = randChoice - tileCharacters[kind][i].chance
		--	if randChoice < 0 then
		--		chosenChar = tileCharacters[kind][i].tile
		--		windWave = tileCharacters[kind][i].windWave
		--		
		--		if tileCharacters[kind][i].colour1 then
		--			local c1 = tileCharacters[kind][i].colour1
		--			local c2 = tileCharacters[kind][i].colour2
		--			local spot = math.random()
		--			colour = {c1[1]*spot + c2[1]*(1 - spot), c1[2]*spot + c2[2]*(1 - spot), c1[3]*spot + c2[3]*(1 - spot), c1[4]*spot + c2[4]*(1 - spot)}
		--		end
		--		
		--		break
		--	end
		--end
		
		local grassNoisePoint = love.math.noise(0.15*x, 0.15*y) + randBetween(-0.2, 0.2)
		local chosenTile = grassTiles[1]
		for i = 2, #grassTiles do
			local newTile = grassTiles[i]
			if math.abs(newTile.targetRegion - grassNoisePoint) <= math.abs(chosenTile.targetRegion - grassNoisePoint) then
				chosenTile = newTile
			else
				break
			end
		end
		chosenChar = chosenTile.tile
		colour = chosenTile.colour
		windWave = chosenTile.windWave
		
		letter = initiateLetter(chosenChar, colour)
		if windWave then
			letter.windWave = windWave
		end
	end
	
	tile.letter = letter
	
	return tile
end

function checkTileWalkable(tile, character)
	if tile.properties.walkable then
		if tile.character == nil then
			if character then
				for i = 1, #tile.lances do
					local lance = tile.lances[i]
					
					if character.master.speed then
						if character.master.speed > 0 then
							return true
						end
					end
					
					if lance.character.side ~= character.side then
						return false
					end
				end
			end
			return true
		else
			return false
		end
	else
		return false
	end
end

function tileHasLance(tile)
	if #tile.lances > 0 then
		return tile.lances[1]
	end
	return false
end

function drawTiles(map, camera)
	local visibleCharacters = {}
	local visibleLances = {}
	local foliageTiles = {}
	
	local tilesWide = camera.tilesWide
	local tilesTall = camera.tilesTall
	
	local startX = roundFloat(camera.centerX) - math.ceil(camera.tilesWide/2)
	local startY = roundFloat(camera.centerY) - math.ceil(camera.tilesTall/2)
	
	for i = startX, startX + tilesWide do
		for j = startY, startY + tilesTall do
			local tile = getMapTile(map, i, j)
			local occupied = false
			if tile.character then
				table.insert(visibleCharacters, tile.character)
				--drawLetter(initiateLetter("#", {1, 1, 0, 1}), i, j, camera)
				drawBackdrop(tile.letter, i, j, camera)
				occupied = true
			end
			if tileHasLance(tile) then
				table.insert(visibleLances, tileHasLance(tile))
				drawBackdrop(tile.letter, i, j, camera)
				occupied = true
			end
			if not occupied then
				if tile.consumable then
					drawLetter(tile.consumable.letter, i, j, camera)
				else
					drawLetter(tile.letter, i, j, camera)
				end
			end		

			if tile.foliage then
				table.insert(foliageTiles, tile)
			end
			
			tile.letter.momentaryInfluence = 0
		end
	end
	
	return visibleCharacters, visibleLances, foliageTiles
end