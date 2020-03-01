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
	local tile = {x = x, y = y, kind = tileKind, properties = tileProperties[kind], character = nil, colour = {1, 1, 1, 1}}
	
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
	
	tile.character = chosenChar
	
	
	return tile
end